import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// The player values the playback UI and refresh coordinator need.
@immutable
class VideoPlaybackValue {
  const VideoPlaybackValue({
    this.isInitialized = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.aspectRatio = 16 / 9,
    this.errorDescription,
  });

  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double aspectRatio;
  final String? errorDescription;
}

/// The replaceable native media controller used by one HLS manifest.
///
/// Keeping this narrow makes the token-refresh lifecycle independently
/// testable. The production implementation below is a direct adapter over
/// Flutter's `video_player`; it adds no cache, downloader, or media wrapper.
abstract interface class VideoPlaybackEngine implements Listenable {
  VideoPlaybackValue get value;

  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(Duration position);

  Widget buildView();

  Future<void> dispose();
}

abstract interface class VideoPlaybackEngineFactory {
  VideoPlaybackEngine create(Uri manifestUri);
}

class NativeVideoPlaybackEngineFactory implements VideoPlaybackEngineFactory {
  const NativeVideoPlaybackEngineFactory();

  @override
  VideoPlaybackEngine create(Uri manifestUri) =>
      NativeVideoPlaybackEngine(manifestUri);
}

/// Notes on the platform contract this adapter relies on (viewer PRD B1):
///
/// - **Cross-protocol redirects are already allowed.** In `api` storage mode
///   the backend 302-redirects segments to presigned object-store URLs, which
///   may differ from the API in scheme. `video_player_android` builds its data
///   source with `setAllowCrossProtocolRedirects(true)` unconditionally
///   (`HttpVideoAsset.java`), and AVPlayer follows such redirects too — there
///   is no Dart-side option to pass, and none is missing. What the *platform*
///   still enforces separately is cleartext policy: see the debug-only
///   `network_security_config.xml` and the ATS block in `Info.plist`.
/// - **No byte-range support on segments.** `api` mode answers no `206`s.
///   Seeking works because HLS seeks by segment, not by byte offset, so
///   [seekTo] is safe — but nothing here may be built on range requests.
/// - **No AirPlay, Cast, PiP, or background playback.** These are capture
///   adjacent output surfaces, disabled per B1/B3: `allowBackgroundPlayback`
///   is off below, PiP is off in `AndroidManifest.xml`, AirPlay routing is
///   cleared in the iOS `AppDelegate`, and neither this adapter nor
///   `video_player` provides any Cast integration. Adding a media wrapper that
///   restores one of these would defeat the requirement, as would one with a
///   disk cache.
/// - **No quality selector.** The default ladder is 360p + 720p and ExoPlayer
///   and AVPlayer both pick a rendition adaptively. Adding a picker would mean
///   parsing `#EXT-X-STREAM-INF` out of the master manifest ourselves —
///   `VideoEntity` has no renditions field to read, and is not getting one,
///   since renditions are SUPER_ADMIN-only.
class NativeVideoPlaybackEngine implements VideoPlaybackEngine {
  NativeVideoPlaybackEngine(Uri manifestUri)
    : _controller = VideoPlayerController.networkUrl(
        manifestUri,
        formatHint: VideoFormat.hls,
        videoPlayerOptions: VideoPlayerOptions(
          // Playback must stop when the app leaves the foreground. The core
          // plugin has no AirPlay, Cast, or PiP affordance, and this screen
          // deliberately adds none.
          allowBackgroundPlayback: false,
          mixWithOthers: false,
          // Do not retain a decoded back-buffer beyond the current position.
          // This is memory-only either way; video_player adds no disk cache.
          backBufferDurationMs: 0,
        ),
      );

  final VideoPlayerController _controller;

  /// The configured native controller, exposed so a test can assert the
  /// capture-adjacent options above are still off. Nothing in the app reads
  /// this — presentation talks to [VideoPlaybackEngine].
  @visibleForTesting
  VideoPlayerController get controller => _controller;

  @override
  VideoPlaybackValue get value {
    final VideoPlayerValue current = _controller.value;
    final double aspectRatio = current.aspectRatio;
    return VideoPlaybackValue(
      isInitialized: current.isInitialized,
      isPlaying: current.isPlaying,
      isBuffering: current.isBuffering,
      position: current.position,
      duration: current.duration,
      aspectRatio: aspectRatio.isFinite && aspectRatio > 0
          ? aspectRatio
          : 16 / 9,
      errorDescription: current.errorDescription,
    );
  }

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _controller.removeListener(listener);

  @override
  Future<void> initialize() => _controller.initialize();

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seekTo(Duration position) => _controller.seekTo(position);

  @override
  Widget buildView() => VideoPlayer(_controller);

  @override
  Future<void> dispose() => _controller.dispose();
}

final Provider<VideoPlaybackEngineFactory> videoPlaybackEngineFactoryProvider =
    Provider<VideoPlaybackEngineFactory>(
      (Ref ref) => const NativeVideoPlaybackEngineFactory(),
    );
