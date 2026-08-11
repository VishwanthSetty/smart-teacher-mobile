import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import 'auth_validators.dart';
import 'login_controller.dart';
import 'login_state.dart';
import 'retry_countdown.dart';
import 'widgets/auth_banner.dart';

/// Login (PRD §5.1.1): email, password, school slug.
///
/// The slug is a first-class credential, not a setting — email is unique per
/// school, not globally, so the same address can exist in two tenants.
///
/// There is no navigation code here. A successful submit opens the session and
/// the router's redirect moves off this route (PRD §6.6); see
/// [LoginController].
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schoolSlugController = TextEditingController();

  bool _obscurePassword = true;

  /// Off until the first submit, so the form doesn't turn red while a user is
  /// still typing their first character.
  bool _validateOnChange = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _schoolSlugController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _validateOnChange = true);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Dismiss the keyboard so the error banner isn't hidden behind it.
    FocusScope.of(context).unfocus();

    await ref.read(loginControllerProvider.notifier).submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          schoolSlug: _schoolSlugController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final LoginState state = ref.watch(loginControllerProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _validateOnChange
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  onChanged: () =>
                      ref.read(loginControllerProvider.notifier).clearFailure(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        'Sign in to continue',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                      if (state.failure case final LoginFailure failure) ...<Widget>[
                        _LoginFailureBanner(
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
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.password],
                        validator: validateExistingPassword,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      TextFormField(
                        controller: _schoolSlugController,
                        decoration: const InputDecoration(
                          labelText: 'School code',
                          prefixIcon: Icon(Icons.school_outlined),
                          helperText: 'Ask your school admin if you’re unsure.',
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      TextButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => context.go(AppRoutes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps a [LoginFailure] onto the shared [AuthBanner].
class _LoginFailureBanner extends StatelessWidget {
  const _LoginFailureBanner({
    required this.failure,
    this.lockoutRemaining,
  });

  final LoginFailure failure;
  final Duration? lockoutRemaining;

  @override
  Widget build(BuildContext context) {
    return AuthBanner(
      message: _message,
      // Waiting out a lockout isn't the same kind of event as a rejected
      // credential — it reads as "not yet", not "wrong".
      tone: failure is TooManyAttempts
          ? AuthBannerTone.waiting
          : AuthBannerTone.error,
      details: switch (failure) {
        LoginRejected(fieldErrors: final List<String> fieldErrors) =>
          fieldErrors,
        _ => const <String>[],
      },
      icon: switch (failure) {
        SchoolSuspended() || AccountDisabled() => Icons.block_outlined,
        LoginNetworkFailure() => Icons.wifi_off_outlined,
        _ => null,
      },
    );
  }

  /// The countdown is appended rather than baked into the failure so the
  /// message updates every second without rebuilding the failure itself.
  String get _message {
    final Duration? remaining = lockoutRemaining;
    if (failure is! TooManyAttempts || remaining == null) {
      return failure.message;
    }
    return 'Too many sign-in attempts. Try again in '
        '${formatRetryWait(remaining)}.';
  }
}
