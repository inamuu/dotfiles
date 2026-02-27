---
name: save-acta
description: Save the current conversation/work summary into the user's Acta daily markdown file under $HOME/ghq/github.com/inamuu/data/Acta using an <!-- acta:comment --> block. Use when the user asks to save, record, or summarize-and-store notes in Acta.
---

# Save Acta

Use this skill when the user asks to save knowledge, a summary, or work notes into Acta.

## Target

- Directory: `$HOME/ghq/github.com/inamuu/data/Acta`
- Daily file: `YYYY-MM-DD.md` (today's local date)

**Note**: The path uses the `$HOME` environment variable, so it works on any Mac.

## Workflow

1. Determine today's local date and target file path.
2. Check whether the daily file exists.
3. Summarize the relevant conversation/work content concisely in Markdown.
4. Generate Acta metadata:
   - `id`: UUID v4
   - `created`: local timestamp in `YYYY-MM-DD HH:MM`
   - `created_ms`: Unix timestamp in milliseconds
   - `tags`: comma-separated tags inferred from the content
5. Append an `acta:comment` block to the end of the daily file.
6. If the file does not exist, create it with a top-level `# YYYY-MM-DD` header before appending the first block.
7. Report the saved file path and a short summary of what was written.

## Required block format

```markdown
<!-- acta:comment
id: [UUID v4]
created: YYYY-MM-DD HH:MM
created_ms: [Unix timestamp in milliseconds]
tags: [tag1, tag2]
-->
[summary in Markdown]
<!-- /acta:comment -->
```

## Tagging guidance

Choose tags that reflect:

- Project/domain (`ToDo_Medley`, `ToDo_Personal`, etc.)
- Technology (`AWS`, `Terraform`, `Docker`, `Rails`, `MySQL`, etc.)
- Work type (`Debug`, `Feature`, `Refactoring`, `Investigation`, etc.)

## Constraints

- Always append; do not rewrite or remove existing Acta content.
- Preserve existing file formatting and spacing as much as possible.
- Use accurate current local time for timestamps.
- Keep the summary compact and useful (decisions, actions, outcomes).
