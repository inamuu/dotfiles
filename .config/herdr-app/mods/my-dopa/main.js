// Dopa: 刺激過多なネオンのレイアウト (layouts/my-dopa.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   hud     上の帯: 跳ねるロゴ、space / tab、スコアとコンボ、XP バー、時計
//   spaces  space のカード
//   party   エージェントのカード
//   tabs    タブのピル
//   pane    ペインの見出し
//   ticker  下のニュース速報

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Hud from "./hud.js";
import { Spaces, Party } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";
import Ticker from "./ticker.js";

const ROLES = { hud: Hud, spaces: Spaces, party: Party, tabs: Tabs, pane: Pane, ticker: Ticker };

export default class Dopa extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-dopa: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
