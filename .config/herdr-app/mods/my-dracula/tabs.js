// タブの列: 番号、名前、状態。選択中は下に紫の線。中クリックで閉じる。
// 右端に Files / Changes パネルの切り替え。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, run, layout } from "herdr";
import { C, statusIcon, hourglass, button } from "./kit.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class Tabs {
  init(_p, cx) {
    hourglass(this, cx, () => (spaces().find((s) => s.active)?.tabs ?? []).some((t) => t.status === "working"));
  }

  // パネルを開いてその中身にする。同じ中身が開いていれば閉じる。
  panel(child) {
    const tree = layout();
    const panel = find(tree, "panel");
    const shown = panel && !panel.hidden;
    const current = find(tree, "panel-body")?.active;
    if (shown && current === child) {
      run("layout.hide", { id: "panel" });
      return;
    }
    run("layout.select", { stack: "panel-body", child });
    run("layout.show", { id: "panel" });
  }

  render() {
    const s = spaces().find((x) => x.active);
    const tabs = (s?.tabs ?? []).filter((t) => !t.settled || t.active);
    const tree = layout();
    const panel = find(tree, "panel");
    const open = panel && !panel.hidden ? find(tree, "panel-body")?.active : null;
    const slot = (t) =>
      h_flex()
        .id(`dr-tab-${t.id}`)
        .h_full()
        .flex_none()
        .max_w(240)
        .px(12)
        .gap(7)
        .items_center()
        .border_b(2)
        .border_color(t.active ? C.purple : "#00000000")
        .bg(t.active ? C.bg : C.dark)
        .cursor_pointer()
        .when(!t.active, (el) => el.hover((st) => st.bg(C.hover)))
        .on_click(() => run("tab.select", { id: t.id }))
        .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
        .child(div().flex_none().text_size(11).text_color(t.active ? C.purple : C.comment).child(String(t.index)))
        .child(div().min_w(0).truncate().text_size(12.5).text_color(t.active ? C.fg : C.muted).child(t.name))
        .when(t.panes > 1, (el) => el.child(div().flex_none().text_size(10.5).text_color(C.comment).child(`×${t.panes}`)))
        .when(Boolean(t.status) && t.status !== "idle", (el) => el.child(statusIcon(t.status, 11, this.frame)));
    return h_flex()
      .size_full()
      .bg(C.dark)
      .border_b(2)
      .border_color(C.line)
      .child(h_flex().flex_1().min_w(0).h_full().gap(2).overflow_x_hidden().children(tabs.map(slot)).child(
        h_flex().h_full().px(4).items_center().child(button("dr-tab-new", "plus", () => run("tab.new"), { tip: "New tab" })),
      ))
      .child(
        h_flex()
          .flex_none()
          .h_full()
          .px(6)
          .gap(2)
          .items_center()
          .child(button("dr-files", "doc", () => this.panel("files"), { tip: "Files", on: open === "files" }))
          .child(button("dr-changes", "diff", () => this.panel("changes"), { tip: "Changes", on: open === "changes" })),
      );
  }
}
