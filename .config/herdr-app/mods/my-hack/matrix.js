// 右端の細い柱: 緑の文字が上から雨のように降る。先頭だけ明るく、尾は暗く消える。
// 描くのは各列の尾の部分だけ (列数 x TRAIL 個) なので軽い。

import { div } from "gpui-kit";
import { C } from "./kit.js";

const CHARS = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉ0123456789ABCDEF<>/{}*+=#$%";
const COLS = 8;
const ROWS = 48; // 柱の高さを 48 行に分ける (位置は % なので窓の高さに合わせて伸びる)
const TRAIL = 14;
const pick = () => CHARS[Math.floor(Math.random() * CHARS.length)];

export default class Matrix {
  init(_p, cx) {
    this.cols = Array.from({ length: COLS }, () => ({
      y: Math.floor(Math.random() * ROWS),
      speed: 1 + Math.floor(Math.random() * 2),
      chars: Array.from({ length: TRAIL }, pick),
    }));
    cx.timer.every(80, (cx) => {
      for (const c of this.cols) {
        c.y += c.speed;
        if (c.y - TRAIL > ROWS) {
          c.y = -Math.floor(Math.random() * 12);
          c.speed = 1 + Math.floor(Math.random() * 2);
        }
        c.chars.unshift(pick());
        c.chars.length = TRAIL;
      }
      cx.notify();
    });
  }

  render() {
    const w = 100 / COLS;
    const cells = [];
    this.cols.forEach((c, x) => {
      for (let k = 0; k < TRAIL; k++) {
        const y = c.y - k;
        if (y < 0) continue;
        const color = k === 0 ? "#eafff0" : k < 4 ? C.green : k < 9 ? C.muted : C.dim;
        cells.push(
          div()
            .absolute()
            .top(`${(y / ROWS) * 100}%`)
            .left(`${x * w}%`)
            .w(`${w}%`)
            .flex()
            .justify_center()
            .text_size(13)
            .font_bold()
            .text_color(color)
            .opacity(k < 8 ? 1 : 1 - (k - 8) / (TRAIL - 7))
            .child(c.chars[k]),
        );
      }
    });
    return div().relative().size_full().overflow_hidden().bg(C.bg).border(1).border_color(C.line).children(cells);
  }
}
