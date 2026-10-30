// 左の 2 つのウィンドウ。紫としま模様と夕焼けのしま模様の上に浮かべる。
//   Spaces  町の家 (色は space ごと、リモートは UFO)、名前、ブランチ、タブ数、いちばん急ぐ状態。
//           クリックで移動、右クリックでメニュー、+ で新しい space。選択中は手のカーソル。
//   Agents  状態、プログラム名と状態のことば、space / tab、その状態になってからの時間。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, STATUS, icon, statusIcon, statusWord, spin, spaceColor, button, cursor, frame, scene, ago } from "./kit.js";

const BG = { cols: 9, rows: 18 };

function row(id, on) {
  return h_flex()
    .id(id)
    .flex_none()
    .px(4)
    .gap(6)
    .items_center()
    .rounded(3)
    .cursor_pointer()
    .when(on, (el) => el.bg(C.pick))
    .when(!on, (el) => el.hover((s) => s.bg(C.hover)))
    .child(cursor(on));
}

// ウィンドウの中の見出し行: 数と右端のボタン
function head(left, right) {
  return h_flex().h(22).flex_none().px(4).gap(6).items_center().text_size(11).text_color(C.dim).child(left).child(div().flex_1()).when(Boolean(right), (el) => el.child(right));
}

export class Spaces {
  init(_p, cx) {
    spin(this, cx, () => spaces().some((s) => s.status === "working"));
  }

  render() {
    const sp = spaces();
    const list = sp.map((s) =>
      row(`mo-space-${s.id}`, s.active)
        .h(s.branch ? 38 : 26)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(icon(s.machine ? "ufo" : "house", 13, spaceColor(s.id)))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().text_size(13).font_bold().text_color(s.active ? C.text : C.muted).child(s.name))
            .when(Boolean(s.branch), (el) =>
              el.child(
                h_flex()
                  .gap(4)
                  .items_center()
                  .child(icon("branch", 10, C.dim))
                  .child(div().min_w(0).truncate().text_size(11).text_color(C.dim).child(s.branch)),
              ),
            ),
        )
        .child(div().flex_none().text_size(11).text_color(C.dim).child(`${s.tabs.length}`))
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(statusIcon(s.status, 12, this.frame))),
    );
    const body = v_flex()
      .flex_1()
      .min_h(0)
      .child(head(`${sp.length} places`, button("mo-space-new", "plus", () => run("space.new"), { tip: "New space", size: 20 })))
      .child(v_flex().flex_1().min_h(0).gap(2).overflow_y_scrollbar().children(list));
    return scene(0, 8, frame("mo-spaces", "SPACES", body), BG);
  }
}

export class Agents {
  init(_p, cx) {
    spin(this, cx, () => agents().some((a) => a.status === "working"));
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
      return row(`mo-agent-${a.address}`, a.focused)
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
            .child(div().truncate().text_size(11).text_color(C.dim).child(`${a.space_name} › ${a.tab_name}`)),
        )
        .when(Boolean(since), (el) => el.child(div().flex_none().text_size(11).text_color(C.dim).child(ago(now - since))));
    });
    const empty = div().px(6).py(6).text_size(12).text_color(C.dim).child("No one is here.");
    const waiting = all.filter((a) => a.status === "blocked").length;
    const body = v_flex()
      .flex_1()
      .min_h(0)
      .child(
        head(
          `${all.length} in party`,
          waiting ? h_flex().gap(4).items_center().child(icon("bang", 11, STATUS.blocked.color)).child(div().text_size(11).text_color(STATUS.blocked.color).child(String(waiting))) : null,
        ),
      )
      .child(v_flex().flex_1().min_h(0).gap(2).overflow_y_scrollbar().children(list.length ? list : [empty]));
    return scene(2, 8, frame("mo-agents", "AGENTS", body), BG);
  }
}
