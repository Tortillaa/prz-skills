---
name: prz-review
description: Reviews an implementation against its plan (.prz/<slug>/plan.md) and grill (.prz/<slug>/grill.md), runs the project's checks, and writes a GO / NO GO report to .prz/<slug>/review.md with evidence for every acceptance criterion and task. Use when the user says "review the implementation", "is this ready", "go or no go", "check against the plan" or "review vs plan".
disable-model-invocation: true
---

# prz-review

Decide whether an implementation is ready, and prove it.

## Conventions

- Inputs: `.prz/<slug>/plan.md` (required), `.prz/<slug>/grill.md` (optional).
  Output: `.prz/<slug>/review.md`. The slug is kebab-case; `repo` is reserved.
- Conversation and generated markdown are in English.
- Reference the plan's and grill's IDs (`D-n`, `AC-n`, `T-n`).

## Workflow

### 1. Load the context

1. If no slug was given, list the existing `.prz/*/` folders and ask which to
   review.
2. Read `plan.md`. If it is missing, stop and suggest `prz-plan`.
3. Read `grill.md` if present; its acceptance criteria and decisions take
   precedence when they conflict with the plan (report the conflict).

### 2. Collect the changes

- Committed changes against the base branch:
  `git diff <base>...HEAD` (base is usually `main`; confirm if unsure).
- Uncommitted changes: `git diff HEAD` and `git status --short`.
- Read the changed files, not just the diff, when context matters.

### 3. Run the checks

Detect and run the project's checks: tests, lint, type-check, build (look at
package scripts, Makefile, CI config, README). Record the exact command, the
result, and a short output excerpt for failures. If a check cannot run, record
why; do not skip it silently.

### 4. Evaluate

- For every `AC-n` and every `T-n`, mark **Met**, **Partial** or **Missing**.
  Each status needs evidence: `file:line`, test name, or command output.
  "Looks implemented" is not evidence.
- Check that the decisions (`D-n`) were respected.
- List changes that are not in the plan (scope creep) and possible regressions.
- Classify findings as blocking, major or minor.

### 5. Verdict and report

1. Decide using [references/verdict-criteria.md](references/verdict-criteria.md).
2. Write `.prz/<slug>/review.md` from
   [assets/review-template.md](assets/review-template.md). If the file exists,
   add the new review as the next numbered section at the top and keep earlier
   reviews below.
3. Reply with the verdict, the one-paragraph reason, and the required actions
   (for NO GO).
