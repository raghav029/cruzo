# Agentic Development Workflow

Three agents for structured development on slice-merchant-app.
Each agent orchestrates sub-agents across phases and pauses at human gates.
**Output is always local changes only** — no commits, no pushes, no PRs.

## Agents

| Invoke | File | Use when |
|--------|------|----------|
| `/bug` | `.claude/agents/bug.md` | You have a symptom and need a fix |
| `/debug` | `.claude/agents/debug.md` | You need to understand what's wrong before fixing |
| `/feature` | `.claude/agents/feature.md` | You are building something new |

## How to Start

Tell Claude Code which agent to run and describe your task:

```
start /bug — crash in payment flow after amount entry
start /debug — BLoC state not updating after API response on beta flavor
start /feature — add transaction filter by date range to the accounts screen
```

Claude will load the agent protocol and drive the session from there.

## Shared Rules (all agents)

1. **Load skills first** — `slice-merchant` always; `flutter-pro` for BLoC/platform depth; `slice-flutter-ui` for any screen or widget work.
2. **Read graphify before touching code** — always read `graphify-out/GRAPH_REPORT.md` before Phase 1 to understand community structure and god nodes in the affected area.
3. **Respect CLAUDE.md invariants** — navigation via `IAppNavigationProvider`, BLoCs in `buildScreen()`, no direct `PlatformChannelService`, always `fvm flutter`/`fvm dart`.
4. **Gates are blocking** — never advance to the next phase without explicit developer approval at the gate.
5. **Sub-agents get scoped context** — when dispatching a sub-agent, always pass: task description, relevant invariants from `CLAUDE.md`, and the specific files/modules in scope. Do not pass the full conversation.

## Plans Folder

`/feature` writes a plan doc to `plans/YYYY-MM-DD-<feature>.md` before Gate 1. This folder is gitignored — plans are local only, never staged or committed. Create it on first use: `mkdir plans`.

## Full Design Spec

`docs/superpowers/specs/2026-04-29-agentic-dev-workflow-design.md`
