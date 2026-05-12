# Features

Each feature follows the clean-architecture three-layer pattern. Add a new feature as:

```
features/<feature_name>/
├── data/
│   ├── datasources/        # remote (Dio) + local (SharedPreferences) data sources
│   ├── models/             # JSON-serialisable models that extend domain entities
│   └── repositories/       # *RepositoryImpl — calls datasources, maps to Failures
├── domain/
│   ├── entities/           # plain Dart classes, framework-free
│   ├── repositories/       # abstract repository contracts (interfaces)
│   └── usecases/           # one class per use-case, extends UseCase<T, Params>
└── presentation/
    ├── cubit/              # *Cubit + *State (Equatable)
    ├── pages/              # full-screen widgets
    └── widgets/            # reusable widgets scoped to this feature
```

## Dependency rule

`presentation` → `domain` ← `data`

- `domain` knows nothing about Flutter, Dio, or SharedPreferences.
- `data` depends on `domain` (it implements the repository contracts).
- `presentation` depends on `domain` only (it calls usecases, never repositories or datasources directly).

## State management

Cubits live in `presentation/cubit/`. Each cubit:

- Receives its dependencies (usecases) through the constructor.
- Emits `Equatable` states.
- Is registered in `lib/config/injection_container.dart` as `registerFactory`, so each page gets a fresh instance.

## Wiring a new feature

1. Build `domain/` first (entities, repository abstract, usecases).
2. Build `data/` (models, datasources, repository impl).
3. Build `presentation/` (cubit + states, pages, widgets).
4. Register everything in `injection_container.dart` under a `_register<FeatureName>Feature()` helper.
5. Hook the page into the router / navigation in `main.dart` or wherever the navigation lives.
