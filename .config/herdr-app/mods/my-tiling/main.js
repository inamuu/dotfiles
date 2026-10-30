// Tiling: タイル型ウィンドウマネージャ風の、文字だけで密度の高い実用レイアウト (layouts/my-tiling.json) の部品を 1 つの mod で。
// 上のバーは無く、端末の面積を最大にする。レイアウトが props { role } で役割を渡す:
//   tree    space とタブの木。いまの space はタブまで開き、タブへ直接移れる
//   agents  エージェントの表 (状態、名前、場所、経過時間)
//   pane    ペインの細い見出し
//   bar     下のバー: タブ (tmux のウィンドウ風)、エージェントの数、場所、ブランチ、時計、パネルの切り替え

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Tree from "./tree.js";
import Agents from "./agents.js";
import Pane from "./pane.js";
import Bar from "./bar.js";

const ROLES = { tree: Tree, agents: Agents, pane: Pane, bar: Bar };

export default class Tiling extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-tiling: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
