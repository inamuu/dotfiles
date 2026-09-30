#!/usr/bin/env python3
"""tmux の display-panes 相当の herdr プラグイン。

open:  キーバインドから呼ばれる action。現在のタブのレイアウトと各ペインの
       表示内容を保存し、picker を overlay で開く
pick:  overlay 内で動く本体。保存した各ペインの表示内容を同じ位置に描き直し、
       その上に大きな番号をブロック文字で重ねる。数字キー 1 つで
       該当ペインへ移動し、数字以外のキーでキャンセル
focus: overlay が閉じるのを待ってから対象ペインへフォーカスを移す

popup はキー入力を受け取れるが枠が必ず出るため、枠のない overlay を使っている。
見た目は同じディレクトリの config.json で調整する。
"""
import concurrent.futures
import json
import os
import re
import signal
import socket
import subprocess
import sys
import tempfile
import termios
import time
import tty
import unicodedata

ROOT = os.path.dirname(os.path.abspath(__file__))
SOCK = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
PLUGIN_ID = os.environ.get("HERDR_PLUGIN_ID", "inamuu.display-panes")
STATE_DIR = os.environ.get("HERDR_PLUGIN_STATE_DIR") or tempfile.gettempdir()
SNAPSHOT = os.path.join(STATE_DIR, "display-panes-snapshot.json")

DEFAULTS = {
    "scale": 0.6,  # ペインの高さに対する数字の高さの割合
    "max_rows": 30,  # 数字の高さの上限 (セル数)
    "active_color": "#ff79c6",
    "other_color": "#bd93f9",
    "background": "#282a36",
    "background_box": True,  # false にすると数字の周りの背景を塗らない
    "active_border": "#bd93f9",
    "other_border": "#6272a4",
}

# 5x7 のビットマップフォント
FONT = {
    "1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
    "2": ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
    "3": ["11111", "00010", "00100", "00010", "00001", "10001", "01110"],
    "4": ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
    "5": ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
    "6": ["00110", "01000", "10000", "11110", "10001", "10001", "01110"],
    "7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
    "8": ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
    "9": ["01110", "10001", "10001", "01111", "00001", "00010", "01100"],
}
GLYPH_W, GLYPH_H, PAD = 5, 7, 1
UNITS_W, UNITS_H = GLYPH_W + PAD * 2, GLYPH_H + PAD * 2


def load_config():
    conf = dict(DEFAULTS)
    try:
        with open(os.path.join(ROOT, "config.json")) as f:
            conf.update(json.load(f))
    except (OSError, ValueError):
        pass
    return conf


def request(method, params):
    s = socket.socket(socket.AF_UNIX)
    s.settimeout(3)
    s.connect(SOCK)
    s.sendall((json.dumps({"id": "dp", "method": method, "params": params}) + "\n").encode())
    buf = b""
    while not buf.endswith(b"\n"):
        chunk = s.recv(65536)
        if not chunk:
            break
        buf += chunk
    s.close()
    resp = json.loads(buf.decode())
    if "error" in resp:
        raise RuntimeError(f"{method}: {resp['error']}")
    return resp["result"]


def parallel(fn, items):
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, len(items))) as ex:
        return list(ex.map(fn, items))


def hex_rgb(value):
    value = value.lstrip("#")
    return bytes(int(value[i:i + 2], 16) for i in (0, 2, 4))


def sgr_fg(value):
    r, g, b = hex_rgb(value)
    return f"\x1b[38;2;{r};{g};{b}m"


def sgr_bg(value):
    r, g, b = hex_rgb(value)
    return f"\x1b[48;2;{r};{g};{b}m"


# ---- open ----------------------------------------------------------------

def open_picker():
    params = {"pane_id": os.environ["HERDR_PANE_ID"]} if os.environ.get("HERDR_PANE_ID") else {}
    layout = request("pane.layout", params)["layout"]
    if layout.get("zoomed") or len(layout["panes"]) <= 1:
        return 0
    panes = sorted(layout["panes"], key=lambda p: (p["rect"]["y"], p["rect"]["x"]))[:9]

    def read(p):
        try:
            r = request("pane.read", {"pane_id": p["pane_id"], "source": "visible",
                                      "format": "ansi", "strip_ansi": False})
            return r["read"]["text"]
        except Exception:
            return ""

    texts = parallel(read, panes)
    snapshot = {
        "active": layout["focused_pane_id"],
        "area": layout["area"],
        "panes": [dict(p, text=t) for p, t in zip(panes, texts)],
    }
    os.makedirs(STATE_DIR, exist_ok=True)
    with open(SNAPSHOT, "w") as f:
        json.dump(snapshot, f)

    result = request("plugin.pane.open", {
        "plugin_id": PLUGIN_ID,
        "entrypoint": "picker",
        "placement": "overlay",
        "focus": True,
    })
    # picker の起動を待たずに端末サイズを更新させ、描き始めを早める (pick 側でも呼ぶ)
    pane_id = find_pane_id(result)
    if pane_id:
        try:
            request("pane.zoom", {"pane_id": pane_id, "mode": "on"})
        except Exception:
            pass
    return 0


def find_pane_id(value):
    if isinstance(value, dict):
        if isinstance(value.get("pane"), dict) and value["pane"].get("pane_id"):
            return value["pane"]["pane_id"]
        for v in value.values():
            found = find_pane_id(v)
            if found:
                return found
    return None


# ---- pick ----------------------------------------------------------------

def fit_rects(snap, cols, rows):
    """元のレイアウトを picker の実サイズに合わせて縮める (枠やスクロールバーの分)。"""
    area = snap["area"]
    sx = cols / area["width"]
    sy = rows / area["height"]
    fitted = []
    for p in snap["panes"]:
        r = p["rect"]
        x0 = round((r["x"] - area["x"]) * sx)
        y0 = round((r["y"] - area["y"]) * sy)
        x1 = round((r["x"] - area["x"] + r["width"]) * sx)
        y1 = round((r["y"] - area["y"] + r["height"]) * sy)
        fitted.append((x0, y0, x1 - x0, y1 - y0))
    return fitted


ANSI_RE = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")


def truncate_ansi(line, width):
    """エスケープシーケンスを残したまま、表示幅 width に切り詰める。"""
    out, used, i = [], 0, 0
    while i < len(line):
        m = ANSI_RE.match(line, i)
        if m:
            out.append(m.group())
            i = m.end()
            continue
        ch = line[i]
        cw = 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
        if used + cw > width:
            break
        out.append(ch)
        used += cw
        i += 1
    return "".join(out)


def draw_screen(snap, conf, rects, cell_ratio):
    """各ペインの枠と表示内容を元の位置に描き直し、中央に番号を重ねる。"""
    # 同期出力 (?2026) で囲み、描きかけの状態が見えないようにする
    out = ["\x1b[?2026h\x1b[?25l\x1b[0m\x1b[2J"]
    for p, (x, y, w, h) in zip(snap["panes"], rects):
        if w < 3 or h < 3:
            continue
        color = sgr_fg(conf["active_border"] if p["pane_id"] == snap["active"] else conf["other_border"])
        out.append(f"\x1b[{y + 1};{x + 1}H{color}╭{'─' * (w - 2)}╮")
        out.append(f"\x1b[{y + h};{x + 1}H╰{'─' * (w - 2)}╯")
        for yy in range(y + 1, y + h - 1):
            out.append(f"\x1b[{yy + 1};{x + 1}H│\x1b[{yy + 1};{x + w}H│")
        out.append("\x1b[0m")
        lines = p.get("text", "").split("\r\n")
        for i, line in enumerate(lines[: h - 2]):
            out.append(f"\x1b[{y + 2 + i};{x + 2}H\x1b[0m{truncate_ansi(line, w - 2)}\x1b[0m")
    # 画像だと枠や内容より遅れて出るので、数字も同じ出力に文字で含める
    for i, (p, rect) in enumerate(zip(snap["panes"], rects), start=1):
        color = conf["active_color"] if p["pane_id"] == snap["active"] else conf["other_color"]
        out.append(digit_text(str(i), rect, color, conf, cell_ratio))
    out.append("\x1b[?2026l")
    sys.stdout.write("".join(out))
    sys.stdout.flush()


def digit_text(digit, rect, color, conf, cell_ratio):
    """数字をブロック文字で rect の中央に描くエスケープシーケンスを返す。"""
    x, y, pw, ph = rect
    target = min(int(ph * float(conf["scale"])), int(conf["max_rows"]))
    unit_h = max(1, target // UNITS_H)
    # セルは縦長なので、横方向は縦の cell_ratio 倍のセルで 1 ドットにする
    while True:
        unit_w = max(1, round(unit_h * cell_ratio))
        if unit_h == 1 or UNITS_W * unit_w <= pw - 2:
            break
        unit_h -= 1
    width, height = UNITS_W * unit_w, UNITS_H * unit_h
    left = x + max(0, (pw - width) // 2)
    top = y + max(0, (ph - height) // 2)

    fg = sgr_fg(color)
    bg = sgr_bg(conf["background"]) if conf["background_box"] else None
    out = []
    for uy in range(UNITS_H):
        gy = uy - PAD
        line = []
        for ux in range(UNITS_W):
            gx = ux - PAD
            if 0 <= gy < GLYPH_H and 0 <= gx < GLYPH_W and FONT[digit][gy][gx] == "1":
                line.append(fg + "█" * unit_w)
            elif bg:
                line.append(bg + " " * unit_w + "\x1b[49m")
            else:
                line.append(f"\x1b[{unit_w}C")
        line = "".join(line) + "\x1b[0m"
        for sub in range(unit_h):
            out.append(f"\x1b[{top + uy * unit_h + sub + 1};{left + 1}H{line}")
    return "".join(out)


def terminal_size():
    # shutil.get_terminal_size は環境変数 COLUMNS/LINES を優先して古い値を返すので使わない
    size = os.get_terminal_size(sys.stdout.fileno())
    return size.columns, size.lines


def read_key():
    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    tty.setraw(fd)
    try:
        return os.read(fd, 1).decode(errors="replace")
    finally:
        termios.tcsetattr(fd, termios.TCSANOW, saved)


def pick():
    conf = load_config()
    own = os.environ["HERDR_PANE_ID"]
    with open(SNAPSHOT) as f:
        snap = json.load(f)
    panes = snap["panes"]

    # plugin pane は推定サイズで起動し、そのままだと全体サイズに広がらないことがある。
    # pane.zoom を呼ぶと端末サイズが更新されるので、呼んだうえで
    # サイズが変わった瞬間まで待ってから描く
    initial = terminal_size()
    try:
        info = request("pane.graphics.info", {"pane_id": own})
        cell_ratio = (info.get("cell_height_px") or 20) / (info.get("cell_width_px") or 10)
    except Exception:
        cell_ratio = 2.0
    try:
        request("pane.zoom", {"pane_id": own, "mode": "on"})
    except Exception:
        pass
    deadline = time.time() + 0.5
    area = snap["area"]

    def expanded():
        # 枠やスクロールバーの分だけ全体より少し小さくなる
        cols, rows = terminal_size()
        return (cols, rows) != initial or (cols >= area["width"] - 4 and rows >= area["height"] - 4)

    while time.time() < deadline and not expanded():
        time.sleep(0.005)

    def redraw(*_):
        draw_screen(snap, conf, fit_rects(snap, *terminal_size()), cell_ratio)

    signal.signal(signal.SIGWINCH, redraw)
    redraw()
    key = read_key()

    if key.isdigit() and 1 <= int(key) <= len(panes):
        target = panes[int(key) - 1]["pane_id"]
        if target != snap["active"]:
            # overlay は閉じるときに元のフォーカスへ戻すので、閉じた後に移動させる
            subprocess.Popen([sys.executable, os.path.abspath(__file__), "focus", target, own],
                             start_new_session=True, stdin=subprocess.DEVNULL,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return 0


# ---- focus ---------------------------------------------------------------

def focus_after_close(target, overlay):
    deadline = time.time() + 3
    while time.time() < deadline:
        try:
            request("pane.get", {"pane_id": overlay})
        except Exception:
            break
        time.sleep(0.02)
    request("pane.focus", {"pane_id": target})
    return 0


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "pick"
    try:
        if mode == "open":
            code = open_picker()
        elif mode == "focus":
            code = focus_after_close(sys.argv[2], sys.argv[3])
        else:
            code = pick()
    except Exception as e:
        print(f"display-panes error: {e}", file=sys.stderr)
        code = 1
    sys.exit(code)
