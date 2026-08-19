# CityGuide

CityGuide is a Flutter application for discovering nearby places, saving
favorites, and planning lightweight city itineraries on Android and iOS.

## Project status

`Development` contains the shared application foundation. New work should begin
on a focused branch created from an up-to-date `Development` branch.

```bash
git switch Development
git pull --ff-only
git switch -c feature/location-permission-matrix
```

Open pull requests back into `Development`. Promote tested releases from
`Development` to `main`.

## Run locally

```bash
flutter pub get
flutter run --dart-define=APP_ENV=development
```

Optional compile-time configuration:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_example
```

The connected Supabase URL and client-safe publishable key are configured for
development and may be overridden with Dart defines. Never put a Supabase
secret key, Google Places server key, or another privileged credential in the
mobile application.

Native Google Maps keys are added only immediately before Feature 3 testing.
Copy `secrets.properties.example` to `secrets.properties` for Android and
`ios/Flutter/Secrets.xcconfig.example` to
`ios/Flutter/Secrets.xcconfig` for iOS. Both real files are ignored by Git.

## Quality checks

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

GitHub Actions runs the same checks for pull requests and pushes to `main` or
`Development`.

## Architecture

The codebase uses feature-first Clean Architecture:

```text
lib/
├── app/                  # Application widget and route composition
├── core/                 # Shared, feature-independent foundations
│   ├── config/
│   ├── error/
│   ├── network/
│   ├── theme/
│   ├── usecases/
│   ├── utils/
│   └── services/
├── shared/               # Cross-feature domain primitives and widgets
└── features/
    └── <feature>/
        ├── data/         # DTOs, data sources, repository implementations
        ├── domain/       # Entities, repository contracts, use cases
        └── presentation/ # Pages, widgets, and state management
```

See [docs/architecture.md](docs/architecture.md) for boundaries and the feature
branch roadmap. Feature 1 manual verification is documented in
[docs/testing/location_permission_matrix.md](docs/testing/location_permission_matrix.md).
Feature 2 verification is documented in
[docs/testing/city_search_fallback.md](docs/testing/city_search_fallback.md).
Feature 3 verification is documented in
[docs/testing/explorer_map.md](docs/testing/explorer_map.md).
