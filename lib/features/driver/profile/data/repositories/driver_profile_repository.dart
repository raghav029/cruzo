import '../services/driver_profile_service.dart';

class DriverProfileRepository {
  DriverProfileRepository({required DriverProfileService service}) : _service = service;
  final DriverProfileService _service;

  Future<Map<String, dynamic>> fetchProfile() => _service.fetchProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) => _service.updateProfile(data);
}
