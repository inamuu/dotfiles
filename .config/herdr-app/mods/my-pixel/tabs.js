// タブをアイテム欄のように並べる。選択中は白い枠と ▶。右端の + で新しいタブ。

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
        .id(`px-tab-${t.id}`)
        .h(30)
        .flex_none()
        .max_w(220)
        .px(8)
        .gap(6)
        .items_center()
        .border(3)
        .border_color(t.active ? C.line : C.shade)
        .rounded(6)
        .bg(C.panel)
        .cursor_pointer()
        .when(!t.active, (el) => el.hover((st) => st.bg(C.hover)))
        .on_click(() => run("tab.select", { id: t.id }))
        .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
        .child(div().w(8).flex_none().when(t.active, (el) => el.child(glyph("cursor", 8, C.text))))
        .child(div().flex_none().text_size(11).text_color(C.dim).child(String(t.index)))
        .child(div().min_w(0).truncate().text_size(12.5).text_color(t.active ? C.text : C.muted).child(t.name))
        .when(Boolean(t.status) && t.status !== "idle", (el) => el.child(mark(t.status, 2)));
    const add = div()
      .id("px-tab-new")
      .size(30)
      .flex_none()
      .flex()
      .items_center()
      .justify_center()
      .border(3)
      .border_color(C.shade)
      .rounded(6)
      .bg(C.panel)
      .cursor_pointer()
      .hover((st) => st.bg(C.hover).border_color(C.line))
      .on_click(() => run("tab.new"))
      .child(glyph("plus", 10, C.muted));
    return h_flex()
      .size_full()
      .gap(6)
      .items_center()
      .overflow_x_hidden()
      .children([...tabs.map(slot), add]);
  }
}
