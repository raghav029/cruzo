import 'package:cruzo/core/network/result.dart';
import 'package:cruzo/features/fleet_manager/daily_schedules/domain/daily_schedule_models.dart';
import 'corp_admin_schedule_service.dart';

class CorpAdminScheduleRepository {
  CorpAdminScheduleRepository({required CorpAdminScheduleService service}) : _service = service;
  final CorpAdminScheduleService _service;

  Future<Result<String>> fetchMyClientId() async {
    try {
      final data = await _service.fetchMyClient();
      return Success(data['data']['id'] as String);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<DailySchedule>>> listSchedules() async {
    try {
      final data = await _service.listSchedules();
      final content = (data['data']['content'] as List? ?? data['data'] as List? ?? []);
      final list = content
          .map((e) => DailySchedule.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<DailySchedule>> createSchedule(Map<String, dynamic> body) async {
    try {
      final data = await _service.createSchedule(body);
      return Success(DailySchedule.fromJson(data['data'] as Map<String, dynamic>));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<List<DailySchedulePassenger>>> listPassengers(String scheduleId) async {
    try {
      final data = await _service.listPassengers(scheduleId);
      final list = (data['data'] as List)
          .map((e) => DailySchedulePassenger.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<DailySchedulePassenger>> enrollPassenger(
    String scheduleId, {
    required String employeeEmail,
    required String pickupAddress,
  }) async {
    try {
      final data = await _service.enrollPassenger(
        scheduleId,
        employeeEmail: employeeEmail,
        pickupAddress: pickupAddress,
      );
      return Success(DailySchedulePassenger.fromJson(data['data'] as Map<String, dynamic>));
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<void>> removePassenger(String scheduleId, String passengerId) async {
    try {
      await _service.removePassenger(scheduleId, passengerId);
      return const Success(null);
    } on Exception catch (e) {
      return Failure(e.toString());
    }
  }
}
