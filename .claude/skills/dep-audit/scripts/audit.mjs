#!/usr/bin/env node
// 依存ライブラリの脆弱性を検出し、レベル別に整理した JSON を出力する
// 使い方: node audit.mjs [対象ディレクトリ]
import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { join, resolve } from "node:path";

const dir = resolve(process.argv[2] || ".");
const has = (f) => existsSync(join(dir, f));
const ORDER = ["critical", "high", "moderate", "low", "unknown"];

function run(cmd, args) {
  try {
    return execFileSync(cmd, args, { cwd: dir, encoding: "utf8", maxBuffer: 64 << 20, stdio: ["ignore", "pipe", "ignore"] });
  } catch (e) {
    // audit 系は脆弱性があると exit code != 0 になるので stdout を使う
    if (e.stdout) return e.stdout;
    throw new Error(`${cmd} の実行に失敗: ${e.message}`);
  }
}

function npmLike(tool) {
  const full = JSON.parse(run(tool, ["audit", "--json"]));
  const prod = JSON.parse(run(tool, ["audit", "--json", "--omit=dev"]));
  const prodNames = new Set(Object.keys(prod.vulnerabilities || {}));
  return Object.values(full.vulnerabilities || {}).map((v) => {
    const advisories = v.via.filter((x) => typeof x === "object");
    const fix = v.fixAvailable;
    return {
      package: v.name,
      severity: v.severity,
      direct: v.isDirect,
      runtime: prodNames.has(v.name),
      range: v.range,
      fix: fix === true ? "npm audit fix で修正可" : fix && fix.name ? `${fix.name}@${fix.version}${fix.isSemVerMajor ? " (major更新)" : ""}` : "修正版なし",
      via: v.via.filter((x) => typeof x === "string"),
      advisories: advisories.map((a) => ({ title: a.title, url: a.url, severity: a.severity })),
    };
  });
}

function trivy() {
  const out = JSON.parse(run("trivy", ["fs", "--quiet", "--scanners", "vuln", "--format", "json", dir]));
  const rows = [];
  for (const r of out.Results || []) {
    for (const v of r.Vulnerabilities || []) {
      rows.push({
        package: v.PkgName,
        severity: (v.Severity || "unknown").toLowerCase().replace("medium", "moderate"),
        direct: null,
        runtime: null,
        range: v.InstalledVersion,
        fix: v.FixedVersion ? `${v.FixedVersion} へ更新` : "修正版なし",
        via: [r.Target],
        advisories: [{ title: v.Title || v.VulnerabilityID, url: v.PrimaryURL, severity: v.Severity }],
      });
    }
  }
  return rows;
}

let source, rows;
if (has("package-lock.json")) { source = "npm audit"; rows = npmLike("npm"); }
else if (has("pnpm-lock.yaml")) { source = "pnpm audit"; rows = npmLike("pnpm"); }
else { source = "trivy fs"; rows = trivy(); }

rows.sort((a, b) => ORDER.indexOf(a.severity) - ORDER.indexOf(b.severity));
const summary = Object.fromEntries(ORDER.map((s) => [s, rows.filter((r) => r.severity === s).length]));
console.log(JSON.stringify({ dir, source, summary, vulnerabilities: rows }, null, 2));
