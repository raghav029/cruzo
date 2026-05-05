class VehicleEndpoints {
  static const String base = '/api/vehicles';

  static String byId(String id) => '$base/$id';
}
