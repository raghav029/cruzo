class DailySchedule {
  final String id;
  final String corporateClientId;
  final String corporateClientName;
  final String name;
  final String vehicleType;
  final List<String> recurrenceDays;
  final String pickupTime;
  final String dropAddress;
  final bool isPooled;
  final int maxCapacity;
  final bool isActive;
  final int enrolledPassengerCount;
  final String createdAt;

  const DailySchedule({
    required this.id,
    required this.corporateClientId,
    required this.corporateClientName,
    required this.name,
    required this.vehicleType,
    required this.recurrenceDays,
    required this.pickupTime,
    required this.dropAddress,
    required this.isPooled,
    required this.maxCapacity,
    required this.isActive,
    required this.enrolledPassengerCount,
    required this.createdAt,
  });

  factory DailySchedule.fromJson(Map<String, dynamic> j) => DailySchedule(
        id: j['id'] as String,
        corporateClientId: j['corporateClientId'] as String,
        corporateClientName: j['corporateClientName'] as String? ?? '',
        name: j['name'] as String,
        vehicleType: j['vehicleType'] as String,
        recurrenceDays: (j['recurrenceDays'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        pickupTime: j['pickupTime'] as String? ?? '',
        dropAddress: j['dropAddress'] as String? ?? '',
        isPooled: j['pooled'] as bool? ?? false,
        maxCapacity: j['maxCapacity'] as int? ?? 1,
        isActive: j['active'] as bool? ?? true,
        enrolledPassengerCount: j['enrolledPassengerCount'] as int? ?? 0,
        createdAt: j['createdAt'] as String? ?? '',
      );
}

class DailySchedulePassenger {
  final String id;
  final String employeeUserId;
  final String employeeName;
  final String employeeEmail;
  final String employeePhone;
  final String pickupAddress;
  final int? stopSequence;
  final bool isActive;
  final String enrolledAt;

  const DailySchedulePassenger({
    required this.id,
    required this.employeeUserId,
    required this.employeeName,
    required this.employeeEmail,
    required this.employeePhone,
    required this.pickupAddress,
    this.stopSequence,
    required this.isActive,
    required this.enrolledAt,
  });

  factory DailySchedulePassenger.fromJson(Map<String, dynamic> j) =>
      DailySchedulePassenger(
        id: j['id'] as String,
        employeeUserId: j['employeeUserId'] as String? ?? '',
        employeeName: j['employeeName'] as String? ?? '',
        employeeEmail: j['employeeEmail'] as String? ?? '',
        employeePhone: j['employeePhone'] as String? ?? '',
        pickupAddress: j['pickupAddress'] as String? ?? '',
        stopSequence: j['stopSequence'] as int?,
        isActive: j['active'] as bool? ?? true,
        enrolledAt: j['enrolledAt'] as String? ?? '',
      );

  DailySchedulePassenger copyWith({int? stopSequence}) =>
      DailySchedulePassenger(
        id: id,
        employeeUserId: employeeUserId,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        employeePhone: employeePhone,
        pickupAddress: pickupAddress,
        stopSequence: stopSequence ?? this.stopSequence,
        isActive: isActive,
        enrolledAt: enrolledAt,
      );
}

class DailyTripPassenger {
  final String id;
  final String employeeUserId;
  final String employeeName;
  final String pickupAddress;
  final int? stopSequence;
  final String status;

  const DailyTripPassenger({
    required this.id,
    required this.employeeUserId,
    required this.employeeName,
    required this.pickupAddress,
    this.stopSequence,
    required this.status,
  });

  factory DailyTripPassenger.fromJson(Map<String, dynamic> j) =>
      DailyTripPassenger(
        id: j['id'] as String,
        employeeUserId: j['employeeUserId'] as String? ?? '',
        employeeName: j['employeeName'] as String? ?? '',
        pickupAddress: j['pickupAddress'] as String? ?? '',
        stopSequence: j['stopSequence'] as int?,
        status: j['status'] as String? ?? 'SCHEDULED',
      );
}

class DailyTrip {
  final String id;
  final String dailyScheduleId;
  final String scheduleName;
  final String tripDate;
  final String scheduledPickupTime;
  final String dropAddress;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleId;
  final String? vehiclePlate;
  final String status;
  final List<DailyTripPassenger> passengers;
  final String createdAt;

  const DailyTrip({
    required this.id,
    required this.dailyScheduleId,
    required this.scheduleName,
    required this.tripDate,
    required this.scheduledPickupTime,
    required this.dropAddress,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleId,
    this.vehiclePlate,
    required this.status,
    required this.passengers,
    required this.createdAt,
  });

  factory DailyTrip.fromJson(Map<String, dynamic> j) => DailyTrip(
        id: j['id'] as String,
        dailyScheduleId: j['dailyScheduleId'] as String? ?? '',
        scheduleName: j['scheduleName'] as String? ?? '',
        tripDate: j['tripDate'] as String? ?? '',
        scheduledPickupTime: j['scheduledPickupTime'] as String? ?? '',
        dropAddress: j['dropAddress'] as String? ?? '',
        driverId: j['driverId'] as String?,
        driverName: j['driverName'] as String?,
        driverPhone: j['driverPhone'] as String?,
        vehicleId: j['vehicleId'] as String?,
        vehiclePlate: j['vehiclePlate'] as String?,
        status: j['status'] as String? ?? 'SCHEDULED',
        passengers: (j['passengers'] as List<dynamic>?)
                ?.map((e) => DailyTripPassenger.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: j['createdAt'] as String? ?? '',
      );

  bool get needsDriver => status == 'SCHEDULED';
}
