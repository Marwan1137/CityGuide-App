# Architecture

## Direction of dependencies

Each feature is split into three layers:

1. **Presentation** owns Flutter UI and state. It calls domain use cases.
2. **Domain** owns business rules, entities, repository contracts, and use
   cases. It must not import Flutter or the data layer.
3. **Data** owns remote/local data sources, DTO mapping, and repository
   implementations. It depends on domain contracts.

Dependencies point inward: `presentation -> domain <- data`. Shared code belongs
in `core` only when it is genuinely used by more than one feature.

## Feature template

Create only the folders a feature actually needs:

```text
features/places/
├── data/
│   ├── data_sources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── state/
    └── widgets/
```

Domain repositories return `AppResult<T>` rather than throwing infrastructure
exceptions into the UI. Data repositories catch provider exceptions and map
them to typed `Failure` values.

## Recommended delivery order

Keep provider choices isolated in their feature branches:

1. `feature/app-navigation` — navigation shell and primary destinations.
2. `feature/places-discovery` — place search and nearby results.
3. `feature/map` — map provider integration and markers.
4. `feature/location` — permissions and current-location behavior.
5. `feature/favorites` — local persistence and saved places.
6. `feature/place-details` — details, photos, and opening hours.
7. `feature/itinerary` — route planning and ordered stops.
8. `feature/auth` — only if synchronized user data is required.

Add dependencies on the branch that first uses them. This keeps `Development`
small and prevents committing a networking, state-management, database, or map
SDK before its requirements are clear.

## Configuration and secrets

`AppConfig` reads non-secret configuration from Dart defines:

- `APP_ENV`: `development`, `staging`, or `production`.
- `API_BASE_URL`: backend base URL when a backend is introduced.

Public mobile SDK keys should be restricted by Android package/signing identity
and iOS bundle ID. Private provider secrets belong on a backend, never inside the
Flutter application or a committed environment file.
