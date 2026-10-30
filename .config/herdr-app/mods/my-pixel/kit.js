// Pixel Quest の共通部品: 色、スプライト、RPG 風のウィンドウ枠。

import { div, svg, image } from "gpui-kit";
import { shared } from "herdr";

export const A = "mods/my-pixel/sprites";

// 黒い画面に白い枠、白い文字。選んでいるものは ▶ で示す。
export const C = {
  ink: "#000000",
  night: "#000000",
  panel: "#000000",
  line: "#ffffff",
  shade: "#6a6a6a",
  gold: "#f4c542",
  text: "#ffffff",
  muted: "#c8c8c8",
  dim: "#8a8a8a",
  hover: "#1c1c1c",
  pick: "#000000",
  green: "#5fd068",
  red: "#ff5a5a",
};

// 状態ごとの RPG 風のことば
export const WORD = { working: "FIGHT", blocked: "HELP!", done: "CLEAR", idle: "REST" };

// ドット絵 1 枚。scale は 1 ドットの px。
export function sprite(name, w, h, scale = 2) {
  return image(`${A}/${name}.svg`).w(w * scale).h(h * scale).flex_none();
}

// 単色アイコン (色付け可)
export function glyph(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// 状態アイコン: 剣 (working)、! の吹き出し (blocked)、星 (done)、Zz (idle)
export function mark(status, scale = 2) {
  return sprite(`mark-${WORD[status] ? status : "idle"}`, 9, 9, scale);
}

// 仲間 1 人。並び順で職業が回る。working のときだけ足踏み (frame 0/1)。
const JOBS = ["warrior", "mage", "priest", "fighter"];
export function member(index, status, frame = 0, scale = 2) {
  return sprite(`${JOBS[index % JOBS.length]}-${status === "working" ? frame : 0}`, 16, 16, scale);
}

// スペースの地図アイコン (城、町、塔、ほら穴)。my-spaces が決めた色 (shared "space.colors") で選ぶ。
const PLACES = new Set(["ansi1", "ansi2", "ansi3", "ansi4", "ansi5", "ansi6"]);
export function place(spaceId, scale = 2) {
  const c = (shared("space.colors") ?? {})[spaceId];
  return sprite(`place-${PLACES.has(c) ? c : "ansi6"}`, 16, 16, scale);
}

// RPG のウィンドウ: 黒い中身に白く太い角丸の枠。見出しは上の枠線に乗せて線を切る。
export function frame(id, title, body) {
  const win = div()
    .id(`${id}-frame`)
    .flex()
    .flex_col()
    .flex_1()
    .min_h(0)
    .border(3)
    .border_color(C.line)
    .rounded(8)
    .bg(C.panel)
    .pt(16)
    .px(8)
    .pb(8)
    .child(body);
  return div()
    .id(id)
    .relative()
    .flex()
    .flex_col()
    .size_full()
    .pt(10)
    .child(win)
    .when(Boolean(title), (el) =>
      el.child(
        div()
          .absolute()
          .top(0)
          .left(18)
          .px(6)
          .h(22)
          .flex()
          .items_center()
          .bg(C.ink)
          .text_size(13)
          .font_bold()
          .text_color(C.text)
          .child(title),
      ),
    );
}

// 小さいピクセルボタン
export function button(id, name, onClick, { color = C.muted, tip } = {}) {
  return div()
    .id(id)
    .size(20)
    .flex_none()
    .flex()
    .items_center()
    .justify_center()
    .border(2)
    .border_color(C.shade)
    .rounded(4)
    .bg(C.night)
    .hover((s) => s.bg(C.hover).border_color(C.line))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(glyph(name, 10, color));
}

// ~ で短くした場所
export function short(path, home) {
  if (!path) return "";
  return home && path.startsWith(home) ? `~${path.slice(home.length)}` : path;
}

// スライムを跳ねさせるタイマー。何かが working のときだけ描き直す。
export function bounce(view, cx, busy) {
  view.frame = 0;
  cx.timer.every(420, (cx) => {
    if (!busy()) return;
    view.frame ^= 1;
    cx.notify();
  });
}
