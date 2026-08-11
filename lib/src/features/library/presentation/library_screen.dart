import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_view.dart';

/// The Library tab (PRD §5.4) — the shared browsing surface, and the only tab
/// both shells have in common (§5.7).
///
/// Placeholder for now; this is the next feature to be built. It will list
/// `GET /curricula` — already narrowed server-side to the caller's
/// entitlements, and for a student to their enrolled grade (§4) — and open a
/// curriculum's tree from `GET /curricula/:id/tree`. An entitled-but-empty
/// school is a legitimate zero-content state, not an error (§6.4), so this
/// screen owes a first-class empty state rather than the placeholder below.
///
/// Renders a body, not a `Scaffold`: the shell owns the app bar and the tab
/// bar (see `AppShell`).
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonView(
      icon: Icons.local_library_outlined,
      title: 'Library',
      description: 'Browse the curricula, videos and documents your school '
          'has access to.',
    );
  }
}
