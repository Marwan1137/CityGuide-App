# CityGuide architecture

## Required feature flow

Every feature follows this dependency chain:

```text
Cubit -> UseCase -> Repository contract -> Repository implementation
      -> DataSource contract -> DataSource implementation
```

Remote features continue through `ApiManager -> ApiExecutor -> ApiResult`.
Domain code never imports Flutter, provider SDKs, DTOs, or data-layer code.
Data models are mapped to domain entities inside repository implementations.
Data sources return `ApiResult<Dto>` and repositories return
`AppResult<Entity>`. Provider exceptions must be converted before crossing a
layer boundary.

Cubits expose direct methods; the project does not use MVI or intent classes.
Each screen explicitly renders loading, loaded, and friendly error states.
Permission denial and disabled-service states are recoverable loaded outcomes.

## Feature layout

```text
features/<feature>/
├── domain/
│   ├── entity/
│   ├── repo_contract/
│   └── use_cases/
├── data/
│   ├── model/
│   ├── repo_impl/
│   ├── data_source_contract/
│   └── data_source_impl/
└── presentation/
    ├── view_model/
    ├── view/
    └── widgets/
```

Cross-feature UI belongs in `lib/shared/widgets`. Cross-feature value objects
belong in `lib/shared/domain`. Feature-specific provider packages are added on
the feature branch that first uses them.

## Dependency injection

GetIt is the runtime container and Injectable generates registrations. After
adding an annotated dependency, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated registration code is committed and checked by CI.

## Supabase and network boundaries

The mobile app uses only the Supabase project URL and client-safe publishable
key. It reuses a stored session and creates an anonymous user only when no
session exists. Edge Functions must require a user JWT. Provider server keys
belong only in Supabase secrets.

Any exposed database table requires explicit grants, RLS, and tested policies.
Database migrations and Edge Function deployments require approval.

HTTP requests use finite timeouts, cancellation tokens where applicable,
redacted logs, and typed errors. Authorization headers, tokens, API keys, and
full user-location histories must never be logged.

## Native map keys

Real native key files are ignored:

- `secrets.properties`
- `ios/Flutter/Secrets.xcconfig`

Tracked `.example` files document their shape. The Android key is restricted to
`com.marwanheikal.cityguide` plus the signing certificate. The iOS key is
restricted to the same bundle identifier. The server Places key never enters
the Flutter repository.

## Branch delivery

Feature branches are named only `feature/<feature-name>` and begin from an
updated `Development`. Approved features are merged back before the next branch
is created. Formatting, analysis, unit tests, Cubit tests, and widget tests must
pass before handoff.
