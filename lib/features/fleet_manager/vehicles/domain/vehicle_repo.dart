import '../../../../core/network/api_result.dart';
import 'vehicle.dart';

abstract class VehicleRepo {
  Future<ApiResult<List<Vehicle>>> list({
    String? status,
    int page = 0,
    int size = 50,
  });

  Future<ApiResult<Vehicle>> create(Map<String, dynamic> body);

  Future<ApiResult<Vehicle>> update(String id, Map<String, dynamic> body);

  Future<ApiResult<void>> delete(String id);
}
