import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../../../fleet_manager/bookings/domain/booking.dart';
import '../../../fleet_manager/bookings/domain/booking_status.dart';
import '../domain/driver_daily_trip.dart';
import '../domain/driver_trip_repo.dart';

class DriverTripRepoImpl implements DriverTripRepo {
  final Dio _dio;
  const DriverTripRepoImpl(this._dio);

  @override
  Future<ApiResult<Booking?>> getMyActiveTrip() {
    return executeRetrofitCall<Booking?>(() async {
      final resp = await _dio.get('/api/bookings/my-trip');
      final data = resp.data['data'];
      if (data == null) return null;
      return Booking.fromJson(data as Map<String, dynamic>);
    }, url: '/api/bookings/my-trip');
  }

  @override
  Future<ApiResult<void>> updateStatus(String bookingId, String status) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/bookings/$bookingId/status',
        queryParameters: {'to': status},
      );
    }, url: '/api/bookings/$bookingId/status');
  }

  @override
  Future<ApiResult<void>> verifyBoardingOtp(String bookingId, String otp) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/bookings/$bookingId/verify-boarding-otp',
        data: {'otp': otp},
      );
    }, url: '/api/bookings/$bookingId/verify-boarding-otp');
  }

  @override
  Future<ApiResult<void>> verifyDropOtp(String bookingId, String otp) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/bookings/$bookingId/verify-drop-otp',
        data: {'otp': otp},
      );
    }, url: '/api/bookings/$bookingId/verify-drop-otp');
  }

  @override
  Future<ApiResult<DriverDailyTrip?>> getMyTodayDailyTrip() {
    return executeRetrofitCall<DriverDailyTrip?>(() async {
      final resp = await _dio.get('/api/daily-trips/my-today-driver');
      final data = resp.data['data'];
      if (data == null) return null;
      return DriverDailyTrip.fromJson(data as Map<String, dynamic>);
    }, url: '/api/daily-trips/my-today-driver');
  }

  @override
  Future<ApiResult<void>> boardPassenger(
    String tripId,
    String passengerId,
    String otp,
  ) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/daily-trips/$tripId/passengers/$passengerId/board',
        data: {'otp': otp},
      );
    }, url: '/api/daily-trips/$tripId/passengers/$passengerId/board');
  }

  @override
  Future<ApiResult<void>> dropPassenger(
    String tripId,
    String passengerId,
    String otp,
  ) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/daily-trips/$tripId/passengers/$passengerId/drop',
        data: {'otp': otp},
      );
    }, url: '/api/daily-trips/$tripId/passengers/$passengerId/drop');
  }

  @override
  Future<ApiResult<void>> markNoShow(String tripId, String passengerId) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/daily-trips/$tripId/passengers/$passengerId/no-show',
      );
    }, url: '/api/daily-trips/$tripId/passengers/$passengerId/no-show');
  }

  @override
  Future<ApiResult<void>> completeDailyTrip(String tripId) {
    return executeRetrofitCall<void>(() async {
      await _dio.post('/api/daily-trips/$tripId/complete');
    }, url: '/api/daily-trips/$tripId/complete');
  }

  @override
  Future<ApiResult<List<Booking>>> getMyTripHistory({
    String? status,
    int page = 0,
  }) {
    return executeRetrofitCall<List<Booking>>(() async {
      final params = <String, dynamic>{'page': page, 'size': 20};
      if (status != null) params['status'] = status;
      final resp = await _dio.get('/api/bookings', queryParameters: params);
      final content = resp.data['data']['content'] as List;
      return content
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
    }, url: '/api/bookings');
  }

  @override
  Future<ApiResult<void>> startDailyTrip(String tripId) {
    return executeRetrofitCall<void>(() async {
      await _dio.post('/api/daily-trips/$tripId/start');
    }, url: '/api/daily-trips/$tripId/start');
  }

  @override
  Future<ApiResult<void>> cancelBooking(String bookingId) {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '/api/bookings/$bookingId/status',
        queryParameters: {'to': BookingStatus.cancelledByDriver.rawValue},
      );
    }, url: '/api/bookings/$bookingId/status');
  }

  @override
  Future<ApiResult<String>> getMyAvailability() {
    return executeRetrofitCall<String>(() async {
      final resp = await _dio.get('/api/drivers/me');
      return resp.data['data']['availability'] as String;
    }, url: '/api/drivers/me');
  }

  @override
  Future<ApiResult<String>> updateAvailability(String availability) {
    return executeRetrofitCall<String>(() async {
      final resp = await _dio.patch(
        '/api/drivers/me/availability',
        queryParameters: {'availability': availability},
      );
      return resp.data['data']['availability'] as String;
    }, url: '/api/drivers/me/availability');
  }
}
