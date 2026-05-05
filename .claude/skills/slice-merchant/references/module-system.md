# Module System — Slice Merchant

## Overview

Every feature is encapsulated in an `IBaseModule`. On startup, `NavigationService.initializeRouter()` aggregates routes from all modules registered in `ModuleRegistry` and hands them to GoRouter.

---

## Feature Directory Layout

```
lib/app/features/<feature_name>/
├── ui/
│   ├── <feature>_screen.dart
│   └── widgets/
├── bloc/
│   ├── <feature>_bloc.dart
│   ├── <feature>_event.dart
│   └── <feature>_state.dart
├── repository/
│   ├── <feature>_repo.dart          # abstract interface
│   └── <feature>_repo_impl.dart
├── data/
│   ├── <feature>_api_endpoints.dart
│   └── models/
├── module/          # or navigation/ — both are used in the codebase
│   ├── <feature>_module.dart        # IBaseModule implementation
│   └── <feature>_routes.dart        # FeatureRoutePath enum + FeatureRoutes
├── analytics/
│   └── <feature>_analytics.dart
└── constant/
    └── <feature>_strings.dart
```

The routing folder is named either `module/` (auth, dashboard, home, profile) or `navigation/` (account, lending, rewards, soundbox, transaction, and others). Both are correct — match the convention of the feature you are working near.

---

## IBaseModule Implementation Template

```dart
// <feature>_module.dart
class FeatureModule extends IBaseModule {
  static final FeatureModule _instance = FeatureModule._();
  factory FeatureModule() => _instance;
  FeatureModule._();

  @override
  void init() {}

  @override
  List<RouteDefinition> getRoutes() => FeatureRoutes.getRoutes();

  @override
  bool canHandleRoute(String path) =>
      FeatureRoutePath.values.any((r) => r.path == path);

  @override
  Object? buildScreen(
    BuildContext context,
    RouteDefinition route,
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) {
    return switch (FeatureRoutePath.fromPath(route.path)) {
      FeatureRoutePath.home => _buildHomeScreen(context),
      FeatureRoutePath.detail => _buildDetailScreen(context, pathParams),
    };
  }

  Widget _buildHomeScreen(BuildContext context) {
    return BlocProvider<FeatureBloc>(
      create: (_) => FeatureBloc(
        featureRepo: FeatureRepoImpl(apiService: dependencyManager()),
        analyticsHandler: dependencyManager(),
        navigationService: dependencyManager(),
      )..add(const LoadFeature()),
      child: const FeatureScreen(),
    );
  }

  Widget _buildDetailScreen(BuildContext context, Map<String, String> pathParams) {
    final id = pathParams['id'] ?? '';
    return BlocProvider<FeatureBloc>(
      create: (_) => FeatureBloc(
        featureRepo: FeatureRepoImpl(apiService: dependencyManager()),
        analyticsHandler: dependencyManager(),
        navigationService: dependencyManager(),
      )..add(LoadFeatureDetail(id: id)),
      child: const FeatureDetailScreen(),
    );
  }
}
```

**Key rules:**
- Module is a singleton (`_instance` pattern)
- Repos and BLoCs are **instantiated here**, never registered in GetIt
- `buildScreen()` uses an exhaustive `switch` on the route enum

---

## ModuleRegistry Registration

File: `lib/app/common/routing/modules/registry/module_registry.dart`

```dart
static List<IBaseModule> getModules() => [
  AuthModule(),
  OnboardingModule(),
  DashboardModule(),
  HomeModule(),
  TransactionModule(),
  LendingModule(),
  RewardsModule(),
  AccountModule(),
  ProfileModule(),
  HnsModule(),
  CommonModule(),
  SoundboxModule(),
  YourNewFeatureModule(),  // ← add here
];
```

Always register a new module here — without it, routes will never be found at runtime.
