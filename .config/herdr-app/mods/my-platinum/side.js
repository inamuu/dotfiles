// 左の 2 つのウィンドウ (Finder の一覧表示風)。
//   Spaces  フォルダ (色は space ごと、リモートはコンピュータ)、名前、ブランチ、タブ数、いちばん急ぐ状態。
//           クリックで移動、右クリックでメニュー、タイトルバー右の + で新しい space。
//   Agents  状態、プログラム名、space / tab、その状態になってからの時間。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, STATUS, icon, statusIcon, tick, spaceColor, button, win, columns, desk, ago } from "./kit.js";

function row(id, on) {
  return h_flex()
    .id(id)
    .flex_none()
    .px(6)
    .gap(6)
    .items_center()
    .cursor_pointer()
    .when(on, (el) => el.bg(C.pick))
    .when(!on, (el) => el.hover((s) => s.bg(C.hover)));
}

export class Spaces {
  init(_p, cx) {
    tick(this, cx, () => spaces().some((s) => s.status === "working"));
  }

  render() {
    const sp = spaces();
    const list = sp.map((s) =>
      row(`pt-space-${s.id}`, s.active)
        .h(s.branch ? 36 : 24)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(icon(s.machine ? "computer" : "folder", 13, spaceColor(s.id)))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().text_size(12.5).when(s.active, (el) => el.font_bold()).text_color(C.text).child(s.name))
            .when(Boolean(s.branch), (el) =>
              el.child(h_flex().gap(4).items_center().child(icon("branch", 10, C.dim)).child(div().min_w(0).truncate().text_size(11).text_color(C.dim).child(s.branch))),
            ),
        )
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(statusIcon(s.status, 12, this.frame)))
        .child(div().w(30).flex_none().text_size(11).text_color(C.muted).child(`${s.tabs.length}`)),
    );
    const body = v_flex()
      .flex_1()
      .min_h(0)
      .child(columns([["Name", 0], ["Tabs", 36]]))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().children(list));
    const add = button("pt-space-new", "plus", () => run("space.new"), { tip: "New space", size: 15 });
    return desk(8, win("pt-spaces", `Spaces (${sp.length})`, body, { right: [add] }));
  }
}

export class Agents {
  init(_p, cx) {
    tick(this, cx, () => agents().some((a) => a.status === "working"));
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
      return row(`pt-agent-${a.address}`, a.focused)
        .h(36)
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .child(statusIcon(a.status, 13, this.frame))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(
              h_flex()
                .gap(6)
                .items_center()
                .child(div().min_w(0).truncate().text_size(12.5).font_bold().text_color(C.text).child(a.program?.name ?? a.app ?? "agent"))
                .child(div().flex_none().text_size(10.5).text_color(st.color).child(st.label)),
            )
            .child(div().truncate().text_size(11).text_color(C.dim).child(`${a.space_name} › ${a.tab_name}`)),
        )
        .child(div().w(30).flex_none().text_size(11).text_color(C.muted).child(since ? ago(now - since) : ""));
    });
    const empty = div().px(8).py(6).text_size(12).text_color(C.dim).child("No agents running.");
    const body = v_flex()
      .flex_1()
      .min_h(0)
      .child(columns([["Agent", 0], ["Time", 36]]))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().children(list.length ? list : [empty]));
    return desk(8, win("pt-agents", `Agents (${all.length})`, body));
  }
}
