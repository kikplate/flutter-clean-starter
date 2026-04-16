# Flutter Clean Boilerplate

Enterprise-style Flutter starter using **Clean Architecture**, **Elementary (MVVM)**, **Dio**, **fpdart** (`TaskEither` / `ApiTask`), and **Get It + Injectable**. The sample feature loads a **list of users** from [JSONPlaceholder](https://jsonplaceholder.typicode.com/users).

## Table of contents

- [Technologies](#technologies)
- [Architecture documentation](#architecture-documentation)
- [Guidelines](#guidelines)
- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Makefile](#makefile)
- [Sample feature](#sample-feature)
- [Testing](#testing)
- [CI](#ci)

## Technologies

| Technology | Role in this project |
|------------|----------------------|
| **Flutter / Dart** | App framework and language (`sdk: ^3.5.0`). |
| **[Elementary](https://pub.dev/packages/elementary)** | MVVM: `ElementaryWidget`, `WidgetModel`, `ElementaryModel`. |
| **[Dio](https://pub.dev/packages/dio)** | HTTP client; base URL points to JSONPlaceholder. |
| **[fpdart](https://pub.dev/packages/fpdart)** | `TaskEither` / `ApiTask` for typed success/failure flows. |
| **[Get It](https://pub.dev/packages/get_it) + [Injectable](https://pub.dev/packages/injectable)** | Dependency injection and codegen. |
| **[json_serializable](https://pub.dev/packages/json_serializable)** | DTOs for API JSON (`UserDto`). |

## Architecture documentation

| Document | Description |
|----------|-------------|
| [General architecture](catalog/docs/Architecture/general-architecture.md) | Clean Architecture overview. |
| [Domain layer](catalog/docs/Architecture/domain-layer-architecture.md) | Entities, use cases, repository contracts. |
| [Data layer](catalog/docs/Architecture/data-layer-architecture.md) | Repositories, DTOs (no separate datasource layer). |
| [Application layer](catalog/docs/Architecture/application-layer-architecture.md) | `lib/application/`: Elementary MVVM, **IVm** for reusable widgets, concrete WMs under `pages/<page>/vm/`. |
| [Implementation example](catalog/docs/Architecture/implementation-example.md) | Vertical-slice style example. |

## Guidelines

| Guideline | Description |
|-----------|-------------|
| [Repository](catalog/docs/Guidelines/repository-guideline.md) | HTTP + DTO mapping in repository implementations. |
| [Dependency injection](catalog/docs/Guidelines/dependency-injection.md) | Injectable / Get It usage. |
| [Use cases](catalog/docs/Guidelines/usecase-guideline.md) | `ApiTask` / use case patterns. |
| [Endpoints](catalog/docs/Guidelines/endpoints.md) | Optional URL construction (not required for this sample). |
| [Model (MVVM)](catalog/docs/Guidelines/model.md) | Elementary `Model` responsibilities. |
| [Folder structure](catalog/docs/folder-structure.md) | `lib/features` vs **`lib/application`** (`common`, `widgets`+IVm, `pages`, `models/<domain>/`). |
| [Naming convention](catalog/docs/Structure/Naming-convention.md) | Naming rules. |
| [Failure interceptor](catalog/docs/Interceptors/failure-interceptor.md) | Dio error handling (reference). |

Full reading order: [catalog/README.md](catalog/README.md).

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, compatible with Dart 3.5+).

## Quick start

```bash
flutter pub get
flutter run
```

Code generation (Injectable / JSON):

```bash
make build
# or: flutter pub run build_runner build --delete-conflicting-outputs
```

Static analysis:

```bash
make analyze
```

## Makefile

| Target | Command |
|--------|---------|
| `make get` | `flutter pub get` |
| `make analyze` | `flutter analyze` |
| `make test` | `flutter test` |
| `make build` | `dart run build_runner build --delete-conflicting-outputs` |
| `make watch` | `dart run build_runner watch --delete-conflicting-outputs` |
| `make clean` | `flutter clean && flutter pub get` |

## Sample feature

- **Users list** — **Domain + data** in `lib/features/users/` (`GetUsersUseCase`, `IUsersRepository`, `UsersRepository`, DTOs). **UI** in `lib/application/` (`application/models/users/users_list_model.dart`, `application/pages/users_list/` with `vm/`). Flow: repository → use case → `ElementaryModel` → `UsersListWM` + `ValueNotifier` for loading / error / list.

## Testing

```bash
make test
```

Unit tests mock repositories or use [http_mock_adapter](https://pub.dev/packages/http_mock_adapter) for `Dio` in `test/`.

## CI

GitHub Actions runs on push and pull requests to `main`: `flutter pub get`, `build_runner`, `flutter analyze`, and `flutter test`. See [.github/workflows/ci.yml](.github/workflows/ci.yml).
