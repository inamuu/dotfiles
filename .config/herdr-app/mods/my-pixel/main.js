// Pixel Quest: レトロ RPG 風のレイアウト (layouts/my-pixel.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   hud     上の帯: ロゴ、ステージ、パーティ、時計
//   spaces  スペース一覧 (家)
//   party   エージェント一覧 (スライム)
//   tabs    タブの欄
//   pane    ペインの見出し
//   ground  下の地面と歩く勇者

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Hud from "./hud.js";
import { Spaces, Party } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";
import Ground from "./ground.js";

const ROLES = { hud: Hud, spaces: Spaces, party: Party, tabs: Tabs, pane: Pane, ground: Ground };

export default class Pixel extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-pixel: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
