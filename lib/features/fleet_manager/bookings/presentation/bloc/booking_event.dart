abstract class BookingEvent {
  const BookingEvent();
}

class BookingLoadRequested extends BookingEvent {
  final String? statusFilter;
  const BookingLoadRequested({this.statusFilter});
}

class BookingApproveRequested extends BookingEvent {
  final String id;
  const BookingApproveRequested(this.id);
}

class BookingRejectRequested extends BookingEvent {
  final String id;
  final String? reason;
  const BookingRejectRequested(this.id, {this.reason});
}

class BookingAssignDriverRequested extends BookingEvent {
  final String id;
  final String driverId;
  final String vehicleId;
  const BookingAssignDriverRequested(this.id, this.driverId, this.vehicleId);
}

class BookingAutoAssignRequested extends BookingEvent {
  final String id;
  const BookingAutoAssignRequested(this.id);
}

class BookingCancelRequested extends BookingEvent {
  final String id;
  final String? reason;
  const BookingCancelRequested(this.id, {this.reason});
}
