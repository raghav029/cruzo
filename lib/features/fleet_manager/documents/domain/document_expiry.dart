class DriverExpiryItem {
  final String driverId;
  final String driverName;
  final String phone;
  final String expiryDate;
  final int daysUntilExpiry;

  const DriverExpiryItem({
    required this.driverId,
    required this.driverName,
    required this.phone,
    required this.expiryDate,
    required this.daysUntilExpiry,
  });

  bool get isExpired => daysUntilExpiry <= 0;
  bool get isCritical => daysUntilExpiry <= 7 && daysUntilExpiry > 0;

  factory DriverExpiryItem.fromJson(Map<String, dynamic> j) => DriverExpiryItem(
        driverId: j['driverId'] as String,
        driverName: j['driverName'] as String,
        phone: j['phone'] as String,
        expiryDate: j['expiryDate'] as String,
        daysUntilExpiry: (j['daysUntilExpiry'] as num).toInt(),
      );
}

class VehicleExpiryItem {
  final String vehicleId;
  final String plateNumber;
  final String make;
  final String model;
  final String expiryDate;
  final int daysUntilExpiry;

  const VehicleExpiryItem({
    required this.vehicleId,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.expiryDate,
    required this.daysUntilExpiry,
  });

  bool get isExpired => daysUntilExpiry <= 0;
  bool get isCritical => daysUntilExpiry <= 7 && daysUntilExpiry > 0;

  factory VehicleExpiryItem.fromJson(Map<String, dynamic> j) => VehicleExpiryItem(
        vehicleId: j['vehicleId'] as String,
        plateNumber: j['plateNumber'] as String,
        make: j['make'] as String,
        model: j['model'] as String,
        expiryDate: j['expiryDate'] as String,
        daysUntilExpiry: (j['daysUntilExpiry'] as num).toInt(),
      );
}

class DocumentExpirySummary {
  final List<DriverExpiryItem> expiringLicenses;
  final List<DriverExpiryItem> expiringDriverInsurance;
  final List<VehicleExpiryItem> expiringVehicleInsurance;
  final List<VehicleExpiryItem> expiringFitnessCerts;

  const DocumentExpirySummary({
    required this.expiringLicenses,
    required this.expiringDriverInsurance,
    required this.expiringVehicleInsurance,
    required this.expiringFitnessCerts,
  });

  int get totalCount =>
      expiringLicenses.length +
      expiringDriverInsurance.length +
      expiringVehicleInsurance.length +
      expiringFitnessCerts.length;

  factory DocumentExpirySummary.fromJson(Map<String, dynamic> j) =>
      DocumentExpirySummary(
        expiringLicenses: (j['expiringLicenses'] as List)
            .map((e) => DriverExpiryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        expiringDriverInsurance: (j['expiringDriverInsurance'] as List)
            .map((e) => DriverExpiryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        expiringVehicleInsurance: (j['expiringVehicleInsurance'] as List)
            .map((e) => VehicleExpiryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        expiringFitnessCerts: (j['expiringFitnessCerts'] as List)
            .map((e) => VehicleExpiryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
