import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/core/errors/app_error.dart';
import 'package:smart_teacher_mobile/src/features/library/data/content_detail_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/data/video_playback_repository.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_engine.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_session_controller.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_player_screen.dart';

import '../../support/fake_content_detail_repository.dart';
import '../../support/fake_video_playback_engine.dart';
import '../../support/fake_video_playback_repository.dart';

void main() {
  testWidgets('a playback-token 404 is final and offers no retry', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository playback = FakeVideoPlaybackRepository(
      error: const NotFoundError(message: 'Not found'),
    );
    await _pumpPlayer(tester, playback: playback);

    expect(find.text('This content is no longer available.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsNothing);
    expect(playback.requestedVideoIds, <String>['video-1']);
  });

  testWidgets('a transient mint failure retries and opens the player', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository playback = FakeVideoPlaybackRepository(
      error: const NetworkError(message: 'Offline'),
    );
    await _pumpPlayer(tester, playback: playback);

    expect(
      find.text('Playback failed. Check your connection and try again.'),
      findsOneWidget,
    );
    playback.error = null;
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Play'), findsOneWidget);
    expect(playback.callCount, 2);
  });

  testWidgets('the whole video surface toggles playback', (
    WidgetTester tester,
  ) async {
    final FakeVideoPlaybackRepository playback = FakeVideoPlaybackRepository();
    final FakeVideoPlaybackEngineFactory engines =
        FakeVideoPlaybackEngineFactory();
    await _pumpPlayer(tester, playback: playback, engines: engines);

    final Finder surface = find.byKey(
      const ValueKey<String>('video-playback-surface'),
    );
    final Rect surfaceRect = tester.getRect(surface);
    await tester.tapAt(surfaceRect.topLeft + const Offset(24, 24));
    await tester.pump();

    expect(engines.engines.single.playCount, 1);
    expect(find.byTooltip('Play'), findsNothing);

    await tester.tapAt(surfaceRect.topLeft + const Offset(24, 24));
    await tester.pump();

    expect(engines.engines.single.pauseCount, 1);
    expect(find.byTooltip('Play'), findsOneWidget);
  });

  testWidgets('the progress controls are pinned to the video bottom edge', (
    WidgetTester tester,
  ) async {
    await _pumpPlayer(tester, playback: FakeVideoPlaybackRepository());

    final Rect frame = tester.getRect(
      find.byKey(const ValueKey<String>('video-playback-frame')),
    );
    final Rect controls = tester.getRect(
      find.byKey(const ValueKey<String>('video-playback-controls')),
    );

    expect(controls.bottom, moreOrLessEquals(frame.bottom));
    expect(controls.center.dy, greaterThan(frame.center.dy));
  });

  testWidgets('the player enters and exits full screen', (
    WidgetTester tester,
  ) async {
    await _pumpPlayer(tester, playback: FakeVideoPlaybackRepository());

    await tester.tap(find.byTooltip('Enter full screen'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Exit full screen'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);

    await tester.tap(find.byTooltip('Exit full screen'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Enter full screen'), findsOneWidget);
  });
}

Future<void> _pumpPlayer(
  WidgetTester tester, {
  required FakeVideoPlaybackRepository playback,
  FakeVideoPlaybackEngineFactory? engines,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentDetailRepositoryProvider.overrideWithValue(
          FakeContentDetailRepository(
            video: buildVideo(id: 'video-1', durationSecs: null),
          ),
        ),
        videoPlaybackRepositoryProvider.overrideWithValue(playback),
        videoPlaybackEngineFactoryProvider.overrideWithValue(
          engines ?? FakeVideoPlaybackEngineFactory(),
        ),
        playbackRefreshSchedulerProvider.overrideWithValue(
          FakePlaybackRefreshScheduler(),
        ),
      ],
      child: const MaterialApp(home: VideoPlayerScreen(videoId: 'video-1')),
    ),
  );
  await tester.pumpAndSettle();
}
