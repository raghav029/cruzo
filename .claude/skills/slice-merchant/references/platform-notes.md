# Platform Notes — Slice Merchant

## iOS

### AppDelegate

Native SDK bridges and method channel handlers are wired in `ios/Runner/AppDelegate.swift`. **Coordinate with the iOS team before**:
- Adding new method channel calls (Flutter → Native)
- Adding new handler registrations (Native → Flutter)
- Modifying startup hooks or SDK initialisation order

### Deep Links

Deep links arrive natively and are forwarded to Flutter via `DeeplinkFlutterMethodChannel`. Handle deep links in the navigation layer — not in individual feature modules. Do not attempt to intercept `onGenerateRoute` or `GoRouter` redirect for deep links.

### SSL Pinning

SSL certificates are stored in `ios/Runner/Security/`. Production builds use certificate pinning via the network layer. When adding a new environment or rotating certificates:
1. Add the new certificate to `ios/Runner/Security/`
2. Update the pinning configuration in the network layer
3. Coordinate with the iOS team for the AppDelegate update

### Jailbreak Detection

`JailbreakCheckHandler` runs at startup. Do not interfere with it or attempt to bypass it in tests — use the test flavor which disables the check.

### AppProtectt (Security SDK)

Managed via `SecurityMethodChannel`. All calls are iOS-only and guarded — see `references/platform-channels.md`. The SDK must be initialised before UI renders; it is called in bootstrap, not in feature modules.

### Screenshot Prevention

```dart
await SecurityMethodChannel.instance.enableScreenshotPrevention();
```

iOS only. Call after `isAppProtecttInitialized()` returns `true`.

---

## Android

### Build Configuration

`android/app/build.gradle.kts` — key rules:

- Use `flutter.minSdkVersion` — never hardcode a `minSdk` value
- Use `flutter.targetSdkVersion` and `flutter.compileSdkVersion`
- Java and Kotlin compile target: `VERSION_11`

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}
kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
}
```

### Platform Channel on Android

The `com.slice.platform_channel` MethodChannel is also implemented on Android. If a new method channel call must work on Android, coordinate with the Android team. `SecurityMethodChannel` methods all return `false` on Android without making any native call.

---

## Flavors

| Flavor | Entry point | `APP_ENV` | Notes |
|--------|-------------|-----------|-------|
| `test` | `lib/main_test.dart` | `test` | Chucker HTTP inspector on long-press, jailbreak check disabled |
| `beta` | `lib/main_beta.dart` | `beta` | Chucker on long-press, production-like otherwise |
| `prod` | `lib/main_prod.dart` | `prod` | SSL pinning active, no debug tooling |

Run with:
```bash
fvm flutter run --flavor test -t lib/main_test.dart --dart-define=APP_ENV=test
```

Build for distribution via `scripts/build_ios.sh <flavor>`.
