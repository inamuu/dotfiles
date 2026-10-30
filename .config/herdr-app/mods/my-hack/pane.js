// ペインの見出し: ">> name :: ~/path" と点滅カーソル、右に [|] [-] [□] [x] の文字ボタン。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, key, stat, caret, short, LABEL } from "./kit.js";

export default class Pane {
  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = (p.program?.key ?? p.title ?? "sh").toLowerCase();
    const st = p.status;
    return h_flex()
      .id(`hk-pane-${id}`)
      .size_full()
      .px(8)
      .gap(8)
      .items_center()
      .text_size(12)
      .bg(on ? "#001a08" : C.bg)
      .border_b(1)
      .border_color(on ? C.green : C.line)
      .on_click(() => run("pane.focus", { pane: id }))
      .child(div().flex_none().font_bold().text_color(on ? C.green : C.dim).child(">>"))
      .child(div().flex_none().max_w(200).truncate().font_bold().text_color(on ? C.green : C.muted).child(name))
      .child(div().flex_none().text_color(C.dim).child("::"))
      .child(div().min_w(0).truncate().text_color(C.dim).child(short(p.cwd, home()) || "/"))
      .when(on, (el) => el.child(caret(11)))
      .child(div().flex_1())
      .when(Boolean(st), (el) => el.child(stat(st, 11)).child(div().flex_none().text_size(11).text_color(C.dim).child(LABEL[st] ?? "")))
      .child(key(`hk-r-${id}`, "[|]", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right" }))
      .child(key(`hk-d-${id}`, "[-]", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down" }))
      .child(key(`hk-z-${id}`, p.zoomed ? "[=]" : "[#]", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom" }))
      .child(key(`hk-x-${id}`, "[x]", () => run("pane.close", { pane: id }), { color: C.red, tip: "Kill" }));
  }
}
