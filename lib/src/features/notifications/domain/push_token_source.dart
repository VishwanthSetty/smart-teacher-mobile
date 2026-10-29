import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where a push token comes from, as a port this app owns.
///
/// The mirror of the backend's own arrangement: `PushService` there is an
/// **Adapter** over FCM/APNs with a `PUSH_PROVIDER=none` no-op that dev and e2e
/// run against. This is the client half of the same idea, and for the same
/// reason — the registration flow, the logout de-registration and every test
/// around them are written once, against an interface, and stay true whichever
/// provider is eventually wired in.
///
/// **No FCM SDK is wired up in this build.** Doing so needs a Firebase project
/// and the native config files that come with it (`google-services.json`,
/// `GoogleService-Info.plist`), neither of which is in this repo — and mobile
/// plan §8.4 lists the push provider as a decision still to be confirmed. So the
/// default implementation is [NoopPushTokenSource], which answers `null`: the
/// app registers no device, `POST /me/devices` is never called, and **the in-app
/// inbox works exactly as it does with push enabled**. That is the behaviour
/// §5.10 asks for when push permission is denied, so the degraded path is the
/// one that is already built and tested.
///
/// Wiring FCM later is one override of [pushTokenSourceProvider] plus the native
/// config; nothing above this line changes.
abstract interface class PushTokenSource {
  /// This platform as `POST /me/devices` spells it: `ios` or `android`.
  ///
  /// The DTO is `@IsIn(['ios', 'android'])`, so anything else is a `400` — see
  /// [currentPushPlatform], which answers `null` rather than guessing.
  String? get platform;

  /// The current token, or `null` when there is none to register — no provider
  /// configured, permission denied, or the token not yet issued.
  Future<String?> currentToken();

  /// Fires whenever the provider re-mints the token, so the new one can be
  /// registered. A source with no provider behind it never emits.
  Stream<String> get tokenRefreshes;
}

/// The default: no push provider, and therefore no device to register.
class NoopPushTokenSource implements PushTokenSource {
  const NoopPushTokenSource();

  @override
  String? get platform => currentPushPlatform;

  @override
  Future<String?> currentToken() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream<String>.empty();
}

/// `ios` / `android`, or `null` on a platform the API does not accept.
///
/// Null rather than a fallback: the DTO rejects anything outside that pair, so
/// registering a desktop build as `'android'` would be a lie that earns a `400`
/// — and this app runs under `flutter test` and on Windows during development.
String? get currentPushPlatform {
  if (kIsWeb) {
    return null;
  }
  if (Platform.isIOS) {
    return 'ios';
  }
  if (Platform.isAndroid) {
    return 'android';
  }
  return null;
}

final Provider<PushTokenSource> pushTokenSourceProvider =
    Provider<PushTokenSource>((Ref ref) => const NoopPushTokenSource());
