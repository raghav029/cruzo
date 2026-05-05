import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import 'dashboard_endpoints.dart';
import '../domain/dashboard_summary.dart';
import '../domain/dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  final Dio _dio;
  const DashboardRepoImpl(this._dio);

  @override
  Future<ApiResult<DashboardSummary>> getSummary() async {
    return executeRetrofitCall<DashboardSummary>(() async {
      final response = await _dio.get(DashboardEndpoints.summary);
      return DashboardSummary.fromJson(response.data['data']);
    }, url: DashboardEndpoints.summary);
  }
}
