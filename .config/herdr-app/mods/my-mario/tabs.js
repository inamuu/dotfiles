// タブをレンガのように並べる。選択中は ? ブロックの色。右端の + で新しいタブ。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, run } from "herdr";
import { C, glyph, mark } from "./kit.js";

export default class Tabs {
  render() {
    const s = spaces().find((x) => x.active);
    const tabs = (s?.tabs ?? []).filter((t) => !t.settled || t.active);
    const slot = (t) =>
      h_flex()
        .id(`mr-tab-${t.id}`)
        .h(30)
        .flex_none()
        .max_w(220)
        .px(8)
        .gap(6)
        .items_center()
        .border(2)
        .border_color(C.ink)
        .bg(t.active ? C.gold : C.brick)
        .cursor_pointer()
        .when(!t.active, (el) => el.hover((st) => st.bg("#e45c10")))
        .on_click(() => run("tab.select", { id: t.id }))
        .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
        .child(div().flex_none().text_size(11).font_bold().text_color(t.active ? C.brick : C.light).child(String(t.index)))
        .child(div().min_w(0).truncate().text_size(12.5).font_bold().text_color(t.active ? C.ink : C.text).child(t.name))
        .when(Boolean(t.status) && t.status !== "idle", (el) => el.child(mark(t.status, 1)));
    const add = div()
      .id("mr-tab-new")
      .size(30)
      .flex_none()
      .flex()
      .items_center()
      .justify_center()
      .border(2)
      .border_color(C.ink)
      .bg(C.brick)
      .cursor_pointer()
      .hover((st) => st.bg("#e45c10"))
      .on_click(() => run("tab.new"))
      .child(glyph("plus", 10, C.text));
    return h_flex()
      .size_full()
      .gap(4)
      .items_center()
      .overflow_x_hidden()
      .children([...tabs.map(slot), add]);
  }
}
