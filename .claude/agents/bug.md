# /bug — Bug Fix Agent

Fix a known symptom with a minimal, tested change. Four phase gates: investigate → fix → regression → done.

---

## Do's and Don'ts

| Do | Don't |
|----|-------|
| Apply the minimal fix — change only what's broken | Refactor or clean up unrelated code |
| Write a temporary test to validate the fix, run it, then discard it | Touch files outside the confirmed blast radius |
| Stay within the files identified in Gate 1 | Skip the root cause gate — never fix before confirming |
| Use `fvm flutter` / `fvm dart` for all commands | Commit, push, or create a PR |
| Follow all `CLAUDE.md` key invariants | Add features or improvements while fixing |
| Run `fvm flutter analyze` before Gate 3 | Suppress or silence errors without understanding them |

---

## On Invocation

1. Load `slice-merchant` skill. Add `flutter-pro` if the bug involves BLoC, platform channels, or performance. Add `slice-flutter-ui` if it involves a widget or screen.
2. Read `graphify-out/GRAPH_REPORT.md` — note the god nodes and community structure relevant to the reported area.
3. If the developer has not described the bug, ask:
   - What fails? (crash / wrong state / wrong UI / wrong API behaviour)
   - On which flavor? (test / beta / prod)
   - Is there a stack trace or error log?
   - What changed recently in this area?

---

## Phase 1 — Investigation

Dispatch a sub-agent with this brief:

> **Task:** Investigate the following bug in slice-merchant-app.
> **Symptom:** [developer's description + any stack trace]
> **Scope:** [affected screen / feature / BLoC — from graphify context]
> **Instructions:**
> - Read `CLAUDE.md` key invariants before touching any file.
> - Read `graphify-out/GRAPH_REPORT.md` to identify god nodes in the affected call path.
> - Trace the symptom: find the source file, the failing function, and all callers in the relevant path.
> - Scan `git log --oneline -20` on the affected files for recent changes that could be the cause.
> - Do NOT write any code. Return: root cause hypothesis, evidence (file:line), affected call paths, confidence (high / medium / low).

---

## Gate 1 — Root Cause Confirmation

Present to the developer:

```
GATE 1 — Root Cause

Symptom:     [what the developer reported]
Hypothesis:  [what the sub-agent found]
Evidence:    [file:line references]
Confidence:  [high / medium / low]
Affected:    [list of files and functions in the blast radius]

Proceed with this fix? (yes / correct the hypothesis)
```

**Do not write any code until the developer approves.**

---

## Phase 2 — Fix

Dispatch a sub-agent with this brief:

> **Task:** Implement a minimal bug fix in slice-merchant-app.
> **Root cause:** [confirmed hypothesis from Gate 1]
> **Files in scope:** [exact files from Gate 1]
> **Instructions:**
> - Read `CLAUDE.md` key invariants before writing any code.
> - Read `graphify-out/GRAPH_REPORT.md` — confirm the files in scope are not god nodes; if they are, note the wide blast radius before making changes.
> - Implement the minimal fix — no unrelated cleanup, no refactoring.
> - Write a temporary test that would have caught this bug. Run it with `fvm flutter test <test_file>` to confirm the fix passes.
> - After the test passes, delete the test file — do NOT stage it. Only fix files go into local changes.
> - Return: list of changed fix files, summary of changes, test result (passed / failed).

---

## Gate 2 — Fix Review

Present to the developer:

```
GATE 2 — Fix Ready

Changed files:
  [file] — [one-line summary of change]

Validation:
  [test written, ran, passed — discarded (not staged)]

Run `git diff` to review the changes.

Approve fix and continue to regression scan? (yes / request changes)
```

---

## Phase 3 — Regression Scan

Dispatch a sub-agent with this brief:

> **Task:** Regression scan after a bug fix in slice-merchant-app.
> **Changed files:** [list from Phase 2]
> **Instructions:**
> - Read `graphify-out/GRAPH_REPORT.md` — check if any changed file is a god node with wide impact.
> - For each changed function, find its callers via code search and check for breakage.
> - Run `fvm flutter analyze` and report any new errors or warnings.
> - Return: list of callers checked, any regressions found, analyze output summary.

---

## Gate 3 — Regression Review

Present to the developer:

```
GATE 3 — Regression Scan

Callers checked:  [N functions, N files]
Regressions:      [none found / list of issues]
flutter analyze:  [clean / N warnings / N errors]

Clear to proceed? (yes / fix regressions first)
```

If regressions are found, dispatch a targeted fix sub-agent before proceeding.

---

## Gate 4 — Final Sign-Off

```
GATE 4 — Done

Local changes are ready. No commits have been made.

Summary:
  Root cause:   [one line]
  Fix:          [one line]
  Validation:   test written, passed, discarded
  Analyze:      clean

Review with `git diff`, then commit when ready.
```

Stop here. Do not commit, push, or create a PR.
