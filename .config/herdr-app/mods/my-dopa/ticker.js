// 下のニュース速報: 左に点滅する LIVE、右へ左へ流れる煽り文句といまの状況。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, panes, home } from "herdr";
import { C, hue, pulse, icon, short } from "./kit.js";

const HYPE = [
  "SHIP IT",
  "NO BUGS ONLY FEATURES",
  "TOUCH GRASS LATER",
  "ONE MORE PROMPT",
  "MAIN CHARACTER ENERGY",
  "IT WORKS ON MY MACHINE",
  "LET HIM COOK",
  "MERGE ON FRIDAY",
];
const ICONS = ["bolt", "flame", "star", "heart", "sparkle", "burst"];

export default class Ticker {
  init(_p, cx) {
    pulse(cx, 200);
  }

  render() {
    const all = agents();
    const n = (st) => all.filter((a) => a.status === st).length;
    const p = panes().find((x) => x.focused);
    const news = [
      `${n("working")} AGENTS COOKING`,
      n("blocked") ? `${n("blocked")} WAITING FOR YOU!!` : "NOBODY WAITING",
      `${n("done")} JUST FINISHED`,
      p?.branch ? `ON BRANCH ${p.branch}` : null,
      p?.cwd ? `NOW AT ${short(p.cwd, home())}` : null,
    ].filter(Boolean);
    const items = [];
    for (let i = 0; i < 3; i++) {
      [...news, ...HYPE].forEach((text, j) => {
        const k = i * 20 + j;
        items.push(icon(ICONS[k % ICONS.length], 14, hue(k)).spin(1200 + (k % 4) * 300));
        items.push(div().flex_none().text_size(13).font_bold().text_color(j < news.length ? C.text : hue(k + 1)).child(text));
      });
    }
    return h_flex()
      .size_full()
      .bg(C.chrome)
      .border_t(3)
      .border_color(hue(5))
      .child(
        h_flex()
          .flex_none()
          .h_full()
          .px(14)
          .gap(6)
          .items_center()
          .bg(C.red)
          .child(div().size(8).rounded(999).bg(C.text).loop("opacity", { from: 0, to: 1, period: 600, easing: "linear" }))
          .child(div().text_size(13).font_bold().text_color(C.text).child("LIVE")),
      )
      .child(
        div()
          .relative()
          .flex_1()
          .h_full()
          .overflow_hidden()
          .child(
            h_flex()
              .absolute()
              .top(0)
              .h_full()
              .gap(14)
              .items_center()
              .whitespace_nowrap()
              .loop("left", { from: 16, to: -2600, period: 40000, easing: "linear" })
              .children(items),
          ),
      );
  }
}
