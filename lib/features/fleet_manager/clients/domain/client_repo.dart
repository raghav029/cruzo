import '../../../../core/network/api_result.dart';
import 'corporate_client.dart';

abstract class ClientRepo {
  Future<ApiResult<List<CorporateClient>>> list({int page = 0, int size = 50});

  Future<ApiResult<CorporateClient>> create(Map<String, dynamic> body);

  Future<ApiResult<CorporateClient>> update(
    String id,
    Map<String, dynamic> body,
  );

  Future<ApiResult<void>> delete(String id);

  Future<ApiResult<void>> createAdmin(
    String clientId,
    Map<String, dynamic> body,
  );
}
