import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/sync/local_activity.dart';
import '../../../../core/sync/playback_tracker.dart';
import '../../../library/presentation/video_playback_session_controller.dart';
import '../activity_sync_controller.dart';

/// **"Resume from 6:52 · Start over"** (mobile plan §3).
///
/// Shown rather than jumping silently, and only past the ten-second
/// divergence threshold — see [shouldOfferResumeChooser]. Below it, resuming
/// silently is what the user expects; above it, a silent jump is exactly what
/// feels broken, because the cross-device case is the one where the user did
/// not put the playhead there.
///
/// Resolving the prompt either way dismisses it for the life of the screen. It
/// is a question about where to *start*, and re-asking it after the user has
/// been watching for five minutes would be absurd.
class ResumePrompt extends ConsumerStatefulWidget {
  const ResumePrompt({required this.videoId, super.key});

  final String videoId;

  @override
  ConsumerState<ResumePrompt> createState() => _ResumePromptState();
}

class _ResumePromptState extends ConsumerState<ResumePrompt> {
  Future<LocalActivity?>? _cached;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    // Read once, in initState: this asks "where was I when I opened this?",
    // and re-reading as the cache moves under it would make the offer chase
    // the playhead it is offering to move.
    _cached = ref.read(activitySyncControllerProvider).cachedActivity(
      widget.videoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resolved) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<LocalActivity?>(
      future: _cached,
      builder:
          (BuildContext context, AsyncSnapshot<LocalActivity?> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            final LocalActivity? cached = snapshot.data;
            final Duration position = Duration(
              seconds: cached?.positionSecs ?? 0,
            );
            if (position <= Duration.zero) {
              return const SizedBox.shrink();
            }

            // Below the threshold the position is restored silently instead of
            // asked about — the seek still happens, just without the prompt.
            if (!shouldOfferResumeChooser(
              cached: cached,
              serverPosition: position,
            )) {
              WidgetsBinding.instance.addPostFrameCallback((Duration _) {
                _resume(position, dismiss: true);
              });
              return const SizedBox.shrink();
            }

            return _PromptBar(
              position: position,
              onResume: () => _resume(position, dismiss: true),
              onStartOver: () => setState(() => _resolved = true),
            );
          },
    );
  }

  void _resume(Duration position, {required bool dismiss}) {
    if (!mounted) {
      return;
    }
    final VideoPlaybackSessionState? session = ref
        .read(videoPlaybackSessionControllerProvider(widget.videoId))
        .value;
    // Only seek once the engine is actually ready; a seek against a
    // half-initialised controller is dropped, and the prompt would be
    // dismissed having done nothing.
    if (session is! VideoPlaybackReady) {
      return;
    }
    unawaited(
      ref
          .read(videoPlaybackSessionControllerProvider(widget.videoId).notifier)
          .seekTo(position),
    );
    if (dismiss) {
      setState(() => _resolved = true);
    }
  }
}

class _PromptBar extends StatelessWidget {
  const _PromptBar({
    required this.position,
    required this.onResume,
    required this.onStartOver,
  });

  final Duration position;
  final VoidCallback onResume;
  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingSm),
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingMd,
            AppConstants.spacingSm,
            AppConstants.spacingSm,
            AppConstants.spacingSm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'You left off at ${_formatDuration(position)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: onStartOver,
                child: const Text('Start over'),
              ),
              FilledButton.tonal(
                onPressed: onResume,
                child: const Text('Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
