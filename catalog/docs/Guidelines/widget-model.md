# Widget model guideline

In our application architecture the upper layers written according MVVM pattern.
## General information
In the MVVM (Model-View-ViewModel) pattern, the ViewModel is a key component that acts as an intermediary between the View (UI) and the Model (data). The ViewModel's primary purpose is to expose data and behavior from the Model to the View in a way that is easy to bind to and display. 
 
The ViewModel in MVVM typically contains the following elements: 
1. **Properties:** These are data fields that the View can bind to for displaying information. 
2. **Commands:** These are methods or actions that the View can trigger in response to user interactions. 
 
By using the ViewModel in MVVM, the View can remain lightweight and focused on displaying data, while the ViewModel handles the logic and behavior of the application. This separation of concerns helps improve the maintainability and testability of the code.

## In our application.
Because we using [elementary](https://pub.dev/packages/elementary) package and all in Flutter is a widget name `View` in pattern replace to `Widget`. So it turns out `WidgetModel` and `MVVM` pattern turns out `MWWM`.

In our app widget model if responsible to implement view logic. By using data from `model` or `bloc` widget model can manage what and how `view` should display it.

Also responsibility of `widget model` is providing themes for view.

### Implementation
So let's create simple `widget model` for example.

#### Interface
Firstly let's create interface of `widget model`.
You should create file following our convention: `i_{domain name}_w_m.dart`: `i` shows that file contains interface, `{domain name}` - name of your domain for example it will be `example`, `w_m` shows you that file contain `widget model`. 
In our example it will be `i_example_w_m.dart`.

Inside file create `abstract interface class` inside file. To fastly create this class use snippet `absi`. And don't forget that we use `elementary` package so you need to extend with `IWidgetModel` class

```dart
// i_example_w_m.dart
abstract interface class IExampleWM extends IWidgetModel {
  
}
```
Now we need define needed dependencies and methods.
To change view we must define `state`.
Add this line inside created interface. This is part of `elementary` package to manage state and change view. 
>**Note** 
Read more about `state` at official elementary [documentation](https://pub.dev/documentation/elementary/latest/).

``` dart
// i_example_w_m.dart
abstract interface class IExampleWM extends IWidgetModel {
/* -------------------------------------------------------------------------- */
  ListenableState<EntityState<bool>> get state;
/* -------------------------------------------------------------------------- */
}
```

In our application we doesn't harcode styles and properties inside view. It neccesary to provide flexibility and keep all changings in one part of an app.
So you must create two interfaces. One for properties that can be changable. Another for styles of your widget.

To create interface for properties create file `i_example_props.dart` file.
Create interface inside this file with name `IExampleProps`. 
Fill this file with getters on your properties that needed for view.

For example:
``` dart
// i_example_props.dart
abstract interface class IExampleProps {
/* -------------------------------------------------------------------------- */
  String get title;
/* -------------------------------------------------------------------------- */
  String get subtitle;
/* -------------------------------------------------------------------------- */
  double get counter;
/* -------------------------------------------------------------------------- */
}
```

Create another interface for styles. It should have name `i_example_theme.dart`.
Like properties fill it with needed style props.

For example:
``` dart 
// i_example_theme.dart
abstract interface class IExampleTheme {
/* -------------------------------------------------------------------------- */
  TextStyle get title;
/* -------------------------------------------------------------------------- */
  TextStyle get subtitle;
/* -------------------------------------------------------------------------- */
  Color get background;
/* -------------------------------------------------------------------------- */
}
```

> **Pay attention**
Interfaces of wm should be inside `presentation` package. Full path is `packages/presentation/lib/src/example/`. Read more about folder structure on special [page](/Peacock/folder-structure).
{.is-warning}

Next step is add interfaces of props and themes as dependencies to `IExampleWM`. 

``` dart
// i_example_w_m.dart
abstract interface class IExampleWM extends IWidgetModel {
/* -------------------------------------------------------------------------- */
  ListenableState<EntityState<bool>> get state;
/* -------------------------------------------------------------------------- */
  IExampleProps get props;
/* -------------------------------------------------------------------------- */
  IExampleTheme get theme;
/* -------------------------------------------------------------------------- */
}
```

After add dependencies define all needed methods. For example it will be one method `onTap()`.

``` dart
// i_example_w_m.dart
abstract interface class IExampleWM extends IWidgetModel {
/* -------------------------------------------------------------------------- */
  ListenableState<EntityState<bool>> get state;
/* -------------------------------------------------------------------------- */
  IExampleProps get props;
/* -------------------------------------------------------------------------- */
  IExampleTheme get theme;
/* -------------------------------------------------------------------------- */
  void onTap();
/* -------------------------------------------------------------------------- */
}
```
#### Implementation
After defining interface you can start to implement `WidgetModel`
Create class `ExampleWM` inside `example_w_m.dart` that extends from `BaseWM` and implements `IExampleWM`.
Check folder structure [page](/Peacock/folder-structure) to correctly create file.

``` dart
// example_w_m.dart
class ExampleWM extends BaseWM<ExampleView, ExampleModel>
    implements IExampleWM {
}
```
>**Note**
`BaseWM<W,M>` is base class that allows us to decrease repetable code. Simply it is a wrapper on `WidgetModel` class from `elementary` that contains needed dependencties. Consider that this class is generic and requires provide `Widget` and `Model`. There are cases when you don't need `Model` so you can use `BaseEmptyWM` or put `EmptyModel` except of provive some model.

Now we need to override all getters and functions that was defined before. Also we need to add all needed dependencies.
Firstly we need to add instanse of state.

```dart
// example_w_m.dart
final _state = EntityStateNotifier<bool>();
```
For this example `bloc` will be needed.

``` dart
// example_w_m.dart
final ExampleStoreBloc _store;
```
Override `state` getter.

``` dart
// example_w_m.dart
@override
ListenableState<EntityState<bool>> get state => _state;
```

Now we need override `theme` getter.
`example_w_m.dart`:
``` dart
@override
IExampleTheme get theme => getExtension<ExampleTheme<ExampleDefaultTheme>>();
```
> `getExtention()` is method from `BaseWM` class. It need to manage theme of widget that connect to our `wm`. How to create theme read [on this page](/Peacock/Architecture/application-layer-architecture).

Override `props` getter. You can follow the code below.

``` dart
// example_w_m.dart
  @override
  IExampleProps get props => ExampleProps(
        title: locale.aboutApp,
        subtitle: 'subtitle',
        counter: _counter,
      );
```
>Getter `locale` allows you manage localization. And manage displayed text.

To have acccess to localed getters you need add needed field into object inside `app_ru.arb` and `app_en.arb`.

``` dart
// ru.arb
  "aboutApp": "О приложении",
  "@aboutApp": {},
```

``` dart
// en.arb
  "aboutApp": "About app",
  "@aboutApp": {},
```

Run `make locale` commant into terminal.

It give you possibility ro mange localization in your `wm`.

``` dart
// example_w_m.dart
@override
  IExampleProps get props => ExampleProps(
        title: locale.aboutApp,
        subtitle: 'subtitle',
        counter: _counter,
      );
```
Because of we get `counter` from store define getter and call it `_counter`

``` dart
// example_w_m.dart
double get _counter => _store.state.counter;
```
Be sure that you have this `counter` in store.

Create construcror and factory.

``` dart
// example_w_m.dart
/* ------------------------------- Constructor ------------------------------ */
  ExampleWM(
    super.model,
    this._store,
  );
/* -------------------------------------------------------------------------- */
  factory ExampleWM.produce() {
    return ExampleWM(
      sl(),
      sl(),
    );
  }
/* -------------------------------------------------------------------------- */
```
> Read more about DI on special [page](/Peacock/Guidelines/dependency-injection).

To handle counter value and change view you need create listener on `store` stream.

``` dart
// example_w_m.dart
  void _initListeners() {
    _store.stream.listen(); // need to provide callback
  }
```
Function `listen()` need callback. Lets create it. And put it callbac to `listen()` function.
``` dart
// example_w_m.dart
  void _initListeners() {
    _store.stream.listen((event) => _listenerHandler());
  }
/* -------------------------------------------------------------------------- */
  void _listenerHandler() {
    _state.content(true);
  }
```
Every time when this callback will be called our view will be redrawed.

To initialize this listener we must call `_initListeners()` function inside `initWidgetModel()` method of superclass. Also on dispose `wm` we need to cancel listener. So for that we have `cancelAll()` method of `SubscriptionMixin`.

Add this mixin in the definition of `wm` class.

Should be:
``` dart
// example_w_m.dart
class ExampleWM extends BaseWM<ExampleView, ExampleModel>
    with SubscriptionMixin
    implements IExampleWM {// .. code}
```

Implement `initWidgetModel()` and `dispose()` methods.

```dart
// example_w_m.dart
/* -------------------------------------------------------------------------- */
  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _initListeners();
  }

/* -------------------------------------------------------------------------- */
  @override
  void dispose() {
    cancelAll();
    super.dispose();
  }
```
All that we need implement is `onTap()` function. This function will just call model method. 

``` dart
// example_w_m.dart
@override
void onTap() {
	model.inreaseCounter();
}
```
> There is no code with implementation of `increase()` method. But in reality it can be like that:
>```dart
> // example_model.dart
> void increase(){
>   _store.add(ExampleStoreEvent.increase())
>}
>```

So simple example of `wm` is ready. You can check full code below.
Full code;
``` dart
// example_w_m.dart
class ExampleWM extends BaseWM<ExampleView, ExampleModel>
    with SubscriptionMixin
    implements IExampleWM {
/* ------------------------------ Dependencies ------------------------------ */
  final _state = EntityStateNotifier<bool>();
/* -------------------------------------------------------------------------- */
  final ExampleStoreBloc _store;
/* -------------------------------------------------------------------------- */
  @override
  IExampleProps get props => ExampleProps(
        title: locale.aboutApp,
        subtitle: 'subtitle',
        counter: _counter,
      );
/* -------------------------------------------------------------------------- */
  @override
  ListenableState<EntityState<bool>> get state => _state;
/* -------------------------------------------------------------------------- */
  @override
  IExampleTheme get theme => getExtension<ExampleTheme<ExampleDefaultTheme>>();
/* -------------------------------------------------------------------------- */
  double get _counter => _store.state.counter;
/* ------------------------------- Constructor ------------------------------ */
  ExampleWM(
    super.model,
    this._store,
  );
/* -------------------------------------------------------------------------- */
  factory ExampleWM.produce() {
    return ExampleWM(
      sl(),
      sl(),
    );
  }
/* -------------------------------------------------------------------------- */
  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _initListeners();
  }

/* -------------------------------------------------------------------------- */
  @override
  void dispose() {
    cancelAll();
    super.dispose();
  }

/* ----------------------------- Implementation ----------------------------- */
  @override
  void onTap() {
    model.inreaseCounter();
  }

/* -------------------------------------------------------------------------- */
  void _initListeners() {
    _store.stream.listen((event) => _listenerHandler());
  }

/* -------------------------------------------------------------------------- */
  void _listenerHandler() {
    _state.content(true);
  }
/* -------------------------------------------------------------------------- */
}
```
## Testing
About testing `WidgetModels` check official `elementary_test` package [documentation](https://pub.dev/packages/elementary_test).

Example code for testing:
``` dart
// example_w_m_test.dart
import 'dart:async';

class MockExampleModel extends Mock implements ExampleModel {}

class MockThemeWrapper extends Mock implements ThemeWrapper {}

class MockAppLocalizationWrapper extends Mock
    implements AppLocalizationsWrapper {}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get aboutApp => '';
}

class MockExampleStoreBloc extends Mock implements ExampleStoreBloc {}

class MockExampleStoreState extends Mock implements ExampleStoreState {}

/* -------------------------------------------------------------------------- */
void main() {
/* -------------------------------------------------------------------------- */
  late ExampleModel model;
  late ThemeWrapper themeWrapper;
  late AppLocalizationsWrapper localizationsWrapper;
  late AppLocalizations appLocalizations;
  late ExampleWM wm;

  late ExampleStoreBloc bloc;
  late ExampleStoreState state;
  late StreamController<ExampleStoreState> controller;
/* -------------------------------------------------------------------------- */
  ExampleWM setupWm() {
    return ExampleWM(
      model,
      themeWrapper: themeWrapper,
      localizationsWrapper: localizationsWrapper,
    );
  }

/* -------------------------------------------------------------------------- */
  final sl = GetIt.instance;
  void setupInjection() {
    sl.registerLazySingleton(() => ExampleModel());
  }

/* -------------------------------------------------------------------------- */
  setUp(() {
    registerFallbackValue(WMContext());
    model = MockExampleModel();
    store = MockExampleStoreBloc();
    state = MockExampleStoreState();
    controller = StreamController.broadcast();
    wm = ExampleWM(model, store);

    when(() => localizationsWrapper.getLocalizations(any()))
        .thenReturn(appLocalizations);
    when(() => themeWrapper.getTheme(any())).thenReturn(AppTheme.themeDataDark);
    when(() => bloc.state).thenReturn(state);
    when(() => bloc.stream).thenAnswer(() => controller.stream);
  });
/* -------------------------------------------------------------------------- */
  group('[ExampleWM] ->', () {
    test('Should normally produce widget model', () async {
      // * Fixturing
      setupInjection();

      // ? Verification
      expect(() => ExampleWM.produce(), returnsNormally);
    });
    testWidgetModel<ExampleWM, ElementaryWidget>(
      "Should normally return getters",
      setupWm,
      (wm, tester, context) {
        // * Fixturing
        when(() => state.counter).thenReturn(1);

        // ! Executing
        tester.init();

        // ? Verification
        expect(() => wm.props, returnsNormally);
        expect(() => wm.state, returnsNormally);
        expect(() => wm.theme, returnsNormally);
        expect(wm.props.counter, 1);

        tester.unmount();
      },
    );
    testWidgetModel<ExampleWM, ElementaryWidget>(
      "Should call model's method on tap",
      setupWm,
      (wm, tester, context) {
        // * Fixturing
        when(() => model.increaseCounter()).thenAnswer((_) {});

        // ! Executing
        tester.init();
        wm.onTap();

        // * Verification
        verify(() => model.increaseCounter()).called(1);
        tester.unmount();
      },
    );
    testWidgetModel<ExampleWM, ElementaryWidget>(
      "Should update props on increased counter",
      setupWm,
      (wm, tester, context) {
        // * Fixturing
        when(() => state.counter).thenReturn(5);

        // ! Executing
        tester.init();
        controller.add(state)

        // * Verification
        expect(wm.state.value.data, isA<double>);
        expect(wm.state.value.data, 5);
        tester.unmount();
      },
    );
  });
}
```