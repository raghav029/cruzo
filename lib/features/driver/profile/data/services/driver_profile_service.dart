import 'package:dio/dio.dart';

class DriverProfileService {
  DriverProfileService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchProfile() async {
    final resp = await _dio.get('/api/drivers/me');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final resp = await _dio.patch('/api/drivers/me', data: data);
    return resp.data['data'] as Map<String, dynamic>;
  }
}
