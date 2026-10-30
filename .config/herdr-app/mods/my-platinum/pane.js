// ペインのタイトルバー: 選んでいるペインはしまと閉じる箱、後ろのペインは無地で灰色の文字。
// 名前、場所、ブランチ、状態。右に分割・最大化。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home } from "herdr";
import { C, STATUS, icon, statusIcon, tick, titlebar, button, short } from "./kit.js";

export default class Pane {
  init(_p, cx) {
    tick(this, cx, () => panes().find((p) => p.pane === props()?.pane)?.status === "working");
  }

  render() {
    const id = props()?.pane;
    const p = panes().find((x) => x.pane === id);
    if (!p) return div();
    const on = p.focused;
    const name = ((p.program?.agent || p.program?.shell) && p.program.name) || p.title || p.program?.name || "shell";
    const st = p.status;
    const title = h_flex()
      .min_w(0)
      .gap(6)
      .items_center()
      .child(icon(p.program?.agent ? "sheep" : "terminal", 12, on ? C.ink : C.dim))
      .child(div().flex_none().max_w(200).truncate().child(name))
      .child(div().min_w(0).max_w(260).truncate().font_weight(400).text_size(11.5).text_color(on ? C.muted : C.dim).child(short(p.cwd, home())))
      .when(Boolean(p.branch), (el) =>
        el.child(h_flex().flex_none().gap(3).items_center().child(icon("branch", 10, on ? C.purple : C.dim)).child(div().max_w(160).truncate().font_weight(400).text_size(11.5).text_color(on ? C.purple : C.dim).child(p.branch))),
      )
      .when(Boolean(st), (el) => el.child(statusIcon(st, 12, this.frame)).child(div().font_weight(400).text_size(11).text_color((STATUS[st] ?? STATUS.idle).color).child((STATUS[st] ?? STATUS.idle).label)));
    const right = [
      button(`pt-r-${id}`, "split-right", () => run("pane.split", { direction: "right", pane: id }), { tip: "Split right", size: 16 }),
      button(`pt-d-${id}`, "split-down", () => run("pane.split", { direction: "down", pane: id }), { tip: "Split down", size: 16 }),
      button(`pt-z-${id}`, p.zoomed ? "unzoom" : "zoom", () => run("pane.zoom", { pane: id }), { tip: p.zoomed ? "Restore" : "Zoom", on: p.zoomed, size: 16 }),
    ];
    return div()
      .id(`pt-pane-${id}`)
      .size_full()
      .on_click(() => run("pane.focus", { pane: id }))
      .child(titlebar(`pt-pt-${id}`, title, { active: on, onClose: () => run("pane.close", { pane: id }), right, h: 22 }));
  }
}
