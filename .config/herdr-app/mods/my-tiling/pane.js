// ペインの細い見出し: 選んでいるペインは薄紫の名前と下線。名前、場所、ブランチ、状態。右に [|] [-] [z] [x]。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, mark, label, key, short } from "./kit.js";

export default class Pane {
  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const st = p.status;
    return h_flex()
      .id(`tl-pane-${id}`)
      .size_full()
      .px(6)
      .gap(8)
      .items_center()
      .bg(C.panel)
      .border_b(1)
      .border_color(on ? C.accent : C.line)
      .text_size(12.5)
      .on_click(() => run("pane.focus", { pane: id }))
      .child(div().flex_none().max_w(220).truncate().font_bold().text_color(on ? C.accent : C.muted).child(name))
      .child(div().min_w(0).truncate().text_color(C.dim).child(short(p.cwd, home())))
      .when(Boolean(p.branch), (el) => el.child(div().flex_none().max_w(180).truncate().text_color(C.purple).child(p.branch)))
      .child(div().flex_1())
      .when(Boolean(st), (el) => el.child(h_flex().flex_none().gap(3).items_center().child(mark(st)).child(label(st))))
      .child(
        h_flex()
          .flex_none()
          .child(key(`tl-r-${id}`, "|", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right" }))
          .child(key(`tl-d-${id}`, "-", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down" }))
          .child(key(`tl-z-${id}`, "z", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom", on: p.zoomed }))
          .child(key(`tl-x-${id}`, "x", () => run("pane.close", { pane: id }), { tip: "Close", color: C.red })),
      );
  }
}
