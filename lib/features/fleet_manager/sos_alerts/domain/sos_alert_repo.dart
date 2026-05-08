import '../../../../core/network/api_result.dart';
import 'sos_alert.dart';

abstract class SosAlertRepo {
  Future<ApiResult<List<SosAlert>>> list({String? status, int page = 0, int size = 50});
  Future<ApiResult<SosAlert>> resolve(String id, {String? notes});
}
