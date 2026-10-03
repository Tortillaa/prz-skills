# Inferring the documentation style

Base the style guide on what the project already does, not on personal
preference. Where the project is inconsistent, pick the majority pattern and
note the alternative. Where there is no sample, propose a common default for
the language and mark it as "proposed".

## What to sample

Aim for a representative sample, not every file:

- `README.md` and any other root markdown (CONTRIBUTING, AGENTS.md).
- `docs/` (a few pages of different kinds).
- Docstrings / doc comments in 5-10 source files from different modules,
  favoring public APIs.
- Inline comments in the same files.
- `CHANGELOG.md`, if present.
- Recent commit messages: `git log --oneline -30`.
- Rules from `.prz/repo/plan.md` or agent rule files, if present.

## What to extract

| Aspect | Questions |
| --- | --- |
| Language | Which natural language? Same for code comments and docs? |
| Tone | Formal or casual? Imperative ("Return the user") or descriptive ("Returns the user")? |
| Docstring format | JSDoc, TSDoc, Google, NumPy, reST, XML doc, none? Which tags are used? |
| Docstring coverage | All public APIs, only complex ones, or none? |
| Inline comments | Density; explain why vs what; TODO format (`TODO(name):`, issue links). |
| Markdown | Heading style and case, list markers, code fence languages, line wrapping, tables. |
| CHANGELOG | Keep a Changelog, conventional-changelog, free form? |
| Sync rules | Which docs must change together with which code (e.g. CLI flags and README usage section). |

## Output

Fill `assets/doc-style-template.md` with concrete rules and one short real
example per rule, taken from the project when possible.
