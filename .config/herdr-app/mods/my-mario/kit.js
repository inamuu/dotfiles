// Mario 風テーマの共通部品: 色、スプライト、レンガ枠のウィンドウ。
// private/ (gitignore 済み) に sprites/ と同じ名前の画像 (png, gif, jpg, webp, svg) を置くと、そちらを使う。
//   例: private/hero-r-0.png  private/mark-done.png

import { div, svg, image } from "gpui-kit";
import { shared, home } from "herdr";
import * as fs from "fs/promises";

export const A = "mods/my-mario/sprites";
const OWN = "mods/my-mario/private";

// 昼の空に黒い地下の窓、レンガの縁。
export const C = {
  sky: "#5c94fc",
  ink: "#000000",
  panel: "#000000",
  brick: "#c84c0c",
  light: "#fcbcb0",
  gold: "#fc9838",
  shade: "#7c7c7c",
  text: "#fcfcfc",
  muted: "#bcbcbc",
  dim: "#7c7c7c",
  hover: "#2a2a2a",
  green: "#58d854",
  red: "#e40058",
};

// 状態ごとのことば
export const WORD = { working: "GO!", blocked: "HELP!", done: "GOAL", idle: "REST" };

// private/ にある差し替え画像: スプライト名 -> ファイル名
const own = {};
export async function loadOwn() {
  try {
    for (const f of await fs.readdir(`${home()}/.config/herdr-app/${OWN}`)) {
      const m = f.match(/^(.+)\.(png|gif|jpe?g|webp|svg)$/i);
      if (m) own[m[1]] = f;
    }
  } catch {
    // private/ が無ければ同梱のドット絵だけ使う
  }
}

// ドット絵 1 枚。scale は 1 ドットの px。
export function sprite(name, w, h, scale = 2) {
  const path = own[name] ? `${OWN}/${own[name]}` : `${A}/${name}.svg`;
  return image(path).w(w * scale).h(h * scale).flex_none();
}

// 単色アイコン (色付け可)
export function glyph(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// 状態アイコン: ? ブロック (working, frame で明滅)、! ブロック (blocked)、コイン (done)、空ブロック (idle)
export function mark(status, scale = 2, frame = 0) {
  if (status === "working") return sprite(`mark-working-${frame}`, 16, 16, scale);
  return sprite(`mark-${WORD[status] ? status : "idle"}`, 16, 16, scale);
}

// スペースの土管。my-spaces が決めた色 (shared "space.colors") で選ぶ。
const PIPES = new Set(["ansi1", "ansi2", "ansi3", "ansi4", "ansi5", "ansi6"]);
export function pipe(spaceId, scale = 2) {
  const c = (shared("space.colors") ?? {})[spaceId];
  return sprite(`pipe-${PIPES.has(c) ? c : "ansi2"}`, 16, 16, scale);
}

// 地下ステージ風のウィンドウ: 黒い中身にレンガ色の太い枠。見出しはレンガの札で上の枠に乗せる。
export function frame(id, title, body) {
  const win = div()
    .id(`${id}-frame`)
    .flex()
    .flex_col()
    .flex_1()
    .min_h(0)
    .border(3)
    .border_color(C.brick)
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
          .left(14)
          .px(8)
          .h(22)
          .flex()
          .items_center()
          .bg(C.brick)
          .border(2)
          .border_color(C.ink)
          .text_size(13)
          .font_bold()
          .text_color(C.text)
          .child(title),
      ),
    );
}

// 小さいボタン
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
    .bg(C.ink)
    .hover((s) => s.bg(C.hover).border_color(C.gold))
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

// ? ブロックを明滅させるタイマー。何かが working のときだけ描き直す。
export function blink(view, cx, busy) {
  view.frame = 0;
  cx.timer.every(420, (cx) => {
    if (!busy()) return;
    view.frame ^= 1;
    cx.notify();
  });
}
