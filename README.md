# cruzo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local Run Config

The Fleet app reads compile-time environment values from `env.json`.

- `API_BASE_URL`: `http://localhost:8080`

Run from VS Code with the `cruzo: Fleet (Chrome)` launch profile, or use:

```bash
flutter run -t lib/main_fleet.dart -d chrome --dart-define-from-file=env.json
```
