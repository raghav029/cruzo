import '../../domain/daily_schedule_models.dart';

abstract class DailyScheduleState {
  const DailyScheduleState();
}

class DailyScheduleInitial extends DailyScheduleState {}

class DailyScheduleLoading extends DailyScheduleState {}

class ScheduleListLoaded extends DailyScheduleState {
  final List<DailySchedule> schedules;
  const ScheduleListLoaded(this.schedules);
}

class PassengersLoaded extends DailyScheduleState {
  final String scheduleId;
  final List<DailySchedulePassenger> passengers;
  const PassengersLoaded(this.scheduleId, this.passengers);
}

class TripsLoaded extends DailyScheduleState {
  final String date;
  final List<DailyTrip> trips;
  const TripsLoaded(this.date, this.trips);
}

class DailyScheduleMutating extends DailyScheduleState {}

class DailyScheduleMutationSuccess extends DailyScheduleState {
  final String message;
  const DailyScheduleMutationSuccess(this.message);
}

class DailyScheduleError extends DailyScheduleState {
  final String message;
  const DailyScheduleError(this.message);
}
