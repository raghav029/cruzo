import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/sos_alert_repo.dart';
import '../../domain/sos_alert.dart';
import 'sos_alert_event.dart';
import 'sos_alert_state.dart';

class SosAlertBloc extends Bloc<SosAlertEvent, SosAlertState> {
  final SosAlertRepo _repo;

  SosAlertBloc(this._repo) : super(SosAlertInitial()) {
    on<SosAlertLoadRequested>(_onLoad);
    on<SosAlertResolveRequested>(_onResolve);
  }

  Future<void> _onLoad(
    SosAlertLoadRequested event,
    Emitter<SosAlertState> emit,
  ) async {
    emit(SosAlertLoading());
    final result = await _repo.list(status: event.statusFilter);
    switch (result) {
      case Success(:final value):
        emit(SosAlertLoaded(value, activeFilter: event.statusFilter));
      case Failure(:final message):
        emit(SosAlertError(message));
    }
  }

  Future<void> _onResolve(
    SosAlertResolveRequested event,
    Emitter<SosAlertState> emit,
  ) async {
    final current = _current();
    emit(SosAlertMutating(current));
    final result = await _repo.resolve(event.id, notes: event.notes);
    switch (result) {
      case Success(:final value):
        final updated = current.map((a) => a.id == event.id ? value : a).toList();
        emit(SosAlertMutationSuccess(updated, 'Alert resolved'));
      case Failure(:final message):
        emit(SosAlertMutationError(current, message));
    }
  }

  List<SosAlert> _current() {
    final s = state;
    if (s is SosAlertLoaded) return s.alerts;
    if (s is SosAlertMutating) return s.alerts;
    if (s is SosAlertMutationSuccess) return s.alerts;
    if (s is SosAlertMutationError) return s.alerts;
    return [];
  }
}
