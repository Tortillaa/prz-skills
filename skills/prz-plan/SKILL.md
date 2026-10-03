---
name: prz-plan
description: Creates an implementation plan for a feature from a saved grill (.prz/<slug>/grill.md) or, if there is none, from a prompt, and saves it to .prz/<slug>/plan.md with tasks traced to decisions and acceptance criteria. Use when the user says "make a plan", "plan this feature", "plan from the grill" or "write an implementation plan".
disable-model-invocation: true
---

# prz-plan

Turn a grill (recommended) or a prompt into a concrete, traceable
implementation plan.

## Conventions

- Input: `.prz/<slug>/grill.md` (optional). Output: `.prz/<slug>/plan.md`.
  The slug is kebab-case; `repo` is reserved.
- Conversation and generated markdown are in English.
- Tasks get IDs `T-n` and reference the grill's `D-n` and `AC-n`. Without a
  grill, define the acceptance criteria (`AC-n`) in the plan itself.

## Workflow

### 1. Find the source

1. If no slug was given, list the existing `.prz/*/` folders and ask which one
   to plan, or derive a slug from the prompt.
2. If `.prz/<slug>/grill.md` exists, read it fully. If its status is `open`,
   show the open questions and ask whether to resolve them now or plan around
   them.
3. If there is no grill, recommend running `prz-grillme` first. Continue only
   if the user accepts planning from the prompt; set source to `prompt (no
   grill)` in the plan metadata.

### 2. Explore

Read the affected code before planning: modules to change, existing patterns
to follow, related tests, build and test commands. Cite real paths.

### 3. Resolve blockers

Ask only questions that block the plan and that the grill did not answer, one
at a time with a recommended answer. Record new decisions in the plan.

### 4. Write the plan

1. Write `.prz/<slug>/plan.md` from
   [assets/plan-template.md](assets/plan-template.md). If a plan exists, ask
   whether to update or replace it.
2. Every `AC-n` must be covered by at least one task and one entry in the test
   plan. Every task must name the files it touches.
3. Keep tasks small enough to verify individually, in implementation order.
4. Present a short summary (approach, number of tasks, risks) and suggest
   implementing, then `prz-doc` and `prz-review`.
