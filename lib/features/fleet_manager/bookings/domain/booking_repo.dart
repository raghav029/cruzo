import '../../../../core/network/api_result.dart';
import 'booking.dart';

abstract class BookingRepo {
  Future<ApiResult<List<Booking>>> list({
    String? status,
    String? fromDate,
    String? toDate,
    int page = 0,
    int size = 100,
  });

  Future<ApiResult<Booking>> approve(String id);

  Future<ApiResult<Booking>> reject(String id, {String? reason});

  Future<ApiResult<Booking>> assignDriver(
    String id,
    String driverId,
    String vehicleId,
  );

  Future<ApiResult<Booking>> autoAssign(String id);

  Future<ApiResult<Booking>> cancel(String id, {String? reason});

  Future<ApiResult<Booking>> getById(String id);
  Future<ApiResult<List<Booking>>> myActive();
  Future<ApiResult<Booking>> refreshBoardingOtp(String id);

  Future<ApiResult<Booking>> create({
    required String corporateClientId,
    required String pickupAddress,
    required String dropAddress,
    required String vehicleType,
    required String scheduledAt,
    String? notes,
  });
}
