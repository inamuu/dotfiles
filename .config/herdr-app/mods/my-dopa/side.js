// 左の 2 列。
//   Spaces  space をネオンのカード。いまの space は虹色の枠と回るキラキラ。クリックで移動、右クリックでメニュー。
//   Party   エージェントのカード。状態ごとに回る / 点滅する / 浮く。入力待ちはカードごと点滅。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, hue, pulse, icon, spaceColor, statusIcon, statusWord } from "./kit.js";

function heading(text, name, i) {
  return h_flex()
    .h(30)
    .flex_none()
    .px(6)
    .gap(8)
    .items_center()
    .child(icon(name, 16, hue(i)).spin(1800))
    .child(div().text_size(14).font_bold().text_color(hue(i + 2)).child(text));
}

function card(id, on, i) {
  return h_flex()
    .id(id)
    .relative()
    .flex_none()
    .px(10)
    .gap(10)
    .items_center()
    .rounded(14)
    .border(2)
    .border_color(on ? hue(i) : C.line)
    .bg(on ? "#2a0b55" : C.card)
    .cursor_pointer()
    .when(!on, (el) => el.hover((s) => s.bg(C.hover).border_color(hue(i))));
}

export class Spaces {
  init(_p, cx) {
    pulse(cx);
  }

  render() {
    const list = spaces().map((s, i) =>
      card(`dp-space-${s.id}`, s.active, i)
        .h(40)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(div().size(12).flex_none().rounded(999).bg(spaceColor(s.id)).when(s.active, (el) => el.loop("opacity", { from: 0.3, to: 1, period: 500 })))
        .child(div().flex_1().min_w(0).truncate().text_size(13.5).font_bold().text_color(s.active ? C.text : C.muted).child(s.name))
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(statusIcon(s.status, 16)))
        .when(s.active, (el) => el.child(icon("sparkle", 14, hue(i + 3)).spin(900))),
    );
    const add = h_flex()
      .id("dp-space-new")
      .h(36)
      .flex_none()
      .gap(8)
      .items_center()
      .justify_center()
      .rounded(14)
      .border(2)
      .border_color(hue(1))
      .cursor_pointer()
      .hover((s) => s.bg(C.hover))
      .on_click(() => run("space.new"))
      .child(icon("plus", 12, hue(1)).spin(2000))
      .child(div().text_size(12).font_bold().text_color(C.text).child("NEW SPACE!!"));
    return v_flex()
      .size_full()
      .p(6)
      .gap(6)
      .rounded(16)
      .bg(C.chrome)
      .border(2)
      .border_color(C.line)
      .child(heading("SPACES", "star", 0))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().gap(6).children([...list, add]));
  }
}

export class Party {
  init(_p, cx) {
    pulse(cx);
  }

  render() {
    const all = agents();
    setAgentOrder(all.map((a) => a.address));
    const list = all.map((a, i) =>
      card(`dp-agent-${a.address}`, a.focused, i)
        .h(48)
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .when(a.status === "blocked", (el) =>
          el.child(div().absolute().top(0).left(0).size_full().rounded(12).bg("#ff3b6b55").loop("opacity", { from: 0, to: 1, period: 500, easing: "linear" })),
        )
        .child(statusIcon(a.status, 20))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().text_size(13).font_bold().text_color(C.text).child(a.program?.name ?? a.app ?? "agent"))
            .child(div().truncate().text_size(11).text_color(C.dim).child(`${a.space_name} / ${a.tab_name}`)),
        )
        .child(statusWord(a.status, 11)),
    );
    const empty = div().px(8).py(10).text_size(12).text_color(C.dim).child("no agents... boring...");
    return v_flex()
      .size_full()
      .p(6)
      .gap(6)
      .rounded(16)
      .bg(C.chrome)
      .border(2)
      .border_color(C.line)
      .child(heading("PARTY", "flame", 3))
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().gap(6).children(list.length ? list : [empty]));
  }
}
