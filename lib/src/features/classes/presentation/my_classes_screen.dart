import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_view.dart';

/// The teacher's "My Classes" tab (PRD §5.5.1).
///
/// Placeholder. It will list `GET /teacher-assignments` — the grade/section/
/// subject rows assigned to the signed-in teacher — and is the source of the
/// `sectionId` values the roster screen (§5.5.2) filters by.
///
/// Not to be confused with the demo `classes` feature deleted when this repo
/// was repointed at the PRD: that one had its own repository, model and detail
/// route and was unrelated to `/teacher-assignments`. Nothing of it survives
/// here.
///
/// Renders a body, not a `Scaffold`: the shell owns the app bar and the tab
/// bar (see `AppShell`).
class MyClassesScreen extends StatelessWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.class_outlined,
      title: 'My Classes',
      description: 'The grades, sections and subjects assigned to you.',
    );
  }
}
