import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/document_expiry.dart';
import '../domain/document_expiry_repo.dart';
import 'document_expiry_endpoints.dart';

class DocumentExpiryRepoImpl implements DocumentExpiryRepo {
  final Dio _dio;
  const DocumentExpiryRepoImpl(this._dio);

  @override
  Future<ApiResult<DocumentExpirySummary>> getExpiring() =>
      executeRetrofitCall<DocumentExpirySummary>(() async {
        final resp = await _dio.get(DocumentExpiryEndpoints.expiring);
        return DocumentExpirySummary.fromJson(
          resp.data['data'] as Map<String, dynamic>,
        );
      }, url: DocumentExpiryEndpoints.expiring);
}
