# Data layer architecture

Application's data layer design consists of:

- **Repository implementations** (domain defines `IRepository` contracts only)
- **DTOs** (wire / API shapes)
- **Local models** (when persisting to local storage, if applicable)

There is **no separate datasource layer**. The repository implementation is responsible for talking to the network and local storage, working with DTOs, and translating to domain entities.

## Repositories

The repository implementation is the integration point for use cases: it returns `ApiTask` / `TaskEither` types that expose **entities** or domain-level failures.

Responsibilities:

1. **Remote**: perform HTTP calls (e.g. with `Dio`), using endpoint helpers where you use them.
2. **Local**: read/write local storage (e.g. `Hive`, `SharedPreferences`) when the feature needs caching or offline data.
3. **DTOs**: parse JSON (or other payloads) into DTO classes, then map DTOs to **entities**.
4. **Errors**: map transport and parsing errors into domain failures inside `TaskEither.tryCatch` (or your shared helpers).

```plantuml

interface IExampleRepository <<Domain>> {
  + ApiTask<List<Example>> fetchExamples()
}

class ExampleRepository <<Data>> implements IExampleRepository {
  - Dio _client
  - ExampleEndpoints _endpoints
}

class ExampleDTO <<Data>> {}

ExampleRepository ..> ExampleDTO : parses
ExampleRepository ..> IExampleRepository
```

Use **private methods** on the repository (or small private types in the same feature folder) when a method body would otherwise be too large—for example `_fetchExampleDtos()` that returns `Future<List<ExampleDTO>>`—without introducing a separate “datasource” type as a layer.

## DTOs

`DTO` is the contract between the remote API (or message payload) and our application. Repositories parse responses into DTOs, then map to entities.

## Models 

`Model` (or local schema types) describe how data is stored locally when you persist entity data. The repository maps between entity ↔ model ↔ storage the same way it maps DTO ↔ entity for remote calls.
