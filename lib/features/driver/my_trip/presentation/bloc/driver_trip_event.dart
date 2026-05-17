abstract class DriverTripEvent {
  const DriverTripEvent();
}

class DriverTripLoadRequested extends DriverTripEvent {
  const DriverTripLoadRequested();
}

class DriverTripStatusUpdated extends DriverTripEvent {
  final String bookingId;
  final String status;
  const DriverTripStatusUpdated(this.bookingId, this.status);
}

class DriverTripBoardingOtpVerified extends DriverTripEvent {
  final String bookingId;
  final String otp;
  const DriverTripBoardingOtpVerified(this.bookingId, this.otp);
}

class DriverTripDropOtpVerified extends DriverTripEvent {
  final String bookingId;
  final String otp;
  const DriverTripDropOtpVerified(this.bookingId, this.otp);
}

class DriverDailyTripPassengerBoarded extends DriverTripEvent {
  final String tripId;
  final String passengerId;
  final String otp;
  const DriverDailyTripPassengerBoarded(this.tripId, this.passengerId, this.otp);
}

class DriverDailyTripPassengerDropped extends DriverTripEvent {
  final String tripId;
  final String passengerId;
  final String otp;
  const DriverDailyTripPassengerDropped(this.tripId, this.passengerId, this.otp);
}

class DriverDailyTripPassengerNoShow extends DriverTripEvent {
  final String tripId;
  final String passengerId;
  const DriverDailyTripPassengerNoShow(this.tripId, this.passengerId);
}

class DriverDailyTripCompleted extends DriverTripEvent {
  final String tripId;
  const DriverDailyTripCompleted(this.tripId);
}

class DriverDailyTripStarted extends DriverTripEvent {
  final String tripId;
  const DriverDailyTripStarted(this.tripId);
}

class DriverTripCancelled extends DriverTripEvent {
  final String bookingId;
  const DriverTripCancelled(this.bookingId);
}

class DriverAvailabilityUpdated extends DriverTripEvent {
  final String availability;
  const DriverAvailabilityUpdated(this.availability);
}
