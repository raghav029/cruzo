import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/booking.dart';
import '../domain/booking_repo.dart';
import 'booking_endpoints.dart';

class BookingRepoImpl implements BookingRepo {
  final Dio _dio;
  const BookingRepoImpl(this._dio);

  @override
  Future<ApiResult<List<Booking>>> list({
    String? status,
    String? fromDate,
    String? toDate,
    int page = 0,
    int size = 100,
  }) async {
    return executeRetrofitCall<List<Booking>>(() async {
      final resp = await _dio.get(
        BookingEndpoints.base,
        queryParameters: {
          if (status != null) 'status': status,
          if (fromDate != null) 'fromDate': fromDate,
          if (toDate != null) 'toDate': toDate,
          'page': page,
          'size': size,
        },
      );
      final items = (resp.data['data']['content'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    }, url: BookingEndpoints.base);
  }

  @override
  Future<ApiResult<Booking>> approve(String id) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(BookingEndpoints.approve(id));
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.approve(id));
  }

  @override
  Future<ApiResult<Booking>> reject(String id, {String? reason}) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(
        BookingEndpoints.reject(id),
        data: reason != null ? {'reason': reason} : {},
      );
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.reject(id));
  }

  @override
  Future<ApiResult<Booking>> assignDriver(
    String id,
    String driverId,
    String vehicleId,
  ) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(
        BookingEndpoints.assignDriver(id),
        data: {'driverId': driverId, 'vehicleId': vehicleId},
      );
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.assignDriver(id));
  }

  @override
  Future<ApiResult<Booking>> autoAssign(String id) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(BookingEndpoints.autoAssign(id));
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.autoAssign(id));
  }

  @override
  Future<ApiResult<Booking>> cancel(String id, {String? reason}) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(
        BookingEndpoints.cancel(id),
        data: reason != null ? {'reason': reason} : {},
      );
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.cancel(id));
  }

  @override
  Future<ApiResult<List<Booking>>> myActive() async {
    return executeRetrofitCall<List<Booking>>(() async {
      final resp = await _dio.get(BookingEndpoints.myActive);
      final items = (resp.data['data'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    }, url: BookingEndpoints.myActive);
  }

  @override
  Future<ApiResult<Booking>> refreshBoardingOtp(String id) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(BookingEndpoints.refreshBoardingOtp(id));
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.refreshBoardingOtp(id));
  }

  @override
  Future<ApiResult<Booking>> getById(String id) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.get(BookingEndpoints.byId(id));
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.byId(id));
  }

  @override
  Future<ApiResult<Booking>> create({
    required String corporateClientId,
    required String pickupAddress,
    required String dropAddress,
    required String vehicleType,
    required String scheduledAt,
    String? notes,
  }) async {
    return executeRetrofitCall<Booking>(() async {
      final resp = await _dio.post(
        BookingEndpoints.base,
        data: {
          'corporateClientId': corporateClientId,
          'pickupAddress': pickupAddress,
          'dropAddress': dropAddress,
          'vehicleTypeRequested': vehicleType,
          'scheduledAt': scheduledAt,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      return Booking.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: BookingEndpoints.base);
  }
}
