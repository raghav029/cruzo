import '../../../../core/network/api_result.dart';
import 'employee_trip.dart';

abstract class EmployeeScheduleRepo {
  Future<ApiResult<EmployeeTrip?>> getTodayTrip();
  Future<ApiResult<List<EmployeeTrip>>> getMySchedule();
  Future<ApiResult<List<EmployeeTrip>>> getScheduleForMonth(
      DateTime from, DateTime to);
  Future<ApiResult<List<String>>> getSkipDates(String passengerId);
  Future<ApiResult<void>> skipDay(String passengerId, String date);
  Future<ApiResult<void>> undoSkip(String passengerId, String date);
}
