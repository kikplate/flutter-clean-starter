# General architecture

## Overview
Clean Architecture is a software design approach that emphasizes separating concerns and dependencies to build large-scale systems that are easy to maintain, scale, and test. The ultimate goal is to create systems where the business logic remains isolated from external frameworks and tools, allowing for greater flexibility and adaptability in response to changing requirements.

![cleanarchitecture.jpg](/cleanarchitecture.jpg)

> Note: for reading more information about clean architecture visit this [link](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Clean architecture choise
Our complex project is comprised of numerous interconnected domains, which are currently plagued by strong interdependencies. However, we envision the ability to seamlessly add new features and capabilities to each domain without encountering unforeseen constraints or limitations.

Therefore, we require an architecture that can support, scalability, single responsibility, maintainability, testability and quality assurance. Also we need a shared language for our big system which is understandable among the team members.

Implementing a clean architecture, customized to accommodate frontend-specific features, was the optimal solution for this issue.

## Project clean architecture diagram
As we discussed we used customized version of clean architecture based on frontend-specific features.

```plantuml
!function $applicationFlow($a)
!return "#dd5555:<color:#black>" + $a + "</color>"
!endfunction

!function $domainFlow($a)
!return "#f8cfcd:<color:#black>" + $a + "</color>"
!endfunction

!function $dataFlow($a)
!return "#Lightgreen:<color:#black>" + $a + "</color>"
!endfunction

  :User;

  partition "Application (lib/application)" {
    $applicationFlow("Page");
    $applicationFlow("View");
    $applicationFlow("VM");
    $applicationFlow("Model");
  }
  partition "Feature (lib/features)" {
    partition Domain {
      $domainFlow("Usecase");
      $domainFlow("Entity");
      #f8cfcd-LightGreen:I-Repository;
    }
    partition Data {
      $dataFlow("Repository");
      $dataFlow("DTO");
    }
  }

  fork
    #e2d6e8:API;
    detach
  fork again
    #e2d6e8:Local Storage;
    detach
  end fork
```


## Layers breaking down

### Application Layer
**Code** for this layer lives under **`lib/application/`** (Elementary views, reusable widgets + **`IVm`** interfaces, per-page `vm/`, and `ElementaryModel` under `application/models/<domain>/`). It is responsible for framework-facing UI and wiring; it **depends on** feature domain code (use cases) but **not** the other way around.

This layer is based on [MVVM (Model-ViewModel-View)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel) Architecture.<br/>
This architecture helps us separate orchestration in the `ElementaryModel`, UI logic in `WidgetModel`s, and UI in views.

> Note: For folder layout (`common`, `pages`, `widgets`, `models`), [folder structure](../folder-structure.md). For MVVM, IVm bridge, and diagrams, see [application layer](application-layer-architecture.md).

### Feature Layer
**Code** for domain rules and data access lives under **`lib/features/<domain>/`** — **`domain/`** (entities, use cases, `IRepository`) and **`data/`** (repository implementations, DTOs). **Do not** add `presentation/` under features; UI belongs in `lib/application/`.

This layer is responsible for business rules and data mapping.

#### Domain 
This layer is a part of Feature layer which is the heart of our app and it just care about the main business logics of the app.<br/>
So This layer is independent of any specific technology or framework and represent the fundamental concepts and rules of the business domain.

This layer contains three parts:
  1. Entity: Is our business object and contains our business rules.

          Example: `User` entity represents:
            - `id`
            - `firstName`
            - `lastname`
            - Also some business object logics like `getFullName`
2. Usecase: The Use Case represents the main business logic of the application and orchestrates the overall process flow. It interacts with entities and communicates with external systems through repositories (IRepository). <br/>
In this scenario, the primary benefit is the separation of core business logic from external frameworks and third-party dependencies, ensuring encapsulation and maintainability of the application.<br/>

        Example:
        In an e-commerce application:
        `PlaceOrderUseCase`:
        Manages the process of placing an order, including validation, inventory management, and order creation.
        Utilizes IProductRepository to retrieve and update product information without directly coupling to the database or external APIs.
3. I-Repository: It's an interface to define a contract for data access operations within the application. It abstracts away the details of specific data storage implementations (such as databases or external services) from the usecase. <br/>
So our usecase knows how to communicate with outside of the app through I-Repository.

#### Data
This layer is responsible for interfacing with external systems and services, adapting their data formats into business entities that the application can use.

1. **Repository (implementation)**: It implements the `IRepository` interface defined in the domain layer. The repository is the **only** data-layer type that use cases depend on. It **performs** remote HTTP calls and local storage access (for example via `Dio`, `Hive`, or other clients), **parses** wire formats into **DTOs**, maps DTOs to **entities**, and maps failures into domain `Failure` types. There is **no separate datasource layer**: fetching and DTO handling live inside the repository (optionally via private methods or small private helpers in the same file/module).

> Note: For more details about feature layer, class diagram, code example, testing of this layers, please visit feature layer documentation.

