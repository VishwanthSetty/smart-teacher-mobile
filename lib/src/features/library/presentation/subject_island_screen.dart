import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/school_suspension_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand/clay.dart';
import '../../../core/widgets/brand/owl_buddy.dart';
import '../../../core/widgets/error_retry_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/school_suspended_view.dart';
import '../../profile/presentation/profile_view.dart';
import '../domain/content_node_entity.dart';
import 'curriculum_tree_controller.dart';
import 'subject_island.dart';

/// The Play register's view of a curriculum (design: `KidsMap`) — its chapters
/// as stepping stones on an island path, and a sheet with one big *Watch* and
/// one big *Do it* for the chapter picked.
///
/// The same tree, the same controller and the same outcomes as
/// [CurriculumTreeScreen] — only the drawing differs. A `404` is still
/// [NotFoundView] and never a refusal (§4), and a suspension still replaces
/// the page (§5.2). Which of the two screens a card opens is the caller's
/// choice, made from the age band the shell passed in, not from the role.
class SubjectIslandScreen extends ConsumerStatefulWidget {
  const SubjectIslandScreen({
    required this.curriculumId,
    this.title,
    super.key,
  });

  final String curriculumId;

  /// The subject name from the tile that was tapped; the tree's own echo of it
  /// stands in after a deep link.
  final String? title;

  @override
  ConsumerState<SubjectIslandScreen> createState() =>
      _SubjectIslandScreenState();
}

class _SubjectIslandScreenState extends ConsumerState<SubjectIslandScreen> {
  /// The stop the child picked; null means "the one the path leads to".
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final bool suspended = ref.watch(schoolSuspensionProvider);
    final AsyncValue<ContentTreeEntity> tree = ref.watch(
      curriculumTreeControllerProvider(widget.curriculumId),
    );
    final String title =
        widget.title ?? tree.value?.subjectName ?? 'My subject';

    if (suspended) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: SchoolSuspendedView(onSignOut: () => signOut(ref)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.sea,
      body: SafeArea(
        bottom: false,
        child: tree.when(
          data: (ContentTreeEntity data) => _buildIsland(context, title, data),
          loading: () => Column(
            children: <Widget>[
              _TopBar(title: title),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (Object error, StackTrace _) => Column(
            children: <Widget>[
              _TopBar(title: title),
              Expanded(
                child: ColoredBox(
                  color: AppColors.cloud,
                  child: _buildError(context, AppError.from(error)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIsland(
    BuildContext context,
    String title,
    ContentTreeEntity data,
  ) {
    // Progress comes from the local cache; until it answers, every stop reads
    // as not started rather than holding the map back.
    final Map<String, String> statuses =
        ref.watch(islandProgressProvider(widget.curriculumId)).value ??
        const <String, String>{};
    final List<IslandStop> stops = buildIslandStops(data.nodes, statuses);

    if (stops.isEmpty) {
      return Column(
        children: <Widget>[
          _TopBar(title: title),
          const Expanded(child: _EmptyIsland()),
        ],
      );
    }

    final int nextIndex = stops.indexWhere(
      (IslandStop s) => s.state == IslandStopState.next,
    );
    final int selected = (_picked ?? (nextIndex < 0 ? 0 : nextIndex)).clamp(
      0,
      stops.length - 1,
    );
    final int doneCount = stops.where((IslandStop s) => s.isDone).length;

    return Column(
      children: <Widget>[
        _TopBar(title: title, done: doneCount, total: stops.length),
        Expanded(
          child: _IslandMap(
            stops: stops,
            selected: selected,
            onPick: (int index) => setState(() => _picked = index),
          ),
        ),
        _StopSheet(
          stop: stops[selected],
          onOpen: (ContentItemEntity item, ContentItemKind kind) =>
              _open(context, item, kind),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, AppError error) {
    if (error is NotFoundError) {
      return NotFoundView(
        message: error.message,
        onBack: context.canPop() ? context.pop : null,
        backLabel: 'Back home',
      );
    }
    return ErrorRetryView(
      error: error,
      onRetry: () => unawaited(
        ref
            .read(
              curriculumTreeControllerProvider(widget.curriculumId).notifier,
            )
            .refresh(),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    ContentItemEntity item,
    ContentItemKind kind,
  ) async {
    final String path = switch (kind) {
      ContentItemKind.video => AppRoutes.videoPath(item.id),
      ContentItemKind.document => AppRoutes.documentPath(item.id),
    };
    await context.push(path, extra: item.displayTitle(kind));
    // Coming back is when a star may have been earned: re-read the cache so
    // the stop turns green without a pull-to-refresh.
    if (mounted) {
      ref.invalidate(islandProgressProvider(widget.curriculumId));
    }
  }
}

TextStyle _fredoka(double size, {Color color = AppColors.ink}) =>
    GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: color,
    );

TextStyle _nunito(double size, {Color color = AppColors.ink}) =>
    GoogleFonts.nunito(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
    );

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.done, this.total});

  final String title;
  final int? done;
  final int? total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: <Widget>[
          Tooltip(
            message: 'Back',
            child: Clay(
              color: AppColors.white,
              lip: AppColors.seaLip,
              lipDepth: 4,
              shape: BoxShape.circle,
              semanticLabel: 'Back',
              onTap: () => context.canPop() ? context.pop() : null,
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Clay(
              color: AppColors.sun,
              lip: AppColors.sunLip,
              lipDepth: 4,
              child: SizedBox(
                height: 52,
                child: Center(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _fredoka(22),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (done != null && total != null) ...<Widget>[
            const SizedBox(width: 10),
            Semantics(
              label: '$done of $total done',
              child: ExcludeSemantics(
                child: Clay(
                  color: AppColors.white,
                  lip: AppColors.seaLip,
                  lipDepth: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.sun,
                          size: 24,
                        ),
                        const SizedBox(width: 2),
                        Text('$done/$total', style: _fredoka(18)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The path itself: stops zig-zag down a green island, joined by a sandy
/// track. Scrolls when a subject has more chapters than fit.
class _IslandMap extends StatelessWidget {
  const _IslandMap({
    required this.stops,
    required this.selected,
    required this.onPick,
  });

  final List<IslandStop> stops;
  final int selected;
  final ValueChanged<int> onPick;

  static const double _rowHeight = 132;
  static const double _stopSize = 64;
  static const double _nextSize = 76;

  /// Where along the width each row's stop sits — a gentle zig-zag.
  static const List<double> _lanes = <double>[0.28, 0.66, 0.42, 0.72, 0.3];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = stops.length * _rowHeight + 48;
        final List<Offset> centers = <Offset>[
          for (int i = 0; i < stops.length; i++)
            Offset(
              width * _lanes[i % _lanes.length],
              24 + _rowHeight * i + _rowHeight / 2 - 12,
            ),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CustomPaint(painter: _IslandPainter(centers)),
                  ),
                ),
                for (int i = 0; i < stops.length; i++)
                  _positionedStop(i, centers[i], width),
                if (_owlAt() case final int owl)
                  Positioned(
                    left: _owlLeft(centers[owl].dx, width),
                    top: centers[owl].dy - 40,
                    child: const ExcludeSemantics(child: OwlBuddy(size: 56)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int? _owlAt() {
    final int index = stops.indexWhere(
      (IslandStop s) => s.state == IslandStopState.next,
    );
    return index < 0 ? null : index;
  }

  /// The owl perches on whichever side of the next stop has more room.
  double _owlLeft(double x, double width) =>
      x < width / 2 ? x + _nextSize / 2 + 10 : x - _nextSize / 2 - 66;

  Widget _positionedStop(int index, Offset center, double width) {
    const double labelWidth = 140;
    return Positioned(
      left: (center.dx - labelWidth / 2).clamp(4, width - labelWidth - 4),
      top: center.dy - _nextSize / 2,
      width: labelWidth,
      child: _StopButton(
        stop: stops[index],
        selected: index == selected,
        size: stops[index].state == IslandStopState.next
            ? _nextSize
            : _stopSize,
        onTap: () => onPick(index),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({
    required this.stop,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final IslandStop stop;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color lip, Color ink) = switch (stop.state) {
      IslandStopState.done => (
        AppColors.leaf,
        AppColors.leafLip,
        AppColors.white,
      ),
      IslandStopState.next => (AppColors.sun, AppColors.sunLip, AppColors.ink),
      IslandStopState.ahead => (
        AppColors.white,
        AppColors.seaLip,
        AppColors.deepBlue,
      ),
    };
    final String stateLabel = switch (stop.state) {
      IslandStopState.done => 'done',
      IslandStopState.next => 'up next',
      IslandStopState.ahead => 'new',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 76 + 6,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Semantics(
              selected: selected,
              child: Clay(
                color: fill,
                lip: lip,
                shape: BoxShape.circle,
                semanticLabel: '${stop.name}, $stateLabel',
                border: Border.all(
                  color: selected ? AppColors.ink : AppColors.white,
                  width: selected ? 4 : 5,
                ),
                onTap: onTap,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Center(
                    child: stop.isDone
                        ? const Icon(
                            Icons.star_rounded,
                            color: AppColors.white,
                            size: 32,
                          )
                        : Text(
                            '${stop.number}',
                            style: _fredoka(24, color: ink),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stop.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _nunito(14),
            ),
          ),
        ),
      ],
    );
  }
}

/// The island body and the sandy track between the stops.
class _IslandPainter extends CustomPainter {
  const _IslandPainter(this.centers);

  final List<Offset> centers;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect island = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 4, size.width - 28, size.height - 12),
      const Radius.circular(72),
    );
    canvas
      ..drawRRect(island, Paint()..color = AppColors.grass)
      ..drawRRect(
        island,
        Paint()
          ..color = AppColors.grassEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      )
      ..drawRRect(island.deflate(14), Paint()..color = AppColors.grassLight);

    if (centers.length > 1) {
      final Path track = Path()..moveTo(centers.first.dx, centers.first.dy);
      for (int i = 1; i < centers.length; i++) {
        final Offset a = centers[i - 1];
        final Offset b = centers[i];
        final double midY = (a.dy + b.dy) / 2;
        track.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
      }
      canvas
        ..drawPath(
          track,
          Paint()
            ..color = AppColors.sand
            ..style = PaintingStyle.stroke
            ..strokeWidth = 22
            ..strokeCap = StrokeCap.round,
        )
        ..drawPath(
          track,
          Paint()
            ..color = AppColors.sandDash
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round,
        );
    }

    // A couple of trees on the shore, for the sense of place.
    for (final Offset tree in <Offset>[
      Offset(size.width - 44, 70),
      Offset(40, size.height - 70),
    ]) {
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(tree.dx - 4, tree.dy, 8, 24),
            const Radius.circular(3),
          ),
          Paint()..color = AppColors.bark,
        )
        ..drawCircle(tree.translate(0, -4), 18, Paint()..color = AppColors.leaf)
        ..drawCircle(
          tree.translate(-9, 3),
          11,
          Paint()..color = AppColors.leafDark,
        );
    }
  }

  @override
  bool shouldRepaint(_IslandPainter oldDelegate) =>
      oldDelegate.centers.length != centers.length ||
      !_sameCenters(oldDelegate.centers);

  bool _sameCenters(List<Offset> other) {
    for (int i = 0; i < centers.length; i++) {
      if (centers[i] != other[i]) {
        return false;
      }
    }
    return true;
  }
}

/// The picked chapter, with its two big buttons.
class _StopSheet extends StatelessWidget {
  const _StopSheet({required this.stop, required this.onOpen});

  final IslandStop stop;
  final void Function(ContentItemEntity item, ContentItemKind kind) onOpen;

  @override
  Widget build(BuildContext context) {
    final ContentItemEntity? video = stop.nextVideo;
    final ContentItemEntity? document = stop.nextDocument;

    return AnimatedSwitcher(
      duration: AppConstants.animationDuration,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
            child: FadeTransition(opacity: animation, child: child),
          ),
      child: Container(
        key: ValueKey<String>(stop.node.id),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x2E0A5E8C),
              blurRadius: 30,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: stop.isDone ? AppColors.leaf : AppColors.sun,
                    shape: BoxShape.circle,
                  ),
                  child: stop.isDone
                      ? const Icon(Icons.star_rounded, color: AppColors.white)
                      : Text('${stop.number}', style: _fredoka(20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      stop.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _fredoka(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                if (video != null)
                  Expanded(
                    child: _BigAction(
                      label: 'Watch',
                      semanticLabel:
                          'Watch: ${video.displayTitle(ContentItemKind.video)}',
                      icon: Icons.play_arrow_rounded,
                      fill: AppColors.coral,
                      lip: AppColors.coralLip,
                      onTap: () => onOpen(video, ContentItemKind.video),
                    ),
                  ),
                if (video != null && document != null)
                  const SizedBox(width: 12),
                if (document != null)
                  Expanded(
                    child: _BigAction(
                      label: 'Do it',
                      semanticLabel:
                          'Do it: '
                          '${document.displayTitle(ContentItemKind.document)}',
                      icon: Icons.edit_rounded,
                      fill: AppColors.grape,
                      lip: AppColors.grapeLip,
                      onTap: () => onOpen(document, ContentItemKind.document),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BigAction extends StatelessWidget {
  const _BigAction({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.fill,
    required this.lip,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final Color fill;
  final Color lip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Clay(
      color: fill,
      lip: lip,
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: SizedBox(
        height: 120,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fill, size: 34),
              ),
              const SizedBox(height: 8),
              Text(label, style: _fredoka(18, color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The curriculum is entitled but nothing is published in it yet (§6.4) —
/// told the way the rest of Play talks, with the owl and few words.
class _EmptyIsland extends StatelessWidget {
  const _EmptyIsland();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const OwlBuddy(size: 120),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Nothing here yet!',
              style: _fredoka(26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'New lessons are coming soon.',
              style: _nunito(17, color: AppColors.playTextMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
