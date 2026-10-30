// 下の地面: 草と土のタイル。エージェントが働いている間は勇者が歩き回る (16x16 を 3 倍)。
// 左上にいまのペインの場所とブランチ。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, panes, home } from "herdr";
import { C, sprite, short } from "./kit.js";

const TILES = 120; // 16x8 のタイル (3 倍で 48px 幅)。4K 幅の画面でも足りる数

export default class Ground {
  init(_p, cx) {
    this.x = 4; // 勇者の位置 (%)
    this.dir = 1;
    this.step = 0;
    cx.timer.every(160, (cx) => {
      if (!agents().some((a) => a.status === "working")) {
        if (this.step === 0) return;
        this.step = 0;
      } else {
        this.step ^= 1;
        this.x += this.dir * 0.6;
        if (this.x > 94) this.dir = -1;
        if (this.x < 2) this.dir = 1;
      }
      cx.notify();
    });
  }

  render() {
    const working = agents().some((a) => a.status === "working");
    const p = panes().find((x) => x.focused);
    const where = short(p?.cwd, home());
    const hero = sprite(`hero-${this.dir > 0 ? "r" : "l"}-${working ? this.step : 1}`, 16, 16, 3);
    return div()
      .relative()
      .size_full()
      .overflow_hidden()
      .bg(C.ink)
      .child(
        h_flex()
          .absolute()
          .bottom(0)
          .left(0)
          .children(Array.from({ length: TILES }, () => sprite("ground", 16, 8, 3))),
      )
      .child(div().absolute().bottom(21).left(`${this.x}%`).child(hero))
      .child(
        h_flex()
          .absolute()
          .top(3)
          .right(14)
          .gap(10)
          .text_size(11)
          .when(Boolean(where), (el) => el.child(div().text_color(C.muted).child(`MAP ${where}`)))
          .when(Boolean(p?.branch), (el) => el.child(div().text_color(C.gold).child(`@ ${p.branch}`))),
      );
  }
}
