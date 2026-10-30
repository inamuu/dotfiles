// 左の 2 つのウィンドウ。
//   Spaces  スペースを土管で並べる。いまの場所に ▶。クリックで移動、右クリックでメニュー。
//   Party   エージェントをブロックで並べる (? = working、! = blocked、コイン = done、空 = idle)。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, WORD, frame, pipe, mark, glyph, blink } from "./kit.js";

function row(id, on) {
  return h_flex()
    .id(id)
    .h(30)
    .flex_none()
    .px(4)
    .gap(8)
    .items_center()
    .cursor_pointer()
    .when(on, (el) => el.bg(C.hover))
    .when(!on, (el) => el.hover((s) => s.bg(C.hover)));
}

// 選択中の行の左に出るカーソル。ほかの行は同じ幅だけ空ける。
function cursor(on) {
  return div()
    .w(8)
    .flex_none()
    .when(on, (el) => el.child(glyph("cursor", 8, C.gold).loop("opacity", { from: 0.25, to: 1, period: 900 })));
}

export class Spaces {
  render() {
    const list = spaces().map((s) =>
      row(`mr-space-${s.id}`, s.active)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(cursor(s.active))
        .child(pipe(s.id, 1.5))
        .child(div().flex_1().min_w(0).truncate().text_size(13).text_color(C.text).child(s.name))
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(mark(s.status, 1))),
    );
    const add = row("mr-space-new", false)
      .text_color(C.dim)
      .hover((s) => s.text_color(C.text))
      .on_click(() => run("space.new"))
      .child(div().w(8).flex_none())
      .child(div().w(24).flex_none().flex().justify_center().child(glyph("plus", 10, C.dim)))
      .child(div().text_size(12).child("NEW WORLD"));
    return frame("mr-spaces", "WORLDS", v_flex().flex_1().min_h(0).overflow_y_scrollbar().gap(2).children([...list, add]));
  }
}

export class Party {
  init(_p, cx) {
    blink(this, cx, () => agents().some((a) => a.status === "working"));
  }

  render() {
    const all = agents();
    setAgentOrder(all.map((a) => a.address));
    const list = all.map((a) =>
      row(`mr-agent-${a.address}`, a.focused)
        .h(38)
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .child(cursor(a.focused))
        .child(mark(a.status, 1.75, this.frame))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().text_size(12.5).text_color(C.text).child(a.program?.name ?? a.app ?? "agent"))
            .child(div().truncate().text_size(11).text_color(C.dim).child(`${a.space_name} / ${a.tab_name}`)),
        )
        .child(
          div()
            .flex_none()
            .text_size(11)
            .font_bold()
            .text_color(a.status === "blocked" ? C.red : a.status === "done" ? C.gold : a.status === "working" ? C.green : C.dim)
            .when(a.status === "blocked", (el) => el.loop("opacity", { from: 0.3, to: 1, period: 700 }))
            .child(WORD[a.status] ?? ""),
        ),
    );
    const empty = div().px(6).py(8).text_size(12).text_color(C.dim).child("No players yet.");
    return frame("mr-party", "PLAYERS", v_flex().flex_1().min_h(0).overflow_y_scrollbar().gap(2).children(list.length ? list : [empty]));
  }
}
