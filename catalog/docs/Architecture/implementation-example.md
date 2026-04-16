# Implementation example

Let's implement a simple **increment button** vertical slice. Files are split like the rest of the app:

| Concern | Location |
|--------|----------|
| Domain + data (entity, use case, `IRepository`, repository, DTOs) | `lib/features/increment/` — `domain/`, `data/` only (no `presentation/`). |
| `ElementaryModel` that calls the use case | `lib/application/models/increment/` (e.g. `increment_model.dart`). |
| Reusable button **view** + **`IButtonVm`** contract | `lib/application/widgets/increment_button/` (widget + abstract `IButtonVm`). |
| Page root + **concrete** `WidgetModel` implementing `IButtonVm` | `lib/application/pages/increment_button/vm/` (e.g. `increment_button_vm.dart`). |

**Imports:** `features/<domain>` must not import `application`; `application` may import `features/<domain>` (use cases, entities) and `features/common` (shared types like `Failure`).

We need:

- View of button (reusable `ElementaryWidget` typed with `IButtonVm`)
- Concrete WM in `pages/.../vm/` implementing `IButtonVm`
- Increment model under `application/models/increment/`
- Use case + repository under `features/increment/`

## View

Colocated with **`IButtonVm`** under `application/widgets/increment_button/` (only the interface is shown here; the file `i_button_vm.dart` would sit beside the widget).

```dart

class Button extends ElementaryWidget<IButtonVm> {

	const Button(super.wmFactory, {super.key});
  
  @override
  Widget build(IButtonVm wm) {
  	return EntityStateNotifierBuilder<bool>(
    	entityNotifier: wm.state,
      builder: (context, data) {
      	return Button(
        	wm.props.title,
          onPress: wm.onClick,
        );
      },
    );
  }
}
```

## IVm + concrete WM

**`IButtonVm`** — abstract contract next to the reusable widget (`application/widgets/increment_button/i_button_vm.dart`). **`IncrementButtonVm`** — concrete `WidgetModel` under `application/pages/increment_button/vm/increment_button_vm.dart`.

```dart
abstract interface class IButtonVm extends IWidgetModel {
	ListenableState<EntityState<bool>> get state
	IButtonProps get props;
  
  void onClick();
}

class IncrementButtonVm extends WidgetModel<Button, IncrementModel> implements IButtonVm {

	final _state = EntityStateNotifier<bool>();

	@override
  ListenableState<EntityState<bool>> get state => _state;

	@override
  IButtonProps get props => ButtonProps(
  	title: Localization.of(context).increment + model.counter.toString(),
  );
  
  IncrementButtonVm(super.model);
  
  @override
  void onClick() async {
  	_state.loading();
    
  	final success = await model.increment();
    if (success) {
    	_state.content(true);
    } else {
    	_state.error();
      
      // Reset state after one second
      await Future.delayed(Duration(seconds: 1), () {
      	_state.content(true);
      });
    }
  }
}
```

## Props

```dart
abstract interface class IButtonProps {
	String get title;
}

class ButtonProps implements IButtonProps {
	final String title:
  
  const ButtonProps({
  	required this.title,
  });
}
```

## Model

`lib/application/models/increment/increment_model.dart` — calls `IncrementUseCase` from `lib/features/increment/domain/`.

```dart
class IncrementModel extends ElementaryModel {
	final IncrementUseCase _incrementUseCase;
	int _counter = 0;
  
  int get counter = _counter;
  
	IncrementModel(this._incrementUseCase);
  
  Future<bool> increment() async {
  	return _incrementUseCase
    	.map((e) => true)
      .getOrElse(() => false)
      .run();
  }
}
```

## UseCase

`lib/features/increment/domain/` (e.g. `increment_usecase.dart`).

```dart
class IncrementUseCase extends NoArgsUseCase<Unit> with NetworkConnectionMixin {
	final IIncrementRepository _repo;
  
  @override
  final NetworkConnection network;
  
  const IncrementUseCase(this.network, this._repo);
  
  ApiTask<Unit> call([params]) {
  	return runIfConnected(
    	_repo.increment(),
    );
  }
}
```

## Repository

`IIncrementRepository` in `lib/features/increment/domain/`; `IncrementRepository` in `lib/features/increment/data/`.

```dart

abstract interface class IIncrementRepository {
	ApiTask<Unit> increment();
}

class IncrementRepository implements IIncrementRepository {
	final Dio _client;

  const IncrementRepository(this._client);
  
  @override
  ApiTask<Unit> increment() {
  	return TaskEither.tryCatch(
    	() async {
        await _postIncrement();
        return unit;
      },
      (error, stacktrace) => failureOr((e) => const IncrementFailure()),
    );
  }

  Future<void> _postIncrement() async {
    try {
      await _client.post('https://increment.com');
    } on DioException catch (e) {
      throw timeoutFailureThrow(e)
          .flatMap(verifyErrorHasResponse)
          .map(transformData)
          .map(mapKnownFailures)
          .getOrElse(() => throw IncrementFailure());
    }
  }
}
```