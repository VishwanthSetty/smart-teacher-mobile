import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Selects a tab in the role-based shell.
///
/// Both shells now open on **Home** (mobile plan §1), so a test that wants the
/// Library, My Classes or Profile tab has to ask for it. Before the Home tab
/// existed those screens happened to be the landing tab, and several tests
/// relied on that implicitly — this helper makes the navigation explicit
/// rather than leaving it to tab ordering that will change again when Tasks
/// and Saved land in phases 3 and 4.
Future<void> openShellTab(WidgetTester tester, String label) async {
  final Finder destination = find.widgetWithText(NavigationDestination, label);
  expect(
    destination,
    findsOneWidget,
    reason: 'the shell should offer a "$label" tab',
  );
  await tester.tap(destination);
  await tester.pumpAndSettle();
}
