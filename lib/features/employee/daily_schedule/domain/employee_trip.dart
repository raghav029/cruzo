class EmployeeTripPassenger {
  final String id;
  final String employeeUserId;
  final String employeeName;
  final String pickupAddress;
  final int? stopSequence;
  final String? boardingOtp;
  final String? dropOtp;
  final String status;
  final String? boardingVerifiedAt;
  final String? dropVerifiedAt;

  const EmployeeTripPassenger({
    required this.id,
    required this.employeeUserId,
    required this.employeeName,
    required this.pickupAddress,
    this.stopSequence,
    this.boardingOtp,
    this.dropOtp,
    required this.status,
    this.boardingVerifiedAt,
    this.dropVerifiedAt,
  });

  factory EmployeeTripPassenger.fromJson(Map<String, dynamic> j) =>
      EmployeeTripPassenger(
        id: j['id'] as String,
        employeeUserId: j['employeeUserId'] as String? ?? '',
        employeeName: j['employeeName'] as String? ?? '',
        pickupAddress: j['pickupAddress'] as String? ?? '',
        stopSequence: j['stopSequence'] as int?,
        boardingOtp: j['boardingOtp'] as String?,
        dropOtp: j['dropOtp'] as String?,
        status: j['status'] as String? ?? 'PENDING',
        boardingVerifiedAt: j['boardingVerifiedAt'] as String?,
        dropVerifiedAt: j['dropVerifiedAt'] as String?,
      );
}

class EmployeeTrip {
  final String id;
  final String dailyScheduleId;
  final String scheduleName;
  final String tripDate;
  final String? scheduledPickupTime;
  final String dropAddress;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final String status;
  final List<EmployeeTripPassenger> passengers;

  const EmployeeTrip({
    required this.id,
    required this.dailyScheduleId,
    required this.scheduleName,
    required this.tripDate,
    this.scheduledPickupTime,
    required this.dropAddress,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    required this.status,
    required this.passengers,
  });

  EmployeeTripPassenger? myPassenger(String userId) {
    try {
      return passengers.firstWhere((p) => p.employeeUserId == userId);
    } catch (_) {
      return null;
    }
  }

  factory EmployeeTrip.fromJson(Map<String, dynamic> j) => EmployeeTrip(
        id: j['id'] as String,
        dailyScheduleId: j['dailyScheduleId'] as String? ?? '',
        scheduleName: j['scheduleName'] as String? ?? '',
        tripDate: j['tripDate'] as String? ?? '',
        scheduledPickupTime: j['scheduledPickupTime'] as String?,
        dropAddress: j['dropAddress'] as String? ?? '',
        driverName: j['driverName'] as String?,
        driverPhone: j['driverPhone'] as String?,
        vehiclePlate: j['vehiclePlate'] as String?,
        status: j['status'] as String? ?? 'SCHEDULED',
        passengers: (j['passengers'] as List<dynamic>? ?? [])
            .map((e) => EmployeeTripPassenger.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
