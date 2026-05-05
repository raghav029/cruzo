# Platform Channels — Slice Merchant

## Architecture — Layered, Never Skip Layers

```
Feature code
    │
    ▼
Typed wrapper          AuthMethodChannel / SecurityMethodChannel / OnboardingMethodChannel
    │
    ▼
Domain channel service  AuthChannelService / OnboardingChannelService
    │
    ▼
PlatformChannelService  (raw MethodChannel — do NOT call from feature code)
```

**Rule: Feature code only touches the typed wrapper layer.** Never call `PlatformChannelService.invokeMethod()` directly.

---

## Channel Names

| Channel | Name | Type |
|---------|------|------|
| Main bridge | `com.slice.platform_channel` | `MethodChannel` |
| Analytics stream | `com.slice.event_channel` | `EventChannel` |

All `MethodChannel` calls share the same channel name — method name disambiguates.

---

## Two-Enum Pattern (per domain)

Every domain has **two enums**:

| Enum | Direction | Contains |
|------|-----------|----------|
| `AuthChannelMethods` | Flutter → Native (invoke) | Methods Flutter calls on iOS |
| `AuthChannelHandlerMethods` | Native → Flutter (handler) | Methods iOS calls back into Flutter |

Never mix them — an invoke enum value used as a handler name (or vice versa) will silently not match.

---

## AuthMethodChannel — Flutter → Native Calls

Resolved via `dependencyManager<AuthMethodChannel>()`.

```dart
final auth = dependencyManager<AuthMethodChannel>();

await auth.startLogin();
await auth.mpinLogout();
await auth.dismissUserIdentity();
await auth.initiateChangeMpin();
await auth.handleBackendSessionExpiry();

// Biometric
final enabled = await auth.isBiometricEnabledForApp();
final systemEnabled = await auth.isBiometricEnabledInSystemSettings();
await auth.toggleBiometric(true);

// Tokens
final authToken = await auth.getAuthToken();
final sessionToken = await auth.getSessionToken();

// Transaction signing
final result = await auth.initiateTransaction(
  requestModel: MpinTransactionRequestModel(/* ... */),
);
// result is Map<String, dynamic>? with: transactionId, signature, issuedAt, expiresAt, payload, authMethod
```

### Native → Flutter Handler Methods (`AuthChannelHandlerMethods`)

iOS calls back into Flutter via these method names. Set a handler in the bootstrap layer — do not set handlers in feature code:

```
onLoginSucceed, onSignupSucceed, onAccessTokenReceived, onUUIDReceived,
onChangeMpinSucceed, onError, onShowLoader, onHideLoader, onLogout,
onAuthenticationSucceed, onAuthenticationFail, onCompleteLogin,
onUidPresented, onSetSessionToken, onToggleBiometric,
onGetBiometricEnabledForApp, onBiometricSystemSettingsStatus
```

---

## OnboardingMethodChannel — Native Onboarding Handoff

```dart
final onboarding = OnboardingMethodChannel(dependencyManager());

await onboarding.startOnboarding({
  'api': apiUrl,
  'hostUrl': hostUrl,
  'apiMethod': 'POST',
  'requestBody': requestBody,
  'entryPoint': entryPoint,
});
```

---

## SecurityMethodChannel — AppProtectt SDK (iOS only)

`SecurityMethodChannel` is a singleton. All methods guard against non-iOS platforms:

```dart
final security = SecurityMethodChannel.instance;

// Called at startup — pass 'prod' or 'nonprod' based on AppConfig
final initialised = await security.initializeAppProtectt();

// Check status
final isInit = await security.isAppProtecttInitialized();
final isVisible = await security.isAppProtecttVisible();

// Update customer reference ID (post-login)
await security.updateCustRefId(deviceId);

// Enable screenshot prevention
await security.enableScreenshotPrevention();
```

All methods return `false` on Android — no guard needed in calling code.

---

## AnalyticsEventChannelService — Native → Flutter Analytics (EventChannel)

Native iOS fires analytics events via the `com.slice.event_channel` EventChannel. The service is registered in `services_module.dart` and started at bootstrap — feature code does not interact with it directly.

If you need to understand the event shape:

```dart
// Event arrives as Map with keys: 'type', 'name', 'data'
// type: 'screen' | 'error' | 'track'
// name: event name string
// data: Map<String, dynamic>
```

---

## Adding a New Method Channel Call

1. Add the method name to the **invoke enum** (`AuthChannelMethods` or create a new domain enum)
2. Add the typed method to the wrapper class (`AuthMethodChannel` or a new wrapper)
3. Coordinate with the iOS team to implement the handler in `AppDelegate.swift`
4. If adding a new **handler** (Native → Flutter callback), add to the handler enum and update the handler in the bootstrap layer — not in feature code
5. Never create a new `MethodChannel` instance in feature code — reuse `PlatformChannelService` via the service layer
