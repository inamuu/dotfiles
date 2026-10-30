// Mario 風のレイアウト (layouts/my-mario.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   hud     上の帯: 名前、コイン、ワールド、時計
//   spaces  スペース一覧 (土管)
//   party   エージェント一覧 (ブロック)
//   tabs    タブの欄
//   pane    ペインの見出し
//   ground  下の地面と走る主人公

import { View, div } from "gpui-kit";
import { props } from "herdr";
import { loadOwn } from "./kit.js";
import Hud from "./hud.js";
import { Spaces, Party } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";
import Ground from "./ground.js";

const ROLES = { hud: Hud, spaces: Spaces, party: Party, tabs: Tabs, pane: Pane, ground: Ground };

export default class Mario extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
    cx.spawn(async (cx) => {
      await loadOwn();
      cx.notify();
    });
  }

  render(cx) {
    if (!this.role) return div().child(`my-mario: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
