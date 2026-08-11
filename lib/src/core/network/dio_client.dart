import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/school_suspension_controller.dart';
import '../storage/token_storage.dart';
import 'auth_event_notifier.dart';
import 'auth_interceptor.dart';
import 'suspension_interceptor.dart';

/// Base URL for `apps/api`. Dev defaults to a local host; override at build
/// time with `--dart-define=API_URL=https://...` for staging/prod.
const String _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:4000',
);

/// The single [Dio] instance used for every API call.
///
/// [AuthInterceptor] handles the whole token lifecycle (PRD §6.2): attaching
/// the bearer token, refreshing on 401, and emitting [AuthEvent.loggedOut]
/// through [authEventNotifierProvider] on unrecoverable failure. That is the
/// one and only place refresh logic lives — no per-screen retry logic.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final TokenStorage storage = ref.watch(tokenStorageProvider);
  final AuthEventNotifier authEvents = ref.watch(authEventNotifierProvider);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: _apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(dio: dio, storage: storage, authEvents: authEvents),
  );

  // After the auth interceptor, so a 401 that refresh recovers from is never
  // seen here as a failure. Read lazily: the detector listens to the session
  // gate, and building it eagerly here would tie the HTTP client's creation to
  // it for no reason.
  dio.interceptors.add(
    SuspensionInterceptor(
      onSuspendedForbidden: () =>
          ref.read(schoolSuspensionProvider.notifier).reportSuspendedForbidden(),
      onAuthenticatedCallSucceeded: () => ref
          .read(schoolSuspensionProvider.notifier)
          .reportAuthenticatedCallSucceeded(),
    ),
  );

  return dio;
});
