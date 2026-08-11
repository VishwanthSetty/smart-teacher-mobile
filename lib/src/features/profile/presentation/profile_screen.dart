import 'package:flutter/material.dart';

import 'profile_view.dart';

/// Profile / "Me" as a standalone route (`/profile`).
///
/// All of the content — and all of the §5.2 behaviour, including the
/// suspended-school takeover — lives in [ProfileView]; this only adds the
/// chrome a standalone route needs. The student shell (§5.7) renders
/// [ProfileView] directly as a tab instead, under the shell's own app bar.
///
/// The route stays even though students reach the profile as a tab: for a
/// teacher, whose tab set is My Classes · Roster · Library, this is where the
/// shell's profile action pushes to, and it is the only way to reach sign-out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const SafeArea(child: ProfileView()),
    );
  }
}
