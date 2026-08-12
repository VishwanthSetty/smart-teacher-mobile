import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Metadata-only handoff for a video or document row (PRD §5.4.2–§5.4.3).
///
/// The route carries [itemId], and this screen uses it for exactly one
/// entitlement-gated detail read. It intentionally has no playback-token,
/// download, share, or open action: the title and safe metadata are the end of
/// the road for this phase.
class ContentItemStubScreen extends ConsumerWidget {
  const ContentItemStubScreen({
    required this.itemId,
    required this.kind,
    this.title,
    super.key,
  });

  final String itemId;
  final ContentItemKind kind;

  /// Optimistic label supplied by the tree. A direct/deep link has no `extra`,
  /// so the endpoint remains the authority and supplies the eventual title.
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ContentItemDetailRequest request = (itemId: itemId, kind: kind);
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
                    _ContentDetailView(detail: data, kind: kind),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace _) =>
                    _buildError(context, ref, request, AppError.from(error)),
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
    if (handedOver.isNotEmpty) {
      return handedOver;
    }
    return switch (kind) {
      ContentItemKind.video => 'Video',
      ContentItemKind.document => 'Document',
    };
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    ContentItemDetailRequest request,
    AppError error,
  ) {
    if (error is NotFoundError) {
      return NotFoundView(
        message: error.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back to curriculum',
      );
    }

    return ErrorRetryView(
      error: error,
      onRetry: () => unawaited(
        ref
            .read(contentItemDetailControllerProvider(request).notifier)
            .refresh(),
      ),
    );
  }
}

class _ContentDetailView extends StatelessWidget {
  const _ContentDetailView({required this.detail, required this.kind});

  final ContentDetailEntity detail;
  final ContentItemKind kind;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String description = detail.description?.trim() ?? '';
    final int? durationSecs;
    if (detail case VideoEntity(durationSecs: final int? value)) {
      durationSecs = value;
    } else {
      durationSecs = null;
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      children: <Widget>[
        Icon(
          switch (kind) {
            ContentItemKind.video => Icons.play_circle_outline,
            ContentItemKind.document => Icons.description_outlined,
          },
          size: 48,
          color: colors.primary,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          _title,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (description.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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
                _MetadataRow(
                  icon: Icons.account_tree_outlined,
                  label: 'Curriculum section',
                  value: _contentNodeTitle,
                ),
                if (durationSecs != null && durationSecs > 0)
                  _MetadataRow(
                    icon: Icons.schedule_outlined,
                    label: 'Duration',
                    value: _formatDuration(durationSecs),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.radius),
          ),
          child: Column(
            children: <Widget>[
              Icon(_comingSoonIcon, color: colors.onSurfaceVariant),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                _comingSoonTitle,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                _comingSoonDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _title {
    final String value = detail.title.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return switch (kind) {
      ContentItemKind.video => 'Untitled video',
      ContentItemKind.document => 'Untitled document',
    };
  }

  String get _contentNodeTitle {
    final String value = detail.contentNodeTitle.trim();
    return value.isEmpty ? 'Untitled section' : value;
  }

  String get _comingSoonTitle => switch (kind) {
    ContentItemKind.video => 'Playback coming soon',
    ContentItemKind.document => 'Reader coming soon',
  };

  String get _comingSoonDescription => switch (kind) {
    ContentItemKind.video => 'Video playback is not available in the app yet.',
    ContentItemKind.document =>
      'Document reading is not available in the app yet.',
  };

  IconData get _comingSoonIcon => switch (kind) {
    ContentItemKind.video => Icons.ondemand_video_outlined,
    ContentItemKind.document => Icons.menu_book_outlined,
  };

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    if (minutes >= 60) {
      final int hours = minutes ~/ 60;
      final int remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
