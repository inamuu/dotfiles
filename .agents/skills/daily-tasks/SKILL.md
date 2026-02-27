---
name: daily-tasks
description: Create today's ToDo_Medley tasks in Acta by carrying over yesterday's unfinished tasks, removing only [x] items, then ask if additional tasks should be added.
---

# Daily Tasks (Acta)

Use this skill when the user asks to run daily task setup for Acta (e.g. `/daily-tasks`).

## Target

- Directory: `/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta`
- File format: `YYYY-MM-DD.md`
- Task block format: `<!-- acta:comment -->` with `tags: ToDo_Medley`

## Workflow

1. Resolve local date in `Asia/Tokyo`:
   - `today_ymd` as `YYYY-MM-DD`
   - `today_compact` as `YYYYMMDD`
   - `yesterday_ymd` as `YYYY-MM-DD`
2. Read `yesterday_ymd.md` and extract the latest `acta:comment` block that contains both:
   - `tags: ToDo_Medley`
   - `# Tasks:`
3. If yesterday file is missing or no matching block exists, search older files (latest first) until one matching block is found.
4. Copy that tasks block and replace heading:
   - `# Tasks: XXXXXXXX` -> `# Tasks: {today_compact}`
5. Remove completed tasks:
   - Remove only lines with `- [x]`
   - Keep `- [ ]`, `- [/]`, `- [R]`, `- [R ]`, and `- [X]`
   - Remove now-empty section headers (e.g. `- その他`) if they have no remaining child items
6. Append the new block to `/Users/kazuma.inamura/ghq/github.com/inamuu/data/Acta/{today_ymd}.md`:
   - Create the file with `# {today_ymd}` if missing
   - Metadata:
     - `id`: UUID v4
     - `created`: `YYYY-MM-DD HH:MM`
     - `created_ms`: Unix timestamp milliseconds
     - `tags`: `ToDo_Medley`
7. Ask exactly:
   - `追加したいタスクはありますか？`
8. If user says `XXを追加して`:
   - Add `- [ ] XX` under `- その他`
   - If `- その他` does not exist, create it at the end and then add the task
9. Report updated file path and what was added.

## Constraints

- Keep existing Acta markdown style and indentation from source as much as possible.
- Do not rewrite unrelated blocks.
- Always respond in Japanese.
