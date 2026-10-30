// space とタブの木。
//   space   色の付いた ▸ / ▾、名前、ブランチ、タブ数、いちばん急ぐ状態。クリックで移動、右クリックでメニュー。
//   タブ    いまの space だけ開いて ├ / └ でつなぐ。番号、名前、ペイン数、状態。クリックでそのタブへ、中クリックで閉じる。
//   見出しの [+] で新しい space。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, run, openOverlay } from "herdr";
import { C, mark, spaceColor, heading, key } from "./kit.js";

function line(id, on) {
  return h_flex()
    .id(id)
    .h(25)
    .flex_none()
    .px(8)
    .gap(6)
    .items_center()
    .cursor_pointer()
    .when(on, (el) => el.bg(C.pick))
    .when(!on, (el) => el.hover((s) => s.bg(C.hover)));
}

export default class Tree {
  render() {
    const rows = [];
    for (const s of spaces()) {
      rows.push(
        line(`tl-space-${s.id}`, false)
          .on_click(() => run("space.select", { id: s.id }))
          .on_mouse_down("right", () =>
            openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
          )
          .child(div().flex_none().text_color(spaceColor(s.id)).child(s.active ? "▾" : "▸"))
          .child(div().flex_none().max_w(160).truncate().font_bold().text_color(s.active ? C.text : C.muted).child(s.machine ? `${s.machine}:${s.name}` : s.name))
          .when(Boolean(s.branch), (el) => el.child(div().min_w(0).truncate().text_color(C.purple).child(s.branch)))
          .child(div().flex_1())
          .when(!s.active, (el) => el.child(div().flex_none().text_color(C.dim).child(String(s.tabs.length))))
          .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(mark(s.status))),
      );
      if (!s.active) continue;
      s.tabs.forEach((t, i) => {
        rows.push(
          line(`tl-tab-${t.id}`, t.active)
            .on_click(() => run("tab.select", { id: t.id }))
            .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
            .child(div().flex_none().text_color(C.line).child(i === s.tabs.length - 1 ? "└" : "├"))
            .child(div().flex_none().text_color(t.active ? C.accent : C.dim).child(String(t.index)))
            .child(div().min_w(0).truncate().text_color(t.active ? C.text : C.muted).child(t.name))
            .when(t.panes > 1, (el) => el.child(div().flex_none().text_color(C.dim).child(`×${t.panes}`)))
            .child(div().flex_1())
            .when(Boolean(t.status) && t.status !== "idle", (el) => el.child(mark(t.status))),
        );
      });
    }
    return v_flex()
      .size_full()
      .bg(C.panel)
      .text_size(13.5)
      .child(heading("spaces", h_flex().gap(2).child(key("tl-tab-new", "t", () => run("tab.new"), { tip: "New tab" })).child(key("tl-space-new", "+", () => run("space.new"), { tip: "New space" }))))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().pb(4).children(rows));
  }
}
