import 'package:dio/dio.dart';
import '../models/error_info.dart';

ErrorInfo mapDioExceptionToErrorInfo(DioException e) {
  final status = e.response?.statusCode;
  final message = e.response?.data is Map ? (e.response?.data['detail'] ?? e.response?.data['message'] ?? e.message) : (e.message ?? 'Request failed');
  final type = (status != null && status >= 500) ? ErrorInfoType.serverError : ErrorInfoType.clientError;
  return ErrorInfo(message: message.toString(), code: status, type: type);
}
