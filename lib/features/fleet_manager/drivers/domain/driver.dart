class Driver {
  final String id;
  final String? userId;
  final String fullName;
  final String email;
  final String phone;
  final String licenseNumber;
  final String? licenseExpiry;
  final String? insuranceExpiry;
  final String availability;
  final String? currentVehicleId;

  const Driver({
    required this.id,
    this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    this.licenseExpiry,
    this.insuranceExpiry,
    required this.availability,
    this.currentVehicleId,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json['id'] as String,
        userId: json['userId'] as String?,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        licenseNumber: json['licenseNumber'] as String,
        licenseExpiry: json['licenseExpiry'] as String?,
        insuranceExpiry: json['insuranceExpiry'] as String?,
        availability: json['availability'] as String,
        currentVehicleId: json['currentVehicleId'] as String?,
      );

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
