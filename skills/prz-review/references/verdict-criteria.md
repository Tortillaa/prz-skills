# Verdict criteria

Apply the rules top to bottom; the first that matches decides.

## NO GO

Any of these:

- An acceptance criterion (`AC-n`) is **Missing**.
- A check (tests, lint, type-check, build) **fails** because of the changes.
- A **blocking** finding: data loss, security vulnerability, crash in a main
  path, broken public API or contract, a decision (`D-n`) violated without
  agreement.
- An `AC-n` is marked Met or Partial but has **no evidence**.

## GO with notes

All of these:

- No NO GO condition applies.
- Some `AC-n` or `T-n` are **Partial** only in minor ways, or there are
  **major/minor** findings that do not affect the acceptance criteria.
- Every note has a concrete follow-up action listed in the report.

## GO

- Every `AC-n` is **Met** with evidence.
- Every check passes, or could not run for a documented reason unrelated to
  the changes.
- No blocking or major findings.

## Severity guide

| Severity | Meaning | Examples |
| --- | --- | --- |
| Blocking | Must be fixed before merge | failing test, security hole, missing AC |
| Major | Should be fixed soon; does not break an AC | missing edge-case test, poor error message on a rare path |
| Minor | Nice to fix | naming, small duplication, style |

## Evidence

Valid evidence: `path/to/file:line` showing the behavior, the name of a passing
test that exercises it, or an excerpt of command output. When a criterion can
only be checked manually, describe the exact manual steps and their result.
