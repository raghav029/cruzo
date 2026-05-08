import '../../../../core/network/api_result.dart';
import 'report_models.dart';

abstract class ReportRepo {
  Future<ApiResult<FleetSummary>> fleetSummary({
    String? fromDate,
    String? toDate,
  });

  Future<ApiResult<CorporateSpend>> corporateSpend({
    required String corporateClientId,
    String? fromDate,
    String? toDate,
  });
}
