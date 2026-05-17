import 'package:dio/dio.dart';

class DriverStatsService {
  DriverStatsService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchStats() async {
    final resp = await _dio.get('/api/drivers/me/stats');
    return resp.data['data'] as Map<String, dynamic>;
  }
}
