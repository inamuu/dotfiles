#!/usr/bin/env python3
"""tmux の display-panes 相当 (枠線ラベル方式)。
現在のタブの各ペインのラベルを一時的に「1」「2」… に書き換えて枠線上に
番号を表示し、中央の小さなポップアップで数字キーを受け取ってフォーカス移動する。
終了時にラベルを元に戻す。q / Esc / その他のキーでキャンセル。
"""
import json
import os
import shutil
import socket
import sys
import termios
import tty

SOCK = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
ACTIVE = os.environ.get("HERDR_ACTIVE_PANE_ID")

RESET = "\x1b[0m"
DIM = "\x1b[38;5;244m"
ACTIVE_FG = "\x1b[1;38;5;203m"
OTHER_FG = "\x1b[1;38;5;75m"
# ラベル開始位置(枠線左端からのオフセット)の見込み。番号が中央からずれる場合はここを調整
LABEL_OFFSET = 3


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
        raise RuntimeError(resp["error"])
    return resp["result"]


def read_key():
    return os.read(sys.stdin.fileno(), 1).decode(errors="replace")


def main():
    layout = request("pane.layout", {"pane_id": ACTIVE})["layout"]
    panes = layout["panes"]
    if len(panes) <= 1:
        return 0
    panes = sorted(panes, key=lambda p: (p["rect"]["y"], p["rect"]["x"]))[:9]

    # 元のラベルを保存
    original = {}
    for p in request("pane.list", {"workspace_id": layout["workspace_id"]})["panes"]:
        original[p["pane_id"]] = p.get("label")

    # 枠線に番号を表示。herdr はラベルを枠線の左寄りに描くので、
    # 枠線と同じ罫線文字で左側を埋めて番号がペイン幅の中央付近に来るようにする。
    # (先頭・末尾の空白は herdr 側で削られるが、罫線文字は保持される)
    numbered = []
    for i, p in enumerate(panes, start=1):
        pid = p["pane_id"]
        width = p["rect"]["width"]
        pad = max(0, width // 2 - LABEL_OFFSET)
        label = "─" * pad + f" {i} "
        request("pane.rename", {"pane_id": pid, "label": label})
        numbered.append(pid)

    try:
        cols, rows = shutil.get_terminal_size((30, 5))
        lines = []
        for i, p in enumerate(panes, start=1):
            color = ACTIVE_FG if p["pane_id"] == ACTIVE else OTHER_FG
            mark = "*" if p["pane_id"] == ACTIVE else " "
            lines.append(f"{color}{i}{RESET}{mark}")
        msg = " ".join(lines)
        out = ["\x1b[?25l\x1b[2J"]
        out.append(f"\x1b[{max(1, rows // 2)};1H" + " " + msg)
        out.append(f"\x1b[{max(1, rows // 2 + 1)};1H{DIM} 数字で移動 / q で戻る{RESET}")
        sys.stdout.write("".join(out))
        sys.stdout.flush()
        key = read_key()
    finally:
        # ラベルを復元
        for pid in numbered:
            try:
                request("pane.rename", {"pane_id": pid, "label": original.get(pid)})
            except Exception:
                pass
        sys.stdout.write("\x1b[?25h\x1b[2J\x1b[H")
        sys.stdout.flush()

    if key.isdigit() and 1 <= int(key) <= len(panes):
        target = panes[int(key) - 1]["pane_id"]
        if target != ACTIVE:
            request("pane.focus", {"pane_id": target})
    return 0


if __name__ == "__main__":
    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    tty.setraw(fd)
    try:
        code = main()
    except Exception as e:
        sys.stdout.write(f"\x1b[?25h\x1b[2J\x1b[Hdisplay-panes error: {e}\r\n")
        sys.stdout.flush()
        read_key()
        code = 1
    finally:
        termios.tcsetattr(fd, termios.TCSANOW, saved)
    sys.exit(code)
