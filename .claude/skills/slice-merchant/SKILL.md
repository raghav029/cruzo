---
name: slice-merchant
description: >
  Slice Merchant App project-specific development patterns. Covers navigation service,
  module system, API integration, DI wiring, platform channels, event bus, analytics,
  SDUI utilities, and platform notes. Use alongside flutter-pro and slice-flutter-ui
  for feature development.
version: 2.0.0
tested-by: @asit-mohanty
last-validated: 2026-04-24
---

# Slice Merchant — Project Skill

Project-specific patterns for the Slice Merchant App. Apply these **on top of** the org-wide Flutter skills.

---

## When to Use

- Scaffolding a new feature module end-to-end
- Navigating between screens or adding a new route
- Making API calls from a repository
- Wiring services via DI (`dependencyManager`)
- Calling native iOS/Android APIs via method channels
- Firing cross-feature events via `EventBus`
- Implementing analytics tracking
- Building BE-driven (SDUI) screens or widgets
- Understanding iOS/Android platform-specific constraints

---

## Companion Skills

Load these alongside this skill when the task requires it:

| Skill | Load when |
|-------|-----------|
| `/flutter-pro` | Complex BLoC state graphs, custom painters/animations, performance profiling (RepaintBoundary, compute()), advanced state management (HydratedBloc, BLoC-to-BLoC), security hardening, CI/analysis_options setup |
| `/slice-flutter-ui` | Building or editing **any** screen or widget — DLS components (SliceButton, SliceCard, etc.), design tokens (color, typography, spacing), theme extensions, light/dark mode |

---

## Core Workflow

```
1. STRUCTURE    → Place files in the correct feature directory (see CLAUDE.md)
2. MODULE       → Implement IBaseModule, define routes, register in ModuleRegistry
3. NAVIGATE     → Use IAppNavigationProvider only — never context.go() or GoRouter directly
4. NETWORK      → Define ApiBasePod endpoint enum, call via apiService.executeRequest()
5. DI           → Resolve services with dependencyManager<T>() — never register BLoCs/repos in GetIt
6. TRACK        → Wire FeatureAnalytics in the BLoC, fire events in handlers not in build()
```

---

## Reference Guide

Load the matching reference based on the current task:

| Topic | Reference | Load when |
|-------|-----------|-----------|
| Navigation | `references/navigation.md` | Adding routes, navigating between screens, bottom sheets, deep links |
| Module System | `references/module-system.md` | Creating a new feature module, `buildScreen()`, `ModuleRegistry` |
| API Integration | `references/api-integration.md` | Making HTTP calls, `ApiBasePod`, endpoint enums, `executeRequest` vs Retrofit |
| Dependency Injection | `references/dependency-injection.md` | Resolving services, understanding bootstrap phases, what's registered |
| Event Bus | `references/event-bus.md` | Cross-feature communication, `EventBus` listen/fire/cancel |
| Analytics | `references/analytics.md` | Tracking screens and actions, `FeatureAnalytics` template |
| SDUI | `references/sdui.md` | BE-driven color/typography parsing, `sduiParseHexColor`, `DLSTextStyle` |
| Platform Channels | `references/platform-channels.md` | Calling native iOS APIs, auth/biometric, onboarding handoff, security SDK, native analytics |
| Platform Notes | `references/platform-notes.md` | iOS AppDelegate, SSL certs, jailbreak, Android build config |

---

## MUST DO

- Use `IAppNavigationProvider` for all navigation — never `context.go()`, `context.push()`, or `GoRouter` directly
- Instantiate repos and BLoCs inside `buildScreen()` — never register them in GetIt
- Call APIs via `apiService.executeRequest()` — returns `ApiResult<T>`, handles errors automatically
- Use `dependencyManager<T>()` to resolve core services
- Fire analytics events inside BLoC event handlers, never inside `build()`
- Use `fvm flutter` / `fvm dart` for all commands — never the global binary
- Read secrets through `Env()` only — never log or expose values
- All MethodChannel calls go through the typed wrapper (`AuthMethodChannel`, `SecurityMethodChannel`, etc.) — never call `PlatformChannelService` directly from feature code

## MUST NOT DO

- Never use `context.go()`, `context.push()`, or `GoRouter` directly
- Never register BLoCs in GetIt / `dependencyManager` — always instantiate in `buildScreen()`
- Never register repos in GetIt unless they depend on a Retrofit API service (see `references/dependency-injection.md`)
- Never call `PlatformChannelService.invokeMethod()` from feature code — use the typed wrapper
- Never log or expose `Env()` values
- Never write to `.g.dart` or `.freezed.dart` files manually
- Never use `apiService.processRequest()` directly in new code — use `executeRequest()` instead
- Never fire analytics in `build()` — only in BLoC event handlers

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Route not found at runtime | Module not registered | Add to `ModuleRegistry.getModules()` |
| `dependencyManager<T>()` throws | Service not registered or wrong type | Check `core_module.dart` / `services_module.dart`; confirm `T` is the interface, not the impl |
| Navigation does nothing | Using `context.go()` bypassing `IAppNavigationProvider` | Replace with `navigationService.navigateTo()` |
| `EventBus` listener not firing | Subscription not set up before event fires, or disposed too early | Move subscription to `initState`; verify `cancel()` is in `dispose()` not `build()` |
| Native method call crashes | Calling `PlatformChannelService` directly or wrong method name | Use typed `AuthMethodChannel` / `SecurityMethodChannel`; check enum name matches iOS implementation |
| `executeRequest` returns `Error` on 2xx | Response model `fromJson` throws | Add try/catch in `fromJson`; check field nullability |
| Analytics not appearing in Mixpanel | Event fired in `build()` instead of BLoC handler | Move `_analytics.fireX()` call into the BLoC event handler |

---

## Known Limitations

- Does not cover Flutter Web or Desktop — iOS and Android only
- Retrofit pattern (`executeRetrofitCall`) is optional; prefer `executeRequest` for new features
- Platform channel additions require coordination with the iOS team (AppDelegate.swift)
- Does not replace `/flutter-pro` for advanced BLoC patterns, animations, or performance work
- Does not replace `/slice-flutter-ui` for DLS component selection and design tokens

## Changelog

| Date | Version | Author | Notes |
|------|---------|--------|-------|
| 2026-04-24 | 2.0.0 | @asit-mohanty | Refactored from monolith to hub-and-spoke; added platform-channels, companion skills, correct API priority order |
| — | 1.0.0 | @asit-mohanty | Initial monolithic version |
