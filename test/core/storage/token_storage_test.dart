import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';

void main() {
  late _FakeFlutterSecureStorage backing;
  late SecureTokenStorage storage;

  setUp(() {
    backing = _FakeFlutterSecureStorage();
    storage = SecureTokenStorage(backing);
  });

  test('saveTokens writes both tokens and reads them back', () async {
    await storage.saveTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    expect(await storage.getAccessToken(), 'access-1');
    expect(await storage.getRefreshToken(), 'refresh-1');
  });

  test('saveTokens overwrites a previously stored pair', () async {
    await storage.saveTokens(accessToken: 'old-a', refreshToken: 'old-r');
    await storage.saveTokens(accessToken: 'new-a', refreshToken: 'new-r');

    expect(await storage.getAccessToken(), 'new-a');
    expect(await storage.getRefreshToken(), 'new-r');
  });

  test('getters return null when nothing has been stored', () async {
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
  });

  test('clearTokens removes both tokens', () async {
    await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');

    await storage.clearTokens();

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(backing.values, isEmpty);
  });

  test('hasValidSession is false with no stored session', () async {
    expect(await storage.hasValidSession(), isFalse);
  });

  test('hasValidSession is true once a refresh token is stored', () async {
    await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');

    expect(await storage.hasValidSession(), isTrue);
  });

  test('hasValidSession keys off the refresh token, not the access token',
      () async {
    // An expired/absent access token is normal — the interceptor refreshes.
    // Only the refresh token decides whether a session is worth resuming.
    await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');
    await backing.delete(key: 'access_token');

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.hasValidSession(), isTrue);
  });

  test('hasValidSession is false for an empty refresh token', () async {
    await storage.saveTokens(accessToken: 'access', refreshToken: '');

    expect(await storage.hasValidSession(), isFalse);
  });

  test('hasValidSession is false after clearTokens', () async {
    await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');

    await storage.clearTokens();

    expect(await storage.hasValidSession(), isFalse);
  });
}

/// In-memory stand-in for the real [FlutterSecureStorage] platform channel,
/// which has no implementation under `flutter test`. Only the four members
/// [SecureTokenStorage] actually calls are meaningful.
class _FakeFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
      return;
    }
    values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return values[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
