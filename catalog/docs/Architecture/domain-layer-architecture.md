# Domain layer architecture

In the application we have designed domain layer architecture. It consists of:

- Entities
- Usecases
- Failures
- Repositories
- Params, Enums and etc.

## Entities

Entity is a core of whole architecture and around entity everything is building up. Also entity is only data representing part of our system. Let's describe it in diagram:

```plantuml

class User {
	+ final String username
  + final String userId
  + final UserProfile profile
  + final UserContacts contacts
}

class UserProfile {
	+ final String firstname
  + final String lastname
  + final Uri avatarUri
}

class UserContacts {
	+ final String phoneNumber
  + final String email
}

User --> UserProfile
User --> UserContacts
```

In the current diagrams we have 3 entities each of them serves for one and only purpose. 

One is responsible for holding all information about user, second one all about user data like firstname or avatar, third one is about to keep user's contacts information. There can be a lot more entities which are connected to each other.

Arround these entites we're building our system (in our case it's application)

> Application's entities can be different from for example server entities because they are not related to business completley. They are representing current system core. For sure it's better to have them in connection with business entities. But for example we can have `AuthorizationData` entity which will hold all user's authoruzation information but for business this entity is useless


## UseCases

We can think about usecase as a method of an entity. Basically it's some of user's business tasks like **create account** or **update avatar photo**. In a nutshell some atomic function that user wants to perform with application.

```plantuml

:User: as User

(Create account) as CreateAccountUseCase
(Set information) as SetInfoUseCase
(Upload avatar photo) as UploadAvatarUseCase

(Login) as LoginUseCase
(Get access tokens) as GetAcccessTokensUseCase
(Refresh tokens) as RefreshTokensUseCase

LoginUseCase --> GetAcccessTokensUseCase
LoginUseCase --> RefreshTokensUseCase

(Reset password) as ResetPasswordUseCase
(Send confirmation email) as SendConfirmationEmailUseCase
(Set new password) as SetNewPasswordUseCase

ResetPasswordUseCase --> SendConfirmationEmailUseCase
ResetPasswordUseCase --> SetNewPasswordUseCase

User --> LoginUseCase
User --> CreateAccountUseCase
User --> ResetPasswordUseCase
User --> SetInfoUseCase
User --> UploadAvatarUseCase
```

As shown in the diagram one usecase can also include some of other usecases to separate concerns to smaller things.

In the relations to the entities it's gonna look like:

```plantuml

class User {}

class GetUserUseCase {
	+ User call()
}

class UpdateUserUseCase {
	+ User call(User user)
}

GetUserUseCase --> User
UpdateUserUseCase --> User
```

Usecases getting entities to perform actions on them or just getting them from defined source like repository. If something goes wrong with usecase it's gonna return `Failure`. Failures and repositories are described below.

## Failures

Failures is our own defined `Exception` like entities for marking that usecase couldn't do it's job and returned error. In our case as we're using functional programming for business logic we don't need exceptions, don't neet to write `try-catch` blocks and care about failures only when it's needed.

All failures are extended from base class `Failure` and follow some rules:

- Each domain has it's own base failure
- All failures in the domain should be extended from base failure of this domain
- Failures can have keys to identify and localize errors to the user

As failures are in the domain layer they can be user wherever we want in the application which makes easy to handle localization for errors supported by failure keys

```plantuml
abstract class Failure {
	+ String get key
	- final List<dynamic> keys
}

class ChatFailure extends Failure {
	+ const ChatFailure('chat')
}

class ChatSocketConnectionFailure extends ChatFailure {
	+ const ChatFailure('socketConnection')
}
```

According this diagram we always know 3 things:

- In which domain error happened: Chat, because of ChatFailure base failure
- Exact error: socket connection error
- Localization keys aka path: it's gonna be a string "chat.socketConnection". By this string we can show to user localized text of error

## Repositories

Repository is a trusted source of data for usecase. But repository itself lays on the data layer. On the domain layer we have only interface of repoitory as a contract which data should return repository and which actions to perform.

```plantuml
class IUserRepository {
	+ User fetchUser()
  + User getUser()
  + User updateUser()
  + void deleteUser()
  + void storeUser()
}

class GetUserDataUseCase {}
class GetUserUseCase {}

GetUserDataUseCase --> IUserRepository
GetUserUseCase --> IUserRepository
```

GetUserUseCase is calling `getUser` and `fetchUser` methods of repository to get result that it should return as an output.

> `Fetch` in our naming means loading from a **remote** source; `get` means reading from **local** storage. Both are implemented on the **repository** (data layer); there is no separate datasource layer.

## Enums, Params and etc.

All basics parts which are related to usecases and entities are also should be on the domain layer. For example user's sex can be a enum:

```plantuml

enum Sex {
	+ male
  + female
  + notSpecified
}

class User {}

User --> Sex
```

So as usecase can accept few parameters to be executed they should be also on domain layer:

```plantuml
class CreateUserParams {
	+ String firstname
  + String lastname
  + String username
  + String password
}

class CreateUserUseCase {
	+ User call(CreateUserParams params)
}

CreateUserUseCase --> CreateUserParams
```