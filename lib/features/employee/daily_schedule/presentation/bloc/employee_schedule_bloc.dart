import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/result.dart';
import '../../domain/employee_schedule_repo.dart';
import '../../domain/employee_trip.dart';
import 'employee_schedule_event.dart';
import 'employee_schedule_state.dart';

class EmployeeScheduleBloc
    extends Bloc<EmployeeScheduleEvent, EmployeeScheduleState> {
  final EmployeeScheduleRepo _repo;

  EmployeeScheduleBloc(this._repo) : super(const EmployeeScheduleInitial()) {
    on<EmployeeScheduleLoadRequested>(_onLoad);
    on<EmployeeScheduleSkipRequested>(_onSkip);
  }

  Future<void> _onLoad(
    EmployeeScheduleLoadRequested event,
    Emitter<EmployeeScheduleState> emit,
  ) async {
    emit(const EmployeeScheduleLoading());
    final todayResult = await _repo.getTodayTrip();
    final scheduleResult = await _repo.getMySchedule();

    final today = switch (todayResult) {
      Success(:final value) => value,
      Failure() => null,
    };
    final upcoming = switch (scheduleResult) {
      Success(:final value) => value,
      Failure() => <EmployeeTrip>[],
    };

    emit(EmployeeScheduleLoaded(
      todayTrip: today,
      upcoming: upcoming,
    ));
  }

  Future<void> _onSkip(
    EmployeeScheduleSkipRequested event,
    Emitter<EmployeeScheduleState> emit,
  ) async {
    final current = state;
    if (current is! EmployeeScheduleLoaded) return;
    emit(EmployeeScheduleSkipping(
        todayTrip: current.todayTrip, upcoming: current.upcoming));
    final result = await _repo.skipDay(event.passengerId, event.date);
    switch (result) {
      case Success():
        emit(EmployeeScheduleSkipSuccess(
            todayTrip: current.todayTrip, upcoming: current.upcoming));
      case Failure(:final message):
        emit(EmployeeScheduleSkipError(
            todayTrip: current.todayTrip,
            upcoming: current.upcoming,
            message: message));
    }
  }
}
