#!/usr/bin/env python3
# Mother レイアウトのドット絵を SVG で書き出す。すべてオリジナル。
#   python3 mods/my-mother/art/gen.py
# 出力先:
#   ../icons/    単色アイコン (mod 側で色を付ける)
#   ../sprites/  色付きのスプライトと、背景のサイケな模様タイル

import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ICONS = os.path.join(HERE, "..", "icons")
SPRITES = os.path.join(HERE, "..", "sprites")
SIZE = 12  # 単色アイコンは 12x12 に満たなければ中央に置く

G = {
    # space: 町の家
    "house": [
        ".....XX.....",
        "....XXXX....",
        "...XXXXXX...",
        "..XXXXXXXX..",
        ".XXXXXXXXXX.",
        "XXXXXXXXXXXX",
        ".X........X.",
        ".X.XX..XX.X.",
        ".X.XX..XX.X.",
        ".X....XX..X.",
        ".X....XX..X.",
        ".XXXXXXXXXX.",
    ],
    # リモートの space: UFO
    "ufo": [
        "....XXXX....",
        "...X....X...",
        "..X......X..",
        ".XXXXXXXXXX.",
        "XX.XX.XX.XXX",
        "XXXXXXXXXXXX",
        ".XXXXXXXXXX.",
        "..X..XX..X..",
        ".X...XX...X.",
    ],
    # 選択カーソル: 指さす手
    "hand": [
        "....XX......",
        "...X..X.....",
        "...X..XXXXXX",
        "XXXX.......X",
        "X..X..XXXXXX",
        "X..X.......X",
        "X..X..XXXXX.",
        "X..X......X.",
        "XXXX..XXXX..",
        "...XXXX.....",
    ],
    # working: うずまき (2 コマ)
    "swirl-0": [
        "...XXXXXX...",
        "..X......X..",
        ".X..XXXX..X.",
        "X..X....X..X",
        "X.X..XX..X.X",
        "X.X.X..X.X.X",
        "X.X.X.XX.X.X",
        "X.X..X...X.X",
        "X..X....X..X",
        ".X..XXXX..X.",
        "..X.......X.",
        "...XXXXXXX..",
    ],
    "swirl-1": [
        "..XXXXXXX...",
        ".X.......X..",
        ".X..XXXX..X.",
        "X..X....X..X",
        "X.X...X..X.X",
        "X.X.XX.X.X.X",
        "X.X.X..X.X.X",
        "X.X..XX..X.X",
        "X..X....X..X",
        ".X..XXXX..X.",
        "..X......X..",
        "...XXXXXX...",
    ],
    # blocked: ! の吹き出し
    "bang": [
        ".XXXXXXXXXX.",
        "XX...XX...XX",
        "X....XX....X",
        "X....XX....X",
        "X....XX....X",
        "X..........X",
        "X....XX....X",
        "XX........XX",
        ".XXXXXXXXXX.",
        "...XX.......",
        "..X.........",
    ],
    # done: 星
    "star": [
        ".....XX.....",
        ".....XX.....",
        "....XXXX....",
        "XXXXXXXXXXXX",
        ".XXXXXXXXXX.",
        "..XXXXXXXX..",
        "...XXXXXX...",
        "..XXXXXXXX..",
        "..XXX..XXX..",
        ".XX......XX.",
    ],
    # idle: Zz
    "zzz": [
        "......XXXXXX",
        "..........X.",
        ".........X..",
        "........X...",
        "XXXXX..XXXXX",
        "...X........",
        "..X.........",
        ".X..........",
        "XXXXX.......",
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

# 色付きスプライト: ロゴの流れ星 (16x12)
LOGO = (
    [
        "..........YY....",
        ".........YWWY...",
        "....P...YWWWWY..",
        "...PP..YWWWWWWY.",
        "..PP..CCYWWWWY..",
        ".PP..CC..YWWY...",
        "PP..CC...YYYY...",
        "...CC...YY..YY..",
        "..CC...YY....YY.",
        ".CC.............",
        "CC..............",
        "................",
    ],
    {"Y": "#f8d848", "W": "#fff8d8", "P": "#e05aa8", "C": "#58d8c8"},
)

# 背景のサイケな模様: 波打つ斜めのしま。32x32 で上下左右につなぎ目なく敷ける。
# 4 色を 8px ずつ、横の位置に縦方向の正弦波でゆらぎを足す。
BANDS = {
    "bg-0": ["#2a0f4a", "#5a1f86", "#c0428e", "#5a1f86"],  # 紫とピンク
    "bg-1": ["#0c2a3a", "#147a78", "#58d8c8", "#147a78"],  # 青緑
    "bg-2": ["#3a1020", "#a03a3a", "#f0a040", "#a03a3a"],  # 夕焼け
}
TILE = 32


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


def write_color(grid, name):
    # grid: 行ごとの色 (None は透明) の配列
    h, w = len(grid), len(grid[0])
    rects = []
    for y, row in enumerate(grid):
        x = 0
        while x < w:
            c = row[x]
            if c is None:
                x += 1
                continue
            n = 1
            while x + n < w and row[x + n] == c:
                n += 1
            rects.append(f'<rect x="{x}" y="{y}" width="{n}" height="1" fill="{c}"/>')
            x += n
    with open(os.path.join(SPRITES, f"{name}.svg"), "w") as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" '
                f'shape-rendering="crispEdges">{"".join(rects)}</svg>\n')


def band(colors):
    grid = []
    for y in range(TILE):
        wave = round(3 * math.sin(2 * math.pi * y / TILE))
        grid.append([colors[((x + y + wave) // 8) % len(colors)] for x in range(TILE)])
    return grid


def main():
    os.makedirs(ICONS, exist_ok=True)
    os.makedirs(SPRITES, exist_ok=True)
    for name, rows in G.items():
        write_mono(rows, name)
    rows, pal = LOGO
    write_color([[pal.get(c) for c in r] for r in rows], "logo")
    for name, colors in BANDS.items():
        write_color(band(colors), name)


if __name__ == "__main__":
    main()
