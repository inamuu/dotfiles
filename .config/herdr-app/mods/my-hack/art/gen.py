#!/usr/bin/env python3
# Hack のアイコンを SVG で書き出す。すべてオリジナルのドット絵。単色 (mod 側で色を付ける)。
#   python3 mods/my-hack/art/gen.py
# 出力先: このスクリプトの一つ上の icons/

import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")

GLYPHS = {
    "skull": [
        "...XXXXXX...",
        "..XXXXXXXX..",
        ".XXXXXXXXXX.",
        ".XX..XX..XX.",
        ".XX..XX..XX.",
        ".XXXXXXXXXX.",
        "..XXX..XXX..",
        "...XXXXXX...",
        "...X.XX.X...",
        "...XXXXXX...",
    ],
    "lock": [
        "...XXXX...",
        "..X....X..",
        "..X....X..",
        "..X....X..",
        "XXXXXXXXXX",
        "XXXXXXXXXX",
        "XXXX..XXXX",
        "XXXX..XXXX",
        "XXXXXXXXXX",
        "XXXXXXXXXX",
    ],
    "unlock": [
        "...XXXX...",
        "..X....X..",
        "..X.......",
        "..X.......",
        "XXXXXXXXXX",
        "XXXXXXXXXX",
        "XXXX..XXXX",
        "XXXX..XXXX",
        "XXXXXXXXXX",
        "XXXXXXXXXX",
    ],
    "chip": [
        "..X.X.X.X..",
        "..X.X.X.X..",
        "XXXXXXXXXXX",
        ".X.......X.",
        "XX.XXXXX.XX",
        ".X.X...X.X.",
        "XX.XXXXX.XX",
        ".X.......X.",
        "XXXXXXXXXXX",
        "..X.X.X.X..",
        "..X.X.X.X..",
    ],
    "radar": [
        "....XXXX....",
        "..XX....XX..",
        ".X........X.",
        ".X...XX...X.",
        "X...X..X...X",
        "X..X.XX.X..X",
        "X..X.XXXXXXX",
        "X...X..X...X",
        ".X...XX...X.",
        ".X........X.",
        "..XX....XX..",
        "....XXXX....",
    ],
    "prompt": [
        "X.........",
        ".X........",
        "..X.......",
        "...X......",
        "..X.......",
        ".X........",
        "X...XXXXXX",
    ],
}


def write(rows, name):
    h, w = len(rows), len(rows[0])
    for y, r in enumerate(rows):
        if len(r) != w:
            raise SystemExit(f"{name}: row {y} is {len(r)} wide, expected {w}")
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
            rects.append(f'<rect x="{x}" y="{y}" width="{n}" height="1"/>')
            x += n
    with open(os.path.join(OUT, f"{name}.svg"), "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" '
                f'shape-rendering="crispEdges" fill="currentColor">{"".join(rects)}</svg>\n')


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, rows in GLYPHS.items():
        write(rows, name)


if __name__ == "__main__":
    main()
