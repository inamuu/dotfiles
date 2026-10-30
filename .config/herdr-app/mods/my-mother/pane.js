// ペインの見出し: 手のカーソル (選択中)、プログラム名、場所、ブランチ、状態。右に分割・最大化・閉じる。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, icon, statusIcon, statusWord, spin, button, cursor, short } from "./kit.js";

export default class Pane {
  init(_p, cx) {
    spin(this, cx, () => panes().find((p) => p.pane === props()?.pane)?.status === "working");
  }

  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const st = p.status;
    return h_flex()
      .id(`mo-pane-${id}`)
      .size_full()
      .pl(8)
      .pr(4)
      .gap(7)
      .items_center()
      .bg(on ? C.pick : C.win)
      .border_b(2)
      .border_color(C.inner)
      .on_click(() => run("pane.focus", { pane: id }))
      .child(cursor(on, 11))
      .child(icon(p.program?.agent ? "star" : "terminal", 12, on ? C.yellow : C.dim))
      .child(div().flex_none().max_w(220).truncate().text_size(12.5).font_bold().text_color(on ? C.text : C.muted).child(name))
      .child(div().min_w(0).truncate().text_size(11.5).text_color(C.dim).child(short(p.cwd, home())))
      .when(Boolean(p.branch), (el) =>
        el.child(h_flex().flex_none().gap(4).items_center().child(icon("branch", 10, C.pink)).child(div().max_w(180).truncate().text_size(11.5).text_color(C.pink).child(p.branch))),
      )
      .child(div().flex_1())
      .when(Boolean(st), (el) => el.child(h_flex().flex_none().gap(5).items_center().child(statusIcon(st, 12, this.frame)).child(statusWord(st))))
      .child(button(`mo-r-${id}`, "split-right", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right", size: 20 }))
      .child(button(`mo-d-${id}`, "split-down", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down", size: 20 }))
      .child(button(`mo-z-${id}`, p.zoomed ? "unzoom" : "zoom", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom", on: p.zoomed, size: 20 }))
      .child(button(`mo-x-${id}`, "close", () => run("pane.close", { pane: id }), { color: C.red, tip: "Close", size: 20 }));
  }
}
