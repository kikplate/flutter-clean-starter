# Implementation example

Let's implement simple increment button feature where we need:

- View of button
- WM of button
- Increment model
- Usecase
- Repository (performs HTTP and maps DTOs; no separate datasource type)

## View

```dart

class Button extends ElementaryWidget<IButtonWM> {

	const Button(super.wmFactory, {super.key});
  
  @override
  Widget build(IButtonWM wm) {
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

## WM

```dart
abstract interface class IButtonWM extends IWidgetModel {
	ListenableState<EntityState<bool>> get state
	IButtonProps get props;
  
  void onClick();
}

class ButtonWM extends WidgetModel<Button, IncrementModel> implements IButtonWM {

	final _state = EntityStateNotifier<bool>();

	@override
  ListenableState<EntityState<bool>> get state => _state;

	@override
  IButtonProps get props => ButtonProps(
  	title: Localization.of(context).increment + model.counter.toString(),
  );
  
  ButtonWM(super.model);
  
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