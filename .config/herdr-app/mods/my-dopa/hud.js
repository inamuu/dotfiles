// 上の帯: 跳ねる虹色ロゴ、いまの space / tab、スコアとコンボ、XP バー、時計。
// エージェントが終わる (done になる) たびに得点。90 秒以内に続けて終わるとコンボで倍率が上がる。

import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { spaces, agents, window } from "herdr";
import { C, hue, pulse, icon, statusIcon } from "./kit.js";

const COMBO_WINDOW = 90000;
const pad = (n) => String(n).padStart(2, "0");

function load(key, fallback) {
  try {
    return JSON.parse(localStorage.getItem(key) ?? "null") ?? fallback;
  } catch {
    return fallback;
  }
}

export default class Hud {
  init(_p, cx) {
    this.seen = {}; // address -> status
    this.score = load("score", 0);
    this.combo = 0;
    this.lastDone = 0;
    this.burst = null; // { text, until }
    pulse(cx);
  }

  // done になったエージェントを数えて得点にする
  tally() {
    const now = Date.now();
    for (const a of agents()) {
      const before = this.seen[a.address];
      if (before && before !== "done" && a.status === "done") {
        this.combo = now - this.lastDone < COMBO_WINDOW ? this.combo + 1 : 1;
        this.lastDone = now;
        const gain = 100 * this.combo;
        this.score += gain;
        this.burst = { text: this.combo > 1 ? `+${gain}  COMBO x${this.combo}!!` : `+${gain}!!`, until: now + 2600 };
        try { localStorage.setItem("score", JSON.stringify(this.score)); } catch {}
      }
      this.seen[a.address] = a.status;
    }
    if (this.combo && now - this.lastDone > COMBO_WINDOW) this.combo = 0;
  }

  logo() {
    return h_flex()
      .flex_none()
      .gap(1)
      .items_end()
      .h(30)
      .children(
        [..."DOPA!!"].map((ch, i) =>
          div()
            .relative()
            .w(ch === "!" ? 9 : 16)
            .h(30)
            .child(
              div()
                .absolute()
                .text_size(22)
                .font_bold()
                .text_color(hue(i))
                .loop("top", { from: 6, to: -2, period: 520 + i * 70 })
                .child(ch),
            ),
        ),
      );
  }

  render() {
    this.tally();
    const w = window();
    const lights = w?.platform === "macos" && w?.titlebar === "none" && !w?.fullscreen;
    const s = spaces().find((x) => x.active);
    const tab = s?.tabs.find((x) => x.active);
    const all = agents();
    const now = new Date();
    const counts = ["working", "blocked", "done"]
      .map((st) => [st, all.filter((a) => a.status === st).length])
      .filter(([, n]) => n > 0);
    const burst = this.burst && this.burst.until > Date.now() ? this.burst : null;
    const level = Math.floor(this.score / 1000) + 1;
    const xp = (this.score % 1000) / 1000;
    return h_flex()
      .size_full()
      .pl(lights ? 84 : 16)
      .pr(16)
      .gap(18)
      .items_center()
      .bg(C.chrome)
      .border_b(3)
      .border_color(hue(3))
      .child(icon("crown", 22, hue(1)).spin(3000))
      .child(this.logo())
      .child(
        h_flex()
          .flex_1()
          .min_w(0)
          .gap(10)
          .items_center()
          .justify_center()
          .when(Boolean(burst), (el) =>
            el.child(
              h_flex()
                .gap(8)
                .items_center()
                .loop("opacity", { from: 0.4, to: 1, period: 260, easing: "linear" })
                .child(icon("burst", 26, hue()).spin(600))
                .child(div().text_size(20).font_bold().text_color(hue(2)).child(burst.text))
                .child(icon("burst", 26, hue(4)).spin(600)),
            ),
          )
          .when(!burst, (el) =>
            el
              .child(icon("sparkle", 14, hue(5)).spin(1500))
              .child(div().min_w(0).truncate().text_size(15).font_bold().text_color(C.text).child(s ? `${s.name}  //  ${tab?.name ?? ""}` : ""))
              .child(icon("sparkle", 14, hue(2)).spin(1500)),
          ),
      )
      .child(
        h_flex()
          .flex_none()
          .gap(10)
          .items_center()
          .children(
            counts.map(([st, n]) =>
              h_flex().gap(4).items_center().child(statusIcon(st, 16)).child(div().text_size(13).font_bold().text_color(C.text).child(`x${n}`)),
            ),
          ),
      )
      .child(
        v_flex()
          .flex_none()
          .w(150)
          .gap(3)
          .child(
            h_flex()
              .justify_between()
              .text_size(11)
              .font_bold()
              .child(div().text_color(hue(1)).child(`LV.${level}`))
              .child(div().text_color(C.text).child(`${this.score.toLocaleString()} pts`))
              .when(this.combo > 1, (el) =>
                el.child(div().text_color(C.yellow).loop("opacity", { from: 0.3, to: 1, period: 300 }).child(`x${this.combo}`)),
              ),
          )
          .child(
            div()
              .h(8)
              .w_full()
              .rounded(999)
              .bg(C.card)
              .overflow_hidden()
              .child(div().h_full().w(Math.max(6, 150 * xp)).rounded(999).bg(hue()).loop("opacity", { from: 0.6, to: 1, period: 500 })),
          ),
      )
      .child(div().flex_none().text_size(14).font_bold().text_color(hue(4)).child(`${pad(now.getHours())}:${pad(now.getMinutes())}`));
  }
}
