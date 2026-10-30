// 下のバー (tmux のステータス行風)。
//   左   薄紫の space 名、タブ「1:name* 2:name」(クリックで移動、中クリックで閉じる、[+] で新規)
//   右   エージェントの状態ごとの数、いまのペインの場所とブランチ、時計、[s] サイドバー [f] Files [c] Changes

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, panes, run, layout, home } from "herdr";
import { C, STATUS, mark, key, short, pad } from "./kit.js";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class Bar {
  init(_p, cx) {
    cx.timer.every(30000, (cx) => cx.notify());
  }

  // パネルを開いてその中身にする。同じ中身が開いていれば閉じる。
  panel(child) {
    const tree = layout();
    const panel = find(tree, "panel");
    const shown = panel && !panel.hidden;
    if (shown && find(tree, "panel-body")?.active === child) {
      run("layout.hide", { id: "panel" });
      return;
    }
    run("layout.select", { stack: "panel-body", child });
    run("layout.show", { id: "panel" });
  }

  render() {
    const s = spaces().find((x) => x.active);
    const tabs = (s?.tabs ?? []).filter((t) => !t.settled || t.active);
    const p = panes().find((x) => x.focused);
    const all = agents();
    const tree = layout();
    const sidebar = find(tree, "sidebar");
    const panel = find(tree, "panel");
    const open = panel && !panel.hidden ? find(tree, "panel-body")?.active : null;
    const counts = ["blocked", "done", "working"].map((st) => [st, all.filter((a) => a.status === st).length]).filter(([, n]) => n > 0);
    const now = new Date();
    const tab = (t) =>
      h_flex()
        .id(`tl-bar-${t.id}`)
        .flex_none()
        .h_full()
        .px(6)
        .gap(3)
        .items_center()
        .when(t.active, (el) => el.bg(C.pick))
        .hover((st) => st.bg(C.hover))
        .cursor_pointer()
        .on_click(() => run("tab.select", { id: t.id }))
        .on_mouse_down("middle", () => run("tab.close", { id: t.id }))
        .child(div().text_color(t.active ? C.accent : C.dim).child(`${t.index}:`))
        .child(div().max_w(160).truncate().text_color(t.active ? C.text : C.muted).child(t.name))
        .when(t.active, (el) => el.child(div().text_color(C.accent).child("*")))
        .when(Boolean(t.status) && t.status !== "idle", (el) => el.child(mark(t.status)));
    return h_flex()
      .size_full()
      .pr(4)
      .gap(10)
      .items_center()
      .bg(C.bg)
      .border_t(1)
      .border_color(C.line)
      .text_size(12.5)
      .child(div().flex_none().h_full().px(8).flex().items_center().bg(C.accent).text_color(C.bg).font_bold().max_w(200).truncate().child(s?.name ?? "herdr"))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .h_full()
          .overflow_x_hidden()
          .children(tabs.map(tab))
          .child(h_flex().h_full().items_center().child(key("tl-bar-new", "+", () => run("tab.new"), { tip: "New tab" }))),
      )
      .children(
        counts.map(([st, n]) => h_flex().flex_none().gap(2).items_center().child(mark(st)).child(div().text_color(STATUS[st].color).child(String(n)))),
      )
      .when(Boolean(p?.cwd), (el) => el.child(div().flex_none().max_w(300).truncate().text_color(C.muted).child(short(p.cwd, home()))))
      .when(Boolean(p?.branch), (el) => el.child(div().flex_none().max_w(200).truncate().text_color(C.purple).child(p.branch)))
      .child(div().flex_none().text_color(C.text).child(`${pad(now.getHours())}:${pad(now.getMinutes())}`))
      .child(
        h_flex()
          .flex_none()
          .child(key("tl-sidebar", "s", () => run("layout.toggle", { id: "sidebar" }), { tip: "Toggle sidebar", on: Boolean(sidebar && !sidebar.hidden) }))
          .child(key("tl-files", "f", () => this.panel("files"), { tip: "Files", on: open === "files" }))
          .child(key("tl-changes", "c", () => this.panel("changes"), { tip: "Changes", on: open === "changes" })),
      );
  }
}
