// Mother レイアウトの共通部品: 色、ドット絵、二重枠のウィンドウ、流れるサイケな背景、回るメーター。

import { div, svg, image } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { shared } from "herdr";

export const I = "mods/my-mother/icons";
export const S = "mods/my-mother/sprites";

// 黒いウィンドウに白と灰色の二重枠。背景はサイケなしま模様。
export const C = {
  win: "#0c0c14",
  hover: "#1e1e2e",
  pick: "#262640",
  edge: "#f8f8f8",
  inner: "#8890a8",
  text: "#f8f8f8",
  muted: "#c8c8d8",
  dim: "#8890a8",
  canvas: "#1a0b2e",
  yellow: "#f8d848",
  teal: "#58d8c8",
  pink: "#e05aa8",
  red: "#ff6070",
  green: "#78e068",
  orange: "#f0a040",
  blue: "#78a8f8",
};

export function icon(name, size, color) {
  return svg(`${I}/${name}.svg`).size(size).flex_none().text_color(color);
}

export function sprite(name, w, h, scale = 2) {
  return image(`${S}/${name}.svg`).w(w * scale).h(h * scale).flex_none();
}

// 状態: うずまき (working、2 コマ)、! (blocked、明滅)、星 (done)、Zz (idle)
export const STATUS = {
  working: { icon: "swirl", color: C.teal, word: "BUSY" },
  blocked: { icon: "bang", color: C.red, word: "SOS!" },
  done: { icon: "star", color: C.yellow, word: "WIN!" },
  idle: { icon: "zzz", color: C.dim, word: "Zzz" },
};

export function statusIcon(status, size = 12, frame = 0) {
  const s = STATUS[status] ?? STATUS.idle;
  const el = icon(status === "working" ? `swirl-${frame}` : s.icon, size, s.color);
  return status === "blocked" ? div().flex_none().loop("opacity", { from: 0.3, to: 1, period: 600, easing: "linear" }).child(el) : el;
}

export function statusWord(status, size = 11) {
  const s = STATUS[status] ?? STATUS.idle;
  return div()
    .flex_none()
    .text_size(size)
    .font_bold()
    .text_color(s.color)
    .when(status === "blocked", (el) => el.loop("opacity", { from: 0.3, to: 1, period: 600, easing: "linear" }))
    .child(s.word);
}

// うずまきを回すタイマー。working が見えている間だけ描き直す。
export function spin(view, cx, busy) {
  view.frame = 0;
  cx.timer.every(500, (cx) => {
    if (!busy()) return;
    view.frame ^= 1;
    cx.notify();
  });
}

// space の色 (my-spaces が決めた ansi 名) をこの配色に
const TONE = { ansi1: C.red, ansi2: C.green, ansi3: C.yellow, ansi4: C.blue, ansi5: C.pink, ansi6: C.teal };
export function spaceColor(id) {
  return TONE[(shared("space.colors") ?? {})[id]] ?? C.teal;
}

// 流れるサイケな背景。32px のタイルを 2 倍で敷きつめ、斜めにずっと流す。
// 1 タイル分 (64px) 動いたら元に戻るので、つなぎ目は見えない。
const T = 64;
export function psyche(variant = 0, { cols = 34, rows = 18, period = 6000 } = {}) {
  const row = () => h_flex().flex_none().children(Array.from({ length: cols }, () => sprite(`bg-${variant}`, 32, 32, 2)));
  return div()
    .absolute()
    .top(0)
    .left(0)
    .size_full()
    .overflow_hidden()
    .child(
      div()
        .absolute()
        .left(-T)
        .loop("top", { from: -T, to: 0, period, easing: "linear" })
        .child(
          v_flex()
            .absolute()
            .top(0)
            .loop("left", { from: 0, to: T, period: period * 1.6, easing: "linear" })
            .children(Array.from({ length: rows }, row)),
        ),
    );
}

// 二重枠のウィンドウ。外は白、内は灰色、角は丸い。title は上の枠に乗せる。
export function frame(id, title, body, { pad = 8, accent } = {}) {
  const win = div()
    .id(`${id}-win`)
    .flex()
    .flex_col()
    .flex_1()
    .min_h(0)
    .border(2)
    .border_color(accent ?? C.edge)
    .rounded(7)
    .bg(C.win)
    .p(2)
    .child(
      div()
        .flex()
        .flex_col()
        .flex_1()
        .min_h(0)
        .border(2)
        .border_color(C.inner)
        .rounded(4)
        .bg(C.win)
        .pt(title ? 12 : pad / 2)
        .px(pad / 2)
        .pb(pad / 2)
        .child(body),
    );
  return div()
    .id(id)
    .relative()
    .flex()
    .flex_col()
    .flex_1()
    .min_h(0)
    .pt(title ? 9 : 0)
    .child(win)
    .when(Boolean(title), (el) =>
      el.child(
        div()
          .absolute()
          .top(0)
          .left(14)
          .px(6)
          .h(20)
          .flex()
          .items_center()
          .border(2)
          .border_color(C.edge)
          .rounded(4)
          .bg(C.win)
          .text_size(12)
          .font_bold()
          .text_color(C.text)
          .child(title),
      ),
    );
}

// 背景の上にウィンドウを浮かべたブロック
export function scene(variant, inset, child, opts) {
  return div().relative().size_full().overflow_hidden().bg(C.canvas).child(psyche(variant, opts)).child(div().relative().size_full().flex().flex_col().p(inset).child(child));
}

// 回るメーター: 数字を 1 けたずつ枠に入れる。roll のとき一の位がくるくる回り続ける。
const DH = 16;
export function meter(n, { digits = 3, roll = false, color = C.text } = {}) {
  const s = String(Math.max(0, Math.min(10 ** digits - 1, n))).padStart(digits, " ");
  const cell = (child) =>
    div().relative().w(11).h(DH).flex_none().overflow_hidden().bg(C.edge).rounded(2).text_size(12.5).font_bold().text_color(C.win).child(child);
  const digit = (ch) => div().w_full().h(DH).flex().items_center().justify_center().child(ch.trim() ? ch : "");
  const cells = [...s].map((ch, i) =>
    i === digits - 1 && roll
      ? cell(
          v_flex()
            .absolute()
            .top(0)
            .left(0)
            .w_full()
            .loop("top", { from: 0, to: -DH * 10, period: 4000, easing: "linear" })
            .children([..."01234567890"].map(digit)),
        )
      : cell(digit(ch)),
  );
  return h_flex().flex_none().gap(1).p(1).bg(color).rounded(3).children(cells);
}

// 四角いアイコンボタン。on: 押されている状態
export function button(id, name, onClick, { color = C.muted, tip, on = false, size = 22 } = {}) {
  return div()
    .id(id)
    .size(size)
    .flex_none()
    .flex()
    .items_center()
    .justify_center()
    .rounded(4)
    .border(1)
    .border_color(on ? C.edge : "#00000000")
    .bg(on ? C.pick : "#00000000")
    .hover((s) => s.bg(C.hover).border_color(C.inner))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(icon(name, 12, on ? C.text : color));
}

// 選択中の行の頭に付く手のカーソル (ちょっと揺れる)
export function cursor(on, size = 12) {
  return div()
    .relative()
    .w(size + 2)
    .h(size)
    .flex_none()
    .when(on, (el) => el.child(div().absolute().top(0).loop("left", { from: 0, to: 2, period: 700 }).child(icon("hand", size, C.text))));
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
