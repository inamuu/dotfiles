// 下のログ: エージェントの状態が変わるたびに 1 行足し、最新の行を 1 文字ずつ打つ。
// 左に直前の 2 行を暗く、右にいまのブランチ。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, panes } from "herdr";
import { C, typing, caret, pad } from "./kit.js";

const stamp = (d) => `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;

export default class Log {
  init(_p, cx) {
    this.seen = {};
    this.lines = [`[${stamp(new Date())}] herdr: session attached. all systems nominal.`];
    cx.timer.every(1000, (cx) => {
      if (this.watch()) cx.notify();
    });
    this.watch();
  }

  // 状態の変化をログにする。変わったら true。
  watch() {
    let changed = false;
    for (const a of agents()) {
      const before = this.seen[a.address];
      if (before && before !== a.status) {
        const name = (a.program?.key ?? a.app ?? "agent").toLowerCase();
        this.lines.push(`[${stamp(new Date())}] ${a.address} ${name}@${a.space_name}: ${before} -> ${a.status}`);
        changed = true;
      }
      this.seen[a.address] = a.status;
    }
    if (this.lines.length > 20) this.lines = this.lines.slice(-20);
    return changed;
  }

  render() {
    const last = this.lines[this.lines.length - 1];
    const prev = this.lines.slice(-3, -1);
    const branch = panes().find((p) => p.focused)?.branch;
    return h_flex()
      .size_full()
      .px(12)
      .gap(14)
      .items_center()
      .bg(C.bg)
      .border_t(1)
      .border_color(C.line)
      .text_size(11.5)
      .child(div().flex_none().font_bold().text_color(C.bg).bg(C.green).px(4).child("LOG"))
      .children(prev.map((l) => div().flex_none().max_w(420).truncate().text_color(C.faint).child(l)))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(2)
          .items_center()
          // 行が変わったら id も変わるので、打ち込みが最初からやり直しになる
          .child(div().id(`hk-log-${this.lines.length}`).min_w(0).truncate().text_color(C.text).frames(typing(last), 28))
          .child(caret(11)),
      )
      .when(Boolean(branch), (el) => el.child(div().flex_none().text_color(C.dim).child(`git:(${branch})`)));
  }
}
