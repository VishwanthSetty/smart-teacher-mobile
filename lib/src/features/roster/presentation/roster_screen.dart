import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_view.dart';

/// The teacher's "Roster" tab (PRD §5.5.2).
///
/// Placeholder. It will be the searchable, section-filterable, **paginated**
/// `GET /students` list — the only paginated endpoint in the API (§6.5), so it
/// is also where the shared paginated-list widget gets built. Strictly
/// read-only: no create/edit/deactivate affordance exists for a TEACHER.
///
/// Renders a body, not a `Scaffold`: the shell owns the app bar and the tab
/// bar (see `AppShell`).
class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.people_outline,
      title: 'Roster',
      description: 'Search and browse the students in your school.',
    );
  }
}
