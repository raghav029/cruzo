class SosAlert {
  final String id;
  final String? bookingId;
  final String triggeredByUserId;
  final String triggeredByName;
  final double? lat;
  final double? lng;
  final String? message;
  final String status;
  final String? resolvedByUserId;
  final String? resolvedAt;
  final String createdAt;

  const SosAlert({
    required this.id,
    this.bookingId,
    required this.triggeredByUserId,
    required this.triggeredByName,
    this.lat,
    this.lng,
    this.message,
    required this.status,
    this.resolvedByUserId,
    this.resolvedAt,
    required this.createdAt,
  });

  bool get isActive => status == 'ACTIVE';

  factory SosAlert.fromJson(Map<String, dynamic> j) => SosAlert(
        id: j['id'] as String,
        bookingId: j['bookingId'] as String?,
        triggeredByUserId: j['triggeredByUserId'] as String,
        triggeredByName: j['triggeredByName'] as String,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        message: j['message'] as String?,
        status: j['status'] as String,
        resolvedByUserId: j['resolvedByUserId'] as String?,
        resolvedAt: j['resolvedAt'] as String?,
        createdAt: j['createdAt'] as String,
      );
}
