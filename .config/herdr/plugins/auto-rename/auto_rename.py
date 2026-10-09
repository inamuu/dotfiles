#!/usr/bin/env python3
"""workspace 名を作業内容から自動で付け直す herdr プラグイン。

event:  pane.agent_status_changed で呼ばれる。done / idle になった workspace を
        バックグラウンドで判定する
action: キーバインドなどから呼ぶ。今の workspace を強制的に付け直す
run:    実処理。ペインの cwd・ブランチ・ターミナルタイトル・直近の出力を集めて
        ollama にラベルを作らせ、workspace.rename する

手動で付けた名前は上書きしない。今の名前が「前回このプラグインが付けた名前」か
「ペインの cwd / リポジトリのディレクトリ名 (herdr の初期名)」のときだけ変える。
設定は同じディレクトリの config.json。
"""
import fcntl
import hashlib
import json
import os
import re
import socket
import subprocess
import sys
import tempfile
import time
import urllib.request

ROOT = os.path.dirname(os.path.abspath(__file__))
SOCK = os.environ.get("HERDR_SOCKET_PATH") or os.path.expanduser("~/.config/herdr/herdr.sock")
STATE_DIR = os.environ.get("HERDR_PLUGIN_STATE_DIR") or tempfile.gettempdir()
STATE = os.path.join(STATE_DIR, "auto-rename-state.json")
LOG = os.path.join(STATE_DIR, "auto-rename.log")

DEFAULTS = {
    "model": "gemma4:12b",
    "ollama_url": "http://localhost:11434/api/generate",
    "keep_alive": "30m",
    "min_interval": 60,  # 同じ workspace を判定する最短間隔 (秒)
    "output_lines": 40,  # エージェントのペインから読む直近の行数
}
TRIGGER_STATUSES = {"done", "idle"}

PROMPT = """You name terminal workspaces. Read the context and output ONE label.
Rules:
- 2 to 4 words, lowercase English, joined by hyphens, max 30 chars
- Describe WHAT is being worked on (e.g. sendgrid-rate-limit, opensearch-upgrade)
- Never include issue/PR numbers or any digits-only words
- The repository name may be shortened or omitted
- Output the label only, no explanation

Context:
{context}"""


def load_config():
    conf = dict(DEFAULTS)
    try:
        with open(os.path.join(ROOT, "config.json")) as f:
            conf.update(json.load(f))
    except (OSError, ValueError):
        pass
    return conf


def log(msg):
    with open(LOG, "a") as f:
        f.write(time.strftime("%Y-%m-%d %H:%M:%S ") + msg + "\n")


def request(method, params):
    s = socket.socket(socket.AF_UNIX)
    s.settimeout(5)
    s.connect(SOCK)
    s.sendall((json.dumps({"id": "ar", "method": method, "params": params}) + "\n").encode())
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


def load_state():
    try:
        with open(STATE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def save_state(state):
    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
    os.replace(tmp, STATE)


def git_info(cwd):
    def git(*args):
        try:
            out = subprocess.run(["git", "-C", cwd, *args], capture_output=True, text=True, timeout=3)
            return out.stdout.strip() if out.returncode == 0 else ""
        except (OSError, subprocess.SubprocessError):
            return ""
    top = git("rev-parse", "--show-toplevel")
    return (os.path.basename(top) if top else ""), git("branch", "--show-current")


def collect(ws_id, output_lines):
    panes = request("pane.list", {"workspace_id": ws_id})["panes"]
    lines, initial_names, key_parts = [], set(), []
    for p in panes:
        cwd = p.get("foreground_cwd") or p.get("cwd") or ""
        repo, branch = git_info(cwd) if cwd else ("", "")
        title = p.get("terminal_title_stripped") or ""
        if cwd:
            initial_names.add(os.path.basename(cwd.rstrip("/")))
        if repo:
            initial_names.add(repo)
        lines.append(f"- pane: cwd={cwd} repo={repo} branch={branch} title={title} agent={p.get('agent') or '-'}")
        key_parts.append(f"{cwd}|{branch}|{title}")
        if p.get("agent") and output_lines:
            try:
                text = request("pane.read", {"pane_id": p["pane_id"], "source": "recent_unwrapped",
                                             "lines": output_lines})["read"]["text"]
                lines.append("  recent output:\n" + "\n".join("    " + l for l in text.splitlines() if l.strip()))
            except (OSError, RuntimeError, KeyError, ValueError):
                pass
    # 出力はたえず変わるので、変化の判定には cwd・ブランチ・タイトルだけを使う
    key = hashlib.sha1("\n".join(sorted(key_parts)).encode()).hexdigest()
    return "\n".join(lines), initial_names, key


def ask_ollama(conf, context):
    body = json.dumps({
        "model": conf["model"],
        "prompt": PROMPT.format(context=context),
        "stream": False,
        "think": False,
        "keep_alive": conf["keep_alive"],
        "options": {"temperature": 0},
    }).encode()
    req = urllib.request.Request(conf["ollama_url"], data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=120) as r:
        text = json.load(r).get("response", "")
    return normalize(text)


def normalize(text):
    text = text.strip().splitlines()[0] if text.strip() else ""
    text = re.sub(r"[^a-z0-9-]+", "-", text.lower())
    words = [w for w in text.split("-") if w and not w.isdigit()]
    # 単語の途中で切れないよう、30 文字に収まるまで末尾の単語を落とす
    while len(words) > 1 and len("-".join(words)) > 30:
        words.pop()
    return "-".join(words)[:30]


def run(ws_id, force):
    conf = load_config()
    lock = open(os.path.join(STATE_DIR, f"auto-rename-{ws_id}.lock"), "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        return 0  # 同じ workspace を判定中

    ws = request("workspace.get", {"workspace_id": ws_id})["workspace"]
    current = ws.get("label", "")
    state = load_state()
    entry = state.get(ws_id, {})

    context, initial_names, key = collect(ws_id, conf["output_lines"])
    if not force:
        if current != entry.get("label") and current not in initial_names:
            return 0  # 手動で付けた名前
        if key == entry.get("key"):
            return 0  # 前回から変化なし
        if time.time() - entry.get("at", 0) < conf["min_interval"]:
            return 0

    label = ask_ollama(conf, context)
    state[ws_id] = {"label": label or current, "key": key, "at": time.time()}
    save_state(state)
    if label and label != current:
        request("workspace.rename", {"workspace_id": ws_id, "label": label})
        log(f"{ws_id}: {current} -> {label}")
    return 0


def find_key(obj, name):
    if isinstance(obj, dict):
        if name in obj:
            return obj[name]
        obj = list(obj.values())
    if isinstance(obj, list):
        for v in obj:
            found = find_key(v, name)
            if found is not None:
                return found
    return None


def spawn(ws_id, force):
    # イベントフックを待たせないよう、判定は切り離したプロセスで行う
    args = [sys.executable, os.path.abspath(__file__), "run", ws_id] + (["--force"] if force else [])
    subprocess.Popen(args, start_new_session=True, stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=open(LOG, "a"))


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode == "event":
        try:
            payload = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
        except ValueError:
            return 0
        ws_id = find_key(payload, "workspace_id")
        if ws_id and find_key(payload, "agent_status") in TRIGGER_STATUSES:
            spawn(ws_id, force=False)
        return 0
    if mode == "action":
        ws_id = os.environ.get("HERDR_WORKSPACE_ID")
        if not ws_id and os.environ.get("HERDR_PANE_ID"):
            ws_id = os.environ["HERDR_PANE_ID"].split(":")[0]
        if not ws_id:
            ws_id = next(w["workspace_id"] for w in request("workspace.list", {})["workspaces"] if w.get("focused"))
        spawn(ws_id, force=True)
        return 0
    if mode == "run":
        try:
            return run(sys.argv[2], "--force" in sys.argv[3:])
        except Exception as e:  # noqa: BLE001 バックグラウンドなのでログに残して終わる
            log(f"{sys.argv[2]}: error: {e!r}")
            return 1
    print("usage: auto_rename.py event|action|run <workspace_id> [--force]", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
