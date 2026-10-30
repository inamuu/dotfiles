// space ごとのブランチの PR と CI の状態を一覧にする。
//   1 行目  space 名、ブランチ。クリックでその space へ
//   2 行目  #番号 タイトル。クリックでブラウザに PR を開く
//   3 行目  CI (通った数/全体、落ちたものはツールチップに名前)、レビュー状態、draft / merged / closed
// ブランチは space 内のペインの cwd から取り、gh pr view をそのフォルダで実行する。
// main / master は対象外。90 秒ごとに更新し、新しいブランチが見えたらすぐ取りに行く。
// CI が実行中から成功 / 失敗に変わったら通知する。見出しの [r] で今すぐ更新。

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, panes, exec, run, theme, notify, props } from "herdr";

const SKIP = new Set(["main", "master", "develop", "HEAD"]);
const FIELDS = "number,title,url,state,isDraft,reviewDecision,statusCheckRollup";
const FULL_MS = 90000;

// 落ちた / 待ち / 通った を statusCheckRollup から数える (CheckRun と StatusContext の両方)
function checks(rollup) {
  const fail = [];
  let pending = 0;
  let pass = 0;
  for (const c of rollup ?? []) {
    const name = c.name ?? c.context ?? "?";
    if (c.__typename === "StatusContext") {
      if (c.state === "SUCCESS") pass++;
      else if (c.state === "PENDING" || c.state === "EXPECTED") pending++;
      else fail.push(name);
      continue;
    }
    if (c.status !== "COMPLETED") pending++;
    else if (["SUCCESS", "SKIPPED", "NEUTRAL"].includes(c.conclusion)) pass++;
    else fail.push(name);
  }
  const total = fail.length + pending + pass;
  const state = total === 0 ? "none" : fail.length ? "fail" : pending ? "pending" : "pass";
  return { state, fail, pending, pass, total };
}

// space ごとに調べるフォルダとブランチ。ブランチのあるペインを優先し、無ければ space の folder
function targets() {
  const all = spaces();
  const spaceOf = {};
  for (const s of all) for (const t of s.tabs) spaceOf[t.id] = s;
  const found = new Map();
  for (const p of panes()) {
    const s = spaceOf[p.tab];
    if (!s || !p.cwd || !p.branch || found.has(s.id)) continue;
    found.set(s.id, { cwd: p.cwd, branch: p.branch });
  }
  return all
    .map((s) => {
      const f = found.get(s.id) ?? (s.branch && s.folder ? { cwd: s.folder, branch: s.branch } : null);
      if (!f || SKIP.has(f.branch)) return null;
      return { space: s, ...f, key: `${s.machine ?? ""}|${f.cwd}|${f.branch}` };
    })
    .filter(Boolean);
}

export default class Prs extends View {
  init(_p, cx) {
    this.data = {}; // key -> { pr, ci, error, at }
    this.busy = false;
    this.lastFull = 0;
    cx.timer.every(5000, (cx) => this.tick(cx));
    this.tick(cx);
  }

  tick(cx, force = false) {
    if (this.busy) return;
    const now = Date.now();
    const full = force || now - this.lastFull > FULL_MS;
    const list = targets().filter((t) => full || !this.data[t.key]);
    if (!list.length) return;
    if (full) this.lastFull = now;
    this.busy = true;
    cx.spawn(async (cx) => {
      try {
        for (const t of list) await this.fetch(t);
      } finally {
        this.busy = false;
        cx.notify();
      }
    });
  }

  async fetch(t) {
    const prev = this.data[t.key];
    let r;
    try {
      r = await exec("gh", ["pr", "view", t.branch, "--json", FIELDS], { cwd: t.cwd, on: t.space.machine });
    } catch (e) {
      this.data[t.key] = { pr: null, error: String(e?.message ?? e), at: Date.now() };
      return;
    }
    if (r.code !== 0) {
      const none = /no (pull requests|open pull requests) found/i.test(r.stderr);
      this.data[t.key] = { pr: null, error: none ? null : r.stderr.trim().split("\n")[0], at: Date.now() };
      return;
    }
    const pr = JSON.parse(r.stdout);
    const ci = checks(pr.statusCheckRollup);
    this.data[t.key] = { pr, ci, error: null, at: Date.now() };
    // CI が実行中から結果に変わったときだけ知らせる (起動直後の 1 回目は黙る)
    if (prev?.ci?.state === "pending" && prev.pr?.number === pr.number && (ci.state === "pass" || ci.state === "fail")) {
      notify({
        title: ci.state === "pass" ? `CI passed: #${pr.number}` : `CI failed: #${pr.number}`,
        body: ci.state === "fail" ? `${pr.title}\n${ci.fail.join(", ")}` : pr.title,
        level: ci.state === "pass" ? "success" : "error",
        action: { name: "space.select", args: { id: t.space.id } },
      });
    }
  }

  ciBadge(id, ci, c) {
    if (!ci || ci.state === "none") return div().flex_none().text_color(c.dim).child("CI -");
    const look = {
      pass: { mark: "✓", color: c.done },
      fail: { mark: "✗", color: c.blocked },
      pending: { mark: "●", color: c.working },
    }[ci.state];
    const tip = [ci.fail.length ? `failed: ${ci.fail.join(", ")}` : null, ci.pending ? `running: ${ci.pending}` : null, `passed: ${ci.pass}/${ci.total}`]
      .filter(Boolean)
      .join("\n");
    return h_flex()
      .id(id)
      .flex_none()
      .gap(3)
      .text_color(look.color)
      .tooltip(tip)
      .child(ci.state === "pending" ? div().child(look.mark).loop("opacity", { from: 0.3, to: 1, period: 1200 }) : div().child(look.mark))
      .child(div().child(`CI ${ci.pass}/${ci.total}`));
  }

  review(pr, c) {
    if (pr.state === "MERGED") return div().flex_none().text_color(c.ansi5).child("merged");
    if (pr.state === "CLOSED") return div().flex_none().text_color(c.dim).child("closed");
    const r = {
      APPROVED: ["approved", c.done],
      CHANGES_REQUESTED: ["changes", c.blocked],
      REVIEW_REQUIRED: ["review", c.working],
    }[pr.reviewDecision];
    return r ? div().flex_none().text_color(r[1]).child(r[0]) : null;
  }

  row(t, c) {
    const d = this.data[t.key];
    const s = t.space;
    const head = h_flex()
      .id(`prs-space-${s.id}`)
      .gap(6)
      .items_center()
      .cursor_pointer()
      .hover((st) => st.text_color(c.foreground))
      .on_click(() => run("space.select", { id: s.id }))
      .child(div().flex_none().max_w(140).truncate().font_bold().text_color(s.active ? c.foreground : c.muted).child(s.machine ? `${s.machine}:${s.name}` : s.name))
      .child(div().min_w(0).truncate().text_color(c.ansi5).child(t.branch));

    let body;
    if (!d) body = div().text_color(c.dim).child("...");
    else if (d.error) body = div().truncate().text_color(c.blocked).tooltip(d.error).child(d.error);
    else if (!d.pr) body = div().text_color(c.dim).child("PR なし");
    else {
      const pr = d.pr;
      body = v_flex()
        .gap(2)
        .child(
          h_flex()
            .id(`prs-pr-${s.id}`)
            .gap(6)
            .cursor_pointer()
            .hover((st) => st.text_color(c.accent))
            .tooltip(pr.url)
            .on_click(() => exec("open", [pr.url]))
            .child(div().flex_none().text_color(c.accent).child(`#${pr.number}`))
            .child(div().min_w(0).truncate().child(pr.title)),
        )
        .child(
          h_flex()
            .gap(10)
            .items_center()
            .children(
              [
                this.ciBadge(`prs-ci-${s.id}`, d.ci, c),
                this.review(pr, c),
                pr.isDraft && pr.state === "OPEN" ? div().flex_none().text_color(c.dim).child("draft") : null,
              ].filter(Boolean),
            ),
        );
    }
    return v_flex()
      .px(10)
      .py(6)
      .gap(3)
      .border_b(1)
      .border_color(c.border)
      .when(s.active, (el) => el.bg(c.selected))
      .child(head)
      .child(body);
  }

  render(cx) {
    const c = theme();
    const list = targets();
    const header = h_flex()
      .w_full()
      .h(26)
      .flex_none()
      .px(10)
      .gap(6)
      .items_center()
      .border_b(1)
      .border_color(c.border)
      .child(div().font_bold().text_color(c.accent).child("pull requests"))
      .child(div().flex_1())
      .when(this.busy, (el) => el.child(div().text_color(c.dim).child("⠋").frames(["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"], 90)))
      .child(
        div()
          .id("prs-refresh")
          .px(3)
          .text_color(c.dim)
          .cursor_pointer()
          .hover((s) => s.text_color(c.foreground).bg(c.hover))
          .tooltip("Refresh")
          .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
          .on_click((_e, cx) => {
            cx.stop_propagation();
            this.tick(cx, true);
            cx.notify();
          })
          .child("[r]"),
      );
    const empty = div().p(10).text_color(c.dim).child("作業中のブランチがありません");
    // オーバーレイ (mod.open) では大きさが中身任せになるので、決まった大きさにする
    const floating = Boolean(props()?.overlay);
    return v_flex()
      .when(floating, (el) => el.w(400).h(400))
      .when(!floating, (el) => el.size_full())
      .bg(c.surface)
      .text_color(c.foreground)
      .text_size(13)
      .child(header)
      .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar().children(list.length ? list.map((t) => this.row(t, c)) : [empty]));
  }
}
