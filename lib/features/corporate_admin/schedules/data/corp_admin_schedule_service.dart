import 'package:dio/dio.dart';

class CorpAdminScheduleService {
  CorpAdminScheduleService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyClient() async {
    final resp = await _dio.get('/api/corporate-clients/my');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listSchedules() async {
    final resp = await _dio.get('/api/daily-schedules', queryParameters: {'page': 0, 'size': 50});
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSchedule(Map<String, dynamic> body) async {
    final resp = await _dio.post('/api/daily-schedules', data: body);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listPassengers(String scheduleId) async {
    final resp = await _dio.get('/api/daily-schedules/$scheduleId/passengers');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> enrollPassenger(String scheduleId, {
    required String employeeEmail,
    required String pickupAddress,
  }) async {
    final resp = await _dio.post('/api/daily-schedules/$scheduleId/passengers', data: {
      'employeeEmail': employeeEmail,
      'pickupAddress': pickupAddress,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<void> removePassenger(String scheduleId, String passengerId) async {
    await _dio.delete('/api/daily-schedules/$scheduleId/passengers/$passengerId');
  }
}
