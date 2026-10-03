#!/usr/bin/env python3
"""Validate every skill in skills/ against the Agent Skills conventions.

Usage: python scripts/validate-skills.py [skill-name ...]
Exits with status 1 if any error is found.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
MAX_NAME_LEN = 64
MAX_DESCRIPTION_LEN = 1024
MAX_BODY_LINES = 500


def parse_frontmatter(text: str) -> tuple[dict[str, str], str] | None:
    """Parse a minimal YAML frontmatter block (top-level scalar keys only)."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return None

    fields: dict[str, str] = {}
    key = None
    block: list[str] = []
    for line in lines[1:end]:
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if match:
            if key is not None and block:
                fields[key] = " ".join(block).strip()
            key, value = match.group(1), match.group(2).strip()
            block = []
            if value in ("|", ">", "|-", ">-"):
                fields[key] = ""
            else:
                fields[key] = value.strip("'\"")
                key = None if value else key
        elif key is not None and line.startswith((" ", "\t")):
            block.append(line.strip())
    if key is not None and block:
        fields[key] = " ".join(block).strip()

    return fields, "\n".join(lines[end + 1 :])


def validate_skill(skill_dir: Path) -> list[str]:
    errors: list[str] = []
    folder = skill_dir.name
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.is_file():
        return [f"{folder}: missing SKILL.md"]

    parsed = parse_frontmatter(skill_md.read_text(encoding="utf-8"))
    if parsed is None:
        return [f"{folder}: SKILL.md must start with a '---' frontmatter block"]
    fields, body = parsed

    name = fields.get("name", "")
    if not name:
        errors.append(f"{folder}: frontmatter is missing 'name'")
    else:
        if name != folder:
            errors.append(f"{folder}: name '{name}' does not match folder name")
        if len(name) > MAX_NAME_LEN:
            errors.append(f"{folder}: name exceeds {MAX_NAME_LEN} characters")
        if not NAME_RE.match(name):
            errors.append(
                f"{folder}: name must be lowercase letters, digits and single hyphens"
            )

    description = fields.get("description", "")
    if not description:
        errors.append(f"{folder}: frontmatter is missing 'description'")
    elif len(description) > MAX_DESCRIPTION_LEN:
        errors.append(
            f"{folder}: description is {len(description)} chars "
            f"(max {MAX_DESCRIPTION_LEN})"
        )

    if not body.strip():
        errors.append(f"{folder}: SKILL.md has no instructions after the frontmatter")
    elif len(body.splitlines()) > MAX_BODY_LINES:
        errors.append(
            f"{folder}: SKILL.md body exceeds {MAX_BODY_LINES} lines; "
            "move details into references/"
        )

    for link in re.findall(r"\]\(([^)#\s]+)\)", body):
        if "://" in link or link.startswith("mailto:"):
            continue
        if not (skill_dir / link).exists():
            errors.append(f"{folder}: broken relative link '{link}'")

    return errors


def main(argv: list[str]) -> int:
    if not SKILLS_DIR.is_dir():
        print(f"No skills directory at {SKILLS_DIR}", file=sys.stderr)
        return 1

    if argv:
        skill_dirs = [SKILLS_DIR / name for name in argv]
        missing = [d.name for d in skill_dirs if not d.is_dir()]
        if missing:
            print(f"Unknown skill(s): {', '.join(missing)}", file=sys.stderr)
            return 1
    else:
        skill_dirs = sorted(
            d for d in SKILLS_DIR.iterdir() if d.is_dir() and not d.name.startswith(".")
        )

    all_errors: list[str] = []
    for skill_dir in skill_dirs:
        errors = validate_skill(skill_dir)
        status = "FAIL" if errors else "ok"
        print(f"[{status}] {skill_dir.name}")
        all_errors.extend(errors)

    if all_errors:
        print("\nErrors:", file=sys.stderr)
        for error in all_errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print(f"\n{len(skill_dirs)} skill(s) valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
