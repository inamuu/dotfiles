// 上のタイトルバー: 青緑のしまが流れる上に細長いウィンドウ。流れ星のロゴ、space › tab、サイドバーの開閉。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, window, run } from "herdr";
import { C, icon, sprite, button, scene } from "./kit.js";

export default class Hud {
  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const s = spaces().find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const bar = h_flex()
      .size_full()
      .px(10)
      .gap(10)
      .items_center()
      .border(2)
      .border_color(C.edge)
      .rounded(6)
      .bg(C.win)
      .child(sprite("logo", 16, 12, 1.5))
      .child(div().flex_none().text_size(13).font_bold().text_color(C.yellow).child("herdr"))
      .child(div().flex_none().text_color(C.inner).child("◆"))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(6)
          .items_center()
          .text_size(12.5)
          .when(Boolean(s?.machine), (el) => el.child(icon("ufo", 12, C.dim)).child(div().flex_none().text_color(C.dim).child(s.machine)))
          .child(div().flex_none().max_w(300).truncate().font_bold().text_color(C.text).child(s?.name ?? ""))
          .when(Boolean(s?.branch), (el) => el.child(icon("branch", 11, C.pink)).child(div().flex_none().max_w(220).truncate().text_color(C.pink).child(s.branch)))
          .child(div().flex_none().text_color(C.dim).child("›"))
          .child(div().min_w(0).truncate().text_color(C.muted).child(tab?.name ?? "")),
      )
      .child(button("mo-sidebar", "sidebar", () => run("layout.toggle", { id: "sidebar" }), { tip: "Toggle sidebar", size: 20 }));
    return scene(1, 0, div().size_full().pl(lights ? 80 : 6).pr(6).py(4).child(bar), { cols: 64, rows: 2, period: 8000 });
  }
}
