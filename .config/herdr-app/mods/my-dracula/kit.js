// Dracula レイアウトの共通部品: Dracula の色、ドット絵アイコン、状態の表示、時間の書き方。

import { div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { shared } from "herdr";

export const A = "mods/my-dracula/icons";

// https://draculatheme.com の配色
export const C = {
  bg: "#282a36",
  dark: "#21222c",
  darker: "#191a21",
  line: "#44475a",
  hover: "#343746",
  fg: "#f8f8f2",
  muted: "#c8cbe0",
  comment: "#6272a4",
  cyan: "#8be9fd",
  green: "#50fa7b",
  orange: "#ffb86c",
  pink: "#ff79c6",
  purple: "#bd93f9",
  red: "#ff5555",
  yellow: "#f1fa8c",
};

export function icon(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// 状態: 砂時計 (working、2 コマ)、ベル (blocked、ゆっくり明滅)、チェック (done)、月 (idle)
export const STATUS = {
  working: { icon: "hourglass", color: C.cyan, label: "working" },
  blocked: { icon: "bell", color: C.orange, label: "needs you" },
  done: { icon: "check", color: C.green, label: "done" },
  idle: { icon: "moon", color: C.comment, label: "idle" },
};

export function statusIcon(status, size = 12, frame = 0) {
  const s = STATUS[status] ?? STATUS.idle;
  const el = icon(status === "working" ? `hourglass-${frame}` : s.icon, size, s.color);
  return status === "blocked" ? div().flex_none().loop("opacity", { from: 0.45, to: 1, period: 1400 }).child(el) : el;
}

// 砂時計を返すためのタイマー。working が見えている間だけ描き直す。
export function hourglass(view, cx, busy) {
  view.frame = 0;
  cx.timer.every(700, (cx) => {
    if (!busy()) return;
    view.frame ^= 1;
    cx.notify();
  });
}

// space の色 (my-spaces が決めた ansi 名) を Dracula の色に
const TONE = { ansi1: C.red, ansi2: C.green, ansi3: C.orange, ansi4: C.purple, ansi5: C.pink, ansi6: C.cyan };
export function spaceColor(id) {
  return TONE[(shared("space.colors") ?? {})[id]] ?? C.purple;
}

// 見出し: "SPACES ── 3" のような小さいラベル
export function heading(text, count, right) {
  return h_flex()
    .h(28)
    .flex_none()
    .px(10)
    .gap(8)
    .items_center()
    .text_size(11)
    .font_bold()
    .child(div().flex_none().text_color(C.purple).child(text))
    .when(count !== undefined, (el) => el.child(div().flex_none().px(5).bg(C.line).text_color(C.fg).child(String(count))))
    .child(div().flex_1().h(2).bg(C.line))
    .when(Boolean(right), (el) => el.child(right));
}

// 四角いアイコンボタン。on: 押されている状態
export function button(id, name, onClick, { color = C.comment, tip, on = false, size = 22 } = {}) {
  return div()
    .id(id)
    .size(size)
    .flex_none()
    .flex()
    .items_center()
    .justify_center()
    .bg(on ? C.line : "#00000000")
    .hover((s) => s.bg(C.line))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(icon(name, 12, on ? C.fg : color));
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
