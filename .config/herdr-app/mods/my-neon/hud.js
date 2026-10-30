// 上のタイトルバー: 目のロゴとずれる「HERDR//」、space › tab、サイドバーの開閉。下にマゼンタとシアンの線、上に走査線。

import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { spaces, window, run } from "herdr";
import { C, icon, glitch, scanlines, button } from "./kit.js";

export default class Hud {
  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const s = spaces().find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const bar = h_flex()
      .flex_1()
      .pl(lights ? 84 : 12)
      .pr(10)
      .gap(10)
      .items_center()
      .child(icon("eye", 16, C.cyan).w(20).h(10).loop("opacity", { from: 0.6, to: 1, period: 1800 }))
      .child(glitch("HERDR//", { size: 13.5 }))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(6)
          .items_center()
          .text_size(12.5)
          .when(Boolean(s?.machine), (el) => el.child(icon("server", 12, C.violet)).child(div().flex_none().text_color(C.violet).child(s.machine)))
          .child(div().flex_none().max_w(300).truncate().font_bold().text_color(C.text).child(s?.name ?? ""))
          .when(Boolean(s?.branch), (el) => el.child(icon("branch", 11, C.magenta)).child(div().flex_none().max_w(220).truncate().text_color(C.magenta).child(s.branch)))
          .child(div().flex_none().text_color(C.yellow).child("//"))
          .child(div().min_w(0).truncate().text_color(C.muted).child(tab?.name ?? "")),
      )
      .child(button("ne-sidebar", "sidebar", () => run("layout.toggle", { id: "sidebar" }), { tip: "Toggle sidebar" }));
    return v_flex()
      .relative()
      .size_full()
      .overflow_hidden()
      .bg(C.bg)
      .child(bar)
      .child(h_flex().h(2).flex_none().child(div().w(120).h_full().bg(C.yellow)).child(div().w(40).h_full().bg(C.magenta)).child(div().flex_1().h_full().bg(C.cyan).opacity(0.35)))
      .child(scanlines());
  }
}
