import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/daily_schedule_repo.dart';
import 'daily_schedule_event.dart';
import 'daily_schedule_state.dart';

class DailyScheduleBloc
    extends Bloc<DailyScheduleEvent, DailyScheduleState> {
  final DailyScheduleRepo _repo;

  DailyScheduleBloc(this._repo) : super(DailyScheduleInitial()) {
    on<ScheduleListRequested>(_onList);
    on<PassengersRequested>(_onPassengers);
    on<StopSequenceAssigned>(_onAssignSequence);
    on<TripsRequested>(_onTrips);
    on<DriverAssigned>(_onAssignDriver);
    on<TripCancelled>(_onCancelTrip);
  }

  Future<void> _onList(
      ScheduleListRequested event, Emitter<DailyScheduleState> emit) async {
    emit(DailyScheduleLoading());
    final result = await _repo.list();
    switch (result) {
      case Success(:final value):
        emit(ScheduleListLoaded(value));
      case Failure(:final message):
        emit(DailyScheduleError(message));
    }
  }

  Future<void> _onPassengers(
      PassengersRequested event, Emitter<DailyScheduleState> emit) async {
    emit(DailyScheduleLoading());
    final result = await _repo.listPassengers(event.scheduleId);
    switch (result) {
      case Success(:final value):
        emit(PassengersLoaded(event.scheduleId, value));
      case Failure(:final message):
        emit(DailyScheduleError(message));
    }
  }

  Future<void> _onAssignSequence(
      StopSequenceAssigned event, Emitter<DailyScheduleState> emit) async {
    emit(DailyScheduleMutating());
    final result = await _repo.assignStopSequence(
        event.scheduleId, event.passengerId, event.sequence);
    switch (result) {
      case Success():
        emit(const DailyScheduleMutationSuccess('Stop sequence updated'));
        add(PassengersRequested(event.scheduleId));
      case Failure(:final message):
        emit(DailyScheduleError(message));
    }
  }

  Future<void> _onTrips(
      TripsRequested event, Emitter<DailyScheduleState> emit) async {
    emit(DailyScheduleLoading());
    final result = await _repo.listTripsByDate(event.date);
    switch (result) {
      case Success(:final value):
        emit(TripsLoaded(event.date, value));
      case Failure(:final message):
        emit(DailyScheduleError(message));
    }
  }

  Future<void> _onAssignDriver(
      DriverAssigned event, Emitter<DailyScheduleState> emit) async {
    emit(DailyScheduleMutating());
    final result = await _repo.assignDriver(
        event.tripId, event.driverId, event.vehicleId);
    switch (result) {
      case Success():
        emit(const DailyScheduleMutationSuccess('Driver assigned'));
      case Failure(:final message):
        emit(DailyScheduleError(message));
    }
  }

  Future<void> _onCancelTrip(
      TripCancelled event, Emitter<DailyScheduleState> emit) async {
    emit(DailyScheduleMutating());
    final result = await _repo.cancelTrip(event.tripId);
    switch (result) {
      case Success():
        emit(const DailyScheduleMutationSuccess('Trip cancelled'));
      case Failure(:final message):
        emit(DailyScheduleError(message));
    }
  }
}
