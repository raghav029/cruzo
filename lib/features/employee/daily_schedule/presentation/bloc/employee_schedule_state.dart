import 'package:equatable/equatable.dart';
import '../../domain/employee_trip.dart';

abstract class EmployeeScheduleState extends Equatable {
  const EmployeeScheduleState();
  @override
  List<Object?> get props => [];
}

class EmployeeScheduleInitial extends EmployeeScheduleState {
  const EmployeeScheduleInitial();
}

class EmployeeScheduleLoading extends EmployeeScheduleState {
  const EmployeeScheduleLoading();
}

class EmployeeScheduleLoaded extends EmployeeScheduleState {
  final EmployeeTrip? todayTrip;
  final List<EmployeeTrip> upcoming;
  const EmployeeScheduleLoaded({required this.todayTrip, required this.upcoming});
  @override
  List<Object?> get props => [todayTrip, upcoming];
}

class EmployeeScheduleError extends EmployeeScheduleState {
  final String message;
  const EmployeeScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeeScheduleSkipping extends EmployeeScheduleLoaded {
  const EmployeeScheduleSkipping({required super.todayTrip, required super.upcoming});
}

class EmployeeScheduleSkipSuccess extends EmployeeScheduleLoaded {
  const EmployeeScheduleSkipSuccess({required super.todayTrip, required super.upcoming});
}

class EmployeeScheduleSkipError extends EmployeeScheduleLoaded {
  final String message;
  const EmployeeScheduleSkipError({
    required super.todayTrip,
    required super.upcoming,
    required this.message,
  });
  @override
  List<Object?> get props => [todayTrip, upcoming, message];
}
