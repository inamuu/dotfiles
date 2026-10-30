// エージェントの表: 状態、名前、space/tab、経過時間を 1 行に。待っているものを先頭に並べる。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, spaces, run, setAgentOrder } from "herdr";
import { C, mark, label, heading, ago } from "./kit.js";

const RANK = { blocked: 0, done: 1, working: 2, idle: 3 };

export default class Agents {
  init(_p, cx) {
    cx.timer.every(15000, (cx) => cx.notify());
  }

  render() {
    const all = [...agents()].sort((a, b) => (RANK[a.status] ?? 4) - (RANK[b.status] ?? 4));
    setAgentOrder(all.map((a) => a.address));
    const tabs = {};
    for (const s of spaces()) for (const t of s.tabs) tabs[t.id] = t;
    const now = Date.now();
    const rows = all.map((a) => {
      const t = tabs[a.tab];
      const since = a.status === "working" ? t?.working_since : t?.changed_at;
      return h_flex()
        .id(`tl-agent-${a.address}`)
        .h(25)
        .flex_none()
        .px(8)
        .gap(6)
        .items_center()
        .cursor_pointer()
        .when(a.focused, (el) => el.bg(C.pick))
        .when(!a.focused, (el) => el.hover((s) => s.bg(C.hover)))
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .child(mark(a.status))
        .child(div().flex_none().max_w(130).truncate().text_color(a.focused ? C.accent : C.text).child(a.program?.name ?? a.app ?? "agent"))
        .child(div().flex_1().min_w(0).truncate().text_color(C.dim).child(`${a.space_name}/${a.tab_name}`))
        .child(div().w(38).flex_none().child(label(a.status)))
        .child(div().w(32).flex_none().flex().justify_end().text_color(C.dim).child(since ? ago(now - since) : ""));
    });
    const empty = div().px(8).py(4).text_color(C.dim).child("no agents");
    return v_flex()
      .size_full()
      .bg(C.panel)
      .text_size(13.5)
      .child(heading(`agents ${all.length}`))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().pb(4).children(rows.length ? rows : [empty]));
  }
}
