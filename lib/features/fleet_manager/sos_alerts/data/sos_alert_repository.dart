import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/sos_alert.dart';
import '../domain/sos_alert_repo.dart';
import 'sos_alert_endpoints.dart';

class SosAlertRepoImpl implements SosAlertRepo {
  final Dio _dio;
  const SosAlertRepoImpl(this._dio);

  @override
  Future<ApiResult<List<SosAlert>>> list({
    String? status,
    int page = 0,
    int size = 50,
  }) =>
      executeRetrofitCall<List<SosAlert>>(() async {
        final resp = await _dio.get(
          SosAlertEndpoints.base,
          queryParameters: {
            if (status != null) 'status': status,
            'page': page,
            'size': size,
          },
        );
        return (resp.data['data']['content'] as List)
            .map((e) => SosAlert.fromJson(e as Map<String, dynamic>))
            .toList();
      }, url: SosAlertEndpoints.base);

  @override
  Future<ApiResult<SosAlert>> resolve(String id, {String? notes}) =>
      executeRetrofitCall<SosAlert>(() async {
        final resp = await _dio.post(
          SosAlertEndpoints.resolve(id),
          data: {if (notes != null && notes.isNotEmpty) 'notes': notes},
        );
        return SosAlert.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: SosAlertEndpoints.resolve(id));
}
