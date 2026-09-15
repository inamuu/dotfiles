#!/usr/bin/env python3
"""searchdata: Acta デイリーノート / Google Drive Docs の記録を検索・表示する。

使い方:
  search.py [-k KEYWORD ...] [--limit N] [--days N] [--include-todo]
  search.py --show N [N ...]        # 直前の検索結果の番号で本文を表示

検索単位は acta:comment ブロック（ブロックが無いファイルはファイル全体）。
tags に ToDo 系（/todo/i）を含むブロックは既定で除外する。
"""
import argparse
import json
import os
import re
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

HOME = Path.home()
SOURCES = {
    "Acta": HOME / "ghq/github.com/inamuu/data/Acta/posts",
    "Docs": HOME / "Google Drive/マイドライブ/Docs",
}
INDEX = HOME / ".cache/searchdata/index.json"
TODO_TAG = re.compile(r"todo", re.I)
TODO_HEAD = re.compile(r"^#{1,3}\s*ToDo\b", re.I | re.M)
BLOCK = re.compile(r"<!-- acta:comment\n(.*?)-->\n(.*?)<!-- /acta:comment -->", re.S)
HEADING = re.compile(r"^#{1,3}\s+(.+)$", re.M)


def date_from_name(name):
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})", name) or re.match(r"(\d{4})(\d{2})(\d{2})_", name)
    if m:
        try:
            return date(int(m[1]), int(m[2]), int(m[3]))
        except ValueError:
            return None
    return None


def title_of(text, fallback):
    m = HEADING.search(text)
    return m[1].strip() if m else fallback


def units_of(path, source):
    text = path.read_text(encoding="utf-8", errors="replace")
    fdate = date_from_name(path.name) or date.fromtimestamp(path.stat().st_mtime)
    blocks = list(BLOCK.finditer(text))
    if not blocks:
        yield dict(source=source, file=str(path), id=None, date=fdate.isoformat(),
                   tags="", title=title_of(text, path.stem), body=text)
        return
    for m in blocks:
        meta, body = m[1], m[2]
        tags = (re.search(r"^tags:\s*(.*)$", meta, re.M) or [None, ""])[1].strip()
        bid = (re.search(r"^id:\s*(\S+)", meta, re.M) or [None, None])[1]
        created = (re.search(r"^created:\s*(\d{4}-\d{2}-\d{2})", meta, re.M) or [None, None])[1]
        yield dict(source=source, file=str(path), id=bid, date=created or fdate.isoformat(),
                   tags=tags, title=title_of(body, path.stem), body=body)


def is_todo(u):
    return bool(TODO_TAG.search(u["tags"])) or bool(TODO_HEAD.search(u["body"][:200]))


def collect(days):
    cutoff = (date.today() - timedelta(days=days)).isoformat()
    for source, root in SOURCES.items():
        if not root.exists():
            print(f"WARN: {source} のディレクトリが見つかりません: {root}", file=sys.stderr)
            continue
        for p in root.rglob("*.md"):
            for u in units_of(p, source):
                if u["date"] >= cutoff:
                    yield u


def search(args):
    units = list(collect(args.days))
    if not args.include_todo:
        units = [u for u in units if not is_todo(u)]
    if args.keyword:
        pats = [re.compile(k, re.I) for k in args.keyword]
        units = [u for u in units if any(p.search(u["title"]) or p.search(u["body"]) for p in pats)]
    units.sort(key=lambda u: u["date"], reverse=True)
    total = len(units)
    units = units[: args.limit]
    INDEX.parent.mkdir(parents=True, exist_ok=True)
    INDEX.write_text(json.dumps(units, ensure_ascii=False), encoding="utf-8")
    if not units:
        print("該当する記録はありません")
        return
    for i, u in enumerate(units, 1):
        tags = f"  ({u['tags']})" if u["tags"] else ""
        print(f"{i}. {u['date']}  [{u['source']}]  {u['title']}{tags}")
    if total > len(units):
        print(f"... 他 {total - len(units)} 件（--limit で増やすかキーワードで絞り込む）")
    if not any(u["source"] == "Docs" for u in units):
        print("(Docs 側にヒットなし)")


def show(args):
    if not INDEX.exists():
        sys.exit("検索結果がありません。先に検索を実行してください")
    units = json.loads(INDEX.read_text(encoding="utf-8"))
    for n in args.show:
        if not 1 <= n <= len(units):
            print(f"番号 {n} は範囲外です", file=sys.stderr)
            continue
        u = units[n - 1]
        print(f"===== {n}. {u['date']}  [{u['source']}]  {u['title']}")
        print(f"file: {u['file']}" + (f"  id: {u['id']}" if u["id"] else ""))
        print(u["body"].rstrip())
        print()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-k", "--keyword", action="append", help="検索キーワード（正規表現、大文字小文字無視、複数指定は OR）")
    ap.add_argument("--limit", type=int, default=20)
    ap.add_argument("--days", type=int, default=365)
    ap.add_argument("--include-todo", action="store_true", help="ToDo 系タグのブロックも含める")
    ap.add_argument("--show", type=int, nargs="+", help="直前の検索結果の番号を表示")
    args = ap.parse_args()
    show(args) if args.show else search(args)


if __name__ == "__main__":
    main()
