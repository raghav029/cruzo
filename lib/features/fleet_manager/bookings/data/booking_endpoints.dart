class BookingEndpoints {
  static const String base = '/api/bookings';

  static String approve(String id) => '$base/$id/approve';

  static String reject(String id) => '$base/$id/reject';

  static String assignDriver(String id) => '$base/$id/assign-driver';

  static String autoAssign(String id) => '$base/$id/auto-assign';

  static String cancel(String id) => '$base/$id/cancel';
}
