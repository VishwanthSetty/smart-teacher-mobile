import 'dart:async';

import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';

/// In-memory [TokenStorage] for tests — keeps the real secure-storage
/// platform channel (which has no implementation under `flutter test`) out of
/// the picture. Override `tokenStorageProvider` with one of these.
class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage({
    String? accessToken,
    String? refreshToken,
    this.restoreGate,
    this.failReads = false,
  })  : _accessToken = accessToken,
        _refreshToken = refreshToken;

  /// When set, [hasValidSession] waits on it — lets a test hold the app in
  /// [SessionStatus.unknown] and observe the splash screen.
  final Completer<void>? restoreGate;

  /// Simulates an unreadable keystore — every read throws, [clearTokens]
  /// still works (deleting a key that can't be read is fine).
  final bool failReads;

  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    if (failReads) {
      throw StateError('keystore unavailable');
    }
    return _accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    if (failReads) {
      throw StateError('keystore unavailable');
    }
    return _refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<bool> hasValidSession() async {
    if (restoreGate != null) {
      await restoreGate!.future;
    }
    if (failReads) {
      throw StateError('keystore unavailable');
    }
    return _refreshToken != null && _refreshToken!.isNotEmpty;
  }
}
