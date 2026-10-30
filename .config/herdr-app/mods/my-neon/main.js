// Neon: サイバーパンク風 (夜の黒にネオン、HUD の枠、ずれる文字、走査線) の実用レイアウト (layouts/my-neon.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   hud     上のタイトルバー: 目のロゴとずれる文字、space › tab、サイドバー開閉
//   spaces  space 一覧
//   agents  エージェント一覧
//   tabs    タブの列と Files / Changes パネルの切り替え
//   pane    ペインの見出し
//   status  下のステータスバー

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Hud from "./hud.js";
import { Spaces, Agents } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";
import Status from "./status.js";

const ROLES = { hud: Hud, spaces: Spaces, agents: Agents, tabs: Tabs, pane: Pane, status: Status };

export default class Neon extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-neon: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
