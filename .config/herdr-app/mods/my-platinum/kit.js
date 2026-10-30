// Platinum レイアウトの共通部品: 色、ドット絵アイコン、立体の縁、しま模様のタイトルバー、ウィンドウ。

import { div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { shared } from "herdr";

export const A = "mods/my-platinum/icons";

// 灰色の地に白と濃い灰色で立体の縁、黒い 1px の線。机の上は青紫。
export const C = {
  desk: "#6b6fa8",
  face: "#dddddd",
  light: "#ffffff",
  shadow: "#999999",
  dark: "#555555",
  ink: "#000000",
  paper: "#ffffff",
  pick: "#ccccff",
  hover: "#eeeeee",
  text: "#000000",
  muted: "#444444",
  dim: "#777777",
  blue: "#2f5fbf",
  red: "#c03030",
  green: "#2a8a3a",
  orange: "#c87a10",
  purple: "#7a3ab0",
  teal: "#1a8a8a",
};

export function icon(name, size, color) {
  return svg(`${A}/${name}.svg`).size(size).flex_none().text_color(color);
}

// 状態: 腕時計 (working、針が回る)、注意の三角 (blocked、明滅)、チェック (done)、月 (idle)
export const STATUS = {
  working: { icon: "watch", color: C.blue, label: "working" },
  blocked: { icon: "alert", color: C.red, label: "needs you" },
  done: { icon: "check", color: C.green, label: "done" },
  idle: { icon: "moon", color: C.dim, label: "idle" },
};

export function statusIcon(status, size = 12, frame = 0) {
  const s = STATUS[status] ?? STATUS.idle;
  const el = icon(status === "working" ? `watch-${frame}` : s.icon, size, s.color);
  return status === "blocked" ? div().flex_none().loop("opacity", { from: 0.3, to: 1, period: 900, easing: "linear" }).child(el) : el;
}

// 腕時計の針を動かすタイマー。working が見えている間だけ描き直す。
export function tick(view, cx, busy) {
  view.frame = 0;
  cx.timer.every(600, (cx) => {
    if (!busy()) return;
    view.frame ^= 1;
    cx.notify();
  });
}

// space の色 (my-spaces が決めた ansi 名) をこの配色に
const TONE = { ansi1: C.red, ansi2: C.green, ansi3: C.orange, ansi4: C.blue, ansi5: C.purple, ansi6: C.teal };
export function spaceColor(id) {
  return TONE[(shared("space.colors") ?? {})[id]] ?? C.blue;
}

// 立体の縁: 左上が白、右下が濃い灰色。sunken で逆 (くぼみ)。
export function bevel(el, { sunken = false } = {}) {
  return div()
    .flex()
    .bg(sunken ? C.light : C.shadow)
    .pr(1)
    .pb(1)
    .child(div().flex().flex_1().min_w(0).min_h(0).bg(sunken ? C.shadow : C.light).pl(1).pt(1).child(el.flex_1().min_w(0).min_h(0)));
}

// タイトルバーのしま: 濃い線と白い線の組を並べる
function stripes() {
  const pair = () => v_flex().flex_none().child(div().h(1).bg(C.shadow)).child(div().h(1).bg(C.light));
  return v_flex().flex_1().min_w(8).gap(1).children([pair(), pair(), pair(), pair()]);
}

// 四角い小さな箱 (閉じる、しまう など)
export function box(id, onClick, tip) {
  return div()
    .id(id)
    .size(11)
    .flex_none()
    .border(1)
    .border_color(C.ink)
    .bg(C.face)
    .hover((s) => s.bg(C.shadow))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick?.();
    })
    .child(div().size_full().border_l(1).border_t(1).border_color(C.light));
}

// タイトルバー。active のときだけしまと箱を出す (後ろのウィンドウは無地)。
export function titlebar(id, title, { active = true, onClose, right = [], h = 20 } = {}) {
  const label = h_flex().flex_none().max_w(320).px(6).gap(5).items_center().text_size(12).font_bold().text_color(active ? C.text : C.dim);
  return h_flex()
    .id(id)
    .h(h)
    .flex_none()
    .px(4)
    .gap(4)
    .items_center()
    .bg(C.face)
    .border_b(1)
    .border_color(C.ink)
    .when(active && Boolean(onClose), (el) => el.child(box(`${id}-close`, onClose, "Close")))
    .when(active, (el) => el.child(stripes()))
    .when(!active, (el) => el.child(div().flex_1()))
    .child(typeof title === "string" ? label.child(div().truncate().child(title)) : label.child(title))
    .when(active, (el) => el.child(stripes()))
    .when(!active, (el) => el.child(div().flex_1()))
    .children(right);
}

// ウィンドウ: 黒い枠、しまのタイトルバー、灰色の縁の中に白い紙。
export function win(id, title, body, opts = {}) {
  return v_flex()
    .id(id)
    .flex_1()
    .min_h(0)
    .border(1)
    .border_color(C.ink)
    .bg(C.face)
    .child(titlebar(`${id}-title`, title, opts))
    .child(
      v_flex()
        .flex_1()
        .min_h(0)
        .p(3)
        .child(v_flex().flex_1().min_h(0).border(1).border_color(C.dark).bg(C.paper).child(body)),
    );
}

// 一覧の上の列見出し (立体のボタンが並ぶ)
export function columns(cols) {
  return h_flex()
    .h(17)
    .flex_none()
    .border_b(1)
    .border_color(C.dark)
    .children(
      cols.map(([text, w]) =>
        bevel(div().px(5).items_center().flex().text_size(10.5).font_bold().text_color(C.muted).child(text)).h_full().when(w === 0, (el) => el.flex_1()).when(w > 0, (el) => el.w(w).flex_none()),
      ),
    );
}

// 机の上にウィンドウを置いたブロック
export function desk(inset, child) {
  return div().size_full().flex().flex_col().bg(C.desk).p(inset).child(child);
}

// 角の丸い押しボタン。on: 押されている状態
export function button(id, name, onClick, { color = C.text, tip, on = false, size = 20 } = {}) {
  return div()
    .id(id)
    .size(size)
    .flex_none()
    .flex()
    .items_center()
    .justify_center()
    .rounded(3)
    .border(1)
    .border_color(on ? C.ink : C.shadow)
    .bg(on ? C.shadow : C.face)
    .hover((s) => s.bg(C.hover).border_color(C.ink))
    .cursor_pointer()
    .when(Boolean(tip), (el) => el.tooltip(tip))
    .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
    .on_click((_e, cx) => {
      cx.stop_propagation();
      onClick();
    })
    .child(icon(name, 11, color));
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
