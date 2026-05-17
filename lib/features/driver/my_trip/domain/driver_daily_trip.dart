import '../../../fleet_manager/bookings/domain/booking_status.dart';

class DriverDailyTripPassenger {
  final String id;
  final String employeeName;
  final String? employeePhone;
  final String pickupAddress;
  final int stopSequence;
  final String boardingOtp;
  final String dropOtp;
  final String status; // PENDING, BOARDED, DROPPED, SKIPPED, NO_SHOW

  const DriverDailyTripPassenger({
    required this.id,
    required this.employeeName,
    this.employeePhone,
    required this.pickupAddress,
    required this.stopSequence,
    required this.boardingOtp,
    required this.dropOtp,
    required this.status,
  });

  factory DriverDailyTripPassenger.fromJson(Map<String, dynamic> j) =>
      DriverDailyTripPassenger(
        id: j['id'] as String,
        employeeName: j['employeeName'] as String? ?? '',
        employeePhone: j['employeePhone'] as String?,
        pickupAddress: j['pickupAddress'] as String? ?? '',
        stopSequence: (j['stopSequence'] as int?) ?? 0,
        boardingOtp: j['boardingOtp'] as String? ?? '',
        dropOtp: j['dropOtp'] as String? ?? '',
        status: j['status'] as String? ?? 'PENDING',
      );

  bool get isPending => status == 'PENDING';
  bool get isBoarded => status == 'BOARDED';
  bool get isTerminal => ['DROPPED', 'SKIPPED', 'NO_SHOW'].contains(status);
}

class DriverDailyTrip {
  final String id;
  final String scheduleName;
  final String tripDate;
  final String? scheduledPickupTime;
  final String dropAddress;
  final BookingStatus status; // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
  final List<DriverDailyTripPassenger> passengers;

  const DriverDailyTrip({
    required this.id,
    required this.scheduleName,
    required this.tripDate,
    this.scheduledPickupTime,
    required this.dropAddress,
    required this.status,
    required this.passengers,
  });

  factory DriverDailyTrip.fromJson(Map<String, dynamic> j) => DriverDailyTrip(
    id: j['id'] as String,
    scheduleName: j['scheduleName'] as String? ?? '',
    tripDate: j['tripDate'] as String? ?? '',
    scheduledPickupTime: j['scheduledPickupTime'] as String?,
    dropAddress: j['dropAddress'] as String? ?? '',
    status: BookingStatus.fromString(j['status'] as String? ?? 'SCHEDULED'),
    passengers: (j['passengers'] as List? ?? [])
        .map(
          (e) => DriverDailyTripPassenger.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  bool get isScheduled =>
      status == BookingStatus.scheduled ||
      status == BookingStatus.driverAssigned;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
}
