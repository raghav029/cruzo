import '../../../../core/network/api_result.dart';
import 'daily_schedule_models.dart';

abstract class DailyScheduleRepo {
  Future<ApiResult<List<DailySchedule>>> list({int page = 0, int size = 50});
  Future<ApiResult<List<DailySchedulePassenger>>> listPassengers(String scheduleId);
  Future<ApiResult<DailySchedulePassenger>> assignStopSequence(
      String scheduleId, String passengerId, int sequence);
  Future<ApiResult<List<DailyTrip>>> listTripsByDate(String date);
  Future<ApiResult<DailyTrip>> assignDriver(
      String tripId, String driverId, String vehicleId);
  Future<ApiResult<void>> cancelTrip(String tripId);
}
