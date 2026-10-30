#!/usr/bin/env python3
# Dopa のアイコンを SVG で書き出す。すべてオリジナル。色は currentColor (mod 側で虹色に塗る)。
#   python3 mods/my-dopa/art/gen.py
# 出力先: このスクリプトの一つ上の icons/

import math
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")
HEAD = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'


def write(name, body):
    with open(os.path.join(OUT, f"{name}.svg"), "w") as f:
        f.write(f"{HEAD}{body}</svg>\n")


def star(points, outer, inner, cx=12, cy=12, turn=-90):
    pts = []
    for i in range(points * 2):
        r = outer if i % 2 == 0 else inner
        a = math.radians(turn + i * 180 / points)
        pts.append(f"{cx + r * math.cos(a):.2f},{cy + r * math.sin(a):.2f}")
    return f'<polygon fill="currentColor" points="{" ".join(pts)}"/>'


def main():
    os.makedirs(OUT, exist_ok=True)
    write("star", star(5, 11, 4.6))
    write("burst", star(12, 11.5, 7))
    write("sparkle", star(4, 11.5, 2.6))
    write("bolt", '<polygon fill="currentColor" points="14,1 3,14 10.5,14 8,23 21,9 13.5,9 16,1"/>')
    write("flame", '<path fill="currentColor" d="M12 1c1 4 6 6.5 6 12.5A6 6 0 0 1 6 13.5c0-2.6 1.2-4.2 2.4-5.4.2 2 1 3.2 2.3 3.6C10 8.5 10.6 4.4 12 1z"/>')
    write("heart", '<path fill="currentColor" d="M12 21.5 2.6 12.4A5.6 5.6 0 0 1 12 5.2a5.6 5.6 0 0 1 9.4 7.2z"/>')
    write("ring", '<g fill="none" stroke="currentColor" stroke-width="3.4" stroke-linecap="round">'
                  '<circle cx="12" cy="12" r="9" stroke-opacity="0.25"/><path d="M12 3a9 9 0 0 1 9 9"/>'
                  '<path d="M12 21a9 9 0 0 1-9-9" stroke-opacity="0.6"/></g>')
    write("alert", '<path fill="currentColor" d="M12 1.5 23 21.5H1zM10.6 8v7h2.8V8zm0 9v2.6h2.8V17z" fill-rule="evenodd"/>')
    write("zzz", '<path fill="currentColor" d="M3 11h8v2l-5 5h5v2H3v-2l5-5H3zm10-8h8v2l-5 5h5v2h-8v-2l5-5h-5z"/>')
    write("plus", '<path fill="currentColor" d="M10 3h4v7h7v4h-7v7h-4v-7H3v-4h7z"/>')
    write("close", '<path fill="currentColor" d="M5.6 2.8 12 9.2l6.4-6.4 2.8 2.8L14.8 12l6.4 6.4-2.8 2.8L12 14.8l-6.4 6.4-2.8-2.8L9.2 12 2.8 5.6z"/>')
    write("split-right", '<path fill="currentColor" fill-rule="evenodd" d="M2 3h20v18H2zm3 3v12h5V6zm8 0v12h6V6z"/>')
    write("split-down", '<path fill="currentColor" fill-rule="evenodd" d="M2 3h20v18H2zm3 3v4h14V6zm0 7v5h14v-5z"/>')
    write("zoom", '<path fill="currentColor" d="M2 2h8v3H5v5H2zm12 0h8v8h-3V5h-5zM2 14h3v5h5v3H2zm17 0h3v8h-8v-3h5z"/>')
    write("unzoom", '<path fill="currentColor" d="M7 2h3v8H2V7h5zm7 0h3v5h5v3h-8zM2 14h8v8H7v-5H2zm12 0h8v3h-5v5h-3z"/>')
    write("crown", '<path fill="currentColor" d="M2 7l5 4 5-7 5 7 5-4-2 12H4zm2 13h16v2H4z"/>')


if __name__ == "__main__":
    main()
