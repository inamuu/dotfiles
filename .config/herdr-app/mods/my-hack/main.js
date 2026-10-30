// Hack: 緑の端末風のレイアウト (layouts/my-hack.json) の部品を 1 つの mod で。
// レイアウトが props { role } で役割を渡す:
//   hud     上の帯: どくろとグリッチするロゴ、接続先、プロセス数、16 進数、レーダー、時計
//   spaces  `ls` 風の space 一覧
//   party   `ps` 風のエージェント一覧
//   tabs    [1:name] のタブ
//   pane    ペインの見出し
//   matrix  右端の文字の雨
//   log     下の状態変化ログ

import { View, div } from "gpui-kit";
import { props } from "herdr";
import Hud from "./hud.js";
import { Spaces, Party } from "./side.js";
import Tabs from "./tabs.js";
import Pane from "./pane.js";
import Matrix from "./matrix.js";
import Log from "./log.js";

const ROLES = { hud: Hud, spaces: Spaces, party: Party, tabs: Tabs, pane: Pane, matrix: Matrix, log: Log };

export default class Hack extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const R = ROLES[pr.role];
    this.role = R ? new R() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`my-hack: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
