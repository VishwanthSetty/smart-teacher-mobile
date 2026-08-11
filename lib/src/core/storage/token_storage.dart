import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The token-persistence contract consumers (the Dio auth interceptor,
/// eventually the auth feature's repository and the router's session gate)
/// depend on. [SecureTokenStorage] is the only production implementation;
/// tests provide a fake in-memory one instead of driving the real platform
/// channel.
abstract class TokenStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearTokens();

  /// Whether a session is worth attempting at all — presence of a refresh
  /// token, nothing more. Expiry is deliberately *not* checked here: the
  /// server is the only authority on that (PRD §6.2 — a rejected token comes
  /// back as a `401` and the interceptor refreshes or forces logout). Local
  /// expiry inspection would mean decoding the JWT and trusting a device
  /// clock, both of which can disagree with the API.
  Future<bool> hasValidSession();
}

/// Thin wrapper around [FlutterSecureStorage] (Keychain on iOS, Keystore on
/// Android) scoped to exactly the values the auth flow needs. Access/refresh
/// tokens must never be held anywhere else — no `SharedPreferences`, no
/// plaintext file, never logged or attached to crash/analytics breadcrumbs
/// (PRD §6.1).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  /// Clears both tokens. Called on logout and on unrecoverable refresh
  /// failure — must complete even if the app is offline.
  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<bool> hasValidSession() async {
    final String? refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }
}

/// Exposed as the [TokenStorage] interface, not the concrete class, so tests
/// and future features override this provider with a fake rather than
/// touching the platform channel.
final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (Ref ref) => SecureTokenStorage(const FlutterSecureStorage()),
);
