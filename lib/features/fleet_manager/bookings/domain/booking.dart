import 'booking_status.dart';

class Booking {
  final String id;
  final String? corporateClientName;
  final String? employeeName;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final String pickupAddress;
  final String dropAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final double? driverCurrentLat;
  final double? driverCurrentLng;
  final String? locationUpdatedAt;
  final String? vehicleTypeRequested;
  final String scheduledAt;
  final String? notes;
  final String status;
  final String? cancellationReason;
  final String? rejectionReason;
  final double? estimatedFare;
  final double? finalFare;
  final String? createdAt;
  final String? driverId;
  final String? vehicleId;
  final String? approvedAt;
  final String? driverAssignedAt;
  final String? tripStartedAt;
  final String? tripCompletedAt;
  final String? boardingOtp;
  final String? dropOtp;

  const Booking({
    required this.id,
    this.corporateClientName,
    this.employeeName,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    required this.pickupAddress,
    required this.dropAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    this.driverCurrentLat,
    this.driverCurrentLng,
    this.locationUpdatedAt,
    this.vehicleTypeRequested,
    required this.scheduledAt,
    this.notes,
    required this.status,
    this.cancellationReason,
    this.rejectionReason,
    this.estimatedFare,
    this.finalFare,
    this.createdAt,
    this.driverId,
    this.vehicleId,
    this.approvedAt,
    this.driverAssignedAt,
    this.tripStartedAt,
    this.tripCompletedAt,
    this.boardingOtp,
    this.dropOtp,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    corporateClientName: json['corporateClientName'] as String?,
    employeeName: json['employeeName'] as String?,
    driverName: json['driverName'] as String?,
    driverPhone: json['driverPhone'] as String?,
    vehiclePlate: json['vehiclePlate'] as String?,
    pickupAddress: json['pickupAddress'] as String,
    dropAddress: json['dropAddress'] as String,
    pickupLat: (json['pickupLat'] as num?)?.toDouble(),
    pickupLng: (json['pickupLng'] as num?)?.toDouble(),
    dropLat: (json['dropLat'] as num?)?.toDouble(),
    dropLng: (json['dropLng'] as num?)?.toDouble(),
    driverCurrentLat: (json['driverCurrentLat'] as num?)?.toDouble(),
    driverCurrentLng: (json['driverCurrentLng'] as num?)?.toDouble(),
    locationUpdatedAt: json['locationUpdatedAt'] as String?,
    vehicleTypeRequested: json['vehicleTypeRequested'] as String?,
    scheduledAt: json['scheduledAt'] as String,
    notes: json['notes'] as String?,
    status: json['status'] as String,
    cancellationReason: json['cancellationReason'] as String?,
    rejectionReason: json['rejectionReason'] as String?,
    estimatedFare: (json['estimatedFare'] as num?)?.toDouble(),
    finalFare: (json['finalFare'] as num?)?.toDouble(),
    createdAt: json['createdAt'] as String?,
    driverId: json['driverId'] as String?,
    vehicleId: json['vehicleId'] as String?,
    approvedAt: json['approvedAt'] as String?,
    driverAssignedAt: json['driverAssignedAt'] as String?,
    tripStartedAt: json['tripStartedAt'] as String?,
    tripCompletedAt: json['tripCompletedAt'] as String?,
    boardingOtp: json['boardingOtp'] as String?,
    dropOtp: json['dropOtp'] as String?,
  );

  BookingStatus get statusEnum => BookingStatus.fromString(status);

  bool get isActionable =>
      statusEnum == BookingStatus.pendingApproval ||
      statusEnum == BookingStatus.approved ||
      statusEnum == BookingStatus.driverAssigned;

  bool get isPending => statusEnum.isPending;
  bool get isApproved => statusEnum == BookingStatus.approved;
  bool get isActive => statusEnum.isActive;
  bool get isCompleted => statusEnum.isCompleted;
  bool get isCancelled =>
      statusEnum.isCancelled || statusEnum == BookingStatus.rejected;

  bool get hasCoords =>
      pickupLat != null &&
      pickupLng != null &&
      dropLat != null &&
      dropLng != null;

  bool get hasDriverLocation =>
      driverCurrentLat != null && driverCurrentLng != null;
}
