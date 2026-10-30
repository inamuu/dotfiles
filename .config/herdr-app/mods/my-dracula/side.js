// 左の 2 つの一覧。
//   Spaces  フォルダのアイコン (色は space ごと)、名前、ブランチ、タブ数、いちばん急ぐ状態。
//           クリックで移動、右クリックでメニュー、見出しの + で新しい space。
//   Agents  状態、プログラム名、space / tab、その状態になってからの時間。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, STATUS, icon, statusIcon, hourglass, spaceColor, heading, button, ago } from "./kit.js";

function row(id, on) {
  return h_flex()
    .id(id)
    .flex_none()
    .pr(8)
    .gap(8)
    .items_center()
    .border_l(3)
    .border_color(on ? C.purple : "#00000000")
    .pl(7)
    .cursor_pointer()
    .when(on, (el) => el.bg(C.line))
    .when(!on, (el) => el.hover((s) => s.bg(C.hover)));
}

export class Spaces {
  init(_p, cx) {
    hourglass(this, cx, () => spaces().some((s) => s.status === "working"));
  }

  render() {
    const sp = spaces();
    const list = sp.map((s) =>
      row(`dr-space-${s.id}`, s.active)
        .h(s.branch ? 40 : 28)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(icon(s.machine ? "server" : s.active ? "folder-open" : "folder", 14, spaceColor(s.id)))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().text_size(13).font_bold().text_color(s.active ? C.fg : C.muted).child(s.name))
            .when(Boolean(s.branch), (el) =>
              el.child(
                h_flex()
                  .gap(4)
                  .items_center()
                  .child(icon("branch", 10, C.comment))
                  .child(div().min_w(0).truncate().text_size(11).text_color(C.comment).child(s.branch)),
              ),
            ),
        )
        .child(div().flex_none().text_size(11).text_color(C.comment).child(`${s.tabs.length}`))
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(statusIcon(s.status, 12, this.frame))),
    );
    return v_flex()
      .size_full()
      .bg(C.dark)
      .child(heading("SPACES", sp.length, button("dr-space-new", "plus", () => run("space.new"), { tip: "New space", size: 20 })))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().pb(6).children(list));
  }
}

export class Agents {
  init(_p, cx) {
    hourglass(this, cx, () => agents().some((a) => a.status === "working"));
    cx.timer.every(15000, (cx) => cx.notify());
  }

  render() {
    const all = agents();
    setAgentOrder(all.map((a) => a.address));
    const tabs = {};
    for (const s of spaces()) for (const t of s.tabs) tabs[t.id] = t;
    const now = Date.now();
    const list = all.map((a) => {
      const t = tabs[a.tab];
      const since = a.status === "working" ? t?.working_since : t?.changed_at;
      const st = STATUS[a.status] ?? STATUS.idle;
      return row(`dr-agent-${a.address}`, a.focused)
        .h(40)
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .child(statusIcon(a.status, 14, this.frame))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(
              h_flex()
                .gap(6)
                .items_center()
                .child(div().min_w(0).truncate().text_size(13).font_bold().text_color(C.fg).child(a.program?.name ?? a.app ?? "agent"))
                .child(div().flex_none().text_size(11).text_color(st.color).child(st.label)),
            )
            .child(div().truncate().text_size(11).text_color(C.comment).child(`${a.space_name} › ${a.tab_name}`)),
        )
        .when(Boolean(since), (el) => el.child(div().flex_none().text_size(11).text_color(C.comment).child(ago(now - since))));
    });
    const empty = div().px(10).py(8).text_size(12).text_color(C.comment).child("No agents running.");
    const waiting = all.filter((a) => a.status === "blocked").length;
    return v_flex()
      .size_full()
      .bg(C.dark)
      .child(heading("AGENTS", all.length, waiting ? h_flex().gap(4).items_center().child(icon("bell", 11, C.orange)).child(div().text_size(11).text_color(C.orange).child(String(waiting))) : null))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().pb(6).children(list.length ? list : [empty]));
  }
}
