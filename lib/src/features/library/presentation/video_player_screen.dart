import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/content_detail_entity.dart';
import '../domain/content_node_entity.dart';
import 'content_item_detail_controller.dart';
import 'video_playback_engine.dart';
import 'video_playback_session_controller.dart';

class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({required this.videoId, this.title, super.key});

  final String videoId;

  /// Optimistic title supplied by the tree. The detail endpoint remains the
  /// authority when this route is opened by deep link or restored later.
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ContentItemDetailRequest request = (
      itemId: videoId,
      kind: ContentItemKind.video,
    );
    final AsyncValue<ContentDetailEntity> detail = ref.watch(
      contentItemDetailControllerProvider(request),
    );
    final bool suspended = ref.watch(schoolSuspensionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_displayTitle(detail.value))),
      body: SafeArea(
        child: suspended
            ? SchoolSuspendedView(onSignOut: () => signOut(ref))
            : detail.when(
                data: (ContentDetailEntity data) =>
                    _VideoDetailView(video: data as VideoEntity),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) =>
                    _buildDetailError(context, ref, request, error),
              ),
      ),
    );
  }

  String _displayTitle(ContentDetailEntity? detail) {
    final String fetched = detail?.title.trim() ?? '';
    if (fetched.isNotEmpty) {
      return fetched;
    }
    final String handedOver = title?.trim() ?? '';
    return handedOver.isEmpty ? 'Video' : handedOver;
  }

  Widget _buildDetailError(
    BuildContext context,
    WidgetRef ref,
    ContentItemDetailRequest request,
    Object error,
  ) {
    final AppError appError = AppError.from(error);
    if (appError is NotFoundError) {
      return NotFoundView(
        message: appError.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to curriculum',
      );
    }
    return ErrorRetryView(
      error: appError,
      onRetry: () => unawaited(
        ref
            .read(contentItemDetailControllerProvider(request).notifier)
            .refresh(),
      ),
    );
  }
}

class _VideoDetailView extends ConsumerWidget {
  const _VideoDetailView({required this.video});

  final VideoEntity video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String description = video.description?.trim() ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingSm,
        AppConstants.spacingMd,
        AppConstants.spacingLg,
      ),
      children: <Widget>[
        _PlaybackPanel(videoId: video.id),
        const SizedBox(height: AppConstants.spacingLg),
        Text(video.title, style: theme.textTheme.headlineSmall),
        if (description.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spacingLg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppConstants.spacingSm),
                _VideoMetadataRow(
                  icon: Icons.account_tree_outlined,
                  label: 'Curriculum section',
                  value: _nonBlank(video.contentNodeTitle, 'Untitled section'),
                ),
                if (video.durationSecs case final int seconds when seconds > 0)
                  _VideoMetadataRow(
                    icon: Icons.schedule_outlined,
                    label: 'Duration',
                    value: _formatDuration(Duration(seconds: seconds)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaybackPanel extends ConsumerWidget {
  const _PlaybackPanel({required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<VideoPlaybackSessionState> session = ref.watch(
      videoPlaybackSessionControllerProvider(videoId),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius),
      child: ColoredBox(
        color: Colors.black,
        child: session.when(
          data: (VideoPlaybackSessionState data) => switch (data) {
            final VideoPlaybackReady ready => _ReadyVideoPlayer(
              ready: ready,
              isFullscreen: false,
              onToggle: () => unawaited(
                ref
                    .read(
                      videoPlaybackSessionControllerProvider(videoId).notifier,
                    )
                    .togglePlayback(),
              ),
              onSeek: (Duration position) => unawaited(
                ref
                    .read(
                      videoPlaybackSessionControllerProvider(videoId).notifier,
                    )
                    .seekTo(position),
              ),
              onFullscreenToggle: () => unawaited(
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        _FullscreenVideoPlayerScreen(videoId: videoId),
                    fullscreenDialog: true,
                  ),
                ),
              ),
            ),
            final VideoPlaybackFailed failure => _PlaybackFailureView(
              failure: failure,
              onRetry: failure.canRetry
                  ? () => unawaited(
                      ref
                          .read(
                            videoPlaybackSessionControllerProvider(
                              videoId,
                            ).notifier,
                          )
                          .retry(),
                    )
                  : null,
            ),
          },
          loading: () => const _LoadingPlayer(),
          error: (Object _, StackTrace _) => _PlaybackFailureView(
            failure: const VideoPlaybackFailed(
              message: 'Playback failed. Check your connection and try again.',
              canRetry: true,
            ),
            onRetry: () => unawaited(
              ref
                  .read(
                    videoPlaybackSessionControllerProvider(videoId).notifier,
                  )
                  .retry(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenVideoPlayerScreen extends ConsumerStatefulWidget {
  const _FullscreenVideoPlayerScreen({required this.videoId});

  final String videoId;

  @override
  ConsumerState<_FullscreenVideoPlayerScreen> createState() =>
      _FullscreenVideoPlayerScreenState();
}

class _FullscreenVideoPlayerScreenState
    extends ConsumerState<_FullscreenVideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(
      SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
  }

  @override
  void dispose() {
    unawaited(SystemChrome.setPreferredOrientations(<DeviceOrientation>[]));
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<VideoPlaybackSessionState> session = ref.watch(
      videoPlaybackSessionControllerProvider(widget.videoId),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: session.when(
          data: (VideoPlaybackSessionState data) => switch (data) {
            final VideoPlaybackReady ready => _ReadyVideoPlayer(
              ready: ready,
              isFullscreen: true,
              onToggle: () => unawaited(
                ref
                    .read(
                      videoPlaybackSessionControllerProvider(
                        widget.videoId,
                      ).notifier,
                    )
                    .togglePlayback(),
              ),
              onSeek: (Duration position) => unawaited(
                ref
                    .read(
                      videoPlaybackSessionControllerProvider(
                        widget.videoId,
                      ).notifier,
                    )
                    .seekTo(position),
              ),
              onFullscreenToggle: Navigator.of(context).pop,
            ),
            final VideoPlaybackFailed failure => _PlaybackFailureView(
              failure: failure,
              onRetry: failure.canRetry
                  ? () => unawaited(
                      ref
                          .read(
                            videoPlaybackSessionControllerProvider(
                              widget.videoId,
                            ).notifier,
                          )
                          .retry(),
                    )
                  : null,
            ),
          },
          loading: () => const _LoadingPlayer(),
          error: (Object _, StackTrace _) => _PlaybackFailureView(
            failure: const VideoPlaybackFailed(
              message: 'Playback failed. Check your connection and try again.',
              canRetry: true,
            ),
            onRetry: () => unawaited(
              ref
                  .read(
                    videoPlaybackSessionControllerProvider(
                      widget.videoId,
                    ).notifier,
                  )
                  .retry(),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingPlayer extends StatelessWidget {
  const _LoadingPlayer();

  @override
  Widget build(BuildContext context) => const AspectRatio(
    aspectRatio: 16 / 9,
    child: Center(child: CircularProgressIndicator(color: Colors.white)),
  );
}

class _PlaybackFailureView extends StatelessWidget {
  const _PlaybackFailureView({required this.failure, this.onRetry});

  final VideoPlaybackFailed failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            failure.isUnavailable
                ? Icons.video_file_outlined
                : Icons.error_outline,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            failure.message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: AppConstants.spacingMd),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}

class _ReadyVideoPlayer extends StatefulWidget {
  const _ReadyVideoPlayer({
    required this.ready,
    required this.isFullscreen,
    required this.onToggle,
    required this.onSeek,
    required this.onFullscreenToggle,
  });

  final VideoPlaybackReady ready;
  final bool isFullscreen;
  final VoidCallback onToggle;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onFullscreenToggle;

  @override
  State<_ReadyVideoPlayer> createState() => _ReadyVideoPlayerState();
}

class _ReadyVideoPlayerState extends State<_ReadyVideoPlayer> {
  double? _dragMilliseconds;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.ready.engine,
    builder: (BuildContext context, Widget? child) {
      final VideoPlaybackValue value = widget.ready.engine.value;
      final double durationMilliseconds = value.duration.inMilliseconds
          .clamp(1, double.maxFinite)
          .toDouble();
      final double positionMilliseconds =
          (_dragMilliseconds ?? value.position.inMilliseconds.toDouble())
              .clamp(0, durationMilliseconds)
              .toDouble();
      final bool showPoster =
          !value.isPlaying && value.position == Duration.zero;
      final String? posterUrl = widget.ready.ticket.posterUrl;

      return AspectRatio(
        key: const ValueKey<String>('video-playback-frame'),
        aspectRatio: value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            widget.ready.engine.buildView(),
            if (showPoster && posterUrl != null)
              Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stack) =>
                        const SizedBox.shrink(),
              ),
            Positioned.fill(
              child: Semantics(
                button: true,
                label: value.isPlaying ? 'Pause video' : 'Play video',
                onTap: widget.onToggle,
                child: GestureDetector(
                  key: const ValueKey<String>('video-playback-surface'),
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onToggle,
                ),
              ),
            ),
            if (!value.isPlaying)
              Center(
                child: IconButton.filled(
                  tooltip: 'Play',
                  iconSize: 38,
                  onPressed: widget.onToggle,
                  icon: const Icon(Icons.play_arrow),
                ),
              ),
            if (value.isBuffering && value.isPlaying)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                key: const ValueKey<String>('video-playback-controls'),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.transparent, Colors.black87],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacingSm,
                    AppConstants.spacingMd,
                    AppConstants.spacingSm,
                    AppConstants.spacingXs,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        _formatDuration(
                          Duration(milliseconds: positionMilliseconds.round()),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: positionMilliseconds,
                          max: durationMilliseconds,
                          onChanged: (double next) {
                            setState(() => _dragMilliseconds = next);
                          },
                          onChangeEnd: (double next) {
                            setState(() => _dragMilliseconds = null);
                            widget.onSeek(Duration(milliseconds: next.round()));
                          },
                        ),
                      ),
                      Text(
                        _formatDuration(value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        tooltip: widget.isFullscreen
                            ? 'Exit full screen'
                            : 'Enter full screen',
                        color: Colors.white,
                        onPressed: widget.onFullscreenToggle,
                        icon: Icon(
                          widget.isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _VideoMetadataRow extends StatelessWidget {
  const _VideoMetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
    title: Text(label),
    subtitle: Text(value),
  );
}

String _nonBlank(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value.trim();

String _formatDuration(Duration duration) {
  final int totalSeconds = duration.inSeconds;
  final int hours = totalSeconds ~/ Duration.secondsPerHour;
  final int minutes =
      (totalSeconds % Duration.secondsPerHour) ~/ Duration.secondsPerMinute;
  final int seconds = totalSeconds % Duration.secondsPerMinute;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
