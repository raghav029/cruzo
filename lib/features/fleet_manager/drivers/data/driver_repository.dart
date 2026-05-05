import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/driver.dart';
import '../domain/driver_repo.dart';
import 'driver_endpoints.dart';

class DriverRepoImpl implements DriverRepo {
  final Dio _dio;
  const DriverRepoImpl(this._dio);

  @override
  Future<ApiResult<List<Driver>>> list({int page = 0, int size = 50}) async {
    return executeRetrofitCall<List<Driver>>(() async {
      final resp = await _dio.get(
        DriverEndpoints.base,
        queryParameters: {'page': page, 'size': size},
      );
      final items = (resp.data['data']['content'] as List)
          .map((e) => Driver.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    }, url: DriverEndpoints.base);
  }

  @override
  Future<ApiResult<Driver>> create(Map<String, dynamic> body) async {
    return executeRetrofitCall<Driver>(() async {
      final resp = await _dio.post(DriverEndpoints.base, data: body);
      return Driver.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: DriverEndpoints.base);
  }

  @override
  Future<ApiResult<Driver>> update(String id, Map<String, dynamic> body) async {
    return executeRetrofitCall<Driver>(() async {
      final resp = await _dio.put(DriverEndpoints.byId(id), data: body);
      return Driver.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: DriverEndpoints.byId(id));
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    return executeRetrofitCall<void>(() async {
      await _dio.delete(DriverEndpoints.byId(id));
    }, url: DriverEndpoints.byId(id));
  }
}
