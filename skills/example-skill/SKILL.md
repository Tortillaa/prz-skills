---
name: example-skill
description: Reference skill that demonstrates the structure and conventions of this repository. Use when the user asks for an example skill, wants to see how skills in prz-skills are organized, or says "show me the example skill".
---

# Example Skill

A minimal, working skill that shows how a `SKILL.md` and its optional folders
fit together. Use it as a model when writing new skills.

## When to use

- The user asks to see or test the example skill.
- The user wants to know how skills in this repository are structured.

## Instructions

1. Reply with a short summary of the skill layout:
   - `SKILL.md`: frontmatter (`name`, `description`) plus instructions.
   - `references/`: extra documentation read only when needed.
   - `scripts/`: helpers the agent runs instead of re-deriving logic.
   - `assets/`: templates or files copied into outputs.
2. Point the user to `template/SKILL.md` and `CONTRIBUTING.md` in the repo root
   to create their own skill.

## Examples

**Input:** "Show me the example skill."

**Output:** A brief list of the four parts above and a pointer to the template.
