---
name: prz-doc
description: Reviews project documentation and code comments so they follow one consistent style (stored in .prz/doc-style.md, inferred from the project the first time) and stay in sync with the code as it changes, then reports and fixes the issues. Use when the user says "review docs", "update documentation", "check comments", "sync docs with code" or "keep the docs up to date".
disable-model-invocation: true
---

# prz-doc

Keep documentation and comments consistent in style and accurate with respect
to the code.

## Conventions

- Style guide: `.prz/doc-style.md` in the target project (repo-level, shared by
  all features).
- Conversation and generated markdown are in English. Documentation itself
  follows the language set in the style guide.

## Workflow

### 1. Load or create the style guide

- If `.prz/doc-style.md` exists, read it and follow it.
- If it is missing, infer the style following
  [references/style-inference.md](references/style-inference.md), write it from
  [assets/doc-style-template.md](assets/doc-style-template.md), show it to the
  user and wait for confirmation before reviewing anything.

### 2. Define the scope

- Default: files changed against the base branch plus uncommitted changes
  (`git diff --name-only <base>...HEAD`, `git status --short`), and the docs
  that describe them.
- If the user gives paths, review only those.

### 3. Check

For each file in scope:

- **Style**: docstrings, comments and markdown follow the style guide.
- **Accuracy**: comments and docstrings match what the code does now
  (parameters, return values, errors, behavior). Flag stale TODOs.
- **Coverage**: public APIs (exported functions, classes, endpoints, CLI flags,
  config keys) are documented as the style guide requires.
- **Sync**: README, `docs/`, CHANGELOG and examples reflect the changes
  (new options, renamed commands, removed features).
- **Noise**: comments that only narrate the code, or explain history instead
  of intent, should be removed.

### 4. Report and fix

1. Report findings grouped by file: location, problem, proposed fix.
2. Apply the fixes, unless the user asked for report-only. Change only
   documentation and comments, never code behavior.
3. If a fix requires a decision (e.g. the doc and the code disagree and it is
   unclear which is right), ask instead of guessing.
4. If the style guide itself turns out to be incomplete, propose an addition
   and update `.prz/doc-style.md` after the user agrees.
