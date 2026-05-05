import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/driver_repo.dart';
import '../../domain/driver.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepo _repo;

  DriverBloc(this._repo) : super(DriverInitial()) {
    on<DriverLoadRequested>(_onLoad);
    on<DriverCreateRequested>(_onCreate);
    on<DriverUpdateRequested>(_onUpdate);
    on<DriverDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    DriverLoadRequested event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    final result = await _repo.list();
    switch (result) {
      case Success(:final value):
        emit(DriverLoaded(value));
      case Failure(:final message):
        emit(DriverError(message));
    }
  }

  Future<void> _onCreate(
    DriverCreateRequested event,
    Emitter<DriverState> emit,
  ) async {
    final current = _current();
    emit(DriverMutating(current));
    final result = await _repo.create(event.data);
    switch (result) {
      case Success(:final value):
        emit(
          DriverMutationSuccess([
            value,
            ...current,
          ], 'Driver added successfully'),
        );
      case Failure(:final message):
        emit(DriverMutationError(current, message));
    }
  }

  Future<void> _onUpdate(
    DriverUpdateRequested event,
    Emitter<DriverState> emit,
  ) async {
    final current = _current();
    emit(DriverMutating(current));
    final result = await _repo.update(event.id, event.data);
    switch (result) {
      case Success(:final value):
        final updated = current
            .map((d) => d.id == event.id ? value : d)
            .toList();
        emit(DriverMutationSuccess(updated, 'Driver updated successfully'));
      case Failure(:final message):
        emit(DriverMutationError(current, message));
    }
  }

  Future<void> _onDelete(
    DriverDeleteRequested event,
    Emitter<DriverState> emit,
  ) async {
    final current = _current();
    emit(DriverMutating(current));
    final result = await _repo.delete(event.id);
    switch (result) {
      case Success():
        emit(
          DriverMutationSuccess(
            current.where((d) => d.id != event.id).toList(),
            'Driver removed',
          ),
        );
      case Failure(:final message):
        emit(DriverMutationError(current, message));
    }
  }

  List<Driver> _current() {
    final s = state;
    if (s is DriverLoaded) return s.drivers;
    if (s is DriverMutating) return s.drivers;
    if (s is DriverMutationSuccess) return s.drivers;
    if (s is DriverMutationError) return s.drivers;
    return [];
  }
}
