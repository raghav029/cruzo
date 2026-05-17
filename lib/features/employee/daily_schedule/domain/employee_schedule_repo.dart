import '../../../../core/network/api_result.dart';
import 'employee_trip.dart';

abstract class EmployeeScheduleRepo {
  Future<ApiResult<EmployeeTrip?>> getTodayTrip();
  Future<ApiResult<List<EmployeeTrip>>> getMySchedule();
  Future<ApiResult<void>> skipDay(String passengerId, String date);
}
