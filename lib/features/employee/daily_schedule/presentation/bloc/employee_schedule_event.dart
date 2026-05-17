abstract class EmployeeScheduleEvent {
  const EmployeeScheduleEvent();
}

class EmployeeScheduleLoadRequested extends EmployeeScheduleEvent {
  const EmployeeScheduleLoadRequested();
}

class EmployeeScheduleSkipRequested extends EmployeeScheduleEvent {
  final String passengerId;
  final String date;
  const EmployeeScheduleSkipRequested(this.passengerId, this.date);
}
