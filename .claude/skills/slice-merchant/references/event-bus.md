# Event Bus — Slice Merchant

## When to Use

Use `EventBus` for **cross-feature communication** that does not go through navigation — e.g., notifying the home screen that a transaction completed in another feature, or updating a badge count when rewards change.

**Do not use** `EventBus` for intra-feature state changes — use BLoC events for those.

---

## Setup

`eventBus` is a global instance from the `event_bus` package. Import it directly:

```dart
import 'package:event_bus/event_bus.dart';
// eventBus is the global singleton — no DI resolution needed
```

---

## Defining an Event

```dart
// Typically in the feature that fires the event, or in a shared constants file
class OnAmountChanged {
  final double amount;
  OnAmountChanged({required this.amount});
}

class OnTransactionCompleted {
  final String transactionId;
  final String status;
  OnTransactionCompleted({required this.transactionId, required this.status});
}
```

---

## Listening to Events

Subscribe in `initState`, cancel in `dispose`:

```dart
class _FeatureScreenState extends State<FeatureScreen> {
  StreamSubscription<OnAmountChanged>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = eventBus.on<OnAmountChanged>().listen(_handleAmountChange);
  }

  void _handleAmountChange(OnAmountChanged event) {
    // Dispatch a BLoC event — do not mutate UI state directly
    context.read<FeatureBloc>().add(AmountUpdated(amount: event.amount));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

---

## Firing Events

Fire from inside a BLoC event handler, not from `build()` or widget callbacks:

```dart
// Inside a BLoC event handler
Future<void> _onSubmit(SubmitEvent event, Emitter<FeatureState> emit) async {
  final result = await _repo.submit(event.data);
  result.when(
    success: (data) {
      eventBus.fire(OnTransactionCompleted(
        transactionId: data.id,
        status: data.status,
      ));
      emit(FeatureSubmitSuccess(data: data));
    },
    error: (error) => emit(FeatureError(message: error.message)),
  );
}
```

---

## Subscription Lifecycle Rules

- Always store the subscription in a nullable field (`StreamSubscription<T>?`)
- Always cancel in `dispose()` — never in `build()`
- If subscribing in a BLoC, cancel in the BLoC's `close()` override
- Never fire events from `build()` — only from BLoC handlers or explicit user actions
