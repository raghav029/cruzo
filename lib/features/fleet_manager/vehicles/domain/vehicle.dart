class Vehicle {
  final String id;
  final String plateNumber;
  final String vehicleType;
  final String make;
  final String model;
  final int year;
  final String? color;
  final String status;
  final String? insuranceExpiry;
  final String? fitnessExpiry;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.year,
    this.color,
    required this.status,
    this.insuranceExpiry,
    this.fitnessExpiry,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        plateNumber: json['plateNumber'] as String,
        vehicleType: json['vehicleType'] as String,
        make: json['make'] as String,
        model: json['model'] as String,
        year: (json['year'] as num).toInt(),
        color: json['color'] as String?,
        status: json['status'] as String,
        insuranceExpiry: json['insuranceExpiry'] as String?,
        fitnessExpiry: json['fitnessExpiry'] as String?,
      );
}
