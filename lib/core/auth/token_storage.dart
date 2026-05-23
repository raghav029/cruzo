import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';
  static const _nameKey = 'user_name';

  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<void> saveRefreshToken(String token) => _storage.write(key: _refreshKey, value: token);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<void> deleteRefreshToken() => _storage.delete(key: _refreshKey);

  Future<void> saveUserInfo({
    required String role,
    required String userId,
    required String name,
  }) async {
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _nameKey, value: name);
  }

  Future<String?> getRole() => _storage.read(key: _roleKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getName() => _storage.read(key: _nameKey);

  Future<void> clearAll() => _storage.deleteAll();
}
