class Booking {
  final String id;
  final String? corporateClientName;
  final String? employeeName;
  final String? driverName;
  final String? vehiclePlate;
  final String pickupAddress;
  final String dropAddress;
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

  const Booking({
    required this.id,
    this.corporateClientName,
    this.employeeName,
    this.driverName,
    this.vehiclePlate,
    required this.pickupAddress,
    required this.dropAddress,
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
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        corporateClientName: json['corporateClientName'] as String?,
        employeeName: json['employeeName'] as String?,
        driverName: json['driverName'] as String?,
        vehiclePlate: json['vehiclePlate'] as String?,
        pickupAddress: json['pickupAddress'] as String,
        dropAddress: json['dropAddress'] as String,
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
      );

  bool get isActionable =>
      status == 'PENDING_APPROVAL' || status == 'APPROVED' || status == 'DRIVER_ASSIGNED';

  bool get isPending => status == 'PENDING_APPROVAL';
  bool get isApproved => status == 'APPROVED';
  bool get isActive =>
      status == 'DRIVER_EN_ROUTE' || status == 'ARRIVED' || status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status.startsWith('CANCELLED') || status == 'REJECTED';
}
