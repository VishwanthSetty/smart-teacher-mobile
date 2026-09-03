import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_engine.dart';
import 'package:video_player/video_player.dart';

/// Guards the platform contract in viewer PRD B1: the native controller is
/// configured for HLS and none of the capture-adjacent output surfaces are on.
/// Constructing the controller touches no platform channel — that only happens
/// on `initialize()`, which these tests never call.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Uri manifestUri = Uri.parse(
    'https://api.example.test/videos/v1/master.m3u8?t=token',
  );

  test('plays the manifest URL as HLS', () {
    final NativeVideoPlaybackEngine engine = NativeVideoPlaybackEngine(
      manifestUri,
    );
    addTearDown(engine.dispose);

    expect(engine.controller.dataSource, manifestUri.toString());
    expect(engine.controller.formatHint, VideoFormat.hls);
  });

  test('leaves background playback and audio mixing off', () {
    final NativeVideoPlaybackEngine engine = NativeVideoPlaybackEngine(
      manifestUri,
    );
    addTearDown(engine.dispose);

    final VideoPlayerOptions? options = engine.controller.videoPlayerOptions;
    expect(options, isNotNull);
    expect(options!.allowBackgroundPlayback, isFalse);
    expect(options.mixWithOthers, isFalse);
  });

  test('retains no decoded back buffer', () {
    final NativeVideoPlaybackEngine engine = NativeVideoPlaybackEngine(
      manifestUri,
    );
    addTearDown(engine.dispose);

    expect(engine.controller.videoPlayerOptions?.backBufferDurationMs, 0);
  });

  test('the default factory builds the native engine', () {
    const NativeVideoPlaybackEngineFactory factory =
        NativeVideoPlaybackEngineFactory();
    final VideoPlaybackEngine engine = factory.create(manifestUri);
    addTearDown(engine.dispose);

    expect(engine, isA<NativeVideoPlaybackEngine>());
  });
}
