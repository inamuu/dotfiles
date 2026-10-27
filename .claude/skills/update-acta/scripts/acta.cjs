#!/usr/bin/env node
// Acta 本体（electron/storage.cjs）の関数を CLI から呼び出すラッパー。
// electron モジュールだけをスタブし、アプリと同じロジックでプロジェクトのファイルを更新する。
"use strict";

const Module = require("node:module");
const os = require("node:os");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

const ACTA_REPO = process.env.ACTA_REPO || path.join(os.homedir(), "ghq/github.com/inamuu/Acta");
const USER_DATA_DIR = process.env.ACTA_USER_DATA || path.join(os.homedir(), "Library/Application Support/acta");
const UNCLASSIFIED = "未分類";

const electronStub = {
  app: {
    getPath(name) {
      if (name === "userData") return USER_DATA_DIR;
      if (name === "documents") return path.join(os.homedir(), "Documents");
      return os.homedir();
    }
  }
};
const originalLoad = Module._load;
Module._load = function load(request, ...rest) {
  if (request === "electron") return electronStub;
  return originalLoad.call(this, request, ...rest);
};
const storage = require(path.join(ACTA_REPO, "electron/storage.cjs"));

function print(value) {
  process.stdout.write(`${JSON.stringify(value, null, 2)}\n`);
}

function gh(args) {
  return execFileSync("gh", args, { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
}

async function findTask(taskId) {
  for (const project of await storage.listProjects()) {
    const task = project.tasks.find((item) => item.id === taskId || (item.sourceUrl && item.sourceUrl === taskId));
    if (task) return { project, task };
  }
  throw new Error(`タスクが見つかりません: ${taskId}`);
}

function summarizeTask(project, task) {
  return {
    projectId: project.id,
    projectName: project.name,
    taskId: task.id,
    title: task.title,
    status: task.status,
    sourceType: task.sourceType || "",
    sourceUrl: task.sourceUrl || "",
    parentId: task.parentId || ""
  };
}

// 本文中の Issue 参照（URL / owner/repo#N / closes #N）を Issue URL に正規化して返す
function issueUrlsFromBody(body, repository) {
  const urls = new Set();
  const text = String(body || "");
  for (const m of text.matchAll(/https:\/\/github\.com\/([\w.-]+\/[\w.-]+)\/issues\/(\d+)/g)) {
    urls.add(`https://github.com/${m[1]}/issues/${m[2]}`);
  }
  for (const m of text.matchAll(/(?:^|[\s(])([\w.-]+\/[\w.-]+)#(\d+)\b/g)) {
    urls.add(`https://github.com/${m[1]}/issues/${m[2]}`);
  }
  if (repository) {
    const re = /\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?|refs?|related(?: to)?|issue)\s*:?\s*#(\d+)\b/gi;
    for (const m of text.matchAll(re)) urls.add(`https://github.com/${repository}/issues/${m[1]}`);
  }
  return Array.from(urls);
}

// GitHub ノードID → { body, linkedIssues, parentIssue }
function fetchLinkInfo(nodeIds) {
  const result = new Map();
  const ids = Array.from(new Set(nodeIds.filter(Boolean)));
  for (let i = 0; i < ids.length; i += 50) {
    const chunk = ids.slice(i, i + 50);
    const query = `query { nodes(ids: ${JSON.stringify(chunk)}) { id ` +
      "... on PullRequest { body repository { nameWithOwner } " +
      "closingIssuesReferences(first: 10) { nodes { url title } } } " +
      "... on Issue { body repository { nameWithOwner } parent { url title } } } }";
    let parsed = null;
    try {
      parsed = JSON.parse(gh(["api", "graphql", "-f", `query=${query}`]));
    } catch (error) {
      // 一部ノードが参照できない場合もエラー終了するので、stdout に data があれば使う
      try { parsed = JSON.parse(String(error.stdout || "")); } catch { parsed = null; }
    }
    for (const node of parsed?.data?.nodes || []) {
      if (!node?.id) continue;
      const repository = node.repository?.nameWithOwner || "";
      const closing = (node.closingIssuesReferences?.nodes || []).map((n) => n.url);
      const linked = Array.from(new Set([...closing, ...issueUrlsFromBody(node.body, repository)]));
      result.set(node.id, {
        bodyExcerpt: String(node.body || "").replace(/\s+/g, " ").slice(0, 400),
        linkedIssues: linked,
        parentIssue: node.parent ? { url: node.parent.url, title: node.parent.title } : null
      });
    }
  }
  return result;
}

function indexTasksByUrl(projects) {
  const byUrl = new Map();
  for (const project of projects) {
    for (const task of project.tasks) {
      if (task.sourceUrl) byUrl.set(task.sourceUrl, summarizeTask(project, task));
    }
  }
  return byUrl;
}

const commands = {
  async pull() {
    print(await storage.syncPull());
  },

  async push() {
    print(await storage.syncBackup());
  },

  async sync() {
    print(await storage.syncGitHubItems());
  },

  // 既存プロジェクトの一覧（分類判断用に直近のタスク名も出す）
  async projects() {
    const projects = await storage.listProjects();
    print(projects
      .filter((project) => !project.archivedAtMs && project.name !== UNCLASSIFIED)
      .map((project) => ({
        id: project.id,
        name: project.name,
        issueUrl: project.issueUrl || "",
        githubProjectUrl: project.githubProjectUrl || "",
        taskCount: project.tasks.length,
        recentTasks: project.tasks.slice(0, 8).map((task) => task.title)
      })));
  },

  // 未分類のタスクと、分類のヒント（本文・リンク先Issue・親Issue とその Acta 上の所属）
  async unclassified() {
    const projects = await storage.listProjects();
    const unclassified = projects.find((project) => project.name === UNCLASSIFIED);
    const tasks = unclassified ? unclassified.tasks : [];
    const byUrl = indexTasksByUrl(projects);
    const info = fetchLinkInfo(tasks.filter((task) => task.source === "github").map((task) => task.id));
    const resolve = (url) => ({ url, acta: byUrl.get(url) || null });
    print(tasks.map((task) => {
      const link = info.get(task.id) || { bodyExcerpt: "", linkedIssues: [], parentIssue: null };
      return {
        ...summarizeTask(unclassified, task),
        repository: task.repository || "",
        bodyExcerpt: link.bodyExcerpt,
        linkedIssues: link.linkedIssues.map(resolve),
        parentIssue: link.parentIssue ? { ...link.parentIssue, acta: byUrl.get(link.parentIssue.url) || null } : null
      };
    }));
  },

  // Open な PR タスクごとに、リンクされた Issue と Acta 上の対応タスクを出す
  async "pr-links"() {
    const projects = await storage.listProjects();
    const prs = [];
    for (const project of projects) {
      if (project.archivedAtMs) continue;
      for (const task of project.tasks) {
        if (task.source === "github" && task.sourceType === "PullRequest" && task.sourceState !== "closed") {
          prs.push({ project, task });
        }
      }
    }
    const byUrl = indexTasksByUrl(projects);
    const info = fetchLinkInfo(prs.map(({ task }) => task.id));
    print(prs.map(({ project, task }) => ({
      ...summarizeTask(project, task),
      linkedIssues: (info.get(task.id)?.linkedIssues || []).map((url) => ({ url, acta: byUrl.get(url) || null }))
    })));
  },

  async "create-project"(name) {
    if (!name) throw new Error("usage: create-project <name>");
    const project = await storage.createProject({ name });
    print({ id: project.id, name: project.name, dirName: project.dirName });
  },

  async reassign(taskId, targetProjectId) {
    if (!taskId || !targetProjectId) throw new Error("usage: reassign <taskId> <targetProjectId>");
    const { project } = await findTask(taskId);
    const written = await storage.reassignProjectTask({ sourceProjectId: project.id, targetProjectId, taskId });
    print({ from: project.name, to: written.name, taskId });
  },

  async "set-parent"(taskId, parentTaskId) {
    if (!taskId || !parentTaskId) throw new Error("usage: set-parent <taskId> <parentTaskId>");
    const { project } = await findTask(taskId);
    await storage.setProjectTaskParent({ projectId: project.id, taskId, parentId: parentTaskId });
    print({ project: project.name, taskId, parentId: parentTaskId });
  },

  async move(taskId, status) {
    if (!taskId || !["Backlog", "InProgress", "Done"].includes(status)) {
      throw new Error("usage: move <taskId> <Backlog|InProgress|Done>");
    }
    const { project } = await findTask(taskId);
    await storage.moveProjectTask({ projectId: project.id, taskId, status });
    print({ project: project.name, taskId, status });
  },

  async delete(taskId) {
    if (!taskId) throw new Error("usage: delete <taskId>");
    const { project, task } = await findTask(taskId);
    await storage.deleteProjectTask({ projectId: project.id, taskId: task.id });
    print({ project: project.name, taskId: task.id, title: task.title, deleted: true });
  }
};

async function main() {
  const [command, ...args] = process.argv.slice(2);
  const handler = commands[command];
  if (!handler) {
    process.stderr.write(`usage: acta.cjs <${Object.keys(commands).join("|")}> [args]\n`);
    process.exit(2);
  }
  await handler(...args);
}

main().catch((error) => {
  process.stderr.write(`${error?.message || error}\n`);
  process.exit(1);
});
