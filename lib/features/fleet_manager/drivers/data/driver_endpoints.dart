class DriverEndpoints {
  static const String base = '/api/drivers';

  static String byId(String id) => '$base/$id';
}
