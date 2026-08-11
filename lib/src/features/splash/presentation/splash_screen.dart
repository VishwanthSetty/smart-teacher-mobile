import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

/// Shown while the app determines whether a valid session exists.
///
/// Deliberately passive: it renders, and nothing more. `SessionController`
/// reads secure storage and the router's redirect (PRD §6.6) moves off this
/// screen the moment the answer arrives — including forwarding to a deep link
/// that landed mid-startup. Don't add navigation logic here; it belongs in
/// the one redirect.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
