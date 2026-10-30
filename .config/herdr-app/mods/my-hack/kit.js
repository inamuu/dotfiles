// Hack の共通部品: 緑の端末色、ASCII の枠、状態ごとの表示、文字ボタン。

import { div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";

export const A = "mods/my-hack/icons";

export const C = {
  bg: "#000000",
  panel: "#000a03",
  line: "#0f5a26",
  green: "#33ff66",
  text: "#a8ffb8",
  muted: "#5fd87e",
  dim: "#2e8a48",
  faint: "#123d1e",
  hover: "#00300f",
  amber: "#ffb000",
  red: "#ff3355",
  cyan: "#2affd5",
};

export const SPIN = ["|", "/", "-", "\\"];

// 状態の表示: [ |/-\ ] 実行中、[ !! ] 入力待ち (点滅)、[ OK ] 完了、[ -- ] 待機
export function stat(status, size = 11) {
  const base = div().flex_none().text_size(size).font_bold();
  if (status === "working") return base.text_color(C.green).frames(SPIN.map((s) => `[ ${s}  ]`), 110);
  if (status === "blocked") return base.text_color(C.amber).loop("opacity", { from: 0.1, to: 1, period: 500, easing: "linear" }).child("[ !! ]");
  if (status === "done") return base.text_color(C.cyan).child("[ OK ]");
  return base.text_color(C.dim).child("[ -- ]");
}

export const LABEL = { working: "RUNNING", blocked: "AWAIT_INPUT", done: "EXIT 0", idle: "SLEEP" };

export function icon(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// 点滅するブロックカーソル
export function caret(size = 12, color = C.green) {
  return div().w(size * 0.6).h(size + 2).flex_none().bg(color).loop("opacity", { from: 0, to: 1, period: 1000, easing: "linear" });
}

// 端末の窓: 上に "┌─[ TITLE ]───" の見出し、細い緑の枠
export function box(id, title, body, { right } = {}) {
  return v_flex()
    .id(id)
    .size_full()
    .border(1)
    .border_color(C.line)
    .bg(C.panel)
    .child(
      h_flex()
        .h(24)
        .flex_none()
        .px(8)
        .gap(6)
        .items_center()
        .border_b(1)
        .border_color(C.line)
        .text_size(11.5)
        .child(div().text_color(C.dim).child("┌─["))
        .child(div().font_bold().text_color(C.green).child(title))
        .child(div().text_color(C.dim).child("]"))
        .child(div().flex_1().h(1).bg(C.faint))
        .when(Boolean(right), (el) => el.child(right)),
    )
    .child(v_flex().flex_1().min_h(0).p(6).child(body));
}

// [x] のような文字のボタン
export function key(id, label, onClick, { color = C.muted, tip } = {}) {
  return div()
    .id(id)
    .flex_none()
    .px(3)
    .text_size(11.5)
    .font_bold()
    .text_color(color)
    .cursor_pointer()
    .hover((s) => s.bg(color).text_color(C.bg))
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(label);
}

export function short(path, home) {
  if (!path) return "";
  return home && path.startsWith(home) ? `~${path.slice(home.length)}` : path;
}

// 文字を 1 つずつ打つように見せる: 途中までの文字列を並べ、最後は長く止める
export function typing(text, hold = 80) {
  const steps = [];
  for (let i = 1; i <= text.length; i++) steps.push(text.slice(0, i));
  for (let i = 0; i < hold; i++) steps.push(text);
  return steps;
}

export const pad = (n, w = 2) => String(n).padStart(w, "0");
