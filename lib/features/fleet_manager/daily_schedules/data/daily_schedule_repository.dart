import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/daily_schedule_models.dart';
import '../domain/daily_schedule_repo.dart';
import 'daily_schedule_endpoints.dart';

class DailyScheduleRepoImpl implements DailyScheduleRepo {
  final Dio _dio;
  const DailyScheduleRepoImpl(this._dio);

  @override
  Future<ApiResult<List<DailySchedule>>> list({int page = 0, int size = 50}) =>
      executeRetrofitCall<List<DailySchedule>>(() async {
        final resp = await _dio.get(
          DailyScheduleEndpoints.list,
          queryParameters: {'page': page, 'size': size},
        );
        final content = resp.data['data']['content'] as List<dynamic>;
        return content
            .map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
            .toList();
      }, url: DailyScheduleEndpoints.list);

  @override
  Future<ApiResult<List<DailySchedulePassenger>>> listPassengers(
          String scheduleId) =>
      executeRetrofitCall<List<DailySchedulePassenger>>(() async {
        final resp =
            await _dio.get(DailyScheduleEndpoints.passengers(scheduleId));
        final data = resp.data['data'] as List<dynamic>;
        return data
            .map((e) =>
                DailySchedulePassenger.fromJson(e as Map<String, dynamic>))
            .toList();
      }, url: DailyScheduleEndpoints.passengers(scheduleId));

  @override
  Future<ApiResult<DailySchedulePassenger>> assignStopSequence(
          String scheduleId, String passengerId, int sequence) =>
      executeRetrofitCall<DailySchedulePassenger>(() async {
        final resp = await _dio.put(
          DailyScheduleEndpoints.assignSequence(scheduleId, passengerId),
          data: {'stopSequence': sequence},
        );
        return DailySchedulePassenger.fromJson(
            resp.data['data'] as Map<String, dynamic>);
      }, url: DailyScheduleEndpoints.assignSequence(scheduleId, passengerId));

  @override
  Future<ApiResult<List<DailyTrip>>> listTripsByDate(String date) =>
      executeRetrofitCall<List<DailyTrip>>(() async {
        final resp = await _dio.get(
          DailyScheduleEndpoints.trips,
          queryParameters: {'date': date},
        );
        final data = resp.data['data'] as List<dynamic>;
        return data
            .map((e) => DailyTrip.fromJson(e as Map<String, dynamic>))
            .toList();
      }, url: DailyScheduleEndpoints.trips);

  @override
  Future<ApiResult<DailyTrip>> assignDriver(
          String tripId, String driverId, String vehicleId) =>
      executeRetrofitCall<DailyTrip>(() async {
        final resp = await _dio.post(
          DailyScheduleEndpoints.assignDriver(tripId),
          data: {'driverId': driverId, 'vehicleId': vehicleId},
        );
        return DailyTrip.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: DailyScheduleEndpoints.assignDriver(tripId));

  @override
  Future<ApiResult<void>> cancelTrip(String tripId) =>
      executeRetrofitCall<void>(() async {
        await _dio.post(DailyScheduleEndpoints.cancelTrip(tripId));
      }, url: DailyScheduleEndpoints.cancelTrip(tripId));
}
