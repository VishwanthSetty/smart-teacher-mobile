import 'package:flutter/material.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_engine.dart';
import 'package:smart_teacher_mobile/src/features/library/presentation/video_playback_session_controller.dart';

class FakePlaybackRefreshScheduler implements PlaybackRefreshScheduler {
  final List<FakeScheduledRefresh> requests = <FakeScheduledRefresh>[];

  FakeScheduledRefresh get latest => requests.last;

  @override
  PlaybackRefreshHandle schedule(Duration delay, void Function() callback) {
    final FakeScheduledRefresh request = FakeScheduledRefresh(
      delay: delay,
      callback: callback,
    );
    requests.add(request);
    return request;
  }
}

class FakeScheduledRefresh implements PlaybackRefreshHandle {
  FakeScheduledRefresh({required this.delay, required this.callback});

  final Duration delay;
  final void Function() callback;
  bool isCanceled = false;

  void fire() {
    if (!isCanceled) {
      callback();
    }
  }

  @override
  void cancel() {
    isCanceled = true;
  }
}

class FakeVideoPlaybackEngineFactory implements VideoPlaybackEngineFactory {
  final List<Uri> manifestUris = <Uri>[];
  final List<FakeVideoPlaybackEngine> engines = <FakeVideoPlaybackEngine>[];
  final List<Object?> initializationErrors = <Object?>[];

  @override
  VideoPlaybackEngine create(Uri manifestUri) {
    manifestUris.add(manifestUri);
    final int index = engines.length;
    final FakeVideoPlaybackEngine engine = FakeVideoPlaybackEngine(
      initializationError: index < initializationErrors.length
          ? initializationErrors[index]
          : null,
    );
    engines.add(engine);
    return engine;
  }
}

class FakeVideoPlaybackEngine implements VideoPlaybackEngine {
  FakeVideoPlaybackEngine({this.initializationError});

  final ChangeNotifier _notifier = ChangeNotifier();
  final Object? initializationError;

  VideoPlaybackValue _value = const VideoPlaybackValue(
    duration: Duration(minutes: 2),
  );
  int initializeCount = 0;
  int playCount = 0;
  int pauseCount = 0;
  int disposeCount = 0;
  final List<Duration> seekPositions = <Duration>[];

  @override
  VideoPlaybackValue get value => _value;

  @override
  void addListener(VoidCallback listener) => _notifier.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  @override
  Future<void> initialize() async {
    initializeCount += 1;
    final Object? error = initializationError;
    if (error != null) {
      throw error;
    }
    _setValue(isInitialized: true, isPlaying: false, position: Duration.zero);
  }

  @override
  Future<void> play() async {
    playCount += 1;
    _setValue(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    pauseCount += 1;
    _setValue(isPlaying: false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    seekPositions.add(position);
    _setValue(position: position);
  }

  void setPlayback({required Duration position, required bool isPlaying}) {
    _setValue(position: position, isPlaying: isPlaying);
  }

  void emitError(String description) {
    _setValue(errorDescription: description, replaceError: true);
  }

  void _setValue({
    bool? isInitialized,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? aspectRatio,
    String? errorDescription,
    bool replaceError = false,
  }) {
    _value = VideoPlaybackValue(
      isInitialized: isInitialized ?? _value.isInitialized,
      isPlaying: isPlaying ?? _value.isPlaying,
      isBuffering: isBuffering ?? _value.isBuffering,
      position: position ?? _value.position,
      duration: duration ?? _value.duration,
      aspectRatio: aspectRatio ?? _value.aspectRatio,
      errorDescription: replaceError
          ? errorDescription
          : _value.errorDescription,
    );
    _notifier.notifyListeners();
  }

  @override
  Widget buildView() => const ColoredBox(
    key: ValueKey<String>('fake-video-surface'),
    color: Colors.black,
  );

  @override
  Future<void> dispose() async {
    disposeCount += 1;
  }
}
