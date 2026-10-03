---
name: prz-initrepo
description: Proposes and plans the foundation of a new repository or a repository being reworked (tech stack, folder structure, contents, tooling and conventions), saves the plan to .prz/repo/plan.md and, after confirmation, scaffolds the base folders and files. Use when the user says "init a repo", "start a new project", "set up the repository", "bootstrap the repo" or "rethink the repo structure".
disable-model-invocation: true
---

# prz-initrepo

Agree on a solid base for a repository through a short interview, write it down
as a plan, and optionally scaffold it.

## Conventions

- Output file: `.prz/repo/plan.md` in the target project (`repo` is a reserved
  slug in `.prz/`).
- Conversation and generated markdown are in English.
- Decisions get stable IDs (`D-1`, `D-2`, ...).

## Workflow

### 1. Detect the mode

- **New**: the repo is empty or only has trivial files. Start from scratch.
- **Rework**: the repo has content. First inventory it: languages, package
  manifests, folder layout, CI config, docs, tooling configs, git conventions
  (`git log --oneline -20`). Frame every question as keep or change.

If `.prz/repo/plan.md` already exists, show its decisions and ask whether to
update it or replace it.

### 2. Interview

Cover the areas in [references/repo-checklist.md](references/repo-checklist.md),
in that order.

- Ask **one question at a time**. Each question includes your recommended answer
  and a one-line reason, so the user can just accept it.
- Skip anything the repo or earlier answers already settle; state the assumption
  instead of asking.
- Group trivial, related choices into one question with a recommended bundle
  (e.g. formatter + linter + editorconfig).
- Push back on choices that conflict with earlier decisions.

### 3. Write the plan

1. Summarize all decisions as a numbered list and ask for confirmation.
2. Write `.prz/repo/plan.md` from
   [assets/repo-plan-template.md](assets/repo-plan-template.md). Fill every
   section; write "None" rather than deleting a section. Include
   "Migration steps" only in rework mode.

### 4. Scaffold (only after explicit confirmation)

1. Ask: "Scaffold the base now?" and list exactly what would be created.
2. On confirmation, create the folders and base files from the plan's
   "Base files to create" section. Use `.gitkeep` for empty folders.
3. Never overwrite an existing file without asking for that specific file.
4. Do not install dependencies or run generators unless the user agrees.
5. Tick the items done in the plan's "Scaffold checklist" and report what was
   created and what was skipped.

### 5. Next steps

Suggest:
- `prz-doc` to create `.prz/doc-style.md` for the new repo.
- `prz-grillme` for the first feature.

## Example question

> **D-3 Package manager.** Recommended: **pnpm** — fast, strict dependency
> resolution, and works well with workspaces if the repo grows into a monorepo.
> Alternatives: npm, yarn. Accept?
