// Neon レイアウトの共通部品: ネオンの色、ドット絵アイコン、HUD 風の枠、ずれる文字、走査線。

import { div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { shared } from "herdr";

export const A = "mods/my-neon/icons";

// 夜の黒に黄色、シアン、マゼンタのネオン
export const C = {
  bg: "#07070d",
  panel: "#0d0e1a",
  raise: "#151730",
  line: "#22284a",
  text: "#e6f6ff",
  muted: "#9fb3c8",
  dim: "#56688a",
  yellow: "#fcee0a",
  cyan: "#00f0ff",
  magenta: "#ff2a6d",
  violet: "#9d4dff",
  green: "#39ff88",
  orange: "#ff9a1f",
};

export function icon(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// 状態: 信号のバー (working)、警告 (blocked、明滅)、チェック (done)、点 (idle)
export const STATUS = {
  working: { icon: "sync", color: C.cyan, word: "SYNC" },
  blocked: { icon: "warn", color: C.magenta, word: "ALERT" },
  done: { icon: "check", color: C.yellow, word: "DONE" },
  idle: { icon: "dot", color: C.dim, word: "IDLE" },
};

const blink = (el) => el.loop("opacity", { from: 0.2, to: 1, period: 450, easing: "linear" });

export function statusIcon(status, size = 12, frame = 0) {
  const s = STATUS[status] ?? STATUS.idle;
  const el = icon(status === "working" ? `sync-${frame}` : s.icon, size, s.color);
  return status === "blocked" ? blink(div().flex_none().child(el)) : el;
}

// 状態のことば。blocked は反転して明滅。
export function statusWord(status, size = 10.5) {
  const s = STATUS[status] ?? STATUS.idle;
  const el = div().flex_none().px(3).text_size(size).font_bold();
  return status === "blocked" ? blink(el.bg(s.color).text_color(C.bg)).child(s.word) : el.text_color(s.color).child(s.word);
}

// 信号のバーを動かすタイマー。working が見えている間だけ描き直す。
export function pulse(view, cx, busy) {
  view.frame = 0;
  cx.timer.every(400, (cx) => {
    if (!busy()) return;
    view.frame ^= 1;
    cx.notify();
  });
}

// space の色 (my-spaces が決めた ansi 名) をネオンの色に
const TONE = { ansi1: C.magenta, ansi2: C.green, ansi3: C.yellow, ansi4: C.violet, ansi5: C.orange, ansi6: C.cyan };
export function spaceColor(id) {
  return TONE[(shared("space.colors") ?? {})[id]] ?? C.cyan;
}

// ずれる文字: マゼンタとシアンの影が左右に小さく揺れる
export function glitch(text, { size = 14, color = C.yellow } = {}) {
  const copy = (c, from, to, period) =>
    div().absolute().top(0).left(0).text_color(c).opacity(0.75).loop("left", { from, to, period, easing: "linear" }).child(text);
  return div()
    .relative()
    .flex_none()
    .text_size(size)
    .font_bold()
    .child(copy(C.magenta, -1.5, 1, 1700))
    .child(copy(C.cyan, 1.5, -1, 2300))
    .child(div().relative().text_color(color).child(text));
}

// 走査線の重ね絵: 3px ごとに 1px のシアンの線。上に流れ、少しちらつく。
const LINES = 480; // 高さ 1440px ぶん。縦長の画面でも足りる数
export function scanlines() {
  return div()
    .absolute()
    .top(0)
    .left(0)
    .size_full()
    .overflow_hidden()
    .loop("opacity", { from: 0.04, to: 0.09, period: 2600 })
    .child(
      v_flex()
        .absolute()
        .left(0)
        .w_full()
        .gap(2)
        .loop("top", { from: 0, to: -3, period: 300, easing: "linear" })
        .children(Array.from({ length: LINES }, () => div().w_full().h(1).flex_none().bg(C.cyan))),
    );
}

// 四隅の鉤 (HUD の照準のような角)
function corners(color) {
  const k = () => div().absolute().size(7).border_color(color);
  return [
    k().top(-1).left(-1).border_t(2).border_l(2),
    k().top(-1).right(-1).border_t(2).border_r(2),
    k().bottom(-1).left(-1).border_b(2).border_l(2),
    k().bottom(-1).right(-1).border_b(2).border_r(2),
  ];
}

// 見出しの札: 黄色の地に黒い文字、右端は斜めに切る
export function tag(text, color = C.yellow) {
  return h_flex()
    .flex_none()
    .h(16)
    .items_center()
    .child(div().h_full().pl(6).pr(2).flex().items_center().bg(color).text_size(10.5).font_bold().text_color(C.bg).child(text))
    .child(icon("slant", 16, color).h(16).w(10));
}

// HUD 風のパネル: 細い枠と四隅の鉤、上に札と線と数
export function panel(id, title, body, { accent = C.cyan, count, right } = {}) {
  const head = h_flex()
    .h(24)
    .flex_none()
    .pl(6)
    .pr(6)
    .gap(6)
    .items_center()
    .child(tag(title))
    .child(div().flex_1().h(1).bg(C.line))
    .when(count !== undefined, (el) => el.child(div().flex_none().text_size(10.5).font_bold().text_color(accent).child(`[${String(count).padStart(2, "0")}]`)))
    .when(Boolean(right), (el) => el.child(right));
  return div()
    .id(id)
    .relative()
    .flex()
    .flex_col()
    .flex_1()
    .min_h(0)
    .border(1)
    .border_color(C.line)
    .bg(C.panel)
    .child(head)
    .child(v_flex().flex_1().min_h(0).child(body))
    .children(corners(accent));
}

// 四角いアイコンボタン。on: 押されている状態
export function button(id, name, onClick, { color = C.muted, tip, on = false, size = 20 } = {}) {
  return div()
    .id(id)
    .size(size)
    .flex_none()
    .flex()
    .items_center()
    .justify_center()
    .border(1)
    .border_color(on ? C.cyan : "#00000000")
    .bg(on ? C.raise : "#00000000")
    .hover((s) => s.bg(C.raise).border_color(C.cyan))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(icon(name, 11, on ? C.cyan : color));
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
