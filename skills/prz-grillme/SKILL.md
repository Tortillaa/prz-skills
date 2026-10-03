---
name: prz-grillme
description: Interviews the user relentlessly about an idea, feature or design, one question at a time, until there is shared understanding, then saves the full record (decisions, constraints, acceptance criteria) to .prz/<slug>/grill.md. Use when the user says "grill me", "interrogate my idea", "stress-test this plan" or "question me about this feature".
disable-model-invocation: true
---

# prz-grillme

Interrogate an idea until every important branch of the decision tree is
resolved, then save the result so `prz-plan` and `prz-review` can build on it.

## Conventions

- Output file: `.prz/<slug>/grill.md` in the target project. The slug is
  kebab-case; `repo` is reserved.
- Conversation and generated markdown are in English.
- Decisions get IDs `D-n`, acceptance criteria get IDs `AC-n`. Never renumber
  existing IDs; append new ones.

## Workflow

### 1. Set up

1. Restate the idea in one sentence and propose a slug. If the user gave no
   idea, list the existing `.prz/*/` folders and ask which to continue.
2. If `.prz/<slug>/grill.md` exists, show its open questions and ask whether to
   **resume** (append a new session) or **start over**.

### 2. Grill

- Ask **one question at a time**. Every question includes your recommended
  answer and why.
- Walk the decision tree branch by branch, finishing a branch before moving on:
  goal, users, scope, constraints, behavior, edge cases, data, errors and
  failure modes, security, testing, rollout.
- When the codebase can answer a question, explore it and state what you found
  instead of asking.
- Push back on vague answers ("it should be fast" -> "under what latency, for
  what load?"). If an answer contradicts an earlier one, point it out and
  record how it was resolved.
- Turn each settled answer into a decision (`D-n`) and, where it is verifiable,
  an acceptance criterion (`AC-n`).

### 3. Close

Stop when the user says so or every branch is resolved.

1. Summarize the decisions, acceptance criteria and open questions; ask for
   confirmation or corrections.
2. Write `.prz/<slug>/grill.md` from
   [assets/grill-template.md](assets/grill-template.md). Set status to
   `complete` or `open` (if open questions remain). When resuming, update the
   sections and add a new entry to the session log.
3. Suggest the next step: `prz-plan` with the same slug.

## Example question

> **Error handling (D-4).** When the payment provider times out, should the order
> stay pending and retry, or fail immediately?
> Recommended: **keep it pending and retry 3 times with backoff** — timeouts are
> usually transient and failing loses the sale. Accept?
