// 上の HUD: ロゴ、いまのステージ (スペースとタブ)、パーティの状態、時計。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, window } from "herdr";
import { C, sprite, mark } from "./kit.js";

const pad = (n) => String(n).padStart(2, "0");

export default class Hud {
  init(_p, cx) {
    cx.timer.every(20000, (cx) => cx.notify());
  }

  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const sp = spaces();
    const s = sp.find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const all = agents();
    const count = (st) => all.filter((a) => a.status === st).length;
    const now = new Date();
    const party = ["working", "blocked", "done", "idle"]
      .filter((st) => count(st) > 0)
      .map((st) =>
        h_flex()
          .gap(4)
          .items_center()
          .child(mark(st, 2))
          .child(div().text_size(12).text_color(C.text).child(`x${count(st)}`)),
      );
    return h_flex()
      .size_full()
      .pl(lights ? 84 : 14)
      .pr(14)
      .gap(18)
      .items_center()
      .bg(C.ink)
      .border_b(2)
      .border_color(C.shade)
      .child(
        h_flex()
          .flex_none()
          .gap(8)
          .items_center()
          .child(sprite("gem", 12, 9, 2))
          .child(div().text_size(14).font_bold().text_color(C.gold).child("HERDR QUEST")),
      )
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(8)
          .items_center()
          .justify_center()
          .text_size(12)
          .child(div().flex_none().text_color(C.dim).child(`STAGE ${s?.index ?? 0}-${tab?.index ?? 0}`))
          .child(div().min_w(0).truncate().text_color(C.text).child(s ? `${s.name}  /  ${tab?.name ?? ""}` : "")),
      )
      .child(h_flex().flex_none().gap(12).items_center().children(party))
      .child(
        h_flex()
          .flex_none()
          .gap(6)
          .items_center()
          .text_size(12)
          .child(div().text_color(C.dim).child("TIME"))
          .child(div().text_color(C.text).child(`${pad(now.getHours())}:${pad(now.getMinutes())}`)),
      );
  }
}
