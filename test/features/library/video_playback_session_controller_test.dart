import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/data/video_playback_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/domain/playback_token_entity.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_engine.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_session_controller.dart';

import '../../support/fake_video_playback_engine.dart';
import '../../support/fake_video_playback_repository.dart';

void main() {
  testWidgets('scheduled refresh replaces, seeks, and resumes at 80% of TTL', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository repository = FakeVideoPlaybackRepository(
      tickets: <PlaybackTokenEntity>[
        buildPlaybackTicket(token: 'first', expiresInSecs: 100),
        buildPlaybackTicket(token: 'second', expiresInSecs: 100),
      ],
    );
    final FakeVideoPlaybackEngineFactory engines =
        FakeVideoPlaybackEngineFactory();
    final FakePlaybackRefreshScheduler scheduler =
        FakePlaybackRefreshScheduler();
    final _SessionHarness harness = _SessionHarness(
      repository: repository,
      engines: engines,
      scheduler: scheduler,
    );
    await harness.start();

    final FakeVideoPlaybackEngine first = engines.engines.single;
    first.setPlayback(
      position: const Duration(minutes: 7, seconds: 12),
      isPlaying: true,
    );

    expect(scheduler.latest.delay, const Duration(seconds: 80));
    expect(repository.callCount, 1);

    scheduler.latest.fire();
    await _flushAsync(tester);

    expect(repository.callCount, 2);
    expect(engines.manifestUris.last.queryParameters['t'], 'second');
    expect(engines.engines.last.seekPositions, <Duration>[
      const Duration(minutes: 7, seconds: 12),
    ]);
    expect(engines.engines.last.playCount, 1);
    expect(first.pauseCount, 1);
    expect(first.disposeCount, 1);
    harness.dispose();
  });

  testWidgets('refresh delay has a 15 second floor', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository repository = FakeVideoPlaybackRepository(
      tickets: <PlaybackTokenEntity>[
        buildPlaybackTicket(token: 'first', expiresInSecs: 1),
        buildPlaybackTicket(token: 'second', expiresInSecs: 1),
      ],
    );
    final FakePlaybackRefreshScheduler scheduler =
        FakePlaybackRefreshScheduler();
    final _SessionHarness harness = _SessionHarness(
      repository: repository,
      engines: FakeVideoPlaybackEngineFactory(),
      scheduler: scheduler,
    );
    await harness.start();

    expect(scheduler.latest.delay, const Duration(seconds: 15));
    expect(repository.callCount, 1);
    scheduler.latest.fire();
    await _flushAsync(tester);
    expect(repository.callCount, 2);
    harness.dispose();
  });

  testWidgets('401 and 403 errors immediately re-mint the native source', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository repository = FakeVideoPlaybackRepository(
      tickets: <PlaybackTokenEntity>[
        buildPlaybackTicket(token: 'first'),
        buildPlaybackTicket(token: 'after-401'),
        buildPlaybackTicket(token: 'after-403'),
      ],
    );
    final FakeVideoPlaybackEngineFactory engines =
        FakeVideoPlaybackEngineFactory();
    final FakePlaybackRefreshScheduler scheduler =
        FakePlaybackRefreshScheduler();
    final _SessionHarness harness = _SessionHarness(
      repository: repository,
      engines: engines,
      scheduler: scheduler,
    );
    await harness.start();

    engines.engines[0].emitError('Response code: 401');
    await _flushAsync(tester);
    expect(repository.callCount, 2);
    expect(engines.manifestUris.last.queryParameters['t'], 'after-401');

    engines.engines[1].emitError('HTTP status: 403');
    await _flushAsync(tester);
    expect(repository.callCount, 3);
    expect(engines.manifestUris.last.queryParameters['t'], 'after-403');
    expect(harness.current, isA<VideoPlaybackReady>());
    harness.dispose();
  });

  testWidgets('fourth refresh inside 60 seconds surfaces an error', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository repository = FakeVideoPlaybackRepository(
      tickets: List<PlaybackTokenEntity>.generate(
        4,
        (int index) => buildPlaybackTicket(token: 'token-$index'),
      ),
    );
    final FakeVideoPlaybackEngineFactory engines =
        FakeVideoPlaybackEngineFactory();
    final FakePlaybackRefreshScheduler scheduler =
        FakePlaybackRefreshScheduler();
    final _SessionHarness harness = _SessionHarness(
      repository: repository,
      engines: engines,
      scheduler: scheduler,
    );
    await harness.start();

    for (int index = 0; index < 3; index += 1) {
      engines.engines[index].emitError('Response code: 401');
      await _flushAsync(tester);
    }
    expect(repository.callCount, 4);
    expect(engines.engines, hasLength(4));

    engines.engines.last.emitError('HTTP 403');
    await _flushAsync(tester);

    expect(repository.callCount, 4);
    final VideoPlaybackSessionState session = harness.current;
    expect(session, isA<VideoPlaybackFailed>());
    expect(
      (session as VideoPlaybackFailed).message,
      'Playback failed. Check your connection and try again.',
    );
    expect(session.canRetry, isTrue);
    harness.dispose();
  });
}

class _SessionHarness {
  _SessionHarness({
    required this.repository,
    required this.engines,
    required this.scheduler,
  }) : container = ProviderContainer(
         overrides: [
           videoPlaybackRepositoryProvider.overrideWithValue(repository),
           videoPlaybackEngineFactoryProvider.overrideWithValue(engines),
           playbackRefreshSchedulerProvider.overrideWithValue(scheduler),
         ],
       );

  final FakeVideoPlaybackRepository repository;
  final FakeVideoPlaybackEngineFactory engines;
  final FakePlaybackRefreshScheduler scheduler;
  final ProviderContainer container;
  ProviderSubscription<AsyncValue<VideoPlaybackSessionState>>? _subscription;

  Future<void> start() async {
    _subscription = container.listen<AsyncValue<VideoPlaybackSessionState>>(
      videoPlaybackSessionControllerProvider('video-1'),
      (
        AsyncValue<VideoPlaybackSessionState>? previous,
        AsyncValue<VideoPlaybackSessionState> next,
      ) {},
    );
    await container.read(
      videoPlaybackSessionControllerProvider('video-1').future,
    );
  }

  VideoPlaybackSessionState get current => container
      .read(videoPlaybackSessionControllerProvider('video-1'))
      .requireValue;

  void dispose() {
    _subscription?.close();
    container.dispose();
  }
}

Future<void> _flushAsync(WidgetTester tester) async {
  for (int index = 0; index < 6; index += 1) {
    await tester.pump();
  }
}
