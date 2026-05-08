class SosAlertEndpoints {
  static const String base = '/api/sos';
  static String byId(String id) => '$base/$id';
  static String resolve(String id) => '$base/$id/resolve';
}
