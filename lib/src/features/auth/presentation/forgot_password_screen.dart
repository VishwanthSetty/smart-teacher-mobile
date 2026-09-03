import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import 'auth_validators.dart';
import 'forgot_password_controller.dart';
import 'forgot_password_state.dart';
import 'retry_countdown.dart';
import 'widgets/auth_banner.dart';

/// Reset request (PRD §5.1.4): email + school slug → `POST
/// /auth/forgot-password`.
///
/// The confirmation is deliberately conditional — "if an account exists" —
/// and identical whether or not one does. See [ForgotPasswordController] for
/// which outcomes are folded into it.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _schoolSlugController = TextEditingController();

  bool _validateOnChange = false;

  @override
  void dispose() {
    _emailController.dispose();
    _schoolSlugController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _validateOnChange = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(forgotPasswordControllerProvider.notifier).submit(
          email: _emailController.text.trim(),
          schoolSlug: _schoolSlugController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordState state =
        ref.watch(forgotPasswordControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: state.isSent
                  ? _SentConfirmation(email: _emailController.text.trim())
                  : _buildForm(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ForgotPasswordState state) {
    final ThemeData theme = Theme.of(context);

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _validateOnChange
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        onChanged: () =>
            ref.read(forgotPasswordControllerProvider.notifier).clearFailure(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Reset your password',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Tell us the email and school code you sign in with, and we’ll '
              'send a link to set a new password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            if (state.failure case final ForgotPasswordFailure failure) ...
                <Widget>[
              _ForgotFailureBanner(
                failure: failure,
                lockoutRemaining: state.lockoutRemaining,
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              autofillHints: const <String>[AutofillHints.email],
              validator: validateEmailField,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _schoolSlugController,
              decoration: const InputDecoration(
                labelText: 'School code',
                prefixIcon: Icon(Icons.school_outlined),
                helperText: 'The same code you use to sign in.',
              ),
              textInputAction: TextInputAction.done,
              autocorrect: false,
              validator: validateSchoolSlugField,
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
                  : const Text('Send reset link'),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            TextButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => context.go(AppRoutes.roleSelection),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown after any outcome the app treats as "the request went through".
///
/// The wording never confirms that an account exists, and never claims an
/// email *was* sent — only that one is on its way if there was somewhere to
/// send it.
class _SentConfirmation extends ConsumerWidget {
  const _SentConfirmation({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const AuthBanner(
          message: 'If that account exists, a reset link is on its way.',
          tone: AuthBannerTone.success,
          icon: Icons.mark_email_read_outlined,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Text(
          'Check the inbox for $email, including the spam folder. The link '
          'expires, so use it soon.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        FilledButton(
          onPressed: () => context.go(AppRoutes.roleSelection),
          child: const Text('Back to sign in'),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextButton(
          onPressed: () => ref
              .read(forgotPasswordControllerProvider.notifier)
              .editRequest(),
          child: const Text('Use a different email'),
        ),
      ],
    );
  }
}

/// Maps a [ForgotPasswordFailure] onto the shared [AuthBanner].
class _ForgotFailureBanner extends StatelessWidget {
  const _ForgotFailureBanner({
    required this.failure,
    this.lockoutRemaining,
  });

  final ForgotPasswordFailure failure;
  final Duration? lockoutRemaining;

  @override
  Widget build(BuildContext context) {
    return AuthBanner(
      message: _message,
      tone: failure is TooManyResetRequests
          ? AuthBannerTone.waiting
          : AuthBannerTone.error,
      details: switch (failure) {
        ForgotPasswordRejected(fieldErrors: final List<String> fieldErrors) =>
          fieldErrors,
        _ => const <String>[],
      },
      icon: failure is ForgotPasswordNetworkFailure
          ? Icons.wifi_off_outlined
          : null,
    );
  }

  String get _message {
    final Duration? remaining = lockoutRemaining;
    if (failure is! TooManyResetRequests || remaining == null) {
      return failure.message;
    }
    return "You've asked for a reset link a few times already. Try again in "
        '${formatRetryWait(remaining)}.';
  }
}

