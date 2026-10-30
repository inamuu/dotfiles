// 上のメニューバー: 白地に黒い下線。羊のロゴ、space › tab、右にエージェントの状態ごとの数と時計、サイドバーの開閉。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, window, run } from "herdr";
import { C, STATUS, icon, statusIcon, tick, button, pad } from "./kit.js";

export default class Menubar {
  init(_p, cx) {
    tick(this, cx, () => agents().some((a) => a.status === "working"));
    cx.timer.every(30000, (cx) => cx.notify());
  }

  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const s = spaces().find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const all = agents();
    const counts = ["blocked", "working", "done"].map((st) => [st, all.filter((a) => a.status === st).length]).filter(([, n]) => n > 0);
    const now = new Date();
    return h_flex()
      .size_full()
      .pl(lights ? 80 : 10)
      .pr(8)
      .gap(14)
      .items_center()
      .bg(C.paper)
      .border_b(1)
      .border_color(C.ink)
      .text_size(12.5)
      .child(icon("sheep", 14, C.ink))
      .child(div().flex_none().font_bold().text_color(C.text).child("herdr"))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(6)
          .items_center()
          .when(Boolean(s?.machine), (el) => el.child(icon("computer", 12, C.dim)).child(div().flex_none().text_color(C.dim).child(s.machine)))
          .child(div().flex_none().max_w(300).truncate().font_bold().text_color(C.text).child(s?.name ?? ""))
          .when(Boolean(s?.branch), (el) => el.child(icon("branch", 11, C.purple)).child(div().flex_none().max_w(220).truncate().text_color(C.purple).child(s.branch)))
          .child(div().flex_none().text_color(C.dim).child("›"))
          .child(div().min_w(0).truncate().text_color(C.muted).child(tab?.name ?? "")),
      )
      .children(
        counts.map(([st, n]) =>
          h_flex().flex_none().gap(4).items_center().child(statusIcon(st, 12, this.frame)).child(div().text_size(11.5).text_color(STATUS[st].color).child(`${n} ${STATUS[st].label}`)),
        ),
      )
      .child(div().flex_none().font_bold().text_color(C.text).child(`${pad(now.getHours())}:${pad(now.getMinutes())}`))
      .child(button("pt-sidebar", "sidebar", () => run("layout.toggle", { id: "sidebar" }), { tip: "Toggle sidebar", size: 18 }));
  }
}
