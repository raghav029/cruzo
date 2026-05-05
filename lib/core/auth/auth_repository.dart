import 'package:dio/dio.dart';
import '../network/api_result.dart';
import 'token_storage.dart';
import 'bloc/auth_state.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _storage;

  const AuthRepository(this._dio, this._storage);

  Future<ApiResult<AuthAuthenticated>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'];
      final token = data['token'] as String;
      final role = roleFromString(data['role'] as String);
      final userId = data['userId'] as String;
      final name = (data['fullName'] ?? data['name'] ?? '') as String;

      await _storage.saveToken(token);
      await _storage.saveUserInfo(
        role: data['role'],
        userId: userId,
        name: name,
      );

      return Success(
        AuthAuthenticated(token: token, role: role, userId: userId, name: name),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Login failed. Please try again.';
      return Failure(message, statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResult<AuthAuthenticated>> restoreSession() async {
    try {
      final token = await _storage.getToken();
      final role = await _storage.getRole();
      final userId = await _storage.getUserId();
      final name = await _storage.getName();

      if (token == null || role == null || userId == null || name == null) {
        return const Failure('No session found');
      }

      return Success(
        AuthAuthenticated(
          token: token,
          role: roleFromString(role),
          userId: userId,
          name: name,
        ),
      );
    } catch (_) {
      return const Failure('Session restore failed');
    }
  }

  Future<void> logout() => _storage.clearAll();
}
