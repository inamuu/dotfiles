// タブを [1:name] のように並べる。選択中は反転表示。右端の [+] で新しいタブ。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, run } from "herdr";
import { C, key, stat } from "./kit.js";

export default class Tabs {
  render() {
    const s = spaces().find((x) => x.active);
    const tabs = (s?.tabs ?? []).filter((t) => !t.settled || t.active);
    const slot = (t) =>
      h_flex()
        .id(`hk-tab-${t.id}`)
        .h(24)
        .flex_none()
        .max_w(260)
        .px(6)
        .gap(6)
        .items_center()
        .text_size(12)
        .font_bold()
        .border(1)
        .border_color(t.active ? C.green : C.line)
        .bg(t.active ? C.green : C.bg)
        .cursor_pointer()
        .when(!t.active, (el) => el.hover((st) => st.bg(C.hover)))
        .on_click(() => run("tab.select", { id: t.id }))
        .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
        .child(div().min_w(0).truncate().text_color(t.active ? C.bg : C.muted).child(`[${t.index}:${t.name}]`))
        .when(Boolean(t.status) && t.status !== "idle" && !t.active, (el) => el.child(stat(t.status, 10.5)));
    return h_flex()
      .size_full()
      .gap(6)
      .items_center()
      .overflow_x_hidden()
      .child(div().flex_none().text_size(12).text_color(C.dim).child("tmux>"))
      .children(tabs.map(slot))
      .child(key("hk-tab-new", "[+]", () => run("tab.new"), { color: C.green, tip: "New tab" }));
  }
}
