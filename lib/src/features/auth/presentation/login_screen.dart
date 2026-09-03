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

/// Login stays navigation-free: opening the session drives the router gate.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.role});

  final String role;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schoolSlugController = TextEditingController();

  bool _obscurePassword = true;
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

    FocusScope.of(context).unfocus();
    await ref
        .read(loginControllerProvider.notifier)
        .submit(
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
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                      _LoginHero(role: widget.role),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.spacingMd,
                          AppConstants.spacingSm,
                          AppConstants.spacingMd,
                          AppConstants.spacingLg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Welcome back!',
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            Text(
                              'Sign in to continue learning',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            if (state.failure
                                case final LoginFailure failure) ...<Widget>[
                              _LoginFailureBanner(
                                failure: failure,
                                lockoutRemaining: state.lockoutRemaining,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                            ],
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppConstants.spacingSm,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    TextFormField(
                                      controller: _schoolSlugController,
                                      decoration: const InputDecoration(
                                        labelText: 'School code',
                                        prefixIcon: Icon(Icons.school_outlined),
                                        helperText:
                                            'Ask your teacher if you don\'t '
                                            'know it.',
                                      ),
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      validator: validateSchoolSlugField,
                                    ),
                                    const SizedBox(
                                      height: AppConstants.spacingSm,
                                    ),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(Icons.mail_outline),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                      ],
                                      validator: validateEmailField,
                                    ),
                                    const SizedBox(
                                      height: AppConstants.spacingSm,
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
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
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.password,
                                      ],
                                      validator: validateExistingPassword,
                                      onFieldSubmitted: (String _) => _submit(),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context.go(
                                                AppRoutes.forgotPassword,
                                              ),
                                        child: const Text('Forgot password?'),
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: state.canSubmit
                                          ? _submit
                                          : null,
                                      child: state.isSubmitting
                                          ? const SizedBox.square(
                                              dimension: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Sign in'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: role == 'teacher'
            ? Icon(
                Icons.school_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            : const _OwlMark(),
      ),
    );
  }
}

/// Code-native, so it stays crisp without shipping an invented image logo.
class _OwlMark extends StatelessWidget {
  const _OwlMark();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      image: true,
      label: 'Smart Teacher owl mascot',
      child: SizedBox(
        width: 116,
        height: 96,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              bottom: 4,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
            ),
            Positioned(
              top: 36,
              child: Container(
                width: 58,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.circle, size: 8),
                    Icon(Icons.circle, size: 8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              child: Transform.rotate(
                angle: -0.08,
                child: const Icon(Icons.school_rounded, size: 48),
              ),
            ),
            Positioned(
              right: 6,
              bottom: 14,
              child: Transform.rotate(
                angle: -0.4,
                child: Icon(
                  Icons.waving_hand_rounded,
                  size: 30,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFailureBanner extends StatelessWidget {
  const _LoginFailureBanner({required this.failure, this.lockoutRemaining});

  final LoginFailure failure;
  final Duration? lockoutRemaining;

  @override
  Widget build(BuildContext context) {
    return AuthBanner(
      message: _message,
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

  String get _message {
    final Duration? remaining = lockoutRemaining;
    if (failure is! TooManyAttempts || remaining == null) {
      return failure.message;
    }
    return 'Too many sign-in attempts. Try again in '
        '${formatRetryWait(remaining)}.';
  }
}
