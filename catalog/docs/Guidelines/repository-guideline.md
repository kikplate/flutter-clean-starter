# Repositories guideline

## General information

In Clean Architecture, the **repository implementation** (in the data layer) hides how data is loaded from the network or local storage. **Domain** defines `IExampleRepository` (or similar); **data** provides `ExampleRepository`.

There is **no separate datasource layer**. The repository:

- Performs HTTP calls (e.g. with `Dio`) and/or local storage access (e.g. `Hive`).
- Parses wire data into **DTOs**, then maps DTOs to **entities**.
- Returns `ApiTask<T>` / `TaskEither<Failure, T>` and maps errors to domain failures.

Use **private methods** on the repository when fetch logic is long (e.g. `_fetchExampleDtos()` returning `Future<List<ExampleDTO>>`), without introducing a separate `*Datasource` type.

## Implementation

### 1. Naming

- Domain: `IExampleRepository` in `domain/repositories/`.
- Data: `ExampleRepository` in `data/repositories/`.

### 2. Dependencies

Inject infrastructure the repository needs, for example:

- `Dio` for HTTP
- Feature `Endpoints` class (if you use the endpoints pattern)
- `HiveInterface` or other local APIs when the feature persists data

Do **not** inject a separate “datasource” class; keep fetch + parse in the repository.

### 3. Example shape

```dart
class ExampleRepository implements IExampleRepository {
  final Dio _client;
  final ExampleEndpoints _endpoints;

  const ExampleRepository(this._client, this._endpoints);

  factory ExampleRepository.produce() {
    return ExampleRepository(sl(), sl());
  }

  @override
  ApiTask<List<Example>> fetchExamples() {
    return TaskEither.tryCatch(
      () async {
        final dtos = await _fetchExampleDtos();
        return dtos
            .map(
              (e) => Example(
                someField: e.someField,
                anotherField: e.anotherField,
              ),
            )
            .toList();
      },
      (error, stackTrace) => failureOr(
        error,
        (f) => const ActionExampleFailure(),
      ),
    );
  }

  Future<List<ExampleDTO>> _fetchExampleDtos() async {
    try {
      final response = await _client.get(_endpoints.examples);
      // Parse to DTOs (helpers: ensureNotEmptyResponse, mapListWith, etc.)
      return /* ... */;
    } on DioException catch (e) {
      throw timeoutFailureThrow(e)
          .flatMap(verifyErrorHasResponse)
          .map(transformData)
          .map(mapKnownFailures)
          .getOrElse(() => throw const FetchSomeDataFailure());
    }
  }
}
```

Override methods from `IExampleRepository` and return `ApiTask` with the correct entity types.

## Testing

- Put tests under `test/` mirroring `lib/` paths, e.g. `test/feature/example/data/example_repository_test.dart`.
- **Mock `Dio`** (or use `http_mock_adapter`) and **endpoints** instead of a datasource mock.
- Verify that the HTTP client was called as expected and that success paths return mapped **entities** (not raw DTOs) on the right side of `TaskEither`.

Example groups:

1. Factory / constructor builds correctly.
2. `fetchExamples()` (or equivalent) returns entities when the client returns valid JSON.
3. Same method returns `Left` with the expected failure when the client throws or returns bad data.

After tests pass, register `ExampleRepository` in DI as `IExampleRepository`.

## Related

- [Data layer architecture](../Architecture/data-layer-architecture.md) — repositories, DTOs, and local models.
