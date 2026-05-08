abstract final class DailyScheduleEndpoints {
  static const list = '/api/daily-schedules';
  static String passengers(String id) => '/api/daily-schedules/$id/passengers';
  static String assignSequence(String id, String pid) =>
      '/api/daily-schedules/$id/passengers/$pid/sequence';
  static const trips = '/api/daily-trips';
  static String assignDriver(String id) => '/api/daily-trips/$id/assign-driver';
  static String cancelTrip(String id) => '/api/daily-trips/$id/cancel';
}
