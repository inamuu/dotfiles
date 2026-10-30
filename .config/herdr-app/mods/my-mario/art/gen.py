#!/usr/bin/env python3
# Mario 風テーマ (my-mario) のスプライトを SVG で書き出す。すべてオリジナルのドット絵。
#   python3 mods/my-mario/art/gen.py
# 出力先: このスクリプトの一つ上の sprites/
# 自分で用意した画像は sprites/ ではなく private/ (gitignore 済み) に同じ名前で置くと差し替わる。

import glob
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sprites")
K = "#000000"


def svg(rows, pal, name):
    h = len(rows)
    w = max(len(r) for r in rows)
    for y, row in enumerate(rows):
        if len(row) != w:
            raise SystemExit(f"{name}: row {y} is {len(row)} wide, expected {w}")
    rects = []
    for y, row in enumerate(rows):
        x = 0
        while x < len(row):
            c = row[x]
            if c == ".":
                x += 1
                continue
            n = 1
            while x + n < len(row) and row[x + n] == c:
                n += 1
            rects.append(f'<rect x="{x}" y="{y}" width="{n}" height="1" fill="{pal[c]}"/>')
            x += n
    body = "".join(rects)
    text = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
            f'viewBox="0 0 {w} {h}" shape-rendering="crispEdges">{body}</svg>\n')
    with open(os.path.join(OUT, f"{name}.svg"), "w") as f:
        f.write(text)


def mirror(rows):
    return [r[::-1] for r in rows]


# 楕円をいくつか重ねた塊 (雲、丘、草むら)。外周 1 ドットを縁取りにする。flat なら下端は縁取らない。
def blob(w, h, ovals, flat=False):
    def inside(x, y):
        if x < 0 or y < 0 or x >= w or y >= h:
            return flat and y >= h and 0 <= x < w
        return any(((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1 for cx, cy, rx, ry in ovals)

    rows = []
    for y in range(h):
        row = ""
        for x in range(w):
            if not inside(x, y):
                row += "."
            elif all(inside(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                row += "F"
            else:
                row += "O"
        rows.append(row)
    return rows


# 主人公 (横向き 16x16): 青い帽子、白いシャツ、茶色のズボン。2 コマで歩く。
HERO_TOP = [
    "................",
    "......CCCCC.....",
    ".....CCCCCCCCC..",
    ".....KSSSSKS....",
    "....KSSSSSKSS...",
    "....KSSSSSSSSS..",
    ".....SSSSSSSS...",
    "......SSSS......",
    ".....WWWWWW.....",
    "....WWWWWWWW....",
    "...SWWWWWWWWS...",
    "...SPPPPPPPPS...",
]
HERO_WALK = [
    "....PPP..PPP....",
    "...PPP....PPP...",
    "..BBB......BBB..",
    "..BBB......BBB..",
]
HERO_STAND = [
    ".....PPPPPP.....",
    ".....PPP.PPP....",
    ".....BBB.BBB....",
    "....BBBB.BBBB...",
]
HERO_PAL = {"K": K, "C": "#0058f8", "S": "#ffcf9e", "W": "#fcfcfc", "P": "#7c4a10", "B": "#881400"}

# ? ブロック (working)。2 コマで色が明滅する。
QBLOCK = [
    "BBBBBBBBBBBBBBBB",
    "BYYYYYYYYYYYYYYK",
    "BYKYYYYYYYYYYKYK",
    "BYYYYYBBBBYYYYYK",
    "BYYYYBBKKBBYYYYK",
    "BYYYYBBKYBBKYYYK",
    "BYYYYYKKYBBKYYYK",
    "BYYYYYYYBBBKYYYK",
    "BYYYYYYBBKKYYYYK",
    "BYYYYYYBBKYYYYYK",
    "BYYYYYYYKKYYYYYK",
    "BYYYYYYBBYYYYYYK",
    "BYYYYYYBBKYYYYYK",
    "BYKYYYYYKKYYYKYK",
    "BYYYYYYYYYYYYYYK",
    "KKKKKKKKKKKKKKKK",
]

# ! ブロック (blocked): 赤地に白い !
ALERT = [
    "KKKKKKKKKKKKKKKK",
    "KRRRRRRRRRRRRRRK",
    "KRKRRRRRRRRRRKRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRRRRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRRRRRRWWRRRRRRK",
    "KRKRRRRRRRRRRKRK",
    "KRRRRRRRRRRRRRRK",
    "KKKKKKKKKKKKKKKK",
]

# 叩いたあとの空ブロック (idle)
USED = [
    "KKKKKKKKKKKKKKKK",
    "KBBBBBBBBBBBBBBK",
    "KBKBBBBBBBBBBKBK",
] + ["KBBBBBBBBBBBBBBK"] * 10 + [
    "KBKBBBBBBBBBBKBK",
    "KBBBBBBBBBBBBBBK",
    "KKKKKKKKKKKKKKKK",
]

# コイン (done)
COIN = [
    "................",
    "......KKKK......",
    ".....KYYYYK.....",
    "....KYYWWYYK....",
] + ["....KYWYYBYK...."] * 8 + [
    "....KYYBBYYK....",
    ".....KYYYYK.....",
    "......KKKK......",
    "................",
]
COIN_PAL = {"K": K, "Y": "#fc9838", "W": "#fce0a8", "B": "#c84c0c"}

# 土管 (スペースのアイコン)。色は my-spaces が決めたスペースの色に合わせる。
PIPE = [
    "KKKKKKKKKKKKKKKK",
    "KLLGGGGGGGGDGDDK",
    "KLLGGGGGGGGDGDDK",
    "KLLGGGGGGGGDGDDK",
    "KLLGGGGGGGGDGDDK",
    "KKKKKKKKKKKKKKKK",
] + [".KLLGGGGGGDGDDK."] * 10
PIPE_COLORS = {
    "ansi1": ("#fca0a0", "#e40058", "#880014"),
    "ansi2": ("#b8f818", "#00a800", "#005800"),
    "ansi3": ("#fce0a8", "#fc9838", "#ac7c00"),
    "ansi4": ("#a4e4fc", "#3cbcfc", "#0058f8"),
    "ansi5": ("#d8b8f8", "#9878f8", "#6844fc"),
    "ansi6": ("#b8f8d8", "#00a888", "#005858"),
}

# 地面のレンガ (16x16)
GROUND = [
    "LLLLLLLKLLLLLLLL",
] + ["LBBBBBBKLBBBBBBB"] * 6 + [
    "KKKKKKKKKKKKKKKK",
    "LLLKLLLLLLLKLLLL",
] + ["BBBKLBBBBBBKLBBB"] * 6 + [
    "KKKKKKKKKKKKKKKK",
]
GROUND_PAL = {"K": K, "L": "#fcbcb0", "B": "#c84c0c"}

# 背景の飾り
CLOUD = blob(32, 14, [(9, 9, 7, 5), (16, 6, 7, 6), (24, 9, 7, 5)])
HILL = blob(40, 18, [(20, 18, 20, 18)], flat=True)
BUSH = blob(32, 10, [(8, 10, 8, 8), (16, 8, 8, 8), (24, 10, 8, 8)], flat=True)

# 単色アイコン (色付け可)
GLYPHS = {
    "cursor": [
        "X.....",
        "XX....",
        "XXX...",
        "XXXX..",
        "XXX...",
        "XX....",
        "X.....",
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
    "plus": [
        "...XX...",
        "...XX...",
        "...XX...",
        "XXXXXXXX",
        "XXXXXXXX",
        "...XX...",
        "...XX...",
        "...XX...",
    ],
    "split-right": [
        "XXXXXXXX",
        "X..X...X",
        "X..X...X",
        "X..X...X",
        "X..X...X",
        "X..X...X",
        "X..X...X",
        "XXXXXXXX",
    ],
    "split-down": [
        "XXXXXXXX",
        "X......X",
        "X......X",
        "XXXXXXXX",
        "X......X",
        "X......X",
        "X......X",
        "XXXXXXXX",
    ],
    "zoom": [
        "XXX..XXX",
        "XX....XX",
        "X.X..X.X",
        "........",
        "........",
        "X.X..X.X",
        "XX....XX",
        "XXX..XXX",
    ],
    "unzoom": [
        "X.X..X.X",
        ".XX..XX.",
        "XXX..XXX",
        "........",
        "........",
        "XXX..XXX",
        ".XX..XX.",
        "X.X..X.X",
    ],
}


def main():
    os.makedirs(OUT, exist_ok=True)
    for old in glob.glob(os.path.join(OUT, "*.svg")):
        os.replace(old, os.path.join(os.path.expanduser("~/.Trash"), "mario-" + os.path.basename(old)))
    for i, legs in enumerate([HERO_WALK, HERO_STAND]):
        svg(HERO_TOP + legs, HERO_PAL, f"hero-r-{i}")
        svg(mirror(HERO_TOP + legs), HERO_PAL, f"hero-l-{i}")
    svg(QBLOCK, {"K": K, "B": "#c84c0c", "Y": "#fc9838"}, "mark-working-0")
    svg(QBLOCK, {"K": K, "B": "#c84c0c", "Y": "#e45c10"}, "mark-working-1")
    svg(ALERT, {"K": K, "R": "#e40058", "W": "#fcfcfc"}, "mark-blocked")
    svg(COIN, COIN_PAL, "mark-done")
    svg(USED, {"K": K, "B": "#c84c0c"}, "mark-idle")
    for key, (light, mid, dark) in PIPE_COLORS.items():
        svg(PIPE, {"K": K, "L": light, "G": mid, "D": dark}, f"pipe-{key}")
    svg(GROUND, GROUND_PAL, "ground")
    svg(CLOUD, {"O": "#3cbcfc", "F": "#fcfcfc"}, "cloud")
    svg(HILL, {"O": K, "F": "#00a800"}, "hill")
    svg(BUSH, {"O": "#005800", "F": "#80d010"}, "bush")
    for name, rows in GLYPHS.items():
        svg(rows, {"X": "#ffffff"}, name)


if __name__ == "__main__":
    main()
