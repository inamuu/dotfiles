// ペインの見出し: 上に虹色の帯が流れ、プログラム名、状態の演出、右に分割・最大化・閉じる。

import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, RAINBOW, hue, pulse, button, short, statusIcon, statusWord } from "./kit.js";

// 横に流れる虹色の帯 (6 色を 2 周並べて左右に揺らす)
function stripe() {
  return div()
    .relative()
    .h(3)
    .w_full()
    .overflow_hidden()
    .child(
      h_flex()
        .absolute()
        .top(0)
        .h(3)
        .w("200%")
        .loop("left", { from: 0, to: -600, period: 2400, easing: "linear" })
        .children([...RAINBOW, ...RAINBOW].map((c) => div().h_full().flex_1().bg(c))),
    );
}

export default class Pane {
  init(_p, cx) {
    pulse(cx, 280);
  }

  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const st = p.status;
    return v_flex()
      .id(`dp-pane-${id}`)
      .size_full()
      .bg(C.chrome)
      .when(on, (el) => el.child(stripe()))
      .child(
        h_flex()
          .flex_1()
          .px(10)
          .gap(8)
          .items_center()
          .on_click(() => run("pane.focus", { pane: id }))
          .when(Boolean(st), (el) => el.child(statusIcon(st, 16)))
          .child(div().flex_none().max_w(260).truncate().text_size(13).font_bold().text_color(on ? hue() : C.text).child(name))
          .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(C.dim).child(short(p.cwd, home())))
          .when(Boolean(st) && st !== "idle", (el) => el.child(statusWord(st, 11)))
          .child(button(`dp-r-${id}`, "split-right", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right" }))
          .child(button(`dp-d-${id}`, "split-down", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down" }))
          .child(button(`dp-z-${id}`, p.zoomed ? "unzoom" : "zoom", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom" }))
          .child(button(`dp-x-${id}`, "close", () => run("pane.close", { pane: id }), { color: C.red, tip: "Close" })),
      );
  }
}
