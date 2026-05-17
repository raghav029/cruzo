import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../env.dart';
import '../auth/token_storage.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../di/injection.dart';

class DioClient {
  DioClient._();

  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(tokenStorage),
      PrettyDioLogger(requestBody: true, responseBody: false),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401) {
      if (getIt.isRegistered<AuthBloc>()) {
        getIt<AuthBloc>().add(const AuthLogoutRequested());
      }
    }
    handler.next(err);
  }
}
