// 左の 2 つの窓。
//   Spaces  `ls /mnt/spaces` のように space を並べる。いまの space は反転表示。クリックで移動、右クリックでメニュー。
//   Party   `ps` のようにエージェントを並べる。状態は [ |/-\ ] [ !! ] [ OK ] [ -- ]。クリックでそのペインへ。

import { div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, agents, run, openOverlay, setAgentOrder } from "herdr";
import { C, box, stat, caret, LABEL } from "./kit.js";

function line(id, on) {
  return h_flex()
    .id(id)
    .flex_none()
    .px(4)
    .gap(8)
    .items_center()
    .text_size(12)
    .cursor_pointer()
    .when(on, (el) => el.bg(C.green))
    .when(!on, (el) => el.hover((s) => s.bg(C.hover)));
}

export class Spaces {
  render() {
    const sp = spaces();
    const list = sp.map((s, i) =>
      line(`hk-space-${s.id}`, s.active)
        .h(24)
        .on_click(() => run("space.select", { id: s.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: s.id } } }),
        )
        .child(div().flex_none().text_color(s.active ? C.bg : C.dim).child(s.machine ? "lrwx" : "drwx"))
        .child(div().flex_none().text_color(s.active ? C.bg : C.dim).child(String(i + 1).padStart(2, "0")))
        .child(div().flex_1().min_w(0).truncate().font_bold().text_color(s.active ? C.bg : C.text).child(`${s.name}/`))
        .when(Boolean(s.status) && s.status !== "idle", (el) => el.child(stat(s.status, 11))),
    );
    const prompt = line("hk-space-new", false)
      .h(24)
      .on_click(() => run("space.new"))
      .child(div().flex_none().text_color(C.green).child("$"))
      .child(div().flex_none().text_color(C.muted).child("mkdir new_space"))
      .child(caret(11));
    return box(
      "hk-spaces",
      "SPACES",
      v_flex()
        .flex_1()
        .min_h(0)
        .overflow_y_scrollbar()
        .gap(1)
        .child(div().h(20).flex_none().px(4).text_size(11.5).text_color(C.dim).child("$ ls -l /mnt/spaces"))
        .children([...list, prompt]),
      { right: div().text_size(11).text_color(C.dim).child(`total ${sp.length}`) },
    );
  }
}

export class Party {
  render() {
    const all = agents();
    setAgentOrder(all.map((a) => a.address));
    const head = h_flex()
      .h(20)
      .flex_none()
      .px(4)
      .gap(8)
      .text_size(11)
      .text_color(C.dim)
      .child(div().w(46).flex_none().child("STAT"))
      .child(div().w(44).flex_none().child("PID"))
      .child(div().flex_1().child("CMD"));
    const list = all.map((a) =>
      line(`hk-agent-${a.address}`, a.focused)
        .h(36)
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .child(div().w(46).flex_none().child(a.focused ? div().text_size(11).font_bold().text_color(C.bg).child(`[${LABEL[a.status]?.slice(0, 2) ?? "--"}]`) : stat(a.status, 11)))
        .child(div().w(44).flex_none().text_size(11).text_color(a.focused ? C.bg : C.dim).child(a.address.replace(/^.*\//, "")))
        .child(
          v_flex()
            .flex_1()
            .min_w(0)
            .child(div().truncate().font_bold().text_color(a.focused ? C.bg : C.text).child((a.program?.key ?? a.app ?? "agent").toLowerCase()))
            .child(div().truncate().text_size(10.5).text_color(a.focused ? C.bg : C.dim).child(`${a.space_name}/${a.tab_name}  ${LABEL[a.status] ?? ""}`)),
        ),
    );
    const empty = div().px(4).py(6).text_size(12).text_color(C.dim).child("no processes found");
    return box(
      "hk-party",
      "PROCESSES",
      v_flex()
        .flex_1()
        .min_h(0)
        .overflow_y_scrollbar()
        .gap(1)
        .child(div().h(20).flex_none().px(4).text_size(11.5).text_color(C.dim).child("$ ps -ef | grep agent"))
        .child(head)
        .children(list.length ? list : [empty]),
      { right: div().text_size(11).text_color(C.dim).child(`${all.length} procs`) },
    );
  }
}
