import '../services/corp_admin_profile_service.dart';

class CorpAdminProfileRepository {
  CorpAdminProfileRepository({required CorpAdminProfileService service})
      : _service = service;
  final CorpAdminProfileService _service;

  /// Returns combined map with keys: client (Map) and me (Map, nullable).
  Future<Map<String, dynamic>> fetchProfile() async {
    final clientResp = await _service.fetchMyClient();
    final client = clientResp['data'] is Map<String, dynamic>
        ? clientResp['data'] as Map<String, dynamic>
        : clientResp;

    Map<String, dynamic>? me;
    try {
      final meResp = await _service.fetchMe();
      me = meResp['data'] is Map<String, dynamic>
          ? meResp['data'] as Map<String, dynamic>
          : meResp;
    } catch (_) {
      // /api/employees/me may not be available for corp admin — ignore
    }

    return {'client': client, 'me': me};
  }
}
