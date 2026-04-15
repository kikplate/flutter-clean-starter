# Usecases Guideline

Use Case is the main part of business logic that shows us what we can do with entities. For example `UploadProfilePictureUseCase` allows us to upload new profile picture for the users profile.

## Base class
All use cases are extends from base class 
```dart
abstract class UseCase<ReturnType, ParamsType> {
	const UseCase();
	TaskEither<Failure, ReturnType> call(ParamsType params);
}
```

> Now `TaskEither<Failure, R>` replaced with typedef `ApiTask<R>`. This is the same type but it simpler to write code with it

Default use case is generic with two typed params:
- `ReturnType` is the type which will be returned in the right operand of `TaskEither`.
- `ParamsType` is the type which will be used as type of argument in call function. 
Because of this generic we always know which type use case will return on success and which arguments in accepts to run itself.

## NoArgsUseCase
Is the use case that can be runned without any params. Its signature looks like that:
```dart
abstract class NoArgsUseCase<ReturnType> extends UseCase<ReturnType, dynamic> {
	@override
	TaskEither<Failure, ReturnType> call([dynamic params]);
}
```

> All use cases implementations should return `TaskEither` with right types. Read an article about [functional programming in dart]() to learn more about it

## Implementation guide
Below will be step-by-step guide **"How to create use case"**
### Choose proper name
Name of use case should explain an action that will be produced with entity. In our case it will be `UploadProfilePictureUseCase`

> Remember file naming conventions. With this name of class file should be named as `upload_profile_picture_use_case.dart`

Let's use snippet `ucsa` to get default code of use case. More about snippets you can read in the [article]()

The example will be look like that:
```dart
class NameUseCase extends UseCase<ReturnType, ParamsType> {
/* ------------------------------- Constructor ------------------------------ */
	NameUseCase();
/* ----------------------------- Implementation ----------------------------- */
	@override
	ApiTask<ReturnType> call(ParamsType params) {
		// TODO: implement call
		throw UnimplementedError();
	}
}
```

Change name, return type, params type, import dependencies and template of our use case will look like:
```dart
import 'dart:io';
 
import 'package:boilerplate_app/core/network/response_helpers.dart';
import 'package:boilerplate_app/core/usecases/usecase.dart';

class UploadProfilePictureUseCase extends UseCase<String, File> {
/* ------------------------------- Constructor ------------------------------ */
	UploadProfilePictureUseCase();
/* ----------------------------- Implementation ----------------------------- */
	@override
	ApiTask<String> call(File params) {
		// TODO: implement call
		throw UnimplementedError();
	}
/* -------------------------------------------------------------------------- */
}
```

### Work with network
As our use case will work with network to upload files we need to check network before we start do anything. For this we need `NetworkConnectionMixin`. Explanation of this mixin you can read in this [article]()

To use this flow we need with keyword `with` add mixin to our class and override needed dependencies like `NetworkConnection network`. After all these manipulations our class will look like:

```dart
class UploadProfilePictureUseCase extends UseCase<String, File> with NetworkConnectionMixin {
/* ------------------------------ Dependencies ------------------------------ */
	@override
	final NetworkConnection network;
/* ------------------------------- Constructor ------------------------------ */
	UploadProfilePictureUseCase(this.network);
/* ----------------------------- Implementation ----------------------------- */
	@override
	ApiTask<String> call(File params) {
		throw UnimplementedError();
	}
/* -------------------------------------------------------------------------- */
}
```


### Repository dependencies
Our use case somehow should call functions outside itself to get result. For this we are using interface of repository.

Interfaces allows us to create contract between use case and any class and its object. We are not dependent on any repository but we know that this any of them which will implement this interface are suitable for this use case.

Create `profile_repository.dart` in `domain/repositories` folder and implement interface like this:

```dart
abstract class ProfileRepository {
/* -------------------------------------------------------------------------- */
	///
	/// Uploads file to profile
	/// As result returns `String` as path to uploaded file
	///
	ApiTask<String> uploadProfilePicture(File params);
/* -------------------------------------------------------------------------- */
}
```

After that add dependency to our use case. And our code will look like that:
```dart
class UploadProfilePictureUseCase extends UseCase<String, File> with NetworkConnectionMixin {
/* ------------------------------ Dependencies ------------------------------ */
	@override
	final NetworkConnection network;
/* -------------------------------------------------------------------------- */
	final ProfileRepository _repository;
/* ------------------------------- Constructor ------------------------------ */
	UploadProfilePictureUseCase(this.network, this._repository);
/* ----------------------------- Implementation ----------------------------- */
	@override
	ApiTask<String> call(File params) {
		throw UnimplementedError();
	}
/* -------------------------------------------------------------------------- */
}
```

### Tests before implementation
Before every implementation of functionality of use case we need to write tests. For the snippets and helpers you can read in category [helpers]() of our documentation.

The first step is creating file in the same folder structure as our main use case but in `test` folder. In our case it will be: 
`test/features/profile/domain/usecases/upload_profile_picture_use_case_test.dart`

#### Define dependencies with `late`
```dart
/* -------------------------------------------------------------------------- */
/*                                   Values                                   */
/* -------------------------------------------------------------------------- */
late UploadProfilePictureUseCase useCase;
late ProfileRepository repository;
late NetworkConnection connection;
/* -------------------------------------------------------------------------- */
```

#### Define groups structure
As our use case works with network connection it will be good to split tests by groups. In our case we can do it like this:
```dart
void main() {
	group('[UploadProfilePictureUseCase] ->', () {
		group('[Online] ->', () {
			//
		});
		group('[Offline] ->', () {
			//
		});
	});
}
```

In the `Online` group we'll write tests when device is **Online** *(means device has network connection)*. And in the `Offline` when device doesn't have connection.

#### Mocking and  `setUp()` function
##### Mocking repository
As we don't wanna use real repository for our testing we should replace it with the mock one. About mocking you can read more in this [article]().

For mocking class you just need to extend from `Mock` class and implement interface of any class which you would like to mock.

```dart
/* -------------------------------------------------------------------------- */
/*                                   Mocking                                  */
/* -------------------------------------------------------------------------- */
class MockProfileRepository extends Mock implements ProfileRepository {}
```
> For mocking you should use `mocktail.dart` instead of old `mockito.dart`
And after mocking our dependencies we can run `setUp()` function which will be executed on start of any test:
##### Faking
As our use cases accepts `File` as argument and we don't want to put real file here we can fake this file. Do this easy as mocking:
```dart
/* -------------------------------------------------------------------------- */
/*                                   Faking                                   */
/* -------------------------------------------------------------------------- */
class FakeFile extends Fake implements File {}
```

And after we can use in in two ways:
- Put directly as argument
- Or register for `any()` function

Registration fallback allows us to use `any()` function in mocking responses and don't care about arguments of functions. It looks like:
```dart
	setUp(() {
		...
		registerFallbackValue(FakeFile());
		...
	});
	test('...', () async {
		...
		/// When you're using fallback values
		when(() => repository.uploadProfilePicture(any())).thenAnswer(...)
		/// or
		/// when you don't use fallback values
		when(() => repository.uploadProfilePicture(FakeFile()).thenAnswer(...)
	});
```
##### Making `setUp` function

```dart
...
void main() {
	setUp(() {
		connection = MockNetworkConnection();
		repository = MockProfileRepository();
		
		useCase = UploadProfilePictureUseCase(connection, repository);
	});
...
```
> For the network connection we already have one with built-in functions to test when device online or offline

#### Start to write tests
In any situation our use case will return `TaskEither` with only left or right param. It seems that we have 4 edge cases for our use case:
- When device online
	- Use case return right value on success
	- Internal repository error
- When device is offline
	- Even if repository supposed to return right value use case will return `NetworkFailure`
	- And also in the case when repository will return left value use case will return `NetworkFailure`
#### Implement first test
1. Create test and pass into callback function:
```dart
test('should return String on repository success', () async {
	
});
```
2. Setup values that will be used. In some cases they can be defined near definitions of `useCase`, `repository` as global values. It's useful when many tests use these values.
```dart
test('should return String on repository success', () async {
	// Setup
	const responseValue = 'filepath';
});
```
3. Setup behavior of our mocked objects. This code means that when anyone call `.uploadProfilePicture()` method of repository it will return value `TashEither.right(responseValue)`:
```dart
...
// * Fixturing
when(() => repository.uploadProfilePicture(any()))
	.thenReturn(TaskEither.right(responseValue));
...
```
5. Execute our use case. Response will contain `Either` object. You can read more about in [functional programming in dart article (fpdart)]()
```dart
...
// ! Executing
final response = await useCase(FakeFile()).run();
...
```
6. After that we need to verify that our use case returned value that we expected:
```dart
...
// ? Verification
expect(response.isRight(), true);
expect(response.getRight().toNullable(), responseValue);
...
```
7. Also we want to verify that our repository was called one time
```dart
verify(() => repository.uploadProfilePicture(any())).called(1);
```
#### Specify test to work as device online
For this we need to make two steps:
1. Place our test code in function
2. Run wrapper `runOnline` with our test function as running environment
Final code of the test will look like this:
```dart
test('should return String on repository success', () async {
	void stub() async {
	
		// Setup
		const responseValue = 'filepath';

		// * Fixturing
		when(() => repository.uploadProfilePicture(any()))
			.thenReturn(TaskEither.right(responseValue));

		// ! Executing
		final response = await useCase(FakeFile()).run();

		// ? Verification
		verify(() => repository.uploadProfilePicture(any())).called(1);
		expect(response.isRight(), true);
		expect(response.getRight().toNullable(), responseValue);
	}
	
	runOnline(stub, connection);
});
```

### Final tests code
```dart
/* -------------------------------------------------------------------------- */
/*                                   Mocking                                  */
/* -------------------------------------------------------------------------- */
class MockProfileRepository extends Mock implements ProfileRepository {}

/* -------------------------------------------------------------------------- */
/*                                   Faking                                   */
/* -------------------------------------------------------------------------- */
class FakeFile extends Fake implements File {}

/* -------------------------------------------------------------------------- */
/*                                   Values                                   */
/* -------------------------------------------------------------------------- */
late UploadProfilePictureUseCase useCase;
late ProfileRepository repository;
late NetworkConnection connection;
/* -------------------------------------------------------------------------- */

void main() {
  setUp(() {
    registerFallbackValue(FakeFile());
    connection = MockNetworkConnection();
    repository = MockProfileRepository();

    useCase = UploadProfilePictureUseCase(connection, repository);
  });
  group('[UploadProfilePictureUseCase] ->', () {
    group('[Online] ->', () {
      test('should return String on repository success', () async {
        void stub() async {
          // Setup
          const responseValue = 'filepath';

          // * Fixturing
          when(() => repository.uploadProfilePicture(any()))
              .thenReturn(TaskEither.right(responseValue));

          // ! Executing
          final response = await useCase(FakeFile()).run();

          // ? Verification
          verify(() => repository.uploadProfilePicture(any())).called(1);
          expect(response.isRight(), true);
          expect(response.getRight().toNullable(), responseValue);
        }

        runOnline(stub, connection);
      });
      test('should return Failure if repository fails', () async {
        void stub() async {
          // Setup
          const responseValue = UnknownFailure();

          // * Fixturing
          when(() => repository.uploadProfilePicture(any()))
              .thenReturn(TaskEither.left(responseValue));

          // ! Executing
          final response = await useCase(FakeFile()).run();

          // ? Verification
          verify(() => repository.uploadProfilePicture(any())).called(1);
          expect(response.isLeft(), true);
          expect(response.getLeft().toNullable(), responseValue);
        }

        runOnline(stub, connection);
      });
    });
    group('[Offline] ->', () {
      test('should return String on repository success', () async {
        void stub() async {
          // Setup
          const responseValue = 'filepath';

          // * Fixturing
          when(() => repository.uploadProfilePicture(any()))
              .thenReturn(TaskEither.right(responseValue));

          // ! Executing
          final response = await useCase(FakeFile()).run();

          // ? Verification
          verify(() => repository.uploadProfilePicture(any())).called(1);
          expect(response.isLeft(), true);
          expect(response.getLeft().toNullable(), isA<NetworkFailure>());
        }

        runOffline(stub, connection);
      });
      test('should return Failure if repository fails', () async {
        void stub() async {
          // Setup
          const responseValue = UnknownFailure();

          // * Fixturing
          when(() => repository.uploadProfilePicture(any()))
              .thenReturn(TaskEither.left(responseValue));

          // ! Executing
          final response = await useCase(FakeFile()).run();

          // ? Verification
          verify(() => repository.uploadProfilePicture(any())).called(1);
          expect(response.isLeft(), true);
          expect(response.getLeft().toNullable(), isA<NetworkFailure>());
        }

        runOffline(stub, connection);
      });
    });
  });
}
```

### Implementing use case functionality
Call function in the use case should do two things:
1. Run use case if device is online
2. Call proper function from repository
The executable code will look like:
```dart
...
@override
ApiTask<String> call(File params) {
	return runIfConnected(
		_repository.uploadProfilePicture(params),
	);
}
...
```

### Running all tests
When we will run all our written tests we will get logs with response. If we did right tests and made our functionality in right way we will get all tests as successful:
```
✓ [UploadProfilePictureUseCase] -> [Online] -> should return String on repository success
✓ [UploadProfilePictureUseCase] -> [Online] -> should return Failure if repository fails
✓ [UploadProfilePictureUseCase] -> [Offline] -> should return String on repository success
✓ [UploadProfilePictureUseCase] -> [Offline] -> should return Failure if repository fails
```
