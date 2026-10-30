// 下のステータスバー: いまのペインの場所とブランチ、エージェントの状態ごとの数、時計。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, panes, home } from "herdr";
import { C, STATUS, icon, statusIcon, hourglass, short, pad } from "./kit.js";

export default class Status {
  init(_p, cx) {
    hourglass(this, cx, () => agents().some((a) => a.status === "working"));
    cx.timer.every(30000, (cx) => cx.notify());
  }

  render() {
    const p = panes().find((x) => x.focused);
    const all = agents();
    const now = new Date();
    const counts = ["blocked", "working", "done"]
      .map((st) => [st, all.filter((a) => a.status === st).length])
      .filter(([, n]) => n > 0);
    return h_flex()
      .size_full()
      .px(10)
      .gap(14)
      .items_center()
      .bg(C.darker)
      .border_t(2)
      .border_color(C.line)
      .text_size(11.5)
      .child(h_flex().flex_none().h_full().px(8).items_center().bg(C.purple).text_color(C.bg).font_bold().child("NORMAL"))
      .when(Boolean(p?.cwd), (el) =>
        el.child(h_flex().min_w(0).gap(5).items_center().child(icon("folder", 11, C.comment)).child(div().min_w(0).truncate().text_color(C.muted).child(short(p.cwd, home())))),
      )
      .when(Boolean(p?.branch), (el) =>
        el.child(h_flex().flex_none().gap(5).items_center().child(icon("branch", 10, C.pink)).child(div().text_color(C.pink).child(p.branch))),
      )
      .child(div().flex_1())
      .children(
        counts.map(([st, n]) =>
          h_flex()
            .flex_none()
            .gap(4)
            .items_center()
            .child(statusIcon(st, 11, this.frame))
            .child(div().text_color(STATUS[st].color).child(`${n} ${STATUS[st].label}`)),
        ),
      )
      .child(div().flex_none().text_color(C.comment).child(`${pad(now.getHours())}:${pad(now.getMinutes())}`));
  }
}
