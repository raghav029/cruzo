import 'package:dio/dio.dart';

class CorpAdminEmployeeService {
  CorpAdminEmployeeService({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyClient() async {
    final resp = await _dio.get('/api/corporate-clients/my');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchEmployees(String clientId) async {
    final resp = await _dio.get(
      '/api/corporate-clients/$clientId/employees',
      queryParameters: {'page': 0, 'size': 50},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createEmployee(
    String clientId, {
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? department,
    String? designation,
  }) async {
    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      if (department != null) 'department': department,
      if (designation != null) 'designation': designation,
    };
    final resp = await _dio.post(
      '/api/corporate-clients/$clientId/employees',
      data: body,
    );
    return resp.data as Map<String, dynamic>;
  }
}
