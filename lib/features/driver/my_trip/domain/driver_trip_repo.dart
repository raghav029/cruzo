import '../../../../core/network/api_result.dart';
import '../../../fleet_manager/bookings/domain/booking.dart';
import 'driver_daily_trip.dart';

abstract class DriverTripRepo {
  Future<ApiResult<Booking?>> getMyActiveTrip();
  Future<ApiResult<void>> updateStatus(String bookingId, String status);
  Future<ApiResult<void>> verifyBoardingOtp(String bookingId, String otp);
  Future<ApiResult<void>> verifyDropOtp(String bookingId, String otp);
  Future<ApiResult<DriverDailyTrip?>> getMyTodayDailyTrip();
  Future<ApiResult<void>> boardPassenger(String tripId, String passengerId, String otp);
  Future<ApiResult<void>> dropPassenger(String tripId, String passengerId, String otp);
  Future<ApiResult<void>> markNoShow(String tripId, String passengerId);
  Future<ApiResult<void>> completeDailyTrip(String tripId);
  Future<ApiResult<List<Booking>>> getMyTripHistory({String? status, int page = 0});
  Future<ApiResult<void>> startDailyTrip(String tripId);
  Future<ApiResult<void>> cancelBooking(String bookingId);
  Future<ApiResult<String>> updateAvailability(String availability);
  Future<ApiResult<String>> getMyAvailability();
}
