import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/report_models.dart';
import '../domain/report_repo.dart';
import 'report_endpoints.dart';

class ReportRepoImpl implements ReportRepo {
  final Dio _dio;
  const ReportRepoImpl(this._dio);

  @override
  Future<ApiResult<FleetSummary>> fleetSummary({
    String? fromDate,
    String? toDate,
  }) =>
      executeRetrofitCall<FleetSummary>(() async {
        final resp = await _dio.get(
          ReportEndpoints.fleetSummary,
          queryParameters: {
            if (fromDate != null) 'fromDate': fromDate,
            if (toDate != null) 'toDate': toDate,
          },
        );
        return FleetSummary.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: ReportEndpoints.fleetSummary);

  @override
  Future<ApiResult<CorporateSpend>> corporateSpend({
    required String corporateClientId,
    String? fromDate,
    String? toDate,
  }) =>
      executeRetrofitCall<CorporateSpend>(() async {
        final resp = await _dio.get(
          ReportEndpoints.corporateSpend,
          queryParameters: {
            'corporateClientId': corporateClientId,
            if (fromDate != null) 'fromDate': fromDate,
            if (toDate != null) 'toDate': toDate,
          },
        );
        return CorporateSpend.fromJson(
          resp.data['data'] as Map<String, dynamic>,
        );
      }, url: ReportEndpoints.corporateSpend);
}
