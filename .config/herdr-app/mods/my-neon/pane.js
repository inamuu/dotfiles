// ペインの見出し: 選んでいるペインは左に黄色の帯。アイコンと名前、場所、ブランチ、状態。右に分割・最大化・閉じる。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, icon, statusIcon, statusWord, pulse, button, short } from "./kit.js";

export default class Pane {
  init(_p, cx) {
    pulse(this, cx, () => panes().find((p) => p.pane === props()?.pane)?.status === "working");
  }

  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const st = p.status;
    return h_flex()
      .id(`ne-pane-${id}`)
      .size_full()
      .pr(4)
      .gap(8)
      .items_center()
      .bg(on ? C.raise : C.panel)
      .border_b(1)
      .border_color(on ? C.cyan : C.line)
      .on_click(() => run("pane.focus", { pane: id }))
      .child(div().w(4).h_full().flex_none().bg(on ? C.yellow : C.line))
      .child(icon(p.program?.agent ? "chip" : "terminal", 12, on ? C.cyan : C.dim))
      .child(div().flex_none().max_w(220).truncate().text_size(12.5).font_bold().text_color(on ? C.text : C.muted).child(name))
      .child(div().min_w(0).truncate().text_size(11.5).text_color(C.dim).child(short(p.cwd, home())))
      .when(Boolean(p.branch), (el) =>
        el.child(h_flex().flex_none().gap(4).items_center().child(icon("branch", 10, C.magenta)).child(div().max_w(180).truncate().text_size(11.5).text_color(C.magenta).child(p.branch))),
      )
      .child(div().flex_1())
      .when(Boolean(st), (el) => el.child(h_flex().flex_none().gap(5).items_center().child(statusIcon(st, 12, this.frame)).child(statusWord(st))))
      .child(button(`ne-r-${id}`, "split-right", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right" }))
      .child(button(`ne-d-${id}`, "split-down", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down" }))
      .child(button(`ne-z-${id}`, p.zoomed ? "unzoom" : "zoom", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom", on: p.zoomed }))
      .child(button(`ne-x-${id}`, "close", () => run("pane.close", { pane: id }), { color: C.magenta, tip: "Close" }));
  }
}
