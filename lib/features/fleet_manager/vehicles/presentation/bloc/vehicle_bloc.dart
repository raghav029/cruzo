import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/vehicle_repo.dart';
import '../../domain/vehicle.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepo _repo;

  VehicleBloc(this._repo) : super(VehicleInitial()) {
    on<VehicleLoadRequested>(_onLoad);
    on<VehicleCreateRequested>(_onCreate);
    on<VehicleUpdateRequested>(_onUpdate);
    on<VehicleDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    VehicleLoadRequested event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    final result = await _repo.list(status: event.statusFilter);
    switch (result) {
      case Success(:final value):
        emit(VehicleLoaded(value, activeFilter: event.statusFilter));
      case Failure(:final message):
        emit(VehicleError(message));
    }
  }

  Future<void> _onCreate(
    VehicleCreateRequested event,
    Emitter<VehicleState> emit,
  ) async {
    final current = _currentVehicles();
    emit(VehicleMutating(current));
    final result = await _repo.create(event.data);
    switch (result) {
      case Success(:final value):
        emit(
          VehicleMutationSuccess([
            value,
            ...current,
          ], 'Vehicle added successfully'),
        );
      case Failure(:final message):
        emit(VehicleMutationError(current, message));
    }
  }

  Future<void> _onUpdate(
    VehicleUpdateRequested event,
    Emitter<VehicleState> emit,
  ) async {
    final current = _currentVehicles();
    emit(VehicleMutating(current));
    final result = await _repo.update(event.id, event.data);
    switch (result) {
      case Success(:final value):
        final updated = current
            .map((v) => v.id == event.id ? value : v)
            .toList();
        emit(VehicleMutationSuccess(updated, 'Vehicle updated successfully'));
      case Failure(:final message):
        emit(VehicleMutationError(current, message));
    }
  }

  Future<void> _onDelete(
    VehicleDeleteRequested event,
    Emitter<VehicleState> emit,
  ) async {
    final current = _currentVehicles();
    emit(VehicleMutating(current));
    final result = await _repo.delete(event.id);
    switch (result) {
      case Success():
        final updated = current.where((v) => v.id != event.id).toList();
        emit(VehicleMutationSuccess(updated, 'Vehicle deleted'));
      case Failure(:final message):
        emit(VehicleMutationError(current, message));
    }
  }

  List<Vehicle> _currentVehicles() {
    final s = state;
    if (s is VehicleLoaded) return s.vehicles;
    if (s is VehicleMutating) return s.vehicles;
    if (s is VehicleMutationSuccess) return s.vehicles;
    if (s is VehicleMutationError) return s.vehicles;
    return [];
  }
}
