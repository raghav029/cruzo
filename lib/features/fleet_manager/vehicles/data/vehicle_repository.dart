import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_repo.dart';
import 'vehicle_endpoints.dart';

class VehicleRepoImpl implements VehicleRepo {
  final Dio _dio;
  const VehicleRepoImpl(this._dio);

  @override
  Future<ApiResult<List<Vehicle>>> list({
    String? status,
    int page = 0,
    int size = 50,
  }) async {
    return executeRetrofitCall<List<Vehicle>>(() async {
      final resp = await _dio.get(
        VehicleEndpoints.base,
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'size': size,
        },
      );
      final items = (resp.data['data']['content'] as List)
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    }, url: VehicleEndpoints.base);
  }

  @override
  Future<ApiResult<Vehicle>> create(Map<String, dynamic> body) async {
    return executeRetrofitCall<Vehicle>(() async {
      final resp = await _dio.post(VehicleEndpoints.base, data: body);
      return Vehicle.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: VehicleEndpoints.base);
  }

  @override
  Future<ApiResult<Vehicle>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    return executeRetrofitCall<Vehicle>(() async {
      final resp = await _dio.put(VehicleEndpoints.byId(id), data: body);
      return Vehicle.fromJson(resp.data['data'] as Map<String, dynamic>);
    }, url: VehicleEndpoints.byId(id));
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    return executeRetrofitCall<void>(() async {
      await _dio.delete(VehicleEndpoints.byId(id));
    }, url: VehicleEndpoints.byId(id));
  }
}
