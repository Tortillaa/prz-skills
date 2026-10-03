# Writing a skill

A skill teaches an agent how to do one specific job well. The agent only sees
each skill's `name` and `description` up front; it reads the full `SKILL.md`
when the description matches the task, and reads files in `references/` only
when `SKILL.md` points to them. Write with that progressive loading in mind.

## Steps

1. Pick a short, descriptive name in kebab-case (e.g. `git-release-notes`).
2. Create the folder and copy the template:

   ```powershell
   New-Item -ItemType Directory skills/git-release-notes
   Copy-Item template/SKILL.md skills/git-release-notes/SKILL.md
   ```

3. Fill in the frontmatter and the body (see conventions below).
4. Add supporting files only if needed:
   - `references/` for long docs, API details, examples.
   - `scripts/` for deterministic work better done by code than by the model.
   - `assets/` for templates, boilerplate or files copied into outputs.
5. Add a row to the Skills table in `README.md`.
6. Validate: `python scripts/validate-skills.py`.
7. Install it and try it on a real task. To test it inside a single project
   without installing it globally, use `-Project` / `--project`:

   ```powershell
   ./scripts/install.cmd -Target cursor -Skill <name> -Project ../some-project
   ```

   ```bash
   ./scripts/install.sh --target cursor --skill <name> --project ../some-project
   ```

   Remove it afterwards with `-Uninstall` / `--uninstall` and the same options.

## Frontmatter

```yaml
---
name: git-release-notes
description: Generates release notes from git history between two tags. Use when the user asks for release notes, a changelog, or a summary of changes since the last release.
---
```

| Field | Rules |
| --- | --- |
| `name` | Required. Matches the folder name. Lowercase letters, digits, hyphens. Max 64 chars. |
| `description` | Required. Max 1024 chars. Third person. States **what** it does and **when** to use it. |

Other optional fields from the standard (`license`, `metadata`,
`allowed-tools`, ...) may be added when useful; not every agent honors them.

## Body conventions

- Be concise; the agent is already capable. Explain only what it would not
  know: project conventions, exact commands, gotchas, required output format.
- Prefer numbered steps for workflows and concrete examples over abstract rules.
- Keep `SKILL.md` under ~500 lines. Link to `references/*.md` for details, one
  level deep (avoid references that link to further references).
- Use relative paths with forward slashes (`references/api.md`,
  `scripts/run.py`).
- Tell the agent explicitly whether to **run** a script or **read** it.

## Quality checklist

- [ ] Folder name equals `name`.
- [ ] Description covers what + when, with trigger words a user would say.
- [ ] Instructions are specific and actionable.
- [ ] At least one example of input and expected output/behavior.
- [ ] Long material moved to `references/`.
- [ ] Scripts run on their own and print clear errors.
- [ ] No secrets, tokens or machine-specific absolute paths.
- [ ] README table updated.
- [ ] `python scripts/validate-skills.py` passes.
