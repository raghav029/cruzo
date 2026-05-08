abstract class DailyScheduleEvent {
  const DailyScheduleEvent();
}

class ScheduleListRequested extends DailyScheduleEvent {
  const ScheduleListRequested();
}

class PassengersRequested extends DailyScheduleEvent {
  final String scheduleId;
  const PassengersRequested(this.scheduleId);
}

class StopSequenceAssigned extends DailyScheduleEvent {
  final String scheduleId;
  final String passengerId;
  final int sequence;
  const StopSequenceAssigned({
    required this.scheduleId,
    required this.passengerId,
    required this.sequence,
  });
}

class TripsRequested extends DailyScheduleEvent {
  final String date;
  const TripsRequested(this.date);
}

class DriverAssigned extends DailyScheduleEvent {
  final String tripId;
  final String driverId;
  final String vehicleId;
  const DriverAssigned({
    required this.tripId,
    required this.driverId,
    required this.vehicleId,
  });
}

class TripCancelled extends DailyScheduleEvent {
  final String tripId;
  const TripCancelled(this.tripId);
}
