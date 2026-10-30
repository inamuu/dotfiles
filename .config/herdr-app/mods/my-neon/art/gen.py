#!/usr/bin/env python3
# Neon レイアウトのドット絵アイコンを SVG で書き出す。すべてオリジナル。単色 (mod 側で色を付ける)。
#   python3 mods/my-neon/art/gen.py
# 出力先: このスクリプトの一つ上の icons/

import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "icons")
SIZE = 12  # 12x12 に満たないものは上下左右の中央に置く

G = {
    # ロゴ: 目
    "eye": [
        "....XXXXXXXX....",
        "..XX........XX..",
        ".X....XXXX....X.",
        "X....XX..XX....X",
        "X....XX.XXX....X",
        ".X....XXXX....X.",
        "..XX........XX..",
        "....XXXXXXXX....",
    ],
    # space: 六角形のノード
    "hex": [
        "....XXXX....",
        "..XX....XX..",
        "XX........XX",
        "X...XXXX...X",
        "X..X....X..X",
        "X..X....X..X",
        "X...XXXX...X",
        "XX........XX",
        "..XX....XX..",
        "....XXXX....",
    ],
    # エージェント: チップ
    "chip": [
        "..X.X.X.X...",
        ".XXXXXXXXX..",
        "XX.......XX.",
        ".X.XXXXX.X..",
        "XX.X...X.XX.",
        ".X.X...X.X..",
        "XX.XXXXX.XX.",
        ".X.......X..",
        ".XXXXXXXXX..",
        "..X.X.X.X...",
    ],
    # working: 信号のバー (2 コマ)
    "sync-0": [
        "............",
        ".........XX.",
        ".........XX.",
        "......XX.XX.",
        "......XX.XX.",
        "...XX.XX.XX.",
        "...XX.XX.XX.",
        "XX.XX.XX.XX.",
        "XX.XX.XX.XX.",
    ],
    "sync-1": [
        "............",
        "............",
        "............",
        "......XX....",
        "......XX....",
        "...XX.XX....",
        "...XX.XX....",
        "XX.XX.XX.XX.",
        "XX.XX.XX.XX.",
    ],
    # blocked: 警告の三角
    "warn": [
        ".....XX.....",
        "....XXXX....",
        "....X..X....",
        "...XX..XX...",
        "...X.XX.X...",
        "..XX.XX.XX..",
        "..X..XX..X..",
        ".XX......XX.",
        ".X...XX...X.",
        "XXXXXXXXXXXX",
    ],
    # 見出しの札の右端の斜め
    "slant": [
        "XXXXXX......",
        "XXXXXX......",
        "XXXXXXX.....",
        "XXXXXXX.....",
        "XXXXXXXX....",
        "XXXXXXXX....",
        "XXXXXXXXX...",
        "XXXXXXXXX...",
        "XXXXXXXXXX..",
        "XXXXXXXXXX..",
        "XXXXXXXXXXX.",
        "XXXXXXXXXXX.",
    ],
    # idle: 四角い点
    "dot": [
        "XXXX",
        "X..X",
        "X..X",
        "XXXX",
    ],
    "branch": [
        "..XX....XX..",
        ".X..X..X..X.",
        ".X..X..X..X.",
        "..XX....XX..",
        "..X......X..",
        "..X.....X...",
        "..X..XXX....",
        "..XXX.......",
        "..XX........",
        ".X..X.......",
        ".X..X.......",
        "..XX........",
    ],
    "check": [
        "..........XX",
        ".........XXX",
        "........XXX.",
        "XX.....XXX..",
        "XXX...XXX...",
        ".XXX.XXX....",
        "..XXXXX.....",
        "...XXX......",
        "....X.......",
    ],
    "terminal": [
        "XXXXXXXXXXXX",
        "X..........X",
        "X.X........X",
        "X..X.......X",
        "X...X......X",
        "X..X.......X",
        "X.X..XXXX..X",
        "X..........X",
        "XXXXXXXXXXXX",
    ],
    "server": [
        "XXXXXXXXXXXX",
        "X..........X",
        "X.XX.....X.X",
        "X..........X",
        "XXXXXXXXXXXX",
        "X..........X",
        "X.XX.....X.X",
        "X..........X",
        "XXXXXXXXXXXX",
    ],
    "doc": [
        "XXXXXXX...",
        "X.....XX..",
        "X.....X.X.",
        "X.....XXXX",
        "X........X",
        "X.XXXXXX.X",
        "X........X",
        "X.XXXXXX.X",
        "X........X",
        "X.XXXX...X",
        "X........X",
        "XXXXXXXXXX",
    ],
    "diff": [
        "XXXXXXXXXXXX",
        "X..........X",
        "X....X.....X",
        "X...XXX....X",
        "X....X.....X",
        "X..........X",
        "X...XXX....X",
        "X..........X",
        "XXXXXXXXXXXX",
    ],
    "sidebar": [
        "XXXXXXXXXXXX",
        "X...X......X",
        "X.X.X......X",
        "X...X......X",
        "X.X.X......X",
        "X...X......X",
        "X.X.X......X",
        "X...X......X",
        "XXXXXXXXXXXX",
    ],
    "plus": [
        "....XX....",
        "....XX....",
        "....XX....",
        "XXXXXXXXXX",
        "XXXXXXXXXX",
        "....XX....",
        "....XX....",
        "....XX....",
    ],
    "close": [
        "XX....XX",
        "XXX..XXX",
        ".XXXXXX.",
        "..XXXX..",
        "..XXXX..",
        ".XXXXXX.",
        "XXX..XXX",
        "XX....XX",
    ],
    "split-right": [
        "XXXXXXXXXX",
        "X...X....X",
        "X...X....X",
        "X...X....X",
        "X...X....X",
        "X...X....X",
        "X...X....X",
        "XXXXXXXXXX",
    ],
    "split-down": [
        "XXXXXXXXXX",
        "X........X",
        "X........X",
        "XXXXXXXXXX",
        "X........X",
        "X........X",
        "X........X",
        "XXXXXXXXXX",
    ],
    "zoom": [
        "XXX....XXX",
        "XX......XX",
        "X.X....X.X",
        "..........",
        "..........",
        "X.X....X.X",
        "XX......XX",
        "XXX....XXX",
    ],
    "unzoom": [
        "X.X....X.X",
        ".XX....XX.",
        "XXX....XXX",
        "..........",
        "..........",
        "XXX....XXX",
        ".XX....XX.",
        "X.X....X.X",
    ],
}

def write(rows, name):
    w = len(rows[0])
    for y, r in enumerate(rows):
        if len(r) != w:
            raise SystemExit(f"{name}: row {y} is {len(r)} wide, expected {w}")
    W, H = max(SIZE, w), max(SIZE, len(rows))
    ox, oy = (W - w) // 2, (H - len(rows)) // 2
    rects = []
    for y, row in enumerate(rows):
        x = 0
        while x < w:
            if row[x] != "X":
                x += 1
                continue
            n = 1
            while x + n < w and row[x + n] == "X":
                n += 1
            rects.append(f'<rect x="{x + ox}" y="{y + oy}" width="{n}" height="1"/>')
            x += n
    with open(os.path.join(OUT, f"{name}.svg"), "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
                f'shape-rendering="crispEdges" fill="currentColor">{"".join(rects)}</svg>\n')


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, rows in G.items():
        write(rows, name)


if __name__ == "__main__":
    main()
