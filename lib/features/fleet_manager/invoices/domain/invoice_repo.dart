import '../../../../core/network/api_result.dart';
import 'invoice.dart';

abstract class InvoiceRepo {
  Future<ApiResult<List<Invoice>>> list({
    String? corporateClientId,
    int page = 0,
    int size = 50,
  });

  Future<ApiResult<Invoice>> get(String invoiceId);

  Future<ApiResult<Invoice>> generate({
    required String corporateClientId,
    required String billingPeriodStart,
    required String billingPeriodEnd,
    String? dueDate,
    String? notes,
  });

  Future<ApiResult<Invoice>> markSent(String invoiceId);

  Future<ApiResult<Invoice>> markPaid(String invoiceId,
      {String? paymentMode, String? paymentReference});
}
