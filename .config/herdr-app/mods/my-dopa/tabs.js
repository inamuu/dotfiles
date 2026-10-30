// タブをネオンのピルで並べる。選択中はピンクで塗り、下に虹色の線が流れる。右端の + で新しいタブ。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, run } from "herdr";
import { C, hue, pulse, icon, statusIcon } from "./kit.js";

export default class Tabs {
  init(_p, cx) {
    pulse(cx);
  }

  render() {
    const s = spaces().find((x) => x.active);
    const tabs = (s?.tabs ?? []).filter((t) => !t.settled || t.active);
    const slot = (t, i) =>
      h_flex()
        .id(`dp-tab-${t.id}`)
        .relative()
        .h(32)
        .flex_none()
        .max_w(240)
        .px(14)
        .gap(8)
        .items_center()
        .rounded(999)
        .border(2)
        .border_color(t.active ? hue(i) : C.line)
        .bg(t.active ? C.pink : C.card)
        .cursor_pointer()
        .when(!t.active, (el) => el.hover((st) => st.bg(C.hover)))
        .on_click(() => run("tab.select", { id: t.id }))
        .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
        .child(div().flex_none().text_size(11).font_bold().text_color(t.active ? C.text : C.dim).child(String(t.index)))
        .child(div().min_w(0).truncate().text_size(13).font_bold().text_color(C.text).child(t.name))
        .when(Boolean(t.status) && t.status !== "idle", (el) => el.child(statusIcon(t.status, 14)))
        .when(t.active, (el) => el.child(icon("sparkle", 12, C.text).spin(800)));
    const add = div()
      .id("dp-tab-new")
      .size(32)
      .flex_none()
      .flex()
      .items_center()
      .justify_center()
      .rounded(999)
      .border(2)
      .border_color(hue(2))
      .bg(C.card)
      .cursor_pointer()
      .hover((st) => st.bg(C.hover))
      .on_click(() => run("tab.new"))
      .child(icon("plus", 14, hue(2)).spin(2400));
    return h_flex()
      .size_full()
      .gap(8)
      .items_center()
      .overflow_x_hidden()
      .children([...tabs.map(slot), add]);
  }
}
