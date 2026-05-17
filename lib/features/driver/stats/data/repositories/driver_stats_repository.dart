import '../services/driver_stats_service.dart';

class DriverStatsRepository {
  DriverStatsRepository({required DriverStatsService service}) : _service = service;
  final DriverStatsService _service;

  Future<Map<String, dynamic>> fetchStats() => _service.fetchStats();
}
