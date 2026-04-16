# Folder structure

This document describes how code is organized under `lib/`. Presentation **does not** live inside `features`; it lives under **`lib/application/`**, beside **`lib/features/`** (domain + data only).

## Dependency rule

- **`lib/features/`** must **not** import from **`lib/application/`** (domain and data stay independent of UI).
- **`lib/application/`** may import **`lib/features/`** (use cases, entities, and **`features/common`** shared types).

## `lib/features/common/` — shared types (non-UI)

Cross-feature, non-UI building blocks used by domain and data layers: **`Failure`**, **`ApiTask`**, and similar. **Domain slices** (`features/users`, etc.) and **`application`** may import here; keep it free of Flutter UI imports.

```
📦 lib/features/common
├─ failures
└─ types
```

## `lib/features/<domain>/` — domain and data only

Each vertical slice (e.g. `users`) contains **no** `presentation/` folder. Only:

```
📦 lib/features/users
├─ data
│  ├─ repositories
│  ├─ dtos
│  └─ endpoints   (optional)
└─ domain
   ├─ entities
   ├─ usecases
   ├─ repositories   (interfaces: I…Repository)
   └─ failures
```

Repositories implement domain contracts and own HTTP/local I/O plus DTO mapping (see [data layer architecture](Architecture/data-layer-architecture.md)).

## `lib/application/` — all UI (Elementary)

Everything the user sees is built here: pages, reusable widgets, Elementary **models** used by WMs, and small shared helpers.

```
📦 lib/application
├─ common              # Shared app-level helpers (formatters, extensions, UI constants—not domain rules)
├─ widgets             # Reusable UI; each widget has a colocated IVm interface (bridge pattern)
├─ pages               # One folder per screen / route
│  └─ <page_name>      # e.g. users_list
│     ├─ <page_name>_page.dart   # Root ElementaryWidget: composes reusable + page widgets
│     ├─ widgets/                # Widgets used only on this page
│     └─ vm/                     # Concrete WidgetModels for this page (implement IVm + IWidgetModel)
└─ models                # ElementaryModel classes, grouped by domain
   └─ <domain>           # e.g. users/
      └─ …_model.dart
```

### `application/common/`

Cross-cutting **UI-related** utilities: spacing constants, generic extensions used by widgets, shared formatters for display strings. Do **not** put domain entities or use cases here.

### `application/widgets/` — reusable components + **IVm**

Each reusable widget (e.g. primary button) lives with an **interface** whose name follows **`I` + PascalCase + `Vm`** (e.g. `IAppPrimaryButtonVm`). That interface is the **only** contract the widget depends on: props, callbacks, optional listenable state. **No** concrete `WidgetModel` implementation lives here—only the **IVm** (bridge / strategy), so the same widget can be driven by different WMs on different pages.

### `application/pages/<page_name>/`

- **Root page widget**: thin composition layer; wires `wmFactory` and builds reusable `application/widgets` plus page-local `widgets/`.
- **`widgets/`**: building blocks **specific to this screen** (not reused elsewhere).
- **`vm/`**: **concrete** Elementary `WidgetModel` classes for this page. They **implement** the relevant **IVm** interfaces from `application/widgets` **and** extend `WidgetModel<…>` / implement `IWidgetModel` as required by Elementary. Name by **screen + role** (e.g. `UsersListPrimaryButtonVm` implements `IAppPrimaryButtonVm`).

### `application/models/<domain>/`

[`ElementaryModel`](Guidelines/model.md) subclasses that call use cases from `lib/features/<domain>/domain/`. One folder per domain keeps imports and ownership clear (e.g. `application/models/users/users_list_model.dart`).

## `lib/bootstrap/`

- **`bootstrap/`** — DI (`GetIt` / Injectable), env, app entry wiring.

## Optional `packages/`

You may extract reusable packages (e.g. UI kit) later; the same rules apply: **features** stay domain+data; **application** stays UI.

## Licenses

> © Folder trees may be generated with [Project Tree Generator](https://woochanleee.github.io/project-tree-generator).
