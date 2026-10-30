// Mother: 二重枠のウィンドウとサイケな背景の実用レイアウト (layouts/my-mother.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   hud     上のタイトルバー: 流れ星のロゴ、space › tab、サイドバー開閉
//   spaces  space 一覧 (町の家)
//   agents  エージェント一覧
//   tabs    タブの列と Files / Changes パネルの切り替え
//   pane    ペインの見出し
//   party   下の仲間の欄: エージェントごとのカードと回るメーター、場所、時計

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Hud from "./hud.js";
import { Spaces, Agents } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";
import Party from "./party.js";

const ROLES = { hud: Hud, spaces: Spaces, agents: Agents, tabs: Tabs, pane: Pane, party: Party };

export default class Mother extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-mother: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
