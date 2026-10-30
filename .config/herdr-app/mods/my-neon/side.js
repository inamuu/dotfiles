// 左の 2 つの HUD パネル。
//   Spaces  六角形のノード (色は space ごと、リモートはサーバー)、名前、ブランチ、タブ数、いちばん急ぐ状態。
//           クリックで移動、右クリックでメニュー、見出しの + で新しい space。選択中は左にシアンの線。
//   Agents  状態、プログラム名と状態のことば、space / tab、その状態になってからの時間。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, icon, statusIcon, statusWord, pulse, spaceColor, panel, button, scanlines, ago } from "./kit.js";

function row(id, on) {
  return h_flex()
    .id(id)
    .flex_none()
    .pr(8)
    .pl(8)
    .gap(8)
    .items_center()
    .border_l(2)
    .border_color(on ? C.cyan : "#00000000")
    .cursor_pointer()
    .when(on, (el) => el.bg(C.raise))
    .when(!on, (el) => el.hover((s) => s.bg(C.raise)));
}

// パネルを夜の黒に置き、走査線を重ねる
function frame(child) {
  return div().relative().size_full().flex().flex_col().p(6).bg(C.bg).child(child).child(scanlines());
}

export class Spaces {
  init(_p, cx) {
    pulse(this, cx, () => spaces().some((s) => s.status === "working"));
  }

  render() {
    const sp = spaces();
    const list = sp.map((s) =>
      row(`ne-space-${s.id}`, s.active)
        .h(s.branch ? 38 : 26)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(icon(s.machine ? "server" : "hex", 13, spaceColor(s.id)))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().text_size(13).font_bold().text_color(s.active ? C.text : C.muted).child(s.name))
            .when(Boolean(s.branch), (el) =>
              el.child(h_flex().gap(4).items_center().child(icon("branch", 10, C.dim)).child(div().min_w(0).truncate().text_size(11).text_color(C.dim).child(s.branch))),
            ),
        )
        .child(div().flex_none().text_size(11).text_color(C.dim).child(`${s.tabs.length}`))
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(statusIcon(s.status, 12, this.frame))),
    );
    const body = v_flex().flex_1().min_h(0).overflow_y_scrollbar().pb(6).children(list);
    const add = button("ne-space-new", "plus", () => run("space.new"), { tip: "New space", size: 18 });
    return frame(panel("ne-spaces", "SPACES", body, { count: sp.length, right: add }));
  }
}

export class Agents {
  init(_p, cx) {
    pulse(this, cx, () => agents().some((a) => a.status === "working"));
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
      return row(`ne-agent-${a.address}`, a.focused)
        .h(38)
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
                .child(div().min_w(0).truncate().text_size(13).font_bold().text_color(C.text).child(a.program?.name ?? a.app ?? "agent"))
                .child(statusWord(a.status)),
            )
            .child(div().truncate().text_size(11).text_color(C.dim).child(`${a.space_name} // ${a.tab_name}`)),
        )
        .when(Boolean(since), (el) => el.child(div().flex_none().text_size(11).text_color(C.dim).child(ago(now - since))));
    });
    const empty = div().px(10).py(6).text_size(12).text_color(C.dim).child("NO SIGNAL");
    const body = v_flex().flex_1().min_h(0).overflow_y_scrollbar().pb(6).children(list.length ? list : [empty]);
    const accent = all.some((a) => a.status === "blocked") ? C.magenta : C.cyan;
    return frame(panel("ne-agents", "AGENTS", body, { count: all.length, accent }));
  }
}
