// Platinum: 昔の Mac 風 (灰色の立体、しまのタイトルバー) の実用レイアウト (layouts/my-platinum.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   menubar 上のメニューバー: 羊のロゴ、space › tab、エージェントの数、時計、サイドバー開閉
//   spaces  space 一覧のウィンドウ
//   agents  エージェント一覧のウィンドウ
//   tabs    タブの列と Files / Changes パネルの切り替え
//   pane    ペインのタイトルバー

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Menubar from "./menubar.js";
import { Spaces, Agents } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";

const ROLES = { menubar: Menubar, spaces: Spaces, agents: Agents, tabs: Tabs, pane: Pane };

export default class Platinum extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-platinum: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
