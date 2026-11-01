import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/student_age_band.dart';
import '../../../../core/widgets/brand/brinda_wave.dart';
import '../../../../core/widgets/brand/clay.dart';
import '../../../../core/widgets/brand/owl_buddy.dart';
import '../../../activity/domain/resource_activity_entity.dart';
import '../../../library/domain/curriculum_entity.dart';
import '../../../library/presentation/library_controller.dart';
import '../../domain/home_entity.dart';
import 'continue_rail.dart';
import 'subject_glyph.dart';

/// Student Home in the **Play** register — Little Learners, Pre-primary to
/// Grade 5 (design canvas: "Little Learners · Home").
///
/// Big clay targets (64 px+), the owl buddy, one colour per subject, and
/// progress as dots, never percentages. Everything it draws comes from data the
/// app already has: the Today card is the first in-progress resource from
/// `/home/student`, and the subject grid is the student's own curricula. The
/// design's star count is not drawn — there is no stars or rewards data behind
/// it, and a number nobody earned would be an invention.
class PlayStudentHome extends ConsumerStatefulWidget {
  const PlayStudentHome({
    required this.home,
    required this.ageBand,
    this.studentName,
    this.classLabel,
    super.key,
  });

  final StudentHomeEntity home;
  final StudentAgeBand ageBand;
  final String? studentName;
  final String? classLabel;

  @override
  ConsumerState<PlayStudentHome> createState() => _PlayStudentHomeState();
}

class _PlayStudentHomeState extends ConsumerState<PlayStudentHome> {
  int _message = 0;

  String? get _firstName {
    final String name = widget.studentName?.trim() ?? '';
    return name.isEmpty ? null : name.split(RegExp(r'\s+')).first;
  }

  List<String> get _messages => <String>[
    if (_firstName case final String name)
      'Hi $name! Ready to play?'
    else
      'Hi! Ready to play?',
    'Tap a colour to start!',
    if (widget.home.continueLearning.isNotEmpty)
      'Your yellow card is waiting!'
    else
      'Pick a subject below!',
    'Learning is fun. Let’s go!',
  ];

  @override
  Widget build(BuildContext context) {
    final List<ResourceActivityEntity> continueLearning =
        widget.home.continueLearning;
    final AsyncValue<List<CurriculumEntity>> library = ref.watch(
      libraryControllerProvider,
    );
    final List<CurriculumEntity> subjects =
        library.value ?? const <CurriculumEntity>[];
    final List<ResourceActivityEntity> playAgain = widget.home.recent
        .take(6)
        .toList(growable: false);
    // Nothing to tap at all — no Today card, no subjects (once the library
    // has answered), nothing to replay. An unplaced student lands here by
    // design, so the copy explains rather than reading as an error.
    final bool nothingYet =
        continueLearning.isEmpty &&
        playAgain.isEmpty &&
        subjects.isEmpty &&
        !library.isLoading;

    return ColoredBox(
      color: AppColors.cloud,
      child: Stack(
        children: <Widget>[
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 260,
            child: BrindaWave(withSun: true),
          ),
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: <Widget>[
              _PlayHeader(
                firstName: _firstName,
                classLabel: widget.classLabel,
                titleSize: widget.ageBand == StudentAgeBand.explorers ? 30 : 26,
              ),
              const SizedBox(height: 14),
              _OwlRow(
                message: _messages[_message % _messages.length],
                onOwlTap: () => setState(() => _message++),
              ),
              if (continueLearning.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                _TodayCard(activity: continueLearning.first),
              ],
              if (nothingYet) ...<Widget>[
                const SizedBox(height: 18),
                Text(
                  'Nothing here yet',
                  textAlign: TextAlign.center,
                  style: _fredoka(22),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your class hasn't been set up yet — ask your teacher.",
                  textAlign: TextAlign.center,
                  style: _nunito(15, color: AppColors.playTextMuted),
                ),
              ],
              if (subjects.isNotEmpty) ...<Widget>[
                const SizedBox(height: 22),
                const _PlayHeading('Let’s learn'),
                const SizedBox(height: 10),
                _SubjectGrid(
                  subjects: subjects,
                  tileHeight: widget.ageBand == StudentAgeBand.explorers
                      ? 128
                      : 112,
                ),
              ],
              if (playAgain.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                const _PlayHeading('Play again'),
                const SizedBox(height: 10),
                for (final ResourceActivityEntity activity in playAgain)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PlayAgainRow(activity: activity),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
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

class _PlayHeading extends StatelessWidget {
  const _PlayHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Semantics(header: true, child: Text(text, style: _fredoka(22))),
  );
}

class _PlayHeader extends StatelessWidget {
  const _PlayHeader({
    required this.firstName,
    required this.classLabel,
    required this.titleSize,
  });

  final String? firstName;
  final String? classLabel;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final String initial = (firstName ?? '').isEmpty
        ? '★'
        : firstName!.substring(0, 1).toUpperCase();

    return Row(
      children: <Widget>[
        ExcludeSemantics(
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 4),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: AppColors.coralLip, offset: Offset(0, 4)),
              ],
            ),
            child: Text(initial, style: _fredoka(24, color: AppColors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (classLabel case final String label when label.isNotEmpty)
                Text(label, style: _nunito(14, color: AppColors.playTextMuted)),
              Text(
                firstName == null ? 'Hi there!' : 'Hi, $firstName!',
                style: _fredoka(titleSize),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OwlRow extends StatelessWidget {
  const _OwlRow({required this.message, required this.onOwlTap});

  final String message;
  final VoidCallback onOwlTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        OwlBuddy(onTap: onOwlTap),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.elasticOut,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
                    alignment: Alignment.bottomLeft,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
              child: Container(
                key: ValueKey<String>(message),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                    bottomLeft: Radius.circular(6),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: AppColors.playLip, offset: Offset(0, 4)),
                  ],
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    style: GoogleFonts.fredoka(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The yellow **Today** card: the most recent in-progress resource, with
/// progress as four dots (style guide: "progress as dots and stars, never %").
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.activity});

  final ResourceActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final double? fraction = activity.progressFraction;
    final int filled = fraction == null
        ? 0
        : (fraction * 4).floor().clamp(0, 4);

    return Clay(
      color: AppColors.sun,
      lip: AppColors.sunLip,
      radius: 28,
      padding: const EdgeInsets.all(16),
      semanticLabel: '${activity.isVideo ? 'Play' : 'Open'} ${activity.title}',
      onTap: () => openActivity(context, activity),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Container(
              width: 96,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.sunPale,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const _ShapesArt(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TODAY',
                  style: _nunito(
                    13,
                    color: const Color(0xFF6B4A00),
                  ).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _fredoka(22),
                ),
                if (fraction != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Semantics(
                    label: '$filled of 4 done',
                    child: ExcludeSemantics(
                      child: Row(
                        children: <Widget>[
                          for (int i = 0; i < 4; i++)
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < filled
                                    ? AppColors.ink
                                    : AppColors.sunPale,
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ExcludeSemantics(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.coral,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: AppColors.coralLip, offset: Offset(0, 5)),
                ],
              ),
              child: Icon(
                activity.isVideo
                    ? Icons.play_arrow_rounded
                    : Icons.menu_book_rounded,
                size: 34,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The little shape friends inside the Today card — decoration only.
class _ShapesArt extends StatelessWidget {
  const _ShapesArt();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _ShapesPainter());
}

class _ShapesPainter extends CustomPainter {
  const _ShapesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 112, size.height / 100);
    final Paint outline = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawCircle(const Offset(34, 38), 20, Paint()..color = AppColors.coral)
      ..drawCircle(const Offset(34, 38), 20, outline)
      ..drawCircle(const Offset(29, 34), 3, Paint()..color = AppColors.ink)
      ..drawCircle(const Offset(40, 34), 3, Paint()..color = AppColors.ink)
      ..drawPath(
        Path()
          ..moveTo(28, 43)
          ..quadraticBezierTo(34, 48, 40, 43),
        outline..strokeWidth = 2.5,
      );
    outline.strokeWidth = 3;

    final Path triangle = Path()
      ..moveTo(70, 18)
      ..lineTo(94, 58)
      ..lineTo(46, 58)
      ..close();
    canvas
      ..drawPath(triangle, Paint()..color = AppColors.leaf)
      ..drawPath(triangle, outline)
      ..save()
      ..translate(35, 77)
      ..rotate(-0.14);
    final RRect square = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-13, -13, 26, 26),
      const Radius.circular(5),
    );
    canvas
      ..drawRRect(square, Paint()..color = AppColors.grape)
      ..drawRRect(square, outline)
      ..restore()
      ..drawLine(
        const Offset(64, 76),
        const Offset(94, 76),
        Paint()
          ..color = AppColors.brindaBlue
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_ShapesPainter oldDelegate) => false;
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid({required this.subjects, required this.tileHeight});

  final List<CurriculumEntity> subjects;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
        // Tile plus its 6 px lip.
        mainAxisExtent: tileHeight + 6,
      ),
      itemBuilder: (BuildContext context, int index) =>
          _SubjectTile(curriculum: subjects[index], index: index),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.curriculum, required this.index});

  final CurriculumEntity curriculum;
  final int index;

  @override
  Widget build(BuildContext context) {
    final SubjectSwatch swatch = SubjectSwatch.playAt(index);
    final SubjectGlyph glyph = SubjectGlyph.forSubject(curriculum.subjectName);
    final int count = curriculum.videoCount + curriculum.documentCount;
    final String name = curriculum.subjectName.trim().isEmpty
        ? 'Subject'
        : curriculum.subjectName.trim();

    return Clay(
      color: swatch.fill,
      lip: swatch.lip,
      padding: const EdgeInsets.all(6),
      semanticLabel: count == 1 ? '$name, 1 lesson' : '$name, $count lessons',
      onTap: () => context.push(
        AppRoutes.subjectIslandPath(curriculum.id),
        extra: curriculum.subjectName,
      ),
      child: ExcludeSemantics(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: glyph.build(
                      color: swatch.glyphInk,
                      iconSize: 30,
                      textStyle: _fredoka(20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _fredoka(17, color: swatch.label),
                  ),
                ],
              ),
            ),
            if (count > 0)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count', style: _nunito(13)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayAgainRow extends StatelessWidget {
  const _PlayAgainRow({required this.activity});

  final ResourceActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final bool video = activity.isVideo;

    return Clay(
      color: AppColors.white,
      lip: AppColors.playLip,
      radius: 22,
      lipDepth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      semanticLabel: activity.title,
      onTap: () => openActivity(context, activity),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: video ? AppColors.coral : AppColors.grape,
              shape: BoxShape.circle,
            ),
            child: Icon(
              video ? Icons.play_arrow_rounded : Icons.edit_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _fredoka(17).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (activity.isCompleted)
            const Icon(Icons.star_rounded, color: AppColors.sunLip, size: 28),
        ],
      ),
    );
  }
}
