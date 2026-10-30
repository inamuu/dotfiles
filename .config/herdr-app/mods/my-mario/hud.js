// 上の HUD: 見出しの下に値を置く 2 段組み。名前、コイン (done の数)、ワールド (スペース-タブ)、状態、時計。

import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { spaces, agents, window } from "herdr";
import { C, sprite, mark, blink } from "./kit.js";

const pad = (n) => String(n).padStart(2, "0");

function stat(label, value, { grow = false } = {}) {
  return v_flex()
    .when(grow, (el) => el.flex_1().min_w(0))
    .when(!grow, (el) => el.flex_none())
    .gap(1)
    .child(div().text_size(12).font_bold().text_color(C.text).child(label))
    .child(value);
}

export default class Hud {
  init(_p, cx) {
    blink(this, cx, () => agents().some((a) => a.status === "working"));
    cx.timer.every(20000, (cx) => cx.notify());
  }

  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const s = spaces().find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const all = agents();
    const count = (st) => all.filter((a) => a.status === st).length;
    const now = new Date();
    const value = (text, color = C.text) => div().min_w(0).truncate().text_size(13).font_bold().text_color(color).child(text);
    const party = ["working", "blocked", "idle"]
      .filter((st) => count(st) > 0)
      .map((st) =>
        h_flex()
          .gap(3)
          .items_center()
          .child(mark(st, 1, this.frame))
          .child(div().text_size(12).font_bold().text_color(C.text).child(`x${count(st)}`)),
      );
    return h_flex()
      .size_full()
      .pl(lights ? 84 : 18)
      .pr(18)
      .gap(28)
      .items_center()
      .bg(C.sky)
      .child(stat("HERDR", value(s?.name ?? ""), { grow: true }))
      .child(
        stat(
          "COINS",
          h_flex()
            .gap(3)
            .items_center()
            .child(sprite("mark-done", 16, 16, 1))
            .child(value(`x${pad(count("done"))}`)),
        ),
      )
      .child(stat("WORLD", value(`${s?.index ?? 0}-${tab?.index ?? 0}`)))
      .when(party.length > 0, (el) => el.child(stat("PARTY", h_flex().gap(8).items_center().children(party))))
      .child(stat("TIME", value(`${pad(now.getHours())}:${pad(now.getMinutes())}`)));
  }
}
