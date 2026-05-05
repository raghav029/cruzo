# /feature — Feature Development Agent

Build a new feature end-to-end using the slice-merchant module structure. Four phase gates: plan → implement → review → done.

---

## Do's and Don'ts

| Do | Don't |
|----|-------|
| Follow the feature directory structure from `CLAUDE.md` | Skip the plan gate — never write code before Gate 1 approval |
| Use the closest existing feature as a reference pattern | Mix UI, BLoC, repo, and data work in a single sub-agent |
| Split implementation into independent parallel sub-agents by layer | Use `context.go()`, `context.push()`, or `GoRouter` directly |
| Register the new module in `ModuleRegistry` | Register BLoCs or repos in GetIt outside the allowed exceptions |
| Run `flutter-review` + `security-review` before Gate 4 | Call `PlatformChannelService.invokeMethod()` from feature code |
| Use `fvm flutter` / `fvm dart` for all commands | Commit, push, or create a PR |
| Call `apiService.executeRequest()` for all API calls | Use `processRequest()` directly in new code |
| Run `graphify update .` after implementation completes | Log or expose `Env()` values |

---

## On Invocation

1. Load `slice-merchant` + `slice-flutter-ui` skills always. Add `flutter-pro` if the feature involves non-trivial BLoC state graphs, animations, or platform depth.
2. Read `graphify-out/GRAPH_REPORT.md` — understand the community structure and god nodes before planning.
3. Ask the developer **one question first**:

   > "Do you have an existing plan or TRD for this feature? (yes / no)"
   > If yes: "Share it as a **Confluence URL**, a **local file path** (e.g. `docs/trd-feature.md`), or **paste the content** directly."

   - **If yes** → skip Phase 1, go to [Phase 1b — TRD Ingestion](#phase-1b--trd-ingestion)
   - **If no** → ask the remaining questions and run [Phase 1 — Discovery](#phase-1--discovery):
     - What does the user see / do? (one-line user story)
     - Which section of the app? (home / accounts / rewards / lending / new module)
     - Are there existing screens or patterns to follow?
     - Are there API endpoints already defined?

---

## Phase 1 — Discovery (no TRD)

Dispatch a sub-agent with this brief:

> **Task:** Discover the integration context for a new feature in slice-merchant-app. Do NOT write any code.
> **Feature:** [developer's description]
> **Instructions:**
> - Read `CLAUDE.md` fully — key invariants, module structure, DI rules.
> - Read `graphify-out/GRAPH_REPORT.md` to understand which communities are affected.
> - Find the most similar existing feature (screen + BLoC + repo) and note its file paths as a reference.
> - Identify: affected module(s), existing routes to hook into, DI registration points, any existing API endpoints to reuse.
> - Return: reference feature path, proposed directory structure under `lib/app/features/<name>/`, list of new files needed, integration points (routes, DI, module registry).

---

## Phase 1b — TRD Ingestion (existing plan provided)

Dispatch a sub-agent with this brief:

> **Task:** Parse a provided TRD/plan and map it to the slice-merchant-app module structure. Do NOT write any code.
> **TRD source:** [one of the following — handle accordingly]
>   - **Confluence URL** → fetch the page content using WebFetch
>   - **Local file path** → read the file using the Read tool
>   - **Pasted content** → use directly as-is
> **Instructions:**
> - Read `CLAUDE.md` fully — key invariants, module structure, DI rules.
> - Read `graphify-out/GRAPH_REPORT.md` to understand affected communities.
> - Parse the TRD and extract: feature description, user stories, API endpoints, data models, UI screens, any stated constraints.
> - Map extracted content to slice-merchant structure: which module, which files, DI registration, route integration.
> - Flag any gaps or ambiguities in the TRD that need developer input before implementation.
> - Return: mapped directory structure, integration points, open questions (if any).

---

## Gate 1 — Plan Approval

Write the full plan to `plans/YYYY-MM-DD-<feature-name>.md` (gitignored — local only) before presenting this gate. Whether the plan came from Discovery or TRD ingestion, the output file format is the same.

Plan file structure:
```markdown
# Plan: <feature name>
Date: YYYY-MM-DD
Source: generated | TRD: confluence (<url>) | TRD: file (<path>) | TRD: pasted

## Reference
[closest existing feature path]

## New module: lib/app/features/<name>/
[full directory tree with file names]

## Integration
- Routes: [where to register]
- DI: [what to register in init()]
- Registry: [ModuleRegistry entry]
- API: [endpoints / new or existing]

## BLoC Design
- States: [list]
- Events: [list]

## Open questions
[gaps from TRD or anything needing developer input — empty if none]
```

Then present in chat:

```
GATE 1 — Feature Plan

Source:     [generated | TRD: confluence <url> | TRD: file <path> | TRD: pasted]
Plan written to: plans/YYYY-MM-DD-<feature-name>.md

Summary:
  Module:    lib/app/features/<name>/
  Reference: [closest existing feature]
  API:       [new / existing endpoints]
  BLoC:      [N states, N events]

Review the plan file, then approve to start implementation. (yes / adjust)
```

**Do not write any code until the developer approves.**

---

## Phase 2 — Implementation

Split work into independent slices and dispatch parallel sub-agents. Typical split:

| Sub-agent | Scope |
|-----------|-------|
| Data layer | `data/` — API endpoints, models, Freezed/JSON serialization |
| Repository | `repository/` — abstract interface + impl using `apiService.executeRequest()` |
| BLoC | `bloc/` — bloc, events, states following approved design |
| UI | `ui/` — screen + widgets using DLS components from `slice-flutter-ui` |
| Module wiring | `module/` + `analytics/` + route registration + DI |

Each sub-agent brief must include:

> **Instructions:**
> - Read `CLAUDE.md` key invariants before writing any code.
> - Read `graphify-out/GRAPH_REPORT.md` — check if any files you will touch are god nodes; note blast radius if so.
> - Follow the reference feature at [path] for patterns.
> - Use `fvm flutter` / `fvm dart` — never the global binary.
> - Navigation: always `IAppNavigationProvider` — never `context.go()` or `GoRouter` directly.
> - BLoCs: instantiate in `buildScreen()` — never register in GetIt.
> - API calls: use `apiService.executeRequest()` — never `processRequest()` directly.
> - Secrets: never log or expose `Env()` values.
> - Stay within the scoped files. Do not modify files outside your slice.

Wait for all parallel sub-agents to complete before proceeding to Gate 2.

---

## Gate 2 — Implementation Review

Present to the developer:

```
GATE 2 — Implementation Ready

Changed files:
  [file] — [one-line summary]

Invariant check:
  Navigation:    [✓ / ✗ issue found]
  DI:            [✓ / ✗ issue found]
  API calls:     [✓ / ✗ issue found]
  Platform ch.:  [✓ / ✗ issue found]

Run `git diff` to review the full implementation.

Approve to run code + security review? (yes / request changes)
```

---

## Phase 3 — Code + Security Review

Dispatch a sub-agent with this brief:

> **Task:** Review the implementation of a new feature in slice-merchant-app.
> **Changed files:** [list from Phase 2]
> **Instructions:**
> - Read `graphify-out/GRAPH_REPORT.md` — check if any changed file is a god node with wide impact.
> - Load `flutter-review` skill and follow its review protocol.
> - Load `security-review` skill and check the changed files for security issues.
> - Produce a findings list with severity: critical / warning / suggestion.
> - Flag any violation of the `CLAUDE.md` key invariants.
> - Return: findings list grouped by severity. Do not fix anything — report only.

---

## Gate 3 — Review Findings

Present to the developer:

```
GATE 3 — Review Findings

Critical:    [list or "none"]
Warnings:    [list or "none"]
Suggestions: [list or "none"]

Fix critical and warning items? (yes / skip suggestions only / review each)
```

If fixes are needed, dispatch a targeted sub-agent to address them, then re-present the diff.

---

## Gate 4 — Final Sign-Off

```
GATE 4 — Done

Local changes are ready. No commits have been made.

Summary:
  Feature:   [one line]
  Files:     [N new, N modified]
  Review:    clean (or N suggestions remaining — your call)

Review with `git diff`, then commit when ready.
Remember to run `graphify update .` to refresh the knowledge graph.
```

Stop here. Do not commit, push, or create a PR.
