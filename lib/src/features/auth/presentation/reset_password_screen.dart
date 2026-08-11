import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import 'auth_validators.dart';
import 'password_strength.dart';
import 'reset_password_controller.dart';
import 'reset_password_state.dart';
import 'retry_countdown.dart';
import 'widgets/auth_banner.dart';
import 'widgets/password_strength_meter.dart';

/// Set a new password (PRD §5.1.4).
///
/// Entered by deep link from the reset email, so [token] comes off the query
/// string — the router already parses it, though the deep-link *registration*
/// itself is still an open backend question (PRD §9.2) and is not wired up
/// here. A null token means the link was malformed, and the screen says so
/// rather than presenting a form that cannot work.
///
/// On success every session for that user is revoked server-side, so this
/// routes to `/login` and never back into the app.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.token, super.key});

  final String? token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _validateOnChange = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String? token = widget.token;
    if (token == null) {
      return;
    }

    setState(() => _validateOnChange = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    final bool changed =
        await ref.read(resetPasswordControllerProvider.notifier).submit(
              token: token,
              password: _passwordController.text,
            );

    if (!changed || !mounted) {
      return;
    }

    // Every session is gone server-side and the controller has already ended
    // the local one, so there is nothing to return to but the sign-in screen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed. Sign in with your new password.'),
      ),
    );
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final ResetPasswordState state = ref.watch(resetPasswordControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: widget.token == null
                  ? const _DeadLink(
                      message: 'This reset link is incomplete. Request a new '
                          'one to continue.',
                    )
                  : state.isLinkDead
                      ? _DeadLink(message: state.failure!.message)
                      : _buildForm(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ResetPasswordState state) {
    final ThemeData theme = Theme.of(context);

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _validateOnChange
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        onChanged: () {
          ref.read(resetPasswordControllerProvider.notifier).clearFailure();
          // Repaints the strength meter and re-runs the confirmation check
          // against the new value.
          setState(() {});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Choose a new password', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Setting a new password signs you out everywhere, on every '
              'device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            if (state.failure case final ResetPasswordFailure failure) ...
                <Widget>[
              _ResetFailureBanner(
                failure: failure,
                lockoutRemaining: state.lockoutRemaining,
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip:
                      _obscurePassword ? 'Show password' : 'Hide password',
                ),
                helperText: 'At least $minPasswordLength characters.',
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.newPassword],
              validator: validateNewPassword,
            ),
            PasswordStrengthMeter(password: _passwordController.text),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.newPassword],
              validator: (String? value) => validatePasswordConfirmation(
                value,
                _passwordController.text,
              ),
              onFieldSubmitted: (String _) => _submit(),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            FilledButton(
              onPressed: state.canSubmit ? _submit : null,
              child: state.isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Set new password'),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            TextButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => context.go(AppRoutes.login),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of the form when no password typed into it could work: the
/// link carried no token, or the server has rejected the one it did carry.
class _DeadLink extends StatelessWidget {
  const _DeadLink({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthBanner(
          message: message,
          tone: AuthBannerTone.error,
          icon: Icons.link_off_outlined,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        FilledButton(
          onPressed: () => context.go(AppRoutes.forgotPassword),
          child: const Text('Request a new link'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }
}

/// Maps a [ResetPasswordFailure] onto the shared [AuthBanner].
class _ResetFailureBanner extends StatelessWidget {
  const _ResetFailureBanner({
    required this.failure,
    this.lockoutRemaining,
  });

  final ResetPasswordFailure failure;
  final Duration? lockoutRemaining;

  @override
  Widget build(BuildContext context) {
    return AuthBanner(
      message: _message,
      tone: failure is TooManyResetAttempts
          ? AuthBannerTone.waiting
          : AuthBannerTone.error,
      details: switch (failure) {
        ResetPasswordRejected(fieldErrors: final List<String> fieldErrors) =>
          fieldErrors,
        _ => const <String>[],
      },
      icon: failure is ResetPasswordNetworkFailure
          ? Icons.wifi_off_outlined
          : null,
    );
  }

  String get _message {
    final Duration? remaining = lockoutRemaining;
    if (failure is! TooManyResetAttempts || remaining == null) {
      return failure.message;
    }
    return 'Too many attempts. Try again in ${formatRetryWait(remaining)}.';
  }
}
