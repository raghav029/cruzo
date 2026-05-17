import 'package:dio/dio.dart';
import '../../../../../core/network/result.dart';
import '../../domain/corp_employee.dart';
import '../services/corp_admin_employee_service.dart';

class CorpAdminEmployeeRepository {
  CorpAdminEmployeeRepository({required CorpAdminEmployeeService service})
      : _service = service;
  final CorpAdminEmployeeService _service;

  Future<String?> getMyClientId() async {
    try {
      final resp = await _service.fetchMyClient();
      final client = resp['data'] as Map<String, dynamic>;
      return client['id']?.toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Result<List<CorpEmployee>>> listEmployees(String clientId) async {
    try {
      final resp = await _service.fetchEmployees(clientId);
      final page = resp['data'] as Map<String, dynamic>;
      final content = page['content'] as List<dynamic>? ?? [];
      return Success(content
          .map((e) => CorpEmployee.fromJson(e as Map<String, dynamic>))
          .toList());
    } on DioException catch (e) {
      final msg = (e.response?.data is Map ? e.response?.data['message'] : null)
          ?? e.message
          ?? 'Failed to load employees';
      return Failure(msg, statusCode: e.response?.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<Result<CorpEmployee>> addEmployee(
    String clientId, {
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? department,
    String? designation,
  }) async {
    try {
      final data = await _service.createEmployee(
        clientId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        department: department,
        designation: designation,
      );
      final employeeData = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      return Success(CorpEmployee.fromJson(employeeData));
    } on DioException catch (e) {
      final msg = (e.response?.data is Map ? e.response?.data['message'] : null)
          ?? e.message
          ?? 'Failed to create employee';
      return Failure(msg, statusCode: e.response?.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
