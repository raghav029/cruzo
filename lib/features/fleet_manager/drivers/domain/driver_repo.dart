import '../../../../core/network/api_result.dart';
import 'driver.dart';

abstract class DriverRepo {
  Future<ApiResult<List<Driver>>> list({int page = 0, int size = 50});

  Future<ApiResult<Driver>> create(Map<String, dynamic> body);

  Future<ApiResult<Driver>> update(String id, Map<String, dynamic> body);

  Future<ApiResult<void>> delete(String id);
}
