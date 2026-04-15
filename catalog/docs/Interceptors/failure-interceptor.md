# Failure interceptor

## Handling principles

We have two ways of handling errors:

- First one is automatic handling with interceptors
- Second is manually handle error whenever it's needed

As first case should be automatic we shouldn't care about this type of errors on business layer *(meaning in usecases and models)* so the logic of handling should be kind of specific.

Second way is widely used in application because it's also a part of business logic when you couldn't do something you're gonna have a related error.

> In this article we're gonna touch only interceptors
{.is-info}

## Failure interceptors

For any `http` error we could have few possibilities what happend:

- `401 Unauthorized` error which can mean two things:
  - Our access token is expired and we need to update it
  - Or we're not authorized
- We got unexpected error which is not in out case

Related to our authentication process lifetime of access token is too short to use only one while whole application session. That means that we need to update access token regularly. As the solution we have an interceptor.

### UnauthorizedInterceptor

`UnauthorizedInterceptor` plays a role in the system where it responsible to handle refreshing all tokens that we have.

> Now we have at least two tokens: `Kaiser` token for our servies and `Trudesk` token for our support system.
{.is-info}

Logic if this interceptor is so simple:

- When we're quering anything from our system's endpoints this interceptor attaches authorization token to headers
- But if endpoints are related to support system we're gonna add access token of `Trudesk`

On the other side when error happens while request this interceptor is gonna:

- Check if this error is `401 Unauthorized`. If it's not this interceptor will skip it's logic
- When interceptor got `401` it's gonna try to refresh tokens:
  - Firstly we're getting our stored tokens
  - Calling usecase which is responsible for refreshing tokens
    - If usecase completed successfuly it's gonna try call previous request again
    - But if we couldn't refresh tokens interceptor will return error

### FailureHandlerInterceptor

To know which errors mostly happening with user while it uses application related to `http` we have another interceptor called `FailureHandlerInterceptor`.

This interceptor is used to send event to any kind of metricas that application faced with network error.

> Now we're using Yandex's `AppMetrica` for storing such things
{.is-info}

So on any network failure this interceptor is gonna build report message of error with description and send events to metrica.