# CityGuide

CityGuide is a Flutter application for discovering nearby places, saving
favorites, and planning lightweight city itineraries on Android and iOS.

## Project status

`Development` contains the shared application foundation. New work should begin
on a focused branch created from an up-to-date `Development` branch.

```bash
git switch Development
git pull --ff-only
git switch -c feature/places-discovery
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
  --dart-define=API_BASE_URL=https://api.example.com
```

Never commit API secrets. Mobile application binaries cannot safely hide a
secret; provider keys must be restricted at the provider level or kept behind a
backend.

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
│   └── widgets/
└── features/
    └── <feature>/
        ├── data/         # DTOs, data sources, repository implementations
        ├── domain/       # Entities, repository contracts, use cases
        └── presentation/ # Pages, widgets, and state management
```

See [docs/architecture.md](docs/architecture.md) for boundaries and the feature
branch roadmap.
