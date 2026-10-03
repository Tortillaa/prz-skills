# AGENTS.md

This repository stores AI agent skills in the open Agent Skills format. Follow
these rules when creating or editing skills here.

## Layout

- Every skill lives in `skills/<skill-name>/` and must contain a `SKILL.md`.
- Optional subfolders: `references/` (docs loaded on demand), `scripts/`
  (executable helpers), `assets/` (templates/files used in outputs). Only create
  them when the skill needs them.
- Do not nest skills inside other skills or group them in category folders.

## Creating a skill

1. Start from `template/SKILL.md`.
2. `name` must equal the folder name: lowercase letters, digits and hyphens,
   max 64 characters, no leading/trailing or consecutive hyphens.
3. `description` (max 1024 characters) must say what the skill does **and**
   when to use it, in third person, including the words a user would say.
4. Keep `SKILL.md` under ~500 lines. Move long reference material into
   `references/` and link to it with relative paths.
5. Add the skill to the table in `README.md`.

## Before finishing

- Run `python scripts/validate-skills.py` and fix every error.
- Write all documentation in English.
- Use conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, ...), e.g.
  `feat(skills): add pdf-extract skill`.
