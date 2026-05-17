import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/employee_trip.dart';
import '../domain/employee_schedule_repo.dart';

class EmployeeScheduleRepoImpl implements EmployeeScheduleRepo {
  final Dio _dio;
  const EmployeeScheduleRepoImpl(this._dio);

  static const _base = '/api/daily-trips';

  @override
  Future<ApiResult<EmployeeTrip?>> getTodayTrip() async {
    return executeRetrofitCall<EmployeeTrip?>(() async {
      final resp = await _dio.get('$_base/my-today');
      final data = resp.data['data'];
      if (data == null) return null;
      return EmployeeTrip.fromJson(data as Map<String, dynamic>);
    }, url: '$_base/my-today');
  }

  @override
  Future<ApiResult<List<EmployeeTrip>>> getMySchedule() async {
    return executeRetrofitCall<List<EmployeeTrip>>(() async {
      final today = DateTime.now();
      final future = today.add(const Duration(days: 30));
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final resp = await _dio.get('$_base/my-schedule',
          queryParameters: {'from': fmt(today), 'to': fmt(future)});
      final items = (resp.data['data'] as List? ?? [])
          .map((e) => EmployeeTrip.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    }, url: '$_base/my-schedule');
  }

  @override
  Future<ApiResult<void>> skipDay(String passengerId, String date) async {
    return executeRetrofitCall<void>(() async {
      await _dio.post(
        '$_base/enrollments/$passengerId/skip',
        data: {'skipDate': date},
      );
    }, url: '$_base/enrollments/$passengerId/skip');
  }
}
