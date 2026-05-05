import '../../../../core/network/api_result.dart';
import 'dashboard_summary.dart';

abstract class DashboardRepo {
  Future<ApiResult<DashboardSummary>> getSummary();
}
