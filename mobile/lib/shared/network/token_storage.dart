import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

final class SecureTokenStorage implements TokenStorage {
  static const _tokenKey = 'themis.auth_token';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
