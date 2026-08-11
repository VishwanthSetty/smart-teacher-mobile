# AGENTS.md

This file provides guidance to OpenAI Codex when working with code in this repository.

## Project

Smart Teacher — a Flutter (Material 3) mobile client for the **TEACHER** and **STUDENT** roles of an existing backend (`apps/api`, not in this repo). Full spec, screen inventory, entitlement model, and API reference: [docs/PRD.md](docs/PRD.md) — read it before adding any feature. Dart SDK `^3.11.5`. State/DI via Riverpod, navigation via go_router, HTTP via Dio, tokens via `flutter_secure_storage`, data models via freezed + json_serializable, typography via google_fonts.

Key architectural fact from the PRD: there is no BFF tier. The app itself holds the access/refresh token pair and calls `apps/api` directly with `Authorization: Bearer <token>` — see §1.2 and §6.1–6.2 of the PRD.

**Current state: Phase 0 foundation only.** No feature screens are built yet (no login, no library, no roster). See "What exists today" below before assuming any screen exists.

## Commands

```bash
flutter pub get
flutter run                       # add -d <device> to pick a target
flutter analyze                   # static analysis; must be clean (strict lints, see below)
flutter test
flutter test test/widget_test.dart                          # single file
flutter test --plain-name 'App boots to the splash screen'  # single test by name
flutter build apk --release
```

Codegen (needed once any `freezed`/`json_serializable` model exists — none do yet):

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Lint contract

`analysis_options.yaml` enables `strict-casts` and `strict-raw-types` plus rules that are *errors in review even when the analyzer only warns*. New code must satisfy them or `flutter analyze` will complain: single quotes, `const` constructors/declarations wherever possible, `final` locals, explicit return types on every declaration, trailing commas on multi-line arg lists, `unawaited_futures`, `sort_child_properties_last`.

## Architecture

Feature-first under `lib/src/`, with a shared `core/` layer. Entry point [main.dart](lib/main.dart) only wraps [SmartTeacherApp](lib/src/app.dart) in a `ProviderScope`.

Each feature under `lib/src/features/<name>/` uses up to three layers:

- `domain/` — plain immutable models (prefer freezed + json_serializable for anything that round-trips through the API — see PRD §8 for the entity shapes to model: `MeEntity`, `CurriculumEntity`, `TeacherAssignmentEntity`, `StudentEntity`, etc.)
- `data/` — an abstract repository + concrete impl (backed by `dioProvider`) + the Riverpod providers exposing it
- `presentation/` — screens and feature-local `widgets/`

The key invariant carried forward from earlier iterations of this app and still expected of new features: **presentation depends on the repository interface, never the implementation.** Define an abstract repository, expose it through a provider, and override that provider in tests (`ProviderScope.overrides`) rather than mocking at the widget level.

Screens should consume data through `FutureProvider`s (or `AsyncNotifier`) and render `AsyncValue` loading/error states, rather than managing futures in `State`.

### What exists today

- [core/errors/api_exception.dart](lib/src/core/errors/api_exception.dart) — `ApiException`, parsed once from a failed `DioException` per PRD §6.3's status-code mapping (`isUnauthorized`/`isForbidden`/`isNotFound`/`isRateLimited`). Parse errors here, not per-screen.
- [core/storage/secure_storage.dart](lib/src/core/storage/secure_storage.dart) — `SecureStorage` wraps `flutter_secure_storage` for the access/refresh token pair, exposed via `secureStorageProvider`. Tokens must never go through `SharedPreferences`, logging, or crash breadcrumbs (PRD §6.1).
- [core/network/dio_client.dart](lib/src/core/network/dio_client.dart) — `dioProvider` is the one `Dio` instance for the whole app (base URL from `--dart-define=API_URL=...`, default `http://localhost:4000`). Its interceptor currently only attaches the bearer token. **The 401 refresh-and-retry interceptor (PRD §6.2) is not implemented yet** — that is auth-feature work, not foundation; when it lands it belongs on this same instance, not a per-screen retry.
- [core/router/app_router.dart](lib/src/core/router/app_router.dart) — `GoRouter` with only `AppRoutes.splash` (`/splash`) registered as `initialLocation`. The session-gated redirect (PRD §6.6 — no valid session → `/login`) and every other route attach here as those features are built. Never hardcode path strings; add to `AppRoutes`.
- [features/splash/presentation/splash_screen.dart](lib/src/features/splash/presentation/splash_screen.dart) — static placeholder, no session check wired up yet.

Nothing else under `lib/src/features/` exists yet. Earlier scaffolding (`classes`, `home`, `profile`, `shell` — a demo bottom-nav app unrelated to the PRD) was deleted when this repo was repointed at the PRD; do not resurrect that structure or its route shape (`ShellRoute` with `/home`/`/classes`/`/profile` tabs) — the PRD's actual role-based shells (§5.7) are Teacher: My Classes/Roster/Library, Student: Library/Profile, and neither exists yet either.

Build order should follow the PRD's phasing (§10): auth (login, refresh interceptor, logout, forgot/reset password) before profile, before curricula/library, before the teacher-only roster screens.

### Theming

[AppTheme](lib/src/core/theme/app_theme.dart) builds light and dark from one `ColorScheme.fromSeed(AppColors.seed)` plus shared component styling — change the seed in [app_colors.dart](lib/src/core/theme/app_colors.dart), not individual widget colors. [ThemeController](lib/src/core/theme/theme_controller.dart) is a Riverpod `Notifier<ThemeMode>` and is **in-memory only**; persistence would go inside its `build`/`set` without touching consumers.

Spacing, radius and animation duration come from `AppConstants` in [app_constants.dart](lib/src/core/constants/app_constants.dart) — use that scale rather than raw numbers. Feature-specific constants stay in the feature folder.
