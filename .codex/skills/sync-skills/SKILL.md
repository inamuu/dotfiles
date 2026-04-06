---
name: sync-skills
description: Claude Code と Codex のローカル skills を相互同期する。ユーザーが「skillsを同期して」「skillを同期して」「Claude/Codexでも使えるようにして」と頼んだときに使う。
---

# Sync Skills

Use this skill when the user wants the same local skill to be available in both Codex and Claude Code.

## Targets

- Codex: `./.codex/skills`
- Claude Code: `./.claude/skills`

## Scope

1. If the user names one or more skills, sync only those skills.
2. If the user does not name skills, compare all local skills under the two directories and sync the missing or outdated side.
3. Ignore:
   - `./.codex/skills/.system`
   - `./.claude/plugins`
   - `./.claude/plugins/cache`

## Source Of Truth

For each skill, choose the source side in this order:

1. If the user says which side was newly created or edited, trust that side.
2. If the skill exists only on one side, use that side.
3. If both sides exist and are effectively the same, do nothing.
4. If both sides exist and differ, compare the relevant file modification times and use the newer side.
5. If modification times are inconclusive or the risk of clobbering user edits is high, ask the user which side should win.

## Format Rules

- Codex output must be `SKILL.md` with `name` and `description` frontmatter.
- Claude output should preserve the existing format if the target skill already exists:
  - `skill.json` + `prompt.md`
  - `skill.md`
  - `SKILL.md`
- If a Claude target skill does not exist yet, create `skill.json` + `prompt.md`.

## Conversion Rules

- Claude `skill.json` + `prompt.md` to Codex:
  - `name` and `description` come from `skill.json`
  - body comes from `prompt.md`
- Claude `skill.md` or `SKILL.md` to Codex:
  - use the folder name as `name` if metadata is absent
  - derive a short `description` from the first explanatory sentence when needed
  - copy the markdown body as the Codex body
- Codex to Claude:
  - keep the body after Codex frontmatter as the Claude prompt body
  - for new Claude skills, create `skill.json` with the same `name` and `description`

## Execution

1. Inspect the relevant files on both sides.
2. Decide the winning side per skill using the rules above.
3. Create or update the opposite side.
4. Do not use helper scripts for the sync itself. Read files and edit them directly.
5. Preserve the existing language and tone of the original skill.
6. Report the files created or updated.

## Response

- Respond in Japanese unless the user asks otherwise.
- Keep the report short and explicit.
