#!/usr/bin/env python3
# Pixel Quest のスプライトを SVG で書き出す。すべてオリジナルのドット絵。
#   python3 mods/my-pixel/art/gen.py
# 出力先: このスクリプトの一つ上の sprites/

import glob
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sprites")
INK = "#101018"
SKIN = {"S": "#ffcf9e", "s": "#e0956a", "E": INK}


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


# 勇者 (横向き 16x16): 兜、赤いマント、青い服、前に構えた剣。2 コマで歩く。
HERO_TOP = [
    "......OOOO......",
    ".....OhHHHO.....",
    "....OhHHHHHO....",
    "....OHHHHHHHO...",
    "....OHOSSSSEO...",
    "...ROHOSSSSSO...",
    "..RROOsSSSSO....",
    "..RrROOOOOO.....",
    ".RrROTTTTTSO....",
    ".RrROtTTTTSOG...",
    ".RrrOBBBBBOWW...",
    "..RrOTTTTTO.....",
]
HERO_WALK = [
    "..RROtTOtTO.....",
    "...OBBOOOBBO....",
    "..OBBBO..OBBBO..",
    "..OOOO....OOOO..",
]
HERO_STAND = [
    "..RROtTTTtO.....",
    "....OBBBBO......",
    "....OBBBBBO.....",
    "....OOOOOO......",
]
HERO_PAL = {
    "O": INK, "H": "#4f8fe8", "h": "#bcd8ff", "R": "#d94a5a", "r": "#9a2a3a",
    "T": "#3f6fd0", "t": "#294a98", "B": "#6b4423", "G": "#f4c542", "W": "#e8eaf4",
    **SKIN,
}

# 仲間 (正面 16x16): 頭は職業ごと、体は共通。working のときだけ足踏み。
HEADS = {
    "warrior": [
        "......OOOO......",
        ".....OhHHHO.....",
        "....OhHHHHHO....",
        "....OHHHHHHO....",
        "....OOSSSSOO....",
        "....OSESSESO....",
        "....OSSssSSO....",
        ".....OOOOOO.....",
    ],
    "mage": [
        ".........OO.....",
        "........OPpO....",
        ".......OPPpO....",
        "......OPPPPpO...",
        "..OOOOOOOOOOOOO.",
        "....OSESSESO....",
        "....OSSssSSO....",
        ".....OOOOOO.....",
    ],
    "priest": [
        "......OOOO......",
        ".....OKKKKO.....",
        "....OKKKKKKO....",
        "...OKKOOOOKKO...",
        "...OKOSSSSOKO...",
        "...OKSESSESKO...",
        "...OKSSssSSKO...",
        "....OOOOOOOO....",
    ],
    "fighter": [
        "....O.O.O.O.....",
        "....OYOYOYOO....",
        "....OYYYYYYO....",
        "....ORRRRRRO....",
        "....OYSSSSYO....",
        "....OSESSESO....",
        "....OSSssSSO....",
        ".....OOOOOO.....",
    ],
}
BODY = [
    "....OCCCCCCO....",
    "...OSCCccCCSO...",
    "...OSOCCCCOSO...",
    "....OCCCCCCO....",
    "....OccOOccO....",
]
FEET = [
    ["....OBBO.OBBO...", "....OOO..OOO....", "................"],
    ["...OBBO.OBBO....", "...OOO..OOO.....", "................"],
]
CLASS_PAL = {
    "warrior": {"H": "#9aa4b8", "h": "#e8ecf4", "C": "#3f6fd0", "c": "#294a98"},
    "mage": {"P": "#8a5ad8", "p": "#5a3a98", "C": "#8a5ad8", "c": "#5a3a98"},
    "priest": {"K": "#eef0f4", "C": "#eef0f4", "c": "#4aa86a"},
    "fighter": {"Y": "#ff8a3c", "R": "#d94a5a", "C": "#ff8a3c", "c": "#c25a1c"},
}

# 状態アイコン (9x9)
MARKS = {
    "working": ([
        ".......OO",
        "......OWO",
        ".....OWO.",
        ".O..OWO..",
        ".OOOWO...",
        "..OGO....",
        "..OGOO...",
        ".OGO.OO..",
        "OOO......",
    ], {"O": INK, "W": "#e8eaf4", "G": "#f4c542"}),
    "blocked": ([
        ".OOOOOOO.",
        "OWWWRWWWO",
        "OWWWRWWWO",
        "OWWWRWWWO",
        "OWWWWWWWO",
        "OWWWRWWWO",
        ".OOOOOOO.",
        "..OWO....",
        "..OO.....",
    ], {"O": INK, "W": "#ffffff", "R": "#e83a3a"}),
    "done": ([
        "....O....",
        "...OYO...",
        "OOOOYOOOO",
        "OYYYYYYYO",
        ".OYYYYYO.",
        "..OYYYO..",
        ".OYYOYYO.",
        ".OYO.OYO.",
        ".OO...OO.",
    ], {"O": INK, "Y": "#f4c542"}),
    "idle": ([
        "..ZZZZ...",
        "....Z....",
        "...Z.....",
        "..ZZZZ...",
        "......ZZZ",
        ".......Z.",
        "......ZZZ",
        ".........",
        ".........",
    ], {"Z": "#9fb4ff"}),
}

# 地図アイコン (16x16): スペース 1 つ。旗や屋根の色はスペースごとの色 (R)。
PLACES = {
    "castle": [
        "...R.......R....",
        "...RR......RR...",
        "...O.......O....",
        "..OOO.....OOO...",
        "..OSO.O.O.OSO...",
        ".OSSSOSOSOSSSO..",
        ".OSsSOOOOOSsSO..",
        ".OSSSSSSSSSSSO..",
        ".OSsSOOOOOSsSO..",
        ".OSSSORRROSSSO..",
        ".OSSSORRROSSSO..",
        ".OSsSSOOOSSsSO..",
        ".OSSSSODDOSSSO..",
        ".OSsSSODDOSsSO..",
        ".OSSSSODDOSSSO..",
        ".OOOOOOOOOOOOO..",
    ],
    "town": [
        "................",
        "....OO..........",
        "...ORRO.........",
        "..ORRRRO...OO...",
        ".ORRRRRRO.ORRO..",
        "OOOOOOOOOORRRRO.",
        ".OWWWWWWOORRRRRO",
        ".OWGGWWWOOOOOOOO",
        ".OWGGWDWO.OWWWO.",
        ".OWWWWDWO.OWGWO.",
        ".OOOOOOOO.OWDWO.",
        "..........OOOOO.",
        "gLggLgggLggLggLg",
        "................",
        "................",
        "................",
    ],
    "tower": [
        ".......OO.......",
        "......ORRO......",
        ".....ORRRRO.....",
        "....ORRRRRRO....",
        "....OOOOOOOO....",
        ".....OSSSSO.....",
        ".....OSssSO.....",
        ".....OSGGSO.....",
        ".....OSSSSO.....",
        ".....OSsSSO.....",
        ".....OSSsSO.....",
        ".....OSGGSO.....",
        "....OSSSSSSSO...",
        "....OSSODOSSO...",
        "....OSSODOSSO...",
        "....OOOOOOOOO...",
    ],
    "cave": [
        ".......R........",
        ".......RR.......",
        ".......O........",
        "......OWO.......",
        ".....OWWWO......",
        "....OMWMMMO.....",
        "...OMMMMMmMO....",
        "..OMMmMMMMmMO...",
        "..OMMMMOOOMMMO..",
        ".OMmMMOOOOOMMmO.",
        ".OMMMOOOOOOOMMO.",
        "OMMmMOOOOOOOMMMO",
        "OOOOOOOOOOOOOOOO",
        "................",
        "................",
        "................",
    ],
}
PLACE_PAL = {
    "O": INK, "S": "#c4c4d4", "s": "#8a8aa0", "D": "#4a3020", "W": "#efe3c4",
    "G": "#7ec8ff", "M": "#9a7a54", "m": "#6a4a2a", "g": "#4aa84a", "L": "#7ee07e",
}
# スペースの色 -> 地図アイコンと旗の色
SPACE_COLORS = {
    "ansi6": ("castle", "#22c3b0"),
    "ansi3": ("town", "#ff8a4c"),
    "ansi4": ("tower", "#5b8def"),
    "ansi5": ("castle", "#a98bff"),
    "ansi2": ("cave", "#5fd068"),
    "ansi1": ("town", "#ff6b9d"),
}

# ロゴの宝石
GEM = [
    "..OOOOOOOO..",
    ".OWHCCCCCDO.",
    "OHHCCCCCCDDO",
    "OOOOOOOOOOOO",
    ".OHCCCCCCDO.",
    "..OHCCCCDO..",
    "...OCCCCO...",
    "....OCDO....",
    ".....OO.....",
]

# 地面タイル (16x8): 草、花、土、石
GROUND = [
    "GGgGGGGgGGFGGgGG",
    "GgggGGgggGGGgggG",
    "gggggggggggggggg",
    "dddDdddddddDdddd",
    "ddddddDdddddddsd",
    "dsdddddddDdddddd",
    "ddddDdddddddDddd",
    "dddddddsdddddddd",
]
GROUND_PAL = {"G": "#5fd068", "g": "#3a9e47", "F": "#ffe08a", "d": "#7a4a2a", "D": "#5a3420", "s": "#9a8fb8"}

# 単色アイコン (svg() で色付けして使う)
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
        os.replace(old, os.path.join(os.path.expanduser("~/.Trash"), "pixel-" + os.path.basename(old)))
    for i, legs in enumerate([HERO_WALK, HERO_STAND]):
        svg(HERO_TOP + legs, HERO_PAL, f"hero-r-{i}")
        svg(mirror(HERO_TOP + legs), HERO_PAL, f"hero-l-{i}")
    for job, head in HEADS.items():
        pal = {"O": INK, "B": "#6b4423", **SKIN, **CLASS_PAL[job]}
        for f, feet in enumerate(FEET):
            svg(head + BODY + feet, pal, f"{job}-{f}")
    for status, (rows, pal) in MARKS.items():
        svg(rows, pal, f"mark-{status}")
    for key, (place, flag) in SPACE_COLORS.items():
        svg(PLACES[place], {**PLACE_PAL, "R": flag}, f"place-{key}")
    svg(GEM, {"O": INK, "W": "#ffffff", "H": "#a8f0ff", "C": "#4fd1e8", "D": "#2a8aa8"}, "gem")
    svg(GROUND, GROUND_PAL, "ground")
    for name, rows in GLYPHS.items():
        svg(rows, {"X": "#ffffff"}, name)


if __name__ == "__main__":
    main()
