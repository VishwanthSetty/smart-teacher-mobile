# Smart Teacher

A clean, production-oriented Flutter application for teachers to manage their
classes and schedule.

## Tech stack

- **Flutter** (Material 3, light/dark theming)
- **Riverpod** — state management & dependency injection
- **go_router** — declarative routing with a persistent bottom-nav shell
- **google_fonts** — typography

## Architecture

The code follows a **feature-first** layout with a shared **core** layer:

```
lib/
├─ main.dart                 # Entry point — wraps the app in a ProviderScope
└─ src/
   ├─ app.dart               # Root MaterialApp.router + theme wiring
   ├─ core/                  # Cross-cutting concerns
   │  ├─ constants/          # App-wide constants (spacing, radius, names)
   │  ├─ theme/              # Colors, ThemeData, ThemeMode controller
   │  ├─ router/             # go_router configuration + route names
   │  └─ widgets/            # Reusable widgets (SectionHeader, AppAvatar)
   └─ features/              # One folder per feature
      ├─ shell/              # Bottom-navigation scaffold
      ├─ home/               # Dashboard
      ├─ classes/            # Class list + detail
      │  ├─ domain/          #   models
      │  ├─ data/            #   repository (mock, swappable for API)
      │  └─ presentation/    #   screens & widgets
      └─ profile/            # Profile + appearance settings
```

Each feature is split into `domain` (models), `data` (repositories/providers),
and `presentation` (screens/widgets). The presentation layer depends on
repository *interfaces*, so the current in-memory `MockClassesRepository` can be
replaced with an API- or database-backed implementation without touching any UI.

## Getting started

```bash
flutter pub get
flutter run
Invoke-RestMethod http://localhost:4000/health

adb reverse tcp:4000 tcp:4000

cd "D:\Brinda Publications\Brinda Repos\smart-teacher-mobile"
flutter run --dart-define=API_URL=http://localhost:4000
```

Production builds must also set the app environment. This enables app-wide
screen-capture protection before the first Flutter frame:

```bash
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_URL=https://api.example.com
```

## Quality checks

```bash
flutter analyze   # static analysis (strict lints in analysis_options.yaml)
flutter test      # widget/unit tests
```
