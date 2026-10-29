import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/core/session/session_controller.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/data/auth_repository.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/logout_controller.dart';
import 'package:smart_teacher_mobile/src/features/notifications/domain/push_token_source.dart';
import 'package:smart_teacher_mobile/src/features/notifications/presentation/push_registration_controller.dart';

import '../../support/activity_overrides.dart';
import '../../support/fake_auth_repository.dart';
import '../../support/fake_notification_repository.dart';
import '../../support/fake_token_storage.dart';

void main() {
  group('push registration (mobile plan §5.10)', () {
    test('registers the token this device holds', () async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final ProviderContainer container = _container(
        repository,
        source: FakePushTokenSource(platform: 'android', token: 'token-abc'),
      );

      await container.read(pushRegistrationControllerProvider).register();

      expect(repository.registered, hasLength(1));
      expect(repository.registered.single.platform, 'android');
      expect(repository.registered.single.token, 'token-abc');
    });

    test('registers nothing when no provider is configured', () async {
      // The production default. §5.10's "if push permission is denied, the
      // in-app inbox still works" is the same path, so the degraded case is the
      // one that is built and tested.
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final ProviderContainer container = _container(repository);

      await container.read(pushRegistrationControllerProvider).register();

      expect(repository.registered, isEmpty);
    });

    test('registers nothing on a platform the API will not accept', () async {
      // The DTO is `@IsIn(['ios', 'android'])`, so registering a desktop build
      // as 'android' would be a lie that earns a `400`.
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final ProviderContainer container = _container(
        repository,
        source: FakePushTokenSource(platform: null),
      );

      await container.read(pushRegistrationControllerProvider).register();

      expect(repository.registered, isEmpty);
    });

    test('a failed registration does not throw at its caller', () async {
      // It sits behind sign-in. Push is best-effort and every alert is written
      // in-app first, so nothing about signing in should be able to fail here.
      final ProviderContainer container = _container(
        FakeNotificationRepository(
          error: const NetworkError(message: 'offline'),
        ),
        source: FakePushTokenSource(),
      );

      await expectLater(
        container.read(pushRegistrationControllerProvider).register(),
        completes,
      );
      expect(container.read(pushRegistrationControllerProvider).deviceId, isNull);
    });

    test('a re-minted token is registered again', () async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final FakePushTokenSource source = FakePushTokenSource();
      addTearDown(source.refreshController.close);
      final ProviderContainer container = _container(repository, source: source);

      await container.read(pushRegistrationControllerProvider).register();
      source.refreshController.add('token-xyz');
      await Future<void>.delayed(Duration.zero);

      expect(repository.registered, hasLength(2));
      expect(repository.registered.last.token, 'token-xyz');
    });
  });

  group('logout de-registration (mobile plan §5.10)', () {
    test('deletes the device row before secure storage is cleared', () async {
      // `DELETE /me/devices/:id` is a bearer-authenticated call, so clearing
      // the tokens first would strand the row on the server — and that row is
      // exactly what a later push would be delivered to.
      final FakeTokenStorage storage = FakeTokenStorage();
      await storage.saveTokens(accessToken: 'access', refreshToken: 'refresh');
      // Reads the keystore from inside `removeDevice`, which is the only way to
      // assert the *ordering* rather than merely that both happened.
      final _TokenProbingNotificationRepository repository =
          _TokenProbingNotificationRepository(storage);

      final ProviderContainer container = _container(
        repository,
        source: FakePushTokenSource(),
        storage: storage,
      );
      await container.read(pushRegistrationControllerProvider).register();

      await container.read(logoutControllerProvider).logout();

      expect(repository.removedDevices, <String>['device-1']);
      // The bearer token was still there when the delete went out.
      expect(repository.accessTokenAtDelete, 'access');
      // And by the time logout returns, the local session really is gone.
      expect(await storage.getAccessToken(), isNull);
      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });

    test('a logout in a session that never registered deletes nothing', () async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final ProviderContainer container = _container(repository);

      await container.read(logoutControllerProvider).logout();

      expect(repository.removedDevices, isEmpty);
    });

    test('a failed delete still signs the user out', () async {
      // Best-effort, like the session revoke beside it: a user must never be
      // trapped in a session they asked to leave.
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final ProviderContainer container = _container(
        repository,
        source: FakePushTokenSource(),
      );
      await container.read(pushRegistrationControllerProvider).register();
      repository.error = const NetworkError(message: 'offline');

      await container.read(logoutControllerProvider).logout();

      expect(
        container.read(sessionControllerProvider),
        SessionStatus.unauthenticated,
      );
    });

    test('the device id is forgotten, so a second logout is a no-op', () async {
      final FakeNotificationRepository repository =
          FakeNotificationRepository();
      final ProviderContainer container = _container(
        repository,
        source: FakePushTokenSource(),
      );
      await container.read(pushRegistrationControllerProvider).register();

      await container.read(logoutControllerProvider).logout();
      await container.read(logoutControllerProvider).logout();

      // A stale id would otherwise point at a row the *next* session would try
      // to delete under a different account.
      expect(repository.removedDevices, <String>['device-1']);
    });
  });
}

/// Captures what secure storage held **at the moment** the device delete was
/// issued, which is the fact §5.10 actually constrains.
class _TokenProbingNotificationRepository extends FakeNotificationRepository {
  _TokenProbingNotificationRepository(this._storage);

  final FakeTokenStorage _storage;

  String? accessTokenAtDelete;

  @override
  Future<void> removeDevice(String id) async {
    accessTokenAtDelete = await _storage.getAccessToken();
    await super.removeDevice(id);
  }
}

ProviderContainer _container(
  FakeNotificationRepository repository, {
  PushTokenSource? source,
  FakeTokenStorage? storage,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      ...activityOverrides(notifications: repository),
      tokenStorageProvider.overrideWithValue(storage ?? FakeTokenStorage()),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      if (source != null) pushTokenSourceProvider.overrideWithValue(source),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
