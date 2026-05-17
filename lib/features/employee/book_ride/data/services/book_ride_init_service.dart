import 'package:dio/dio.dart';

class BookRideInitService {
  BookRideInitService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchEmployeeInfo() async {
    final resp = await _dio.get('/api/employees/me');
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> fetchPolicy() async {
    try {
      final resp = await _dio.get('/api/employees/me/policy');
      return resp.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
