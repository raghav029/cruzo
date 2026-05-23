class LiveTrip {
  final String bookingId;
  final String vehicleName;
  final String? plateNumber;
  final String? driverName;
  final String? driverPhone;
  final String? passengerName;
  final String? pickupAddress;
  final String? dropAddress;
  final double? driverLat;
  final double? driverLng;
  final DateTime? locationUpdatedAt;
  final DateTime scheduledAt;

  const LiveTrip({
    required this.bookingId,
    required this.vehicleName,
    this.plateNumber,
    this.driverName,
    this.driverPhone,
    this.passengerName,
    this.pickupAddress,
    this.dropAddress,
    this.driverLat,
    this.driverLng,
    this.locationUpdatedAt,
    required this.scheduledAt,
  });

  bool get hasLocation => driverLat != null && driverLng != null;

  factory LiveTrip.fromJson(Map<String, dynamic> json) {
    return LiveTrip(
      bookingId: json['bookingId'] as String,
      vehicleName: json['vehicleName'] as String? ?? 'Unknown Vehicle',
      plateNumber: json['plateNumber'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      passengerName: json['passengerName'] as String?,
      pickupAddress: json['pickupAddress'] as String?,
      dropAddress: json['dropAddress'] as String?,
      driverLat: (json['driverLat'] as num?)?.toDouble(),
      driverLng: (json['driverLng'] as num?)?.toDouble(),
      locationUpdatedAt: json['locationUpdatedAt'] != null
          ? DateTime.parse(json['locationUpdatedAt'] as String)
          : null,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    );
  }
}
