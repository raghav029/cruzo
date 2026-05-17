import '../services/book_ride_init_service.dart';

class BookRideInitData {
  final String? corporateClientId;
  final double? maxBookingValue;
  final List<String>? allowedVehicleTypes;

  const BookRideInitData({
    this.corporateClientId,
    this.maxBookingValue,
    this.allowedVehicleTypes,
  });
}

class BookRideInitRepository {
  BookRideInitRepository({required BookRideInitService service}) : _service = service;
  final BookRideInitService _service;

  Future<BookRideInitData> fetchInitData() async {
    final results = await Future.wait([
      _service.fetchEmployeeInfo().catchError((_) => <String, dynamic>{}),
      _service.fetchPolicy(),
    ]);
    final employeeData = results[0] as Map<String, dynamic>;
    final policyData = results[1] as Map<String, dynamic>?;

    List<String>? allowedTypes;
    if (policyData != null) {
      final types = policyData['allowedVehicleTypes'] as String?;
      allowedTypes = types != null
          ? types.split(',').map((e) => e.trim()).toList()
          : null;
    }

    return BookRideInitData(
      corporateClientId: employeeData['corporateClientId'] as String?,
      maxBookingValue: (policyData?['maxBookingValue'] as num?)?.toDouble(),
      allowedVehicleTypes: allowedTypes,
    );
  }
}
