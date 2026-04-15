# Bloc guideline

## General information
In Flutter, a Bloc (short for Business Logic Component) is a design pattern that helps to manage the state of a widget or an application. It separates the business logic from the UI components, making the code more organized and easier to maintain. 
 
A Bloc typically consists of the following components: 
1. Events: Represent the different actions that can occur in the application. 
2. State: Represents the current state of the application based on the events that have occurred. 
3. Logic: Contains the business logic to handle events and update the state accordingly. 
 
By using Blocs, developers can create reactive and scalable applications that are easier to test and maintain. Flutter provides packages like  flutter_bloc  and  bloc  to implement the Bloc pattern efficiently.

## In our application
Usually we use for state managment. Because of business logic lays on another layers.
Let's create our own `bloc` for our application to understand how we use it in application. 

### Implementation.
To fastly create bloc you can right click on folder where you want to create bloc. Choose `Bloc: New Bloc`.
In popup choose name for your `Bloc`. For example it will be `ExampleStore`. `Example` - domain name, `Store` - definition how it used.

After steps above it will generate folder `bloc` with three files:  `ExampleStoreBloc`, `ExampleStoreState`, `ExampleStoreEvent`.
Go to `ExampleStoreState` to change file. Here we need two states: `resolved` and `loading`.
Follow example of code below:
``` dart
@freezed
class ExampleStoreState with _$ExampleStoreState {
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreState.loading({
    @Default([]) List<Example> examples,
  }) = _Loading;
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreState.resolved({
    @Default([]) List<Example> examples,
  }) = _Resolved;
/* -------------------------------------------------------------------------- */
}
```
At next step go to `ExampleStoreEvent` to change file. Here we need to add all possible events. For example we add 3 events: `addExamples`, `deleteExampleById`, `deleteAll`.

``` dart
@freezed
class ExampleStoreEvent with _$ExampleStoreEvent {
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreEvent.addExamples(List<Example> examples) =
      _AddExamples;
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreEvent.deleteExampleById(String id) =
      _DeleteExampleById;
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreEvent.deleteAll() = _DeleteAll;
/* -------------------------------------------------------------------------- */
}
```
Go to `ExampleStoreBloc` to change file. First of all we need to change constructor. Just add `on<EventName>` to every event defined before and call neccessary function. Don't foreget to add initial state.
Example code:

``` dart
  ExampleStoreBloc() : super(const _Resolved(examples: [])) {
    on<_AddExamples>(_addExamples);
    on<_DeleteExampleById>(_deleteExampleById);
    on<_DeleteAll>(_deleteAll);
  }
```
Add type `_EmmiterT` outside of class it will be needed later.
```dart
typedef _EmitterT = Emitter<ExampleStoreState>;
```
Define method `emitLoading()`. This method contains of emitting loading state. so because we will use if inside every methods it would be better to separate it in another function.
``` dart
  void _emitLoading(_EmitterT emit) {
    emit(_Loading(
      examples: state.examples,
    ));
  }
```

So as you can see we provided callbacks to `on()`. Now we must implement this methods. All of them contains of some logic.
Check example code:

``` dart
void _addExamples(_AddExamples event, _EmitterT emit) {
	_emitLoading(emit);
    emit(
	   _Resolved(
      examples: [
        ...List.of(state.examples).filter((t) => !event.examples.contains(t)),
        ...event.examples.toSet(),
      ],
    ),
  );
}

/* -------------------------------------------------------------------------- */
void _deleteExampleById(_DeleteExampleById event, _EmitterT emit) {
  _emitLoading(emit);
  emit(
    _Resolved(
      examples: [
        ...List.of(state.examples).filter((t) => t.id != event.id),
      ],
    ),
  );
}

/* -------------------------------------------------------------------------- */
void _deleteAll(_DeleteAll event, _EmitterT emit) {
  _emitLoading(emit);
  emit(
    const _Resolved(
      examples: [],
    ),
  );
}
```
### Full code
`example_store_bloc.dart`:
```dart
import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_store_event.dart';
part 'example_store_state.dart';
part 'example_store_bloc.freezed.dart';

typedef _EmitterT = Emitter<ExampleStoreState>;

class ExampleStoreBloc extends Bloc<ExampleStoreEvent, ExampleStoreState> {
  ExampleStoreBloc() : super(const _Resolved(examples: [])) {
    on<_AddExamples>(_addExamples);
    on<_DeleteExampleById>(_deleteExampleById);
    on<_DeleteAll>(_deleteAll);
  }

  /* -------------------------------------------------------------------------- */
  void _emitLoading(_EmitterT emit) {
    emit(_Loading(
      examples: state.examples,
    ));
  }

/* -------------------------------------------------------------------------- */
  void _addExamples(_AddExamples event, _EmitterT emit) {
    _emitLoading(emit);
    emit(
      _Resolved(
        examples: [
          ...List.of(state.examples).filter((t) => !event.examples.contains(t)),
          ...event.examples.toSet(),
        ],
      ),
    );
  }

/* -------------------------------------------------------------------------- */
  void _deleteExampleById(_DeleteExampleById event, _EmitterT emit) {
    _emitLoading(emit);
    emit(
      _Resolved(
        examples: [
          ...List.of(state.examples).filter((t) => t.id != event.id),
        ],
      ),
    );
  }

/* -------------------------------------------------------------------------- */
  void _deleteAll(_DeleteAll event, _EmitterT emit) {
    _emitLoading(emit);
    emit(
      const _Resolved(
        examples: [],
      ),
    );
  }
/* -------------------------------------------------------------------------- */
}

```

`example_store_event.dart`:
```dart
part of 'example_store_bloc.dart';

@freezed
class ExampleStoreEvent with _$ExampleStoreEvent {
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreEvent.addExamples(List<Example> examples) =
      _AddExamples;
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreEvent.deleteExampleById(String id) =
      _DeleteExampleById;
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreEvent.deleteAll() = _DeleteAll;
/* -------------------------------------------------------------------------- */
}
```

`example_store_state.dart`:
``` dart
part of 'example_store_bloc.dart';

@freezed
class ExampleStoreState with _$ExampleStoreState {
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreState.loading({
    @Default([]) List<Example> examples,
  }) = _Loading;
/* -------------------------------------------------------------------------- */
  const factory ExampleStoreState.resolved({
    @Default([]) List<Example> examples,
  }) = _Resolved;
/* -------------------------------------------------------------------------- */
}
```


## Testing
You can read about testing blocs on package [documentation](https://pub.dev/packages/bloc_test) or on official [website](https://bloclibrary.dev/testing/).	
