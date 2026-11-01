import 'package:flutter/material.dart';

/// What a subject tile draws in its disc: a short text glyph (`Aa`, `123`) or
/// an icon — from the style guide's subject icon set, which uses these as
/// placeholders until the illustrated set is generated.
///
/// Matched on the subject's *name*, because that is all the curriculum row
/// carries; anything unrecognised gets its initials, never a wrong picture.
@immutable
class SubjectGlyph {
  const SubjectGlyph.text(String this.text) : icon = null;

  const SubjectGlyph.icon(IconData this.icon) : text = null;

  factory SubjectGlyph.forSubject(String subjectName) {
    final String name = subjectName.toLowerCase();
    bool has(List<String> words) => words.any(name.contains);

    if (has(<String>['math', 'number', 'ganit'])) {
      return const SubjectGlyph.text('123');
    }
    if (has(<String>['rhyme', 'music', 'song'])) {
      return const SubjectGlyph.icon(Icons.music_note_rounded);
    }
    if (has(<String>['story', 'stories', 'reading'])) {
      return const SubjectGlyph.icon(Icons.menu_book_rounded);
    }
    if (has(<String>['art', 'draw', 'craft', 'colour', 'color'])) {
      return const SubjectGlyph.icon(Icons.brush_rounded);
    }
    if (has(<String>['science', 'physics', 'chemistry', 'biology'])) {
      return const SubjectGlyph.icon(Icons.science_rounded);
    }
    if (has(<String>['evs', 'environment', 'world', 'nature'])) {
      return const SubjectGlyph.icon(Icons.eco_rounded);
    }
    if (has(<String>['social', 'history', 'geography', 'civics'])) {
      return const SubjectGlyph.icon(Icons.public_rounded);
    }
    if (has(<String>['computer', 'coding', 'ict'])) {
      return const SubjectGlyph.icon(Icons.computer_rounded);
    }
    if (has(<String>[
      'english',
      'hindi',
      'kannada',
      'telugu',
      'tamil',
      'sanskrit',
      'language',
      'abc',
      'phonics',
    ])) {
      return const SubjectGlyph.text('Aa');
    }

    final List<String> words = subjectName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return const SubjectGlyph.icon(Icons.auto_stories_rounded);
    }
    final String initials = words.length == 1
        ? words.first.substring(0, words.first.length.clamp(0, 2))
        : '${words[0][0]}${words[1][0]}';
    return SubjectGlyph.text(
      initials.substring(0, 1).toUpperCase() + initials.substring(1),
    );
  }

  final String? text;
  final IconData? icon;

  Widget build({
    required Color color,
    required double iconSize,
    required TextStyle textStyle,
  }) {
    if (icon case final IconData data) {
      return Icon(data, size: iconSize, color: color);
    }
    return Text(text ?? '', style: textStyle.copyWith(color: color));
  }
}
