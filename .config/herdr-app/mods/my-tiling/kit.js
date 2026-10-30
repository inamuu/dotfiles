// Tiling の共通部品: 落ち着いた配色、文字だけの状態表示、見出し、文字ボタン。
// アイコンは使わず、すべて等幅の文字で描く。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { shared } from "herdr";

// 深い紫を地に、強調は薄紫 1 色。状態だけ色を分ける。
export const C = {
  bg: "#17131f",
  panel: "#1c1727",
  line: "#2f2742",
  hover: "#261f35",
  pick: "#322848",
  text: "#e2dbf2",
  muted: "#aea2c8",
  dim: "#6f648c",
  accent: "#c39bff",
  blue: "#8fb0ff",
  green: "#a6e3a1",
  red: "#ff7a9a",
  purple: "#f0a6e0",
  cyan: "#8ad8f0",
  yellow: "#f2d58a",
};

const SPIN = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

// 状態: 点字のくるくる (working)、! (blocked、反転)、✓ (done)、· (idle)
export const STATUS = {
  working: { mark: "⠋", color: C.blue, label: "run" },
  blocked: { mark: "!", color: C.red, label: "wait" },
  done: { mark: "✓", color: C.green, label: "done" },
  idle: { mark: "·", color: C.dim, label: "idle" },
};

export function mark(status) {
  const s = STATUS[status] ?? STATUS.idle;
  const el = div().flex_none().w(14).flex().justify_center().font_bold().text_color(s.color);
  if (status === "working") return el.frames(SPIN, 90);
  if (status === "blocked") return el.bg(C.red).text_color(C.bg).child("!");
  return el.child(s.mark);
}

export function label(status) {
  const s = STATUS[status] ?? STATUS.idle;
  return div().flex_none().text_color(s.color).child(s.label);
}

// space の色 (my-spaces が決めた ansi 名) をこの配色に
const TONE = { ansi1: C.red, ansi2: C.green, ansi3: C.yellow, ansi4: C.blue, ansi5: C.purple, ansi6: C.cyan };
export function spaceColor(id) {
  return TONE[(shared("space.colors") ?? {})[id]] ?? C.muted;
}

// 見出し: "spaces ──────── [+]"
export function heading(text, right) {
  return h_flex()
    .h(24)
    .flex_none()
    .px(8)
    .gap(6)
    .items_center()
    .child(div().flex_none().text_color(C.accent).font_bold().child(text))
    .child(div().flex_1().h(1).bg(C.line))
    .when(Boolean(right), (el) => el.child(right));
}

// 文字ボタン: [x] のような角かっこ付き
export function key(id, text, onClick, { tip, color = C.dim, on = false } = {}) {
  return div()
    .id(id)
    .flex_none()
    .px(3)
    .text_color(on ? C.accent : color)
    .hover((s) => s.text_color(C.text).bg(C.hover))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(`[${text}]`);
}

export function short(path, home) {
  if (!path) return "";
  return home && path.startsWith(home) ? `~${path.slice(home.length)}` : path;
}

// ms -> "45s" "12m" "3h" "2d"
export function ago(ms) {
  const s = Math.max(0, Math.floor(ms / 1000));
  if (s < 60) return `${s}s`;
  if (s < 3600) return `${Math.floor(s / 60)}m`;
  if (s < 86400) return `${Math.floor(s / 3600)}h`;
  return `${Math.floor(s / 86400)}d`;
}

export const pad = (n) => String(n).padStart(2, "0");
