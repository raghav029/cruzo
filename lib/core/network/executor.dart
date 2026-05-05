import 'package:dio/dio.dart';
import 'models/api_response.dart';
import 'models/error_info.dart';
import 'result.dart';
import 'interceptors/api_error_logging_interceptor.dart';
import 'utils/dio_error_mapper.dart';

/// Executes a Retrofit-style call (returns raw data) and maps errors to [Result].
Future<Result<T>> executeRetrofitCall<T>(
  Future<T> Function() retrofitCall, {
  String? url,
}) async {
  try {
    final data = await retrofitCall();
    return Success(data);
  } on DioException catch (e) {
    final errorInfo = mapDioExceptionToErrorInfo(e);
    if (errorInfo.type == ErrorInfoType.clientError && url != null) {
      ApiErrorLoggingInterceptor.logApiClientSideError(url, errorInfo.message);
    }
    return Failure(errorInfo.message, statusCode: errorInfo.code);
  } catch (e) {
    if (url != null) ApiErrorLoggingInterceptor.logApiParsingFailure(url, e.toString());
    return Failure(e.toString());
  }
}

/// Executes an `APIResponse<T>`-returning call (processRequest style) and maps the
/// result to [Result]. This is useful when service layers return `APIResponse`.
Future<Result<T>> executeProcessRequest<T>(
  Future<APIResponse<T>> Function() processRequestCall, {
  String? url,
}) async {
  try {
    final response = await processRequestCall();
    if (response.hasError) {
      return Failure(response.error!.message, statusCode: response.error!.code);
    }

    if (response.data != null) return Success(response.data as T);
    if (response.dataList != null && response.dataList!.isNotEmpty) {
      return Success(response.dataList!.first);
    }

    return const Failure('No data');
  } on DioException catch (e) {
    final errorInfo = mapDioExceptionToErrorInfo(e);
    if (errorInfo.type == ErrorInfoType.clientError && url != null) {
      ApiErrorLoggingInterceptor.logApiClientSideError(url, errorInfo.message);
    }
    return Failure(errorInfo.message, statusCode: errorInfo.code);
  } catch (e) {
    if (url != null) ApiErrorLoggingInterceptor.logApiParsingFailure(url, e.toString());
    return Failure(e.toString());
  }
}
