import '../services/employee_profile_service.dart';

class EmployeeProfileRepository {
  EmployeeProfileRepository({required EmployeeProfileService service}) : _service = service;
  final EmployeeProfileService _service;

  Future<Map<String, dynamic>> fetchProfile() => _service.fetchProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) => _service.updateProfile(data);
}
