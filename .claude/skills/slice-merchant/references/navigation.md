# Navigation — Slice Merchant

## Rule

**Never use `context.go()`, `context.push()`, or `GoRouter` directly in feature code.**
All navigation goes through `IAppNavigationProvider`.

---

## Resolving the Navigation Service

```dart
// In a BLoC or widget — resolve from DI
final IAppNavigationProvider navigationService = dependencyManager();
```

---

## IAppNavigationProvider API

```dart
// Push a new screen
await navigationService.navigateTo(FeatureRoutePath.detail.path);

// Push with path/query params
await navigationService.navigateTo(
  FeatureRoutePath.detail.path,
  params: {'id': item.id},
);

// Present as a bottom sheet
await navigationService.presentBottomSheet(FeatureRoutePath.sheet.path);

// Replace current route (no back-stack entry)
await navigationService.pushReplacementTo(FeatureRoutePath.home.path);

// Navigate to a dashboard tab (root-level)
await navigationService.navigateToDashboard(DashboardRoutePath.home);

// Pop current route
navigationService.pop();

// Pop with a result
navigationService.pop(result: myResult);
```

---

## FeatureRoutePath Pattern

Every feature defines its own `FeatureRoutePath` enum in `<feature>/module/<feature>_routes.dart`:

```dart
enum FeatureRoutePath {
  home('/feature/home'),
  detail('/feature/detail'),
  sheet('/feature/sheet');

  final String path;
  const FeatureRoutePath(this.path);

  static FeatureRoutePath fromPath(String path) =>
      FeatureRoutePath.values.firstWhere(
        (r) => r.path == path,
        orElse: () => throw Exception('Unknown Feature route: $path'),
      );
}

class FeatureRoutes {
  static List<AppRoute> getRoutes() => [
    AppRoute(path: FeatureRoutePath.home.path, name: 'feature_home'),
    AppRoute(path: FeatureRoutePath.detail.path, name: 'feature_detail'),
    AppRoute(path: FeatureRoutePath.sheet.path, name: 'feature_sheet'),
  ];
}
```

---

## Adding a New Route — 4-Step Checklist

1. Add the path to `FeatureRoutePath` enum in `<feature>/module/<feature>_routes.dart`
2. Add the `AppRoute` to `FeatureRoutes.getRoutes()`
3. Handle the route in `FeatureModule.buildScreen()` switch
4. If this is a **new feature**, register `FeatureModule()` in `ModuleRegistry.getModules()`

---

## Dashboard Tabs

The dashboard uses a `StatefulShellRoute` with four branches. Navigate to tabs via:

```dart
await navigationService.navigateToDashboard(DashboardRoutePath.home);
await navigationService.navigateToDashboard(DashboardRoutePath.accounts);
await navigationService.navigateToDashboard(DashboardRoutePath.rewards);
await navigationService.navigateToDashboard(DashboardRoutePath.lending);
```

Never use `context.go('/dashboard/home')` — it bypasses the provider and breaks shell state.

---

## Deep Links

Deep links arrive via `DeeplinkFlutterMethodChannel` on iOS and are forwarded to the Flutter navigation layer. Handle them in the navigation layer, not in individual features. Coordinate with the iOS team before adding new deep link patterns.
