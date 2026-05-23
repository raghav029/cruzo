import 'package:dio/dio.dart';

class CorpAdminProfileService {
  CorpAdminProfileService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyClient() async {
    final resp = await _dio.get('/api/corporate-clients/my');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchMe() async {
    final resp = await _dio.get('/api/employees/me');
    return resp.data as Map<String, dynamic>;
  }
}
