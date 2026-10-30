// 上の帯: どくろとグリッチするロゴ、接続先 (space / tab)、プロセス数、流れる 16 進数、回るレーダー、秒まで出る時計。

import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, window } from "herdr";
import { C, icon, pad } from "./kit.js";

const GLITCH = ["HERDR//NET", "HERDR//NET", "HERDR//NET", "H3RDR//N3T", "HERDR//NET", "HE#DR//NE7", "HERDR//NET", "HERDR//NET", "#3RD?//NET", "HERDR//NET"];

function hexes(n, len) {
  const out = [];
  for (let i = 0; i < n; i++) {
    let s = "";
    for (let j = 0; j < len; j++) s += "0123456789ABCDEF"[Math.floor(Math.random() * 16)];
    out.push(`0x${s}`);
  }
  return out;
}

function stat(label, value, color = C.text) {
  return h_flex()
    .flex_none()
    .gap(5)
    .text_size(11.5)
    .child(div().text_color(C.dim).child(label))
    .child(div().font_bold().text_color(color).child(String(value)));
}

export default class Hud {
  init(_p, cx) {
    this.hex = hexes(24, 8);
    cx.timer.every(1000, (cx) => cx.notify());
  }

  render() {
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const sp = spaces();
    const s = sp.find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const all = agents();
    const n = (st) => all.filter((a) => a.status === st).length;
    const now = new Date();
    return h_flex()
      .size_full()
      .pl(lights ? 84 : 14)
      .pr(14)
      .gap(16)
      .items_center()
      .bg(C.bg)
      .border_b(1)
      .border_color(C.line)
      .child(icon("skull", 18, C.green).loop("opacity", { from: 0.5, to: 1, period: 1400 }))
      .child(div().flex_none().w(100).text_size(14).font_bold().text_color(C.green).frames(GLITCH, 140))
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(8)
          .items_center()
          .text_size(12)
          .child(icon(n("blocked") ? "unlock" : "lock", 12, n("blocked") ? C.amber : C.dim))
          .child(div().flex_none().text_color(C.dim).child("ssh"))
          .child(div().min_w(0).truncate().text_color(C.text).child(`root@${s?.name ?? "?"}:${tab?.name ?? ""}`))
          .child(div().flex_none().text_color(C.dim).child("::"))
          .child(div().flex_none().text_color(C.muted).child("CONNECTED")),
      )
      .child(stat("SPC", sp.length))
      .child(stat("PROC", all.length))
      .child(stat("RUN", n("working"), C.green))
      .child(stat("WAIT", n("blocked"), n("blocked") ? C.amber : C.text))
      .child(div().flex_none().w(90).text_size(11.5).text_color(C.dim).frames(this.hex, 90))
      .child(icon("radar", 16, C.green).spin(1600))
      .child(
        div()
          .flex_none()
          .text_size(13)
          .font_bold()
          .text_color(C.green)
          .child(`${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`),
      );
  }
}
