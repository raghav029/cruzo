import '../../domain/sos_alert.dart';

abstract class SosAlertState {
  const SosAlertState();
}

class SosAlertInitial extends SosAlertState {}

class SosAlertLoading extends SosAlertState {}

class SosAlertLoaded extends SosAlertState {
  final List<SosAlert> alerts;
  final String? activeFilter;
  const SosAlertLoaded(this.alerts, {this.activeFilter});
}

class SosAlertError extends SosAlertState {
  final String message;
  const SosAlertError(this.message);
}

class SosAlertMutating extends SosAlertState {
  final List<SosAlert> alerts;
  const SosAlertMutating(this.alerts);
}

class SosAlertMutationSuccess extends SosAlertState {
  final List<SosAlert> alerts;
  final String message;
  const SosAlertMutationSuccess(this.alerts, this.message);
}

class SosAlertMutationError extends SosAlertState {
  final List<SosAlert> alerts;
  final String message;
  const SosAlertMutationError(this.alerts, this.message);
}
