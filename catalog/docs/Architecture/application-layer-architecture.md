# Application layer architecture

As architectural decision for creating application level we're using `MVVM` pattern which is `Model` - `View` - `ViewModel`.

For the flutter project we're using [Elementary](https://pub.dev/packages/elementary) library as main contract for creating such architecture.

## Mapping to `lib/application`

All UI lives under **`lib/application/`** (see [folder structure](../folder-structure.md)): **`common/`**, **`widgets/`**, **`pages/`**, **`models/<domain>/`**. **Presentation is not placed under `lib/features/`**—each feature folder holds **domain + data only** (`lib/features/<domain>/domain`, `.../data`).

### Folders at a glance

| Path | Role |
|------|------|
| `application/common/` | Shared UI helpers (formatters, extensions, constants)—not domain rules. |
| `application/widgets/` | **Reusable** `ElementaryWidget`s; each ships with a colocated **`IVm`** interface (naming: `I` + purpose + `Vm`, e.g. `IAppPrimaryButtonVm`). No concrete `WidgetModel` here. |
| `application/pages/<page>/` | **Screen** root widget, page-only `widgets/`, and **`vm/`** for **concrete** WMs that implement the IVms used on that page + Elementary `WidgetModel`. |
| `application/models/<domain>/` | `ElementaryModel` subclasses that call use cases from `lib/features/<domain>/`. |

### IVm bridge for reusable widgets

A reusable widget must depend only on an **abstract IVm** (props, callbacks, optional `Listenable` / state), not on a concrete page WM. **Concrete** `WidgetModel` classes **implement** that IVm and live under **`application/pages/<page_name>/vm/`** (e.g. `UsersListRefreshButtonVm implements IAppRefreshButtonVm`). The page root composes reusable widgets and wires the WM factory so each reusable child receives the WM that implements its IVm.

Elementary’s own `IWidgetModel` still applies to **screen-level** WMs; IVm is an extra **narrow contract** for small reusable pieces so they stay decoupled from any single page.

Here's an example of library's architecture with we should follow:
```plantuml

abstract class ElementaryView<T extends IWidgetModel> {
	+ constructor(T Function() wmFactory)
}

abstract class IWidgetModel<V extends ElementaryView, M extends ElementaryModel> {
	+ constructor(M model)
  # V view
  # M model
}

abstract class ElementaryModel {}

ElementaryView --> IWidgetModel
IWidgetModel --> ElementaryModel
```

## Our extended architecture

The diagram below illustrates a **reusable** button: **`AppButtonView`** depends on **`IAppButtonVm`** (under `application/widgets/`), not on a concrete WM. **`LoginPrimaryButtonVm`** (under `application/pages/login/vm/`) implements `IAppButtonVm` and extends `WidgetModel` with the page’s `ElementaryModel`. For **page-only** buttons you may skip IVm and use a WM directly in `pages/<page>/vm/`.

As an example of a simple button to show the extended architecture:

```plantuml
abstract class ElementaryView<T extends IWidgetModel> {}

abstract class IWidgetModel<V extends ElementaryView, M extends ElementaryModel> {}

abstract class ElementaryModel {}

ElementaryView -up-|> IWidgetModel
IWidgetModel -down-> ElementaryView
IWidgetModel --> ElementaryModel

class AppButtonView {}

AppButtonView --|> ElementaryView : T = IAppButtonVm
AppButtonView --> AppButtonModel

class IAppButtonVm <<interface>> {
	+ EntityState<Entity> get state
	+ IAppButtonProps get props
  + IAppButtonTheme get theme
  
  + void onClick()
}

note right of IAppButtonVm
  Lives next to reusable
  widget under application/widgets/
end note

AppButtonView ..> IAppButtonVm : build(wm)

class LoginPrimaryButtonVm {}

LoginPrimaryButtonVm ..|> IAppButtonVm
LoginPrimaryButtonVm --|> IWidgetModel : V = AppButton, M = LoginModel

LoginPrimaryButtonVm --> AppButtonView
LoginPrimaryButtonVm --> AppButtonBloc
LoginPrimaryButtonVm --> IAppButtonProps
LoginPrimaryButtonVm --> IAppButtonTheme

class AppButtonBloc {}
abstract class Bloc<STATE, EVENT> {}

AppButtonBloc --> Bloc

class AppButtonModel extends ElementaryModel {}

abstract class IAppButtonProps {
	+ String buttonText
  + Icon? leadingIcon
  + Icon? tailingIcon
}

abstract class IAppButtonTheme {
	+ Size size
  + Color backgroundColor
  + TextStyle textStyle
}
```

In our case we have few main components of application layer:

- View
- WM (concrete `WidgetModel` under `application/pages/<page>/vm/`, often implementing a reusable **`IVm`**)
- `IVm` (abstract interface colocated with reusable widgets under `application/widgets/`)
- Model (`ElementaryModel` under `application/models/<domain>/`)
- BLoC (optional; state/cache where it fits)

**AppButtonView** is used for UI markup only. For a **reusable** button, the view is typed with **`IAppButtonVm`**; the **concrete** WM (e.g. `LoginPrimaryButtonVm`) implements that IVm and wires props, theme, and `onClick`.

**Concrete WM** provides data and theme to the view, handles local state, and bridges to the `ElementaryModel` / optional BLoC.

**Model** orchestrates use cases from `lib/features/<domain>/` (see [model](../Guidelines/model.md)).

**BLoC** is optional—use it as a state machine or cache when the feature benefits from it.


## View

View is the main part of UI. Only here existing all widgets which are gonna be rendered on the user's screen.

It extends from `ElementaryView` and requires one template argument `T` which should be type or subtype of `IWidgetModel`.

View's responsibility is one and only UI markup that's why in the `build` method of the view we don't have context because we don't need it at all. All information that should be inside widget is gonna be provided from upcoming `WidgetModel`.

General view signature looks like:
```dart
///
/// Specifying which WM's interface should be accepted by the View
///
class SomeView extends ElementaryView<ISomeWM> {

	///
  /// Accepting [wmFactory] which is function that returns
  /// instance of [ISomeWM].
  ///
	const SomeView(super.wmFactory, {super.key});

	///
  /// In the build method we're accepting instanse of [ISomeWM].
  ///
	@override
  Widget build(ISomeWM wm) {
  	...
  }
}
```

## WidgetModel

WidgetModel is responsable for few things:

- Provide all data that View needs to fulfill it's fields like username, date, simple text and etc.
- Provide theme and style data
- Handle client logic and state
- Be a bridge between UI and business logic

### Data provider

All our WMs serve as source of data to the View. For this goals we have and protocol for data.

```plantuml

interface IUserWM {
	+ IUserProps get props
}

abstract class IUserProps {
	+ String username
  + String firstName
  + String lastName
}

abstract class ElementaryView<T extends IWidgetModel> {}
class UserView {}


IUserWM --> IUserProps

UserView --|> ElementaryView : T = IUserWM
UserView --> IUserWM
```

We're saying that this WM should have a getter that is gonna return instance of `IUserProps` which is our protocol. View uses `props` field to fill markup with data and WM provides it.

### Style provider

On the other hand WMs are used to provide theme data to the view:

```plantuml
interface IButtonWM {
	+ IButtonTheme get theme
}

abstract class IButtonTheme {
	+ Color backgroundColor
  + TextStyle textStyle
  + Size size
}

IButtonWM --|> IButtonTheme

DefaultButtonTheme -up-|> IButtonTheme
InlineButtonTheme -up-|> IButtonTheme
DangerButtonTheme -up-|> IButtonTheme
```

Because of such separation concept we can easily change theme of the button not touching anything else.

### Client state and logic

WM also handles state of its view and logic that should be executed when user interracts with the view. In the button example we can have 3 states:

- Default
- Loading
- Error

and function `onClick` which will be executed when user clicks this button.

```plantuml

class IButtonWM extends IWidgetModel {
	+ EntityState<Entity> get state
	+ void onClick()
  - UserStoreBloc userStore
}

class UserStoreBloc {}
class UserModel {}

ButtonView --|> IButtonWM

class ButtonWM {}
ButtonWM --> UserStoreBloc
ButtonWM --> UserModel
ButtonWM -up-|> IButtonWM
```

When user clicks on the button WM it's gonna call model's methods to execute some logic. Until method is finished state will be `loading`.

When model executed state of the `UserStoreBloc` will be changed. WM will change state to `default` or `error` depending in the result. Also when model had executed logic state of the `Bloc` with user will be changed. From it WM can get some data and decide if it's gonna show `error` state or anything else.

Here's better example of using store:
```plantuml

class UserBlocStore {
	+ UserBlocState get state
}

class UserBlocState {
	+ String username
  + Uri? userAvatarUri
}

UserBlocStore --> UserBlocState

class UserAvatarView {}
class UserAvatarWM {}

UserAvatarWM --> UserBlocStore
UserAvatarView --|> UserAvatarWM
```

In this example WM gets all updated data from `UserBlocStore` and refreses the state of view if it's needed. Bloc's state change be changed by other models and components.


## Model

Model is a *business logic* layer of whole application layer. It means that only model decides which usecases we're gonna call, which data will we update in our stores and way of doing these things

```plantuml

abstract class EventBusProtocolHolder {}
class UserStoreBloc {}

class UserModel {
	- UserStoreBloc _userStore
  - EventBusProtocolHolder _bus
  
  + void updateUserInfo()
  + void resetPassword()
  + void changeUserAvatar()
}

UserModel --> UserStoreBloc
UserModel --> EventBusProtocolHolder

UserModel --> ChangeAvatarUseCase
UserModel --> ResetPasswordUseCase
UserModel --> UpdateUserInfoUseCase
```

When some method of `UserModel` is called it's gonna call needed usecases to execute application business logic. After executing model can change state of the store by sending event with new user data or/and send some event to application's global **bus** to notify non-related components that user's avatar was changed.

## BLoC as state machine

We're using `bloc` library as state machine or it's better to say as internal memory DB / Cache. That's why all events of every `bloc` look like `CRUD`s

```plantuml

class UserStoreBloc {}
class UserStoreEvent {
	+ factory UserStoreEvent.get()
  + factory UserStoreEvent.update()
  + factory UserStoreEvent.drop()
}

UserStoreBloc --> UserStoreEvent
```

## Pros and cons

This architecture has as positive sides and negative as well.

### Pros

**It's completly flexible:**

If you need to change style of current component you are going to the WM and changing only returned theme, because it returns interface you will break nothing. 

If you need to change title of current component you also going to the WM and changing what your props getter returns.

If you need to change logic that is gonna be executed you're going to the WM and changing method of model which should be called.

If you need to change business logic you're going to the model and changing usecases which methods of model call.

**Only if you need to change widget** you are going to the related View.

**Parts are separated:**

If you need to change how current component acts you just need to create new WM or use already created one. To change button from `LoginButton` to `LogoutButton` you need only change WM that is required for the View.

Parts like `Model` and `Bloc` can be used in other components so you don't write all business logic again and from every place you can get relevant data from `Bloc`s

Themes are also separated so you're just creating new one and you can use it in every comonent that requires that theme.

**Development speed:**

When you already have a lot of `View`s for creating UI mostly you need just to create or reuse `WM`s for the views. Because you have `Model`s which are already executes business logic and `Bloc`s which has data

**Testing:**

Every part easy to test because all of them has not heavy dependencies on each other. Also you know what to test:

- In `WM` you're testing that states are changing and they are correct. Also that data that you provide to view is valid and goes from right sources
- In `Model` that all your business logic executes in the right way
- In `Bloc` that you correctly store and provide data 
- In `View` that it looks like it should look

### Cons

**A lot of components:**

You need to know this architecture to undestand where the data goes, which component is responsible for what things

**Development time:**

To implement whole application layer it will take much time. If you don't already have components like `Bloc` or `Model` it will take much more time than you would have them
