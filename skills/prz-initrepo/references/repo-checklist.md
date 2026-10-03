# Repository checklist

Work through these areas in order. For each item, decide or confirm, and offer a
recommended default that fits the stack chosen so far. Skip items that do not
apply to the repo type (e.g. deployment for a docs-only repo).

## 1. Purpose and scope

- What the repo contains, and what it explicitly does not.
- Type: application, library/package, CLI, monorepo, documentation, infra/IaC,
  collection (skills, templates, dotfiles).
- Audience: personal, team, public open source.
- Expected lifetime and size (prototype vs long-lived product).

## 2. Tech stack

- Languages and pinned versions.
- Frameworks and runtime (e.g. Node, Python, .NET, JVM, browser).
- Package manager and lockfile policy.
- Data: database, ORM/migrations, caching, storage.
- External services and APIs.

Default: the most common, well-supported option for the chosen language; avoid
adding services the scope does not need.

## 3. Folder structure

- Source (`src/`, `app/`, `packages/*`), tests (colocated or `tests/`), docs,
  scripts, config, assets.
- Monorepo layout and workspace tool if there is more than one package.
- Where generated files go and whether they are committed.

Default: follow the framework's conventional layout; one top-level folder per
concern; no deep nesting without a reason.

## 4. Tooling

- Formatter, linter, type checking.
- Test framework and how tests are run (`test` script/command).
- Pre-commit hooks.
- `.editorconfig`.
- Task runner (package scripts, Makefile, justfile).

## 5. Environment and configuration

- Environment variables and an `.env.example` with every key.
- Secrets handling (never committed; where they live).
- Version pinning files (`.nvmrc`, `.python-version`, `global.json`, ...).
- Local setup steps, ideally one command.
- Dev containers or Docker for local dev, if useful.

## 6. Git workflow

- Default branch and branching model (trunk-based, GitHub flow, git flow).
- Conventional commits and commit scopes.
- PR/MR template, CODEOWNERS, required reviews.
- `.gitignore` and `.gitattributes` (line endings, binary files).

Default: trunk-based with short-lived branches and conventional commits.

## 7. CI/CD

- Checks on every PR: format, lint, type-check, tests, build.
- Release process, versioning (semver) and CHANGELOG format.
- Deployment targets and environments.
- Platform (GitHub Actions, GitLab CI, ...).

## 8. Documentation

- README sections: purpose, setup, usage, development, license.
- CONTRIBUTING, AGENTS.md or other AI agent rules.
- Architecture decision records (ADRs) location, if any.
- Documentation language and tone (feeds `prz-doc`).
- License.

## 9. Quality and security

- Dependency updates (Dependabot, Renovate).
- Vulnerability and secret scanning.
- Test coverage expectations.
- Error tracking/logging conventions, if it is an application.
