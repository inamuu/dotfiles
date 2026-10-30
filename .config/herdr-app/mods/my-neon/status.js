// 下のステータスバー: 黄色の「ONLINE」、いまのペインの場所とブランチ、エージェントの状態ごとの数 (目盛り付き)、時計。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, panes, home } from "herdr";
import { C, STATUS, icon, statusIcon, pulse, short, pad } from "./kit.js";

// n 個の目盛り (最大 8)
function ticks(n, color) {
  return h_flex().flex_none().gap(1).children(Array.from({ length: Math.min(n, 8) }, () => div().w(3).h(9).bg(color)));
}

export default class Status {
  init(_p, cx) {
    pulse(this, cx, () => agents().some((a) => a.status === "working"));
    cx.timer.every(30000, (cx) => cx.notify());
  }

  render() {
    const p = panes().find((x) => x.focused);
    const all = agents();
    const now = new Date();
    const counts = ["blocked", "working", "done"].map((st) => [st, all.filter((a) => a.status === st).length]).filter(([, n]) => n > 0);
    return h_flex()
      .size_full()
      .pr(10)
      .gap(14)
      .items_center()
      .bg(C.bg)
      .border_t(1)
      .border_color(C.line)
      .text_size(11.5)
      .child(h_flex().flex_none().h_full().pl(8).pr(4).items_center().bg(C.yellow).text_color(C.bg).font_bold().child("ONLINE"))
      .child(icon("slant", 12, C.yellow).h_full().w(8).ml(-14))
      .when(Boolean(p?.cwd), (el) =>
        el.child(h_flex().min_w(0).gap(5).items_center().child(div().flex_none().text_color(C.cyan).child(">")).child(div().min_w(0).truncate().text_color(C.muted).child(short(p.cwd, home())))),
      )
      .when(Boolean(p?.branch), (el) => el.child(h_flex().flex_none().gap(5).items_center().child(icon("branch", 10, C.magenta)).child(div().text_color(C.magenta).child(p.branch))))
      .child(div().flex_1())
      .children(
        counts.map(([st, n]) =>
          h_flex()
            .flex_none()
            .gap(5)
            .items_center()
            .child(statusIcon(st, 11, this.frame))
            .child(div().text_color(STATUS[st].color).font_bold().child(`${STATUS[st].word} ${n}`))
            .child(ticks(n, STATUS[st].color)),
        ),
      )
      .child(div().flex_none().font_bold().text_color(C.cyan).child(`${pad(now.getHours())}:${pad(now.getMinutes())}`));
  }
}
