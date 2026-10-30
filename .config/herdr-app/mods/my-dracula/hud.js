// 上のタイトルバー: こうもりのロゴ、space › tab のパンくず、サイドバーの開閉。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, window, run } from "herdr";
import { C, icon, button } from "./kit.js";

export default class Hud {
  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const s = spaces().find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    return h_flex()
      .size_full()
      .pl(lights ? 84 : 12)
      .pr(10)
      .gap(10)
      .items_center()
      .bg(C.darker)
      .border_b(2)
      .border_color(C.line)
      .child(svg_bat())
      .child(div().flex_none().text_size(13).font_bold().text_color(C.purple).child("herdr"))
      .child(div().flex_none().text_color(C.line).child("|"))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(6)
          .items_center()
          .text_size(12.5)
          .when(Boolean(s?.machine), (el) => el.child(icon("server", 12, C.comment)).child(div().flex_none().text_color(C.comment).child(s.machine)))
          .child(div().flex_none().max_w(300).truncate().font_bold().text_color(C.fg).child(s?.name ?? ""))
          .when(Boolean(s?.branch), (el) => el.child(icon("branch", 11, C.pink)).child(div().flex_none().max_w(220).truncate().text_color(C.pink).child(s.branch)))
          .child(div().flex_none().text_color(C.comment).child("›"))
          .child(div().min_w(0).truncate().text_color(C.muted).child(tab?.name ?? "")),
      )
      .child(button("dr-sidebar", "sidebar", () => run("layout.toggle", { id: "sidebar" }), { tip: "Toggle sidebar" }));
  }
}

function svg_bat() {
  return icon("bat", 18, C.purple).w(21).h(16);
}
