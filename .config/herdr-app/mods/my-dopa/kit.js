// Dopa の共通部品: ネオンの色、虹色の時計、アイコン、状態ごとの演出。

import { div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { shared } from "herdr";

export const A = "mods/my-dopa/icons";

export const C = {
  bg: "#0b0016",
  chrome: "#12002a",
  card: "#1a0638",
  hover: "#34106a",
  line: "#5a2aa8",
  text: "#fdf6ff",
  muted: "#d8c4ff",
  dim: "#9a7ad0",
  pink: "#ff2bd6",
  cyan: "#00f0ff",
  lime: "#b6ff00",
  yellow: "#ffe600",
  orange: "#ff7a00",
  red: "#ff3b6b",
  violet: "#7a5cff",
};

export const RAINBOW = [C.pink, C.orange, C.yellow, C.lime, C.cyan, C.violet];

// 全 view で揃う虹色: 時刻から決めるので、別々の mod でも同じ色が同時に流れる。
export const TICK = 140;
export function hue(offset = 0) {
  const n = Math.floor(Date.now() / TICK) + offset;
  return RAINBOW[((n % RAINBOW.length) + RAINBOW.length) % RAINBOW.length];
}

// 虹色を動かすために view を定期的に描き直す
export function pulse(cx, ms = TICK) {
  cx.timer.every(ms, (cx) => cx.notify());
}

export function icon(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// スペースの色 (my-spaces が決めた ansi 名) をネオンに
const NEON = { ansi1: C.red, ansi2: C.lime, ansi3: C.orange, ansi4: C.cyan, ansi5: C.violet, ansi6: C.pink };
export function spaceColor(id) {
  return NEON[(shared("space.colors") ?? {})[id]] ?? C.pink;
}

// 状態ごとの見せ方
export const LOOK = {
  working: { icon: "ring", color: C.cyan, words: ["COOKING", "COOKING.", "COOKING..", "COOKING..."] },
  blocked: { icon: "alert", color: C.red, words: ["YOUR TURN!!", "YOUR TURN!!", "HURRY UP!!", "HURRY UP!!"] },
  done: { icon: "burst", color: C.lime, words: ["GG!!", "GG!!", "NICE!!", "W!!"] },
  idle: { icon: "zzz", color: C.dim, words: ["afk", "afk.", "afk..", "afk..."] },
};

// 状態アイコン: 回る / 点滅する / 回りながら光る / ふわふわ浮く
export function statusIcon(status, size = 16) {
  const l = LOOK[status] ?? LOOK.idle;
  const el = icon(l.icon, size, status === "blocked" ? hue() : l.color);
  if (status === "working") return el.spin(700);
  if (status === "done") return el.spin(2400);
  if (status === "blocked") return div().flex_none().loop("opacity", { from: 0.15, to: 1, period: 360, easing: "linear" }).child(el);
  return div().flex_none().relative().h(size).w(size).child(div().absolute().loop("top", { from: -2, to: 2, period: 1600 }).child(el));
}

// 状態のことば (ネイティブで切り替わる)
export function statusWord(status, size = 11) {
  const l = LOOK[status] ?? LOOK.idle;
  return div()
    .flex_none()
    .text_size(size)
    .font_bold()
    .text_color(status === "blocked" ? hue(2) : l.color)
    .frames(l.words, status === "working" ? 260 : 420);
}

// ネオンの丸いピル。color: 枠の色。fill: 中の色。
export function pill(id, color, fill = C.card) {
  return h_flex().id(id).items_center().rounded(999).border(2).border_color(color).bg(fill);
}

// 押すとちょっと縮む小さいボタン
export function button(id, name, onClick, { color = C.muted, tip } = {}) {
  return div()
    .id(id)
    .size(22)
    .flex_none()
    .flex()
    .items_center()
    .justify_center()
    .rounded(999)
    .bg(C.card)
    .hover((s) => s.bg(C.hover))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(icon(name, 12, color));
}

export function short(path, home) {
  if (!path) return "";
  return home && path.startsWith(home) ? `~${path.slice(home.length)}` : path;
}
