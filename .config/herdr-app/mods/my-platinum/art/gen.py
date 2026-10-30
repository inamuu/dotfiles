#!/usr/bin/env python3
# Platinum レイアウトのドット絵アイコンを SVG で書き出す。すべてオリジナル。単色 (mod 側で色を付ける)。
#   python3 mods/my-platinum/art/gen.py
# 出力先: このスクリプトの一つ上の icons/

import os

ICONS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")
SIZE = 12  # 12x12 に満たないものは上下左右の中央に置く

G = {
    # ロゴ: 羊 (herd)
    "sheep": [
        "...XXXXX....",
        "..XXXXXXXX..",
        ".XXXXXXXXXXX",
        "XXXXXXXXX..X",
        "XXXXXXXXX.X.",
        "XXXXXXXXXXX.",
        ".XXXXXXXXX..",
        "..X.X..X.X..",
        "..X.X..X.X..",
    ],
    "folder": [
        ".XXXX.......",
        "X....X......",
        "XXXXXXXXXXXX",
        "X..........X",
        "X..........X",
        "X..........X",
        "X..........X",
        "X..........X",
        "XXXXXXXXXXXX",
    ],
    # リモートの space: 箱型のコンピュータ
    "computer": [
        ".XXXXXXXXXX.",
        ".X........X.",
        ".X.XXXXXX.X.",
        ".X.X....X.X.",
        ".X.X....X.X.",
        ".X.XXXXXX.X.",
        ".X........X.",
        ".X.XX.....X.",
        ".XXXXXXXXXX.",
        "XXXXXXXXXXXX",
    ],
    # working: 腕時計 (2 コマ、針が回る)
    "watch-0": [
        "...XXXXXX...",
        "...X....X...",
        "..XXXXXXXX..",
        ".X...X....X.",
        ".X...X....X.",
        ".X...XXX..X.",
        ".X........X.",
        ".X........X.",
        "..XXXXXXXX..",
        "...X....X...",
        "...XXXXXX...",
    ],
    "watch-1": [
        "...XXXXXX...",
        "...X....X...",
        "..XXXXXXXX..",
        ".X........X.",
        ".X........X.",
        ".X...X....X.",
        ".X..X.....X.",
        ".X.X......X.",
        "..XXXXXXXX..",
        "...X....X...",
        "...XXXXXX...",
    ],
    # blocked: 注意の三角
    "alert": [
        ".....XX.....",
        "....X..X....",
        "....X..X....",
        "...X.XX.X...",
        "...X.XX.X...",
        "..X..XX..X..",
        "..X..XX..X..",
        ".X........X.",
        ".X...XX...X.",
        "X..........X",
        "XXXXXXXXXXXX",
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
    "moon": [
        "....XXXX....",
        "..XXX.......",
        ".XXX........",
        ".XX.........",
        "XXX.........",
        "XXX.........",
        "XXX........X",
        ".XXX......XX",
        ".XXXX....XXX",
        "..XXXXXXXXX.",
        "....XXXXX...",
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

def write_mono(rows, name):
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
    with open(os.path.join(ICONS, f"{name}.svg"), "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" '
                f'shape-rendering="crispEdges" fill="currentColor">{"".join(rects)}</svg>\n')


def main():
    os.makedirs(ICONS, exist_ok=True)
    for name, rows in G.items():
        write_mono(rows, name)


if __name__ == "__main__":
    main()
