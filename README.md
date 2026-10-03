# prz-skills

A personal collection of AI agent skills, written in the open
[Agent Skills](https://agentskills.io) format. Each skill is a folder with a
`SKILL.md` file (YAML frontmatter + Markdown instructions) and optional
supporting files, so it works with any agent that supports the standard:
Cursor, Claude Code, Codex, and others.

## Repository layout

```
prz-skills/
├── skills/                 # One folder per skill
│   └── <skill-name>/
│       ├── SKILL.md        # Required: frontmatter + instructions
│       ├── references/     # Optional: extra docs loaded on demand
│       ├── scripts/        # Optional: executable helpers
│       └── assets/         # Optional: templates/files used in outputs
├── template/SKILL.md       # Starting point for new skills
├── scripts/
│   ├── validate-skills.py  # Lints every skills/*/SKILL.md
│   └── install.ps1         # Links skills into your agent's skills directory
├── AGENTS.md               # Instructions for AI agents working in this repo
└── CONTRIBUTING.md         # How to write a new skill
```

## Skills

| Skill | Description |
| --- | --- |
| [example-skill](skills/example-skill/SKILL.md) | Reference skill showing the expected structure and conventions. |
| [prz-initrepo](skills/prz-initrepo/SKILL.md) | Plans the base of a new or reworked repo (stack, structure, tooling, conventions) and optionally scaffolds it. |
| [prz-grillme](skills/prz-grillme/SKILL.md) | Grills the user about an idea one question at a time and saves the record as markdown. |
| [prz-plan](skills/prz-plan/SKILL.md) | Builds an implementation plan from a saved grill (recommended) or a prompt. |
| [prz-review](skills/prz-review/SKILL.md) | Reviews the implementation against the plan and grill and reports GO / NO GO with evidence. |
| [prz-doc](skills/prz-doc/SKILL.md) | Keeps documentation and comments consistent in style and in sync with the code. |

## prz workflow

The `prz-*` skills form a workflow. They are only run when invoked explicitly
(e.g. `/prz-grillme`) and hand work to each other through markdown files in a
`.prz/` folder in the target project:

```
.prz/
├── repo/plan.md        # prz-initrepo: repository foundation
├── doc-style.md        # prz-doc: documentation style guide
└── <feature-slug>/
    ├── grill.md        # prz-grillme
    ├── plan.md         # prz-plan
    └── review.md       # prz-review
```

1. **Once per repo**: `prz-initrepo` to agree on the stack, structure and
   conventions (and scaffold them).
2. **Per feature**: `prz-grillme` -> `prz-plan` -> implement -> `prz-doc` ->
   `prz-review` (GO / NO GO).

Decisions (`D-n`), acceptance criteria (`AC-n`) and tasks (`T-n`) keep stable
IDs so each step can trace back to the previous one.

## Installing skills

Skills are discovered from a skills directory specific to each agent. Each skill
folder goes directly inside it (e.g. `~/.cursor/skills/example-skill/SKILL.md`).

| Agent | User-level (all projects) | Project-level |
| --- | --- | --- |
| Cursor | `~/.cursor/skills/` | `.cursor/skills/` |
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| Codex / generic | `~/.agents/skills/` | `.agents/skills/` |

### With the install script (Windows / PowerShell)

```powershell
# Link every skill into Cursor's user skills directory
./scripts/install.ps1 -Target cursor

# Link a single skill into Claude Code
./scripts/install.ps1 -Target claude -Skill example-skill

# Copy instead of symlinking
./scripts/install.ps1 -Target agents -Copy
```

Symlinks keep installed skills in sync with this repo. Creating symlinks on
Windows requires Developer Mode or an elevated shell; the script falls back to
copying when it can't create a link.

### Manually

Copy or symlink the folder `skills/<skill-name>` into one of the directories
above.

## Creating a new skill

1. Copy `template/SKILL.md` to `skills/<skill-name>/SKILL.md`.
2. Fill in `name` and `description` and write the instructions.
3. Add a row to the [Skills](#skills) table.
4. Run `python scripts/validate-skills.py`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for conventions and a quality checklist.

## License

[MIT](LICENSE)
