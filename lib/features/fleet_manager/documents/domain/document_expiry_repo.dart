import '../../../../core/network/api_result.dart';
import 'document_expiry.dart';

abstract class DocumentExpiryRepo {
  Future<ApiResult<DocumentExpirySummary>> getExpiring();
}
