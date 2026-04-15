# Dependency Injection guideline

## Overview

Dependency injection allows to connect things together not related to direct instantiation object of classes. Let's say that usecase depends on interface of repository. By using `DI` we can inject this dependency not knowing which implementation will be used but we know about interface.

> As one of the implementations we're using [get_it](https://pub.dev/packages/get_it) library
{.is-info}

## Two ways of usage

We're using two different ways or registration new components to our **Service Locator**:

- Manually with some helpers
- Using annotations

Both these cases depends on different situations and scenarios regarding which we decide in which way we should register entity

### Annotations

Let's take a look at general example of one of our components being registered:

```dart

@lazySingleton(
    as: IExampleRepository,
)
class ExampleRepository implements IExampleRepository {

    final Dio _client;
    final ExampleEndpoints _endpoints;

    const ExampleRepository(this._client, this._endpoints);

    @factoryMethod
    factory ExampleRepository.produce() {
        return ExampleRepository(sl(), sl());
    }

    ...
}
```

According to this code we're saying few things:

- Firstly that our repository will be registered as `IExampleRepository`. It means that everyithing that depends on this interface will get instance of `ExampleRepository`
- Second thing is `factoryMethod`. This annotation describe which way this class should be instantiated. In our case will be called `ExampleRepository.produce()` to get instance.

Repositories take shared infrastructure such as `Dio` and feature `Endpoints` classes; there is no separate datasource registration.

As the result in generated file it will look like:

```dart
/// Generated injection_container.config.dart

void setup() {
    ...
    GetIt.instance.registerLazySingleton<IExampleRepository>(() => ExampleRepository.produce())
    ...
}
```

### Manual modules

As parts of application can be separated to different packages we should register them manually for the independancy reasons:

- On the one hand we don't want out packages be dependend on some different packages which are not related to goals of this package. `DI` dependencies as an example.
- On the other we don't want our packages to have generated files until it's necessary.

For this cases we should register all dependencies by ourselves. So we have two different options:

- Do it as described in generated file example:
```dart
 void setup(GetIt sl) {
    ...
    sl.registerLazySingleton(...);
    sl.registerFactory(...);
    sl.registerSingleton(...);
    ...
}
```
- Or use helper class like `ModuleDI`.

### ModuleDI

`ModuleDI` is a simple abstract class that simplifies registration of few different modules.

```dart
abstract class ModuleDI {
    void initUseCases() {
        ...
    }

    void initRepositories() {
        ...
    }

    ...

    void init() {
        initUseCases();
        initRepositories();
        ...
    }
}
```

Because it has unified interface in the function where we registrating our moduels we can simply have such construction:

```dart
const modules = [
    FirstModule(),
    SecondModule(),
    ...
]

modules.forEach((e) => e.init());
```

Second pros of such method that in registration of each feature we have separated method overrides and this registration code is much more simpler to read:

```dart
class ExampleModule extends ModuleDI {
    @override
    GetIt get sl;

    const ExampleModule(this.sl);

    @override
    void initUseCases() {
        sl.registerSingleton(...);
    }

    @override
    void initRepositories() {
        sl.registerFactory(...);
    }
}
```

You don't need override methods which are not used and you're separating feature registration related to our architecture design.

## Rules

Rules to choose one of registration types are simple:

- If components are in `lib/` folder (meaning it's not dependency package of application) just use annotations.
- If you're registrating packages dependencies create new `ModuleDI`.