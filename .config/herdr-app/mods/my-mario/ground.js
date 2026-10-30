// 下の地面: 空に雲、丘と草むら、レンガの地面、右端に土管。
// エージェントが働いている間は主人公が走り回る (16x16 を 2 倍)。右上にいまのペインの場所とブランチ。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, panes, home } from "herdr";
import { C, sprite, short } from "./kit.js";

const TILES = 140; // 16x16 のタイル (2 倍で 32px 幅)。4K 幅の画面でも足りる数

export default class Ground {
  init(_p, cx) {
    this.x = 4; // 主人公の位置 (%)
    this.dir = 1;
    this.step = 0;
    cx.timer.every(140, (cx) => {
      if (!agents().some((a) => a.status === "working")) {
        if (this.step === 0) return;
        this.step = 0;
      } else {
        this.step ^= 1;
        this.x += this.dir * 0.6;
        if (this.x > 88) this.dir = -1;
        if (this.x < 2) this.dir = 1;
      }
      cx.notify();
    });
  }

  render() {
    const working = agents().some((a) => a.status === "working");
    const p = panes().find((x) => x.focused);
    const where = short(p?.cwd, home());
    const hero = sprite(`hero-${this.dir > 0 ? "r" : "l"}-${working ? this.step : 1}`, 16, 16, 2);
    const deco = (name, w, h, scale, left, bottom) => div().absolute().left(left).bottom(bottom).child(sprite(name, w, h, scale));
    return div()
      .relative()
      .size_full()
      .overflow_hidden()
      .bg(C.sky)
      .child(deco("cloud", 32, 14, 1, "18%", 44))
      .child(deco("cloud", 32, 14, 1, "57%", 48))
      .child(deco("hill", 40, 18, 1.5, "6%", 32))
      .child(deco("bush", 32, 10, 1.5, "36%", 32))
      .child(deco("hill", 40, 18, 1, "70%", 32))
      .child(
        h_flex()
          .absolute()
          .bottom(0)
          .left(0)
          .children(Array.from({ length: TILES }, () => sprite("ground", 16, 16, 2))),
      )
      .child(div().absolute().bottom(32).right(24).child(sprite("pipe-ansi2", 16, 16, 2)))
      .child(div().absolute().bottom(32).left(`${this.x}%`).child(hero))
      .child(
        h_flex()
          .absolute()
          .top(4)
          .right(18)
          .gap(12)
          .text_size(11.5)
          .font_bold()
          .when(Boolean(where), (el) => el.child(div().text_color(C.text).child(where)))
          .when(Boolean(p?.branch), (el) => el.child(div().text_color(C.ink).child(`@ ${p.branch}`))),
      );
  }
}
