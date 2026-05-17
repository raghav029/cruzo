abstract class BookRideEvent {
  const BookRideEvent();
}

class BookRideSubmitted extends BookRideEvent {
  final String corporateClientId;
  final String pickupAddress;
  final String dropAddress;
  final String vehicleType;
  final DateTime scheduledAt;
  final String? notes;

  const BookRideSubmitted({
    required this.corporateClientId,
    required this.pickupAddress,
    required this.dropAddress,
    required this.vehicleType,
    required this.scheduledAt,
    this.notes,
  });
}

class BookRideReset extends BookRideEvent {
  const BookRideReset();
}
