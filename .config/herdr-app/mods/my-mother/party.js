// 下の仲間の欄: しま模様の上に小さなウィンドウを並べる。
//   左      いまのペインの場所とブランチ
//   中      エージェント 1 人に 1 枚のカード。名前と状態、その状態になってからの分数をメーターで。
//           working の間はメーターの一の位が回り続ける。blocked のカードは赤い枠。
//   右      時計

import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { agents, spaces, panes, run, home } from "herdr";
import { C, STATUS, icon, statusIcon, statusWord, spin, meter, frame, scene, short, pad } from "./kit.js";

const MAX = 6; // カードはこの枚数まで。残りは +N

export default class Party {
  init(_p, cx) {
    spin(this, cx, () => agents().some((a) => a.status === "working"));
    cx.timer.every(20000, (cx) => cx.notify());
  }

  card(a, t, now) {
    const since = a.status === "working" ? t?.working_since : t?.changed_at;
    const min = since ? Math.floor((now - since) / 60000) : 0;
    const st = STATUS[a.status] ?? STATUS.idle;
    const body = v_flex()
      .flex_1()
      .justify_center()
      .gap(2)
      .child(
        h_flex()
          .gap(5)
          .items_center()
          .child(statusIcon(a.status, 11, this.frame))
          .child(div().flex_1().min_w(0).truncate().text_size(12).font_bold().text_color(a.focused ? C.yellow : C.text).child(a.program?.name ?? a.app ?? "agent"))
          .child(statusWord(a.status, 10.5)),
      )
      .child(
        h_flex()
          .gap(5)
          .items_center()
          .child(div().flex_none().text_size(10.5).font_bold().text_color(C.muted).child("MIN"))
          .child(meter(min, { roll: a.status === "working", color: st.color })),
      );
    return div()
      .id(`mo-card-${a.address}`)
      .w(150)
      .h_full()
      .flex()
      .flex_none()
      .cursor_pointer()
      .on_click(() => run("pane.focus", { pane: a.pane }))
      .child(frame(`mo-cardf-${a.address}`, null, body, { pad: 4, accent: a.status === "blocked" ? C.red : undefined }));
  }

  render() {
    const p = panes().find((x) => x.focused);
    const all = agents();
    const tabs = {};
    for (const s of spaces()) for (const t of s.tabs) tabs[t.id] = t;
    const now = Date.now();
    const d = new Date(now);
    const where = v_flex()
      .flex_1()
      .min_w(0)
      .justify_center()
      .gap(3)
      .text_size(11.5)
      .child(div().min_w(0).truncate().text_color(C.muted).child(short(p?.cwd, home()) || "-"))
      .when(Boolean(p?.branch), (el) =>
        el.child(h_flex().gap(4).items_center().child(icon("branch", 10, C.pink)).child(div().min_w(0).truncate().text_color(C.pink).child(p.branch))),
      );
    const cards = all.slice(0, MAX).map((a) => this.card(a, tabs[a.tab], now));
    const more = all.length - MAX;
    const clock = v_flex()
      .flex_1()
      .items_center()
      .justify_center()
      .child(div().text_size(15).font_bold().text_color(C.text).child(`${pad(d.getHours())}:${pad(d.getMinutes())}`));
    return scene(
      0,
      5,
      h_flex()
        .size_full()
        .gap(6)
        .child(div().flex_1().min_w(160).h_full().flex().child(frame("mo-where", null, where, { pad: 8 })))
        .children(cards)
        .when(more > 0, (el) => el.child(div().flex_none().h_full().flex().items_center().px(4).text_size(12).font_bold().text_color(C.text).child(`+${more}`)))
        .child(div().w(76).h_full().flex().flex_none().child(frame("mo-clock", null, clock, { pad: 4 }))),
      { cols: 64, rows: 3, period: 7000 },
    );
  }
}
