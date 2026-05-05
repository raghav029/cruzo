# Analytics — Slice Merchant

## Rule

Fire analytics events inside **BLoC event handlers only** — never in `build()`, widget callbacks, or `initState`.

---

## FeatureAnalytics Template

```dart
// <feature>/analytics/<feature>_analytics.dart

class FeatureAnalytics {
  final IAnalyticsProvider _provider;
  FeatureAnalytics(this._provider);

  void fireScreenLoad() =>
      BaseEvents.sendScreenLoadEvent(_provider, FeatureAnalyticsConstants.screen);

  void fireButtonTap(String buttonName) {
    _provider.logEvent(
      AnalyticsEventType.action,
      AnalyticsEventNames.buttonTap,
      {
        AnalyticsProperties.screenName: FeatureAnalyticsConstants.screen,
        AnalyticsProperties.buttonName: buttonName,
      },
    );
  }

  void fireSubmitSuccess(String itemId) {
    _provider.logEvent(
      AnalyticsEventType.track,
      FeatureAnalyticsConstants.submitSuccess,
      {
        AnalyticsProperties.screenName: FeatureAnalyticsConstants.screen,
        'itemId': itemId,
      },
    );
  }

  void fireError(String errorMessage) {
    _provider.logEvent(
      AnalyticsEventType.error,
      FeatureAnalyticsConstants.error,
      {
        AnalyticsProperties.screenName: FeatureAnalyticsConstants.screen,
        'message': errorMessage,
      },
    );
  }
}

abstract final class FeatureAnalyticsConstants {
  static const String screen = 'FeatureScreen';
  static const String flow = 'feature_flow';
  static const String submitSuccess = 'feature_submit_success';
  static const String error = 'feature_error';
}
```

---

## Wiring in the BLoC

Inject `IAnalyticsProvider` (resolved via `dependencyManager`) and wrap it:

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final FeatureRepo _featureRepo;
  final FeatureAnalytics _analytics;
  final IAppNavigationProvider _navigationService;

  FeatureBloc({
    required FeatureRepo featureRepo,
    required IAnalyticsProvider analyticsHandler,
    required IAppNavigationProvider navigationService,
  })  : _featureRepo = featureRepo,
        _analytics = FeatureAnalytics(analyticsHandler),
        _navigationService = navigationService,
        super(const FeatureInitial()) {
    on<LoadFeature>(_onLoad);
    on<SubmitFeature>(_onSubmit);
  }

  Future<void> _onLoad(LoadFeature event, Emitter<FeatureState> emit) async {
    _analytics.fireScreenLoad();  // ← fire here, not in build()
    emit(const FeatureLoading());
    final result = await _featureRepo.getData();
    result.when(
      success: (data) => emit(FeatureLoaded(data: data)),
      error: (error) {
        _analytics.fireError(error.message);
        emit(FeatureError(message: error.message));
      },
    );
  }

  Future<void> _onSubmit(SubmitFeature event, Emitter<FeatureState> emit) async {
    _analytics.fireButtonTap('submit');
    // ...
  }
}
```

---

## Module Wiring

```dart
// In the module's buildScreen()
Widget _buildHomeScreen(BuildContext context) {
  return BlocProvider<FeatureBloc>(
    create: (_) => FeatureBloc(
      featureRepo: FeatureRepoImpl(apiService: dependencyManager()),
      analyticsHandler: dependencyManager<IAnalyticsProvider>(),
      navigationService: dependencyManager(),
    )..add(const LoadFeature()),
    child: const FeatureScreen(),
  );
}
```

---

## Event Types

| `AnalyticsEventType` | When to use |
|---------------------|-------------|
| `screen` | Screen load / view |
| `action` | Button taps, user interactions |
| `track` | Business events (submit, complete, success) |
| `error` | API errors, validation failures |
