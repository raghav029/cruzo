class ClientEndpoints {
  static const String base = '/api/corporate-clients';

  static String byId(String id) => '$base/$id';

  static String admins(String clientId) => '$base/$clientId/admins';
}
