// ペインの見出し: いまのペインは金の ▶ と名前。右に分割・最大化・閉じる。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, WORD, glyph, mark, button, short } from "./kit.js";

export default class Pane {

  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const st = p.status;
    return h_flex()
      .id(`px-pane-${id}`)
      .size_full()
      .px(8)
      .gap(8)
      .items_center()
      .bg(on ? C.pick : C.night)
      .border_b(2)
      .border_color(C.shade)
      .on_click(() => run("pane.focus", { pane: id }))
      .child(div().w(8).flex_none().when(on, (el) => el.child(glyph("cursor", 8, C.text))))
      .when(Boolean(st), (el) => el.child(mark(st, 2)))
      .child(div().flex_none().max_w(240).truncate().text_size(12.5).font_bold().text_color(C.text).child(name))
      .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(C.dim).child(short(p.cwd, home())))
      .when(st === "blocked", (el) =>
        el.child(div().flex_none().text_size(11).font_bold().text_color(C.red).loop("opacity", { from: 0.3, to: 1, period: 700 }).child(WORD.blocked)),
      )
      .child(button(`px-r-${id}`, "split-right", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right" }))
      .child(button(`px-d-${id}`, "split-down", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down" }))
      .child(button(`px-z-${id}`, p.zoomed ? "unzoom" : "zoom", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom" }))
      .child(button(`px-x-${id}`, "close", () => run("pane.close", { pane: id }), { color: C.red, tip: "Close" }));
  }
}
