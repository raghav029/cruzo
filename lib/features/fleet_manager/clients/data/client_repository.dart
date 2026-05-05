import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/corporate_client.dart';
import '../domain/client_repo.dart';
import 'client_endpoints.dart';

class ClientRepoImpl implements ClientRepo {
  final Dio _dio;
  const ClientRepoImpl(this._dio);

  @override
  Future<ApiResult<List<CorporateClient>>> list({
    int page = 0,
    int size = 50,
  }) async {
    return executeRetrofitCall<List<CorporateClient>>(() async {
      final resp = await _dio.get(
        ClientEndpoints.base,
        queryParameters: {'page': page, 'size': size},
      );
      final items = (resp.data['data']['content'] as List)
          .map((e) => CorporateClient.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    }, url: ClientEndpoints.base);
  }

  @override
  Future<ApiResult<CorporateClient>> create(Map<String, dynamic> body) async {
    return executeRetrofitCall<CorporateClient>(() async {
      final resp = await _dio.post(ClientEndpoints.base, data: body);
      return CorporateClient.fromJson(
        resp.data['data'] as Map<String, dynamic>,
      );
    }, url: ClientEndpoints.base);
  }

  @override
  Future<ApiResult<CorporateClient>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    return executeRetrofitCall<CorporateClient>(() async {
      final resp = await _dio.put(ClientEndpoints.byId(id), data: body);
      return CorporateClient.fromJson(
        resp.data['data'] as Map<String, dynamic>,
      );
    }, url: ClientEndpoints.byId(id));
  }

  @override
  Future<ApiResult<void>> delete(String id) async {
    return executeRetrofitCall<void>(() async {
      await _dio.delete(ClientEndpoints.byId(id));
    }, url: ClientEndpoints.byId(id));
  }

  @override
  Future<ApiResult<void>> createAdmin(
    String clientId,
    Map<String, dynamic> body,
  ) async {
    return executeRetrofitCall<void>(() async {
      await _dio.post(ClientEndpoints.admins(clientId), data: body);
    }, url: ClientEndpoints.admins(clientId));
  }
}
