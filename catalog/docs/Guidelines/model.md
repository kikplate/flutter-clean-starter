# Model guideline

## General information
In the MVVM pattern, the Model represents the data and data logic of the application. It is responsible for managing the application's data, state, and business rules. Here are some key points about the Model in MVVM: 
 
1. **Data Management**: The Model is responsible for retrieving, storing, and managing the data used by the application. This can include data from databases, web services, local storage, or any other data source. 
 
2. **Business Logic**: The Model contains the business logic of the application, which defines how the data should be processed, validated, and manipulated. This logic ensures that the data remains consistent and follows the rules of the application. 
 
3. **Independent of UI**: The Model is designed to be independent of the user interface (View) and the presentation logic (ViewModel). This separation of concerns helps in making the application more maintainable and testable. 
 
4. **Encapsulation**: The Model encapsulates the data and business logic, hiding the implementation details from the other components of the application. This promotes a clean and modular design. 
 
Overall, the Model plays a crucial role in the MVVM pattern by managing the application's data and data logic, ensuring that the application remains robust, maintainable, and scalable.

## In our application
Model in our application is representation of model layer in `MVVM` architechture pattern.
In many descriptions about model it says that model has responsibility of business logic. But in our application model has less responsibility to business logic. Business logic is responsibility of usecases. So `model` just call all needed usecases, combine them if needed and handle data. 
>**Note**
So as has been said model is just part of application where you can combine usecases and get needed result.

Anoter responsibility of `Model` in our app is managing data, state and data logic, e.g filtering, checking and etc. 

## Example implementation
Let's implement example model in our application.

### Defining class
As we use [Elementary](https://pub.dev/packages/elementary) package when you create `model` class you need to extend of `ElementaryModel`.
Choose a valid name that should follow convention `{Domain name}Model`. 
For example we work with `Example` domain. Let's create class `ExampleModel`
``` dart
class ExampleModel extends ElementaryModel{
	// code
}
```
### Defininng dependencies
In example our model provide us possibility to fetch `List<Example>`. To get it we need to use `FetchExampleUsecase`. 
Also we need to keep somewhere the data that we will fetch. In our application we usually put it inside state of `Bloc` because data can be changed from time to time.
Let's define dependencies in our model:
``` dart 
/* -------------------------------------------------------------------------- */
  final FetchExampleUsecase _exampleUsecase;
/* -------------------------------------------------------------------------- */
  final ExampleStoreBloc _exampleStore;
/* -------------------------------------------------------------------------- */
```
>As you can see all fields are private. Hide dependencies from external access and give access to needed data by using getters.
### Add getters
Our `WidgetModel` should have access to `List<Example>`. So add getter that returns list of `Example` from state of `ExampleBloc` and provide needed retrun type;

``` dart
	List<Example> get examples => _exampleStore.state.examples;
```
>**Note**
To have access to `examples` you need specify it inside state. Get more info in [bloc guideline]().

For example we define getter thar return `List<Example>` without any additional logic. But if you need you can filter it or do another logic on this data.

If you need to listen some `ExampleBloc` changes you can add getter for `Stream` of `ExampleBloc`.

``` dart
	Stream<ExampleStoreState> get storeStream => _exampleStore.stream;
```

>Filtering
If you want you can add `filter()` function and code will be: `_exampleStore.state.examples.filter((e) => someCondition)`

### Creating constructor
After specifying all needed dependencies add their initialization into constructor.
``` dart
  ExampleModel(
    this._exampleUsecase,
    this._exampleStore,
  );
```

Create factory method. 

``` dart
  factory ExampleModel.produce() {
    return ExampleModel(
      sl(),
      sl(),
    );
  }
```
>**Note**
`sl()` is dependency injection. you can use it for every class that has been initialized in injection container. To get more info check [dependency injection]() page

### Implement Methods
Now we need to implement some logic for our model.
As said above many posibility takes usecases. So we just need to call them.
In our model we use `FetchExampleUsecase`. to call it we can call `run()` method of usecase. 
For example we will run usecase and add returned data into store.
``` dart
  Future<List<Example>> fetchExample() {
    return _exampleUsecase('example')
        .map(
          mapSideEffect(
            (e) => _exampleStore.add(
              ExampleStoreBloc.addExampleToStore(e),
            ),
          ),
        )
        .getOrElse((l) => [])
        .run();
  }
```
> **Note**
About `mapSideEffect()` you can read on helpers page. Function `map()` is from [fpdart](https://pub.dev/packages/fpdart) package.

Lets simplify code readability by separating logic to simple functions.
``` dart
  Future<List<Example>> fetchExample() {
    return _exampleUsecase('example')
        .map(mapSideEffect(addExampleToStore))
        .getOrElse((l) => [])
        .run();
  }

/* -------------------------------------------------------------------------- */
void _addExampleToStore(List<Example> example) {
	_exampleStore.add(ExampleStoreBloc.addExampleToStore(example));
}
```

### init() method
Every time `WidgetModel` that depend on our Model initialized we want to fetch data. 
> As said in `elementary` documentation:
 	Will be call at first build when Widget Model created.
  
For this purpose there is `init()` method in `ElementaryModel`
Lets define logic for `init()` 
``` dart
  @override
  void init() {
    _fetchExample();
  }
```
So every time some `WidgetModel` depend on `ExampleModel`  initialized we will call `init()` method of model and after that will be called `_fetchExample()` function.

### Full code
``` dart
import 'package:boilerplate_app/bootstrap/di/injection_container.dart';
import 'package:boilerplate_app/core/network/response_helpers.dart';
import 'package:boilerplate_app/example_doc/bloc/bloc/example_store_bloc.dart';
import 'package:boilerplate_app/example_doc/example.dart';
import 'package:boilerplate_app/example_doc/fetch_example_usecase.dart';
import 'package:elementary/elementary.dart';

class ExampleModel extends ElementaryModel {
/* -------------------------------------------------------------------------- */
  final FetchExampleUsecase _exampleUsecase;
/* -------------------------------------------------------------------------- */
  final ExampleStoreBloc _exampleStore;
/* -------------------------------------------------------------------------- */
  List<Example> get examples => _exampleStore.state.examples;
/* -------------------------------------------------------------------------- */
  Stream<ExampleStoreState> get storeStream => _exampleStore.stream;
/* -------------------------------------------------------------------------- */
  ExampleModel(
    this._exampleUsecase,
    this._exampleStore,
  );
/* -------------------------------------------------------------------------- */
  factory ExampleModel.produce() {
    return ExampleModel(
      sl(),
      sl(),
    );
  }
/* -------------------------------------------------------------------------- */
  @override
  void init() {
    fetchExample();
  }

/* -------------------------------------------------------------------------- */
  Future<List<Example>> fetchExample() {
    return _exampleUsecase('example')
        .map(mapSideEffect(_addExampleToStore))
        .getOrElse((l) => [])
        .run();
  }

/* -------------------------------------------------------------------------- */
  void _addExampleToStore(List<Example> example) {
    _exampleStore.add(ExampleStoreBloc.addExampleToStore(example));
  }
/* -------------------------------------------------------------------------- */
}

```

## Testing
### Mock dependencies
First of all mock dependencies.
Use `mock` snippet to fastly write mocks.

``` dart
class MockExampleStoreBloc extends Mock implements ExampleStoreBloc {}

/* -------------------------------------------------------------------------- */
class MockExampleExampleUsecase extends MockUseCase
    implements FetchExampleUsecase {}

/* -------------------------------------------------------------------------- */
```
### Dependency injection
Mock dependency injection by register mock classes into GetIt.
``` dart
final sl = GetIt.instance;
void injectionRegistry() {
  sl.registerLazySingleton<FetchExampleUsecase>(
      () => MockExampleExampleUsecase());
  sl.registerLazySingleton<ExampleStoreBloc>(() => MockExampleStoreBloc());
}
```
### main()
Create function `main()`
Create test `Example` instance inside to mock real instance of this class.
Also define dependencies
``` dart
/* -------------------------------------------------------------------------- */
  final example = Example();
/* -------------------------------------------------------------------------- */
  late ExampleStoreBloc storage;
  late FetchExampleUsecase usecase;
  late ExampleModel model;
/* -------------------------------------------------------------------------- */
```
Call `injectionRegistry()` that was defined above.
Setup testing model by calling `setUp()`.
And don't forget to tear down usecase.

``` dart
/* -------------------------------------------------------------------------- */
  injectionRegistry();
/* -------------------------------------------------------------------------- */
  setUp(() {
    storage = MockExampleStoreBloc();
    usecase = MockExampleExampleUsecase();

    model = ExampleModel(
      usecase,
      storage,
    );
  });
/* -------------------------------------------------------------------------- */
  tearDown(() {
    usecase.tearDown();
  });
/* -------------------------------------------------------------------------- */
```

### Testing
Create main group with descrition `[ExampleModel] ->`. To simplify proccess use `gtp` snippet.
Inside main group create test to check that model correctly initialized from factory.

``` dart
group('[ExampleModel] ->', () {
    test('Should normally initialize from factory', () async {
      expect(() => ExampleModel.produce(), returnsNormally);
    });
    // some code
});
```
Create group with description`[Getters]->` in main group.
We have 2 getters. One for getting `examples`. Second for bloc stream.
Before testing you need to specify behaviour of `ExampleStoreBloc` because of test doesn't have access to this file.
``` dart
// Setup
final stream = StreamController<ExampleStoreState>.broadcast();
// * Fixturing
when(() => storage.state).thenReturn(
	ExampleStoreState.resolved(
		[example],
	),
);
when(() => storage.stream).thenAnswer((_) => stream.stream);
```
After fixturing you can start testing. Initialize model and check that all getters works as you want
``` dart
// ! Executing
model.init();

// ? Verification
expect(() => model.examples, returnsNormally);
expect(model.examples, [example]);
expect(model.storeStream, isA<Stream<ExampleStoreState>>());
expect(model.storeStream, stream.stream);
```
Create new group inside testing. Add to description name of method that you want test. In example it will be`fetchExample()`.
Inside group create two tests that checks behaviour when usecase is successful and when usecase is failed.
Dont forget to fixture behaviour of `ExampleStoreBloc`

``` dart
    group('[fetchExample()] ->', () {
      test('Should return list of Example on success usecase and add to store',
          () async {
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved([example]),
        );
        usecase.success();

        // ! Executing
        final response = await model.fetchExample();

        // ? Verification
        usecase.verify(1);
        expect(response, [example]);
      });
      test('Should return empty if usecase failed', () async {
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved([]),
        );
        usecase.fail(const UnknownFailure());

        // ! Executing
        final response = await model.fetchExample();

        // ? Verification
        usecase.verify(1);
        expect(response, []);
      });
    });
```
Last group that we created in example is group for testing `init()` method. 
Check the code below.
``` dart
    group('[init()] ->', () {
      test('Should call usecase and add to store on init', () async {
        // Setup
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved([example]),
        );
        usecase.success();
        // ! Executing
        model.init();
        // ? Verification
        expect(model.examples, [example]);
        usecase.verify(1);
      });
    });
```
### Full code
``` dart
import 'dart:async';

import 'package:boilerplate_app/core/failures/unknown_failure.dart';
import 'package:boilerplate_app/example_doc/bloc/bloc/example_store_bloc.dart';
import 'package:boilerplate_app/example_doc/example.dart';
import 'package:boilerplate_app/example_doc/example_model.dart';
import 'package:boilerplate_app/example_doc/fetch_example_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../mock_use_case.dart';
/* -------------------------------------------------------------------------- */
/*                                   Mocking                                  */
/* -------------------------------------------------------------------------- */

class MockExampleStoreBloc extends Mock implements ExampleStoreBloc {}

/* -------------------------------------------------------------------------- */
class MockExampleExampleUsecase extends MockUseCase
    implements FetchExampleUsecase {}

/* -------------------------------------------------------------------------- */
final sl = GetIt.instance;
void injectionRegistry() {
  sl.registerLazySingleton<FetchExampleUsecase>(
      () => MockExampleExampleUsecase());
  sl.registerLazySingleton<ExampleStoreBloc>(() => MockExampleStoreBloc());
}

void main() {
/* -------------------------------------------------------------------------- */
  final example = Example();
/* -------------------------------------------------------------------------- */
  late ExampleStoreBloc storage;
  late FetchExampleUsecase usecase;
  late ExampleModel model;
/* -------------------------------------------------------------------------- */
  injectionRegistry();
/* -------------------------------------------------------------------------- */
  setUp(() {
    storage = MockExampleStoreBloc();
    usecase = MockExampleExampleUsecase();

    model = ExampleModel(
      usecase,
      storage,
    );
  });
/* -------------------------------------------------------------------------- */
  tearDown(() {
    usecase.tearDown();
  });
/* -------------------------------------------------------------------------- */
  group('[ExampleModel] ->', () {
    test('Should normally initialize from factory', () async {
      expect(() => ExampleModel.produce(), returnsNormally);
    });
    group('[Getters] ->', () {
      test('Should normally initialize getters and returns valid values',
          () async {
        // Setup
        final stream = StreamController<ExampleStoreState>.broadcast();
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved(
            [example],
          ),
        );
        when(() => storage.stream).thenAnswer((_) => stream.stream);

        // ! Executing
        model.init();

        // ? Verification
        expect(() => model.examples, returnsNormally);
        expect(model.examples, [example]);
        expect(model.storeStream, isA<Stream<ExampleStoreState>>());
        expect(model.storeStream, stream.stream);
      });
    });
    group('[fetchExample()] ->', () {
      test('Should return list of Example on success usecase and add to store',
          () async {
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved([example]),
        );
        usecase.success();

        // ! Executing
        final response = await model.fetchExample();

        // ? Verification
        usecase.verify(1);
        expect(response, [example]);
      });
      test('Should return empty if usecase failed', () async {
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved([]),
        );
        usecase.fail(const UnknownFailure());

        // ! Executing
        final response = await model.fetchExample();

        // ? Verification
        usecase.verify(1);
        expect(response, []);
      });
    });
    group('[init()] ->', () {
      test('Should call usecase and add to store on init', () async {
        // Setup
        // * Fixturing
        when(() => storage.state).thenReturn(
          ExampleStoreState.resolved([example]),
        );
        usecase.success();
        // ! Executing
        model.init();
        // ? Verification
        expect(model.examples, [example]);
        usecase.verify(1);
      });
    });
  });
}

```