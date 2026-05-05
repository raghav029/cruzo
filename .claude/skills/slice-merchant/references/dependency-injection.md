# Dependency Injection — Slice Merchant

## Resolving Dependencies

Use `dependencyManager<T>()` (a type alias for `GetIt.instance<T>()`). Always resolve by **interface**, not implementation.

```dart
// Core services — all available after bootstrap
final api       = dependencyManager<IAPIServiceInterface>();
final nav       = dependencyManager<IAppNavigationProvider>();
final analytics = dependencyManager<IAnalyticsProvider>();
final session   = dependencyManager<AppSession>();
final config    = dependencyManager<FirebaseRemoteConfigServiceInterface>();
final storage   = dependencyManager<AppStorageService>();
```

---

## What Is Registered and Where

### `lib/app/di/core_module.dart`
Synchronous singletons registered first during `configureDependencies()`:

| Type | What |
|------|------|
| `IAPIServiceInterface` | Dio-based HTTP client with SSL pinning (prod), session interceptors |
| `IAppNavigationProvider` | Navigation service wrapping GoRouter |
| `AppSession` | Auth session state (tokens, user identity) |
| `AppStorageService` | Secure local storage |
| `PlatformChannelService` | Raw MethodChannel bridge (do not resolve in feature code) |
| `AuthChannelService` | Auth channel wrapper |
| `AuthMethodChannel` | Typed auth channel — resolve this for auth/biometric calls |
| `SecurityMethodChannel` | AppProtectt security SDK channel |

### `lib/app/di/services_module.dart`
Async singletons — available after `dependencyManager.allReady()`:

| Type | What |
|------|------|
| `IAnalyticsProvider` | Mixpanel/Firebase analytics |
| `FirebaseRemoteConfigServiceInterface` | Remote config |
| `AnalyticsEventChannelService` | Native → Flutter analytics event bridge |
| Platform channels (Firebase, push notifications) | Registered and initialised asynchronously |

---

## Bootstrap Phases

`bootstrap.dart` initialises in three phases — do not call `dependencyManager<T>()` before phase 3 completes:

```
Phase 1 — configureDependencies()
  └─ Registers core_module (sync) + services_module (async)

Phase 2 — dependencyManager.allReady()
  └─ Awaits all async singletons (Firebase, analytics, etc.)

Phase 3 — Post-init wiring
  └─ NavigationService.initializeRouter()
  └─ AuthFlowCoordinator setup
  └─ Push notification registration
  └─ Deeplink router initialisation
```

---

## Feature Code Rules

- **BLoCs**: Always instantiate inside `buildScreen()` — never register in GetIt
- **Repos**: Instantiate inside `buildScreen()` as the default. Exception: when the repo depends on a Retrofit API service (which itself needs a `Dio` instance), register both in the module's `init()` as lazy singletons (see below)
- **Services**: Only resolve services registered in `core_module` or `services_module`

```dart
// Standard — instantiate in buildScreen() (preferred for simple repos)
Object? buildScreen(BuildContext context, RouteDefinition route,
    Map<String, String> pathParams, Map<String, String> queryParams) {
  return BlocProvider<FeatureBloc>(
    create: (_) => FeatureBloc(
      featureRepo: FeatureRepoImpl(apiService: dependencyManager()),
      navigationService: dependencyManager(),
      analyticsHandler: dependencyManager(),
    )..add(const LoadFeature()),
    child: const FeatureScreen(),
  );
}
```

### Exception: Retrofit API service + repo registered in `init()`

When a feature repo requires a Retrofit-generated API service (which needs `Dio`), register the service and its dependent repo as lazy singletons in `init()`. The account module follows this pattern:

```dart
@override
void init() {
  // Retrofit service needs Dio — register once as lazy singleton
  dependencyManager.registerLazySingleton<FeatureAPIService>(() {
    return FeatureAPIService(dependencyManager<Dio>());
  });
  // Repo depends on the Retrofit service — also a lazy singleton
  dependencyManager.registerLazySingleton<FeatureRepo>(
    () => FeatureRepoImpl(
      apiService: dependencyManager<IAPIServiceInterface>(),
      featureAPIService: dependencyManager<FeatureAPIService>(),
    ),
  );
}

// Then resolve in buildScreen()
dependencyManager<FeatureRepo>()
```

**Never** register BLoCs in `init()` — BLoCs are always instantiated in `buildScreen()`.
