import 'package:flutter/material.dart';

/// The Smart Teacher palette — "one brand, three registers" (the Claude design
/// canvas *Smart Teacher Playful UI*, style-guide artboard).
///
/// Prefer `Theme.of(context).colorScheme` in widgets; reach for these only when
/// a value is genuinely brand-fixed (a hero card, a subject colour, a clay lip).
///
/// The older names (`sky50`…`navy`, `textPrimary`…) are kept and remapped onto
/// the Brinda core, so every screen that already used them moves with the
/// brand rather than keeping the previous blue.
class AppColors {
  const AppColors._();

  // ── Brand core, from the Brinda wave ──────────────────────────────────────
  /// Kids' text colour.
  static const Color ink = Color(0xFF1B2340);

  /// Fills and the Play register's accents.
  static const Color brindaBlue = Color(0xFF1FA3DC);

  /// Decoration only (the wave) — never text.
  static const Color waveSky = Color(0xFF7CC9EA);

  /// The Play register's ground.
  static const Color cloud = Color(0xFFEAF7FD);

  /// The pale wave fill and the selected-tab pill.
  static const Color mist = Color(0xFFD3EFFB);

  /// Primary actions; white text on it passes contrast.
  static const Color deepBlue = Color(0xFF0A75AA);

  /// Darker Deep Blue for selected labels and pressed states.
  static const Color deepBlueDark = Color(0xFF0A5E8C);

  /// Hero cards and the teacher's lead tiles.
  static const Color brandNavy = Color(0xFF0F2B5B);

  /// Muted text on navy.
  static const Color onNavyMuted = Color(0xFFBFD6EE);

  // ── Focus / Teach neutrals ────────────────────────────────────────────────
  /// The Focus and Teach registers' ground.
  static const Color ground = Color(0xFFF4F8FB);
  static const Color line = Color(0xFFE4ECF3);
  static const Color fieldBorder = Color(0xFFDCE6EF);
  static const Color track = Color(0xFFD7E2EC);
  static const Color focusText = Color(0xFF14213D);
  static const Color focusTextMuted = Color(0xFF4D5B73);
  static const Color focusTextSubtle = Color(0xFF5A6780);
  static const Color playTextMuted = Color(0xFF3C4A6B);
  static const Color playLip = Color(0xFFC9E6F3);

  // ── Play palette: one colour per subject, each with its clay lip ─────────
  static const Color coral = Color(0xFFFF7657);
  static const Color coralLip = Color(0xFFD44E33);
  static const Color sun = Color(0xFFFFC53D);
  static const Color sunLip = Color(0xFFE0A21C);
  static const Color sunPale = Color(0xFFFFF1C4);
  static const Color sunInk = Color(0xFF7A5200);
  static const Color leaf = Color(0xFF3DBE7A);
  static const Color leafLip = Color(0xFF279A5C);
  static const Color grape = Color(0xFF8B6CF0);
  static const Color grapeLip = Color(0xFF6849D1);
  static const Color bubblegum = Color(0xFFFF8FC1);
  static const Color bubblegumLip = Color(0xFFDB6A9E);

  // ── Subject island map (Play) ────────────────────────────────────────────
  static const Color sea = Color(0xFFBFE6F7);
  static const Color seaLip = Color(0xFF8CCBE6);
  static const Color grass = Color(0xFF9ED98B);
  static const Color grassEdge = Color(0xFF6FBF5E);
  static const Color grassLight = Color(0xFFB7E6A0);
  static const Color sand = Color(0xFFFFF3D1);
  static const Color sandDash = Color(0xFFE8C98A);
  static const Color bark = Color(0xFF8A5A2B);
  static const Color leafDark = Color(0xFF2FA866);

  // ── Status chips (tint + ink pairs that pass 4.5:1) ──────────────────────
  static const Color doneGreen = Color(0xFF1E9E5A);
  static const Color doneTint = Color(0xFFDDF4E7);
  static const Color doneInk = Color(0xFF1E7A49);
  static const Color overdueTint = Color(0xFFFDE4DE);
  static const Color overdueInk = Color(0xFFB23A21);
  static const Color videoTint = Color(0xFFE1F3FB);
  static const Color docTint = Color(0xFFEDE7FF);
  static const Color badge = Color(0xFFE2553A);

  // ── Compatibility names, remapped onto the brand ─────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color sky50 = cloud;
  static const Color sky100 = mist;
  static const Color sky200 = Color(0xFFB4DFF3);
  static const Color sky300 = Color(0xFF9AD4EE);
  static const Color sky400 = waveSky;
  static const Color blue = deepBlue;
  static const Color navy = brandNavy;

  static const Color textPrimary = focusText;
  static const Color textSecondary = focusTextMuted;
  static const Color textDisabled = Color(0xFF93A2B0);

  static const Color darkBackground = Color(0xFF0A1929);
  static const Color darkSurface = Color(0xFF12263A);
  static const Color darkOutline = Color(0xFF1B3A5C);
  static const Color darkText = Color(0xFFE8F1FA);

  static const Color success = doneInk;
  static const Color warning = sunLip;
  static const Color danger = Color(0xFFD32F2F);
}

/// A subject's Play colour: its fill, the clay lip under it, and the colours
/// that read on it.
@immutable
class SubjectSwatch {
  const SubjectSwatch({
    required this.fill,
    required this.lip,
    required this.label,
    required this.glyphInk,
  });

  final Color fill;
  final Color lip;

  /// Text drawn directly on [fill].
  final Color label;

  /// The glyph inside the white disc on the tile.
  final Color glyphInk;

  /// Cycled by position so neighbouring tiles never share a colour.
  static const List<SubjectSwatch> play = <SubjectSwatch>[
    SubjectSwatch(
      fill: AppColors.coral,
      lip: AppColors.coralLip,
      label: AppColors.white,
      glyphInk: AppColors.coralLip,
    ),
    SubjectSwatch(
      fill: AppColors.sun,
      lip: AppColors.sunLip,
      label: AppColors.ink,
      glyphInk: Color(0xFF8A5A00),
    ),
    SubjectSwatch(
      fill: AppColors.leaf,
      lip: AppColors.leafLip,
      label: AppColors.white,
      glyphInk: AppColors.doneInk,
    ),
    SubjectSwatch(
      fill: AppColors.grape,
      lip: AppColors.grapeLip,
      label: AppColors.white,
      glyphInk: AppColors.grapeLip,
    ),
    SubjectSwatch(
      fill: AppColors.brindaBlue,
      lip: AppColors.deepBlue,
      label: AppColors.white,
      glyphInk: AppColors.deepBlue,
    ),
    SubjectSwatch(
      fill: AppColors.bubblegum,
      lip: AppColors.bubblegumLip,
      label: AppColors.ink,
      glyphInk: Color(0xFFB24A7C),
    ),
  ];

  /// The Focus register's quieter tint/ink pairs, same order as [play].
  static const List<(Color tint, Color ink)> focus = <(Color, Color)>[
    (Color(0xFFFFE6DF), Color(0xFFC2410C)),
    (AppColors.docTint, AppColors.grapeLip),
    (AppColors.videoTint, AppColors.deepBlue),
    (AppColors.doneTint, AppColors.doneInk),
    (AppColors.sunPale, AppColors.sunInk),
    (Color(0xFFFFE3F0), Color(0xFFB24A7C)),
  ];

  static SubjectSwatch playAt(int index) => play[index % play.length];

  static (Color, Color) focusAt(int index) => focus[index % focus.length];
}
