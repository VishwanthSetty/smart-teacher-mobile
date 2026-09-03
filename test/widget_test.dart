import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_teacher_mobile/src/app.dart';
import 'package:smart_teacher_mobile/src/core/storage/token_storage.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:smart_teacher_mobile/src/features/auth/presentation/role_selection_screen.dart';

import 'support/fake_token_storage.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        ],
        child: const SmartTeacherApp(),
      ),
    );

    // First frame, before the session restore resolves: the router parks on
    // the splash screen rather than guessing which side of the gate to show.
    expect(find.text('Smart Teacher'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Once storage answers "no session", the gate takes over (PRD §6.6).
    await tester.pumpAndSettle();
    expect(find.byType(RoleSelectionScreen), findsOneWidget);
  });
}

