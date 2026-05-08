import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/executor.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repo.dart';
import 'invoice_endpoints.dart';

class InvoiceRepoImpl implements InvoiceRepo {
  final Dio _dio;
  const InvoiceRepoImpl(this._dio);

  @override
  Future<ApiResult<List<Invoice>>> list({
    String? corporateClientId,
    int page = 0,
    int size = 50,
  }) =>
      executeRetrofitCall<List<Invoice>>(() async {
        final resp = await _dio.get(
          InvoiceEndpoints.base,
          queryParameters: {
            if (corporateClientId != null)
              'corporateClientId': corporateClientId,
            'page': page,
            'size': size,
          },
        );
        return (resp.data['data']['content'] as List)
            .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
            .toList();
      }, url: InvoiceEndpoints.base);

  @override
  Future<ApiResult<Invoice>> get(String invoiceId) =>
      executeRetrofitCall<Invoice>(() async {
        final resp = await _dio.get(InvoiceEndpoints.byId(invoiceId));
        return Invoice.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: InvoiceEndpoints.byId(invoiceId));

  @override
  Future<ApiResult<Invoice>> generate({
    required String corporateClientId,
    required String billingPeriodStart,
    required String billingPeriodEnd,
    String? dueDate,
    String? notes,
  }) =>
      executeRetrofitCall<Invoice>(() async {
        final resp = await _dio.post(
          InvoiceEndpoints.generate,
          data: {
            'corporateClientId': corporateClientId,
            'billingPeriodStart': billingPeriodStart,
            'billingPeriodEnd': billingPeriodEnd,
            if (dueDate != null) 'dueDate': dueDate,
            if (notes != null) 'notes': notes,
          },
        );
        return Invoice.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: InvoiceEndpoints.generate);

  @override
  Future<ApiResult<Invoice>> markSent(String invoiceId) =>
      executeRetrofitCall<Invoice>(() async {
        final resp = await _dio.post(InvoiceEndpoints.markSent(invoiceId));
        return Invoice.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: InvoiceEndpoints.markSent(invoiceId));

  @override
  Future<ApiResult<Invoice>> markPaid(String invoiceId,
          {String? paymentMode, String? paymentReference}) =>
      executeRetrofitCall<Invoice>(() async {
        final resp = await _dio.post(
          InvoiceEndpoints.markPaid(invoiceId),
          data: {
            if (paymentMode != null) 'paymentMode': paymentMode,
            if (paymentReference != null) 'paymentReference': paymentReference,
          },
        );
        return Invoice.fromJson(resp.data['data'] as Map<String, dynamic>);
      }, url: InvoiceEndpoints.markPaid(invoiceId));
}
