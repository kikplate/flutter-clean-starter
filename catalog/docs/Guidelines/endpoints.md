# Endpoints guideline

In our application to call backends API we have `endpoints`. `Endpoints` is a classes that help us easily construct correct URL paths.
Every endpoint name should contains `feature name` and suffux `endpoints`.
For example `ExampleEndpoints` class allows us create endpoints for `Example` feature.

>**Note**
Every endpoint should be extended by `Endpoints` that lays in core of our app.

```dart
class ExampleEndpoints extends Endpoints{
/* -------------------------------------------------------------------------- */
}
```
Because of separating every endpoint by feature you should add private field with name of feature. It needed to create general endpoint to backend.

``` dart
class ExampleEndpoints extends Endpoints {
/* -------------------------------------------------------------------------- */
  final String _example;
/* -------------------------------------------------------------------------- */
  String get example =>  buildApiEndpoint(_example);
}
```
`buildApiEndpoint()` is a method of supercalss that returns you composed `baseUri`, `apiVersion`, `_exapmle`. 

In this case if `_example` value will be "example" it will return something like this `http://localhost/api/v1/example`.

Create constructor of this class. Don't forget to define required fields of super class: `baseUri` and `apiVersion`.

```dart
/* -------------------------------------------------------------------------- */
ExampleEndpoints({
	required super.baseUrl,
	required super.apiVersion,
	required String example,
}) : _example = example;
/* -------------------------------------------------------------------------- */
```

After creating endpoint. Register it inside `EndpointsProvider`. This file allows you use your new endpoints from DI. 
Add to the end of file `endpoints_provider.dart`:
```dart 
  static ExampleEndpoints provideExampleEndpoints(
    BaseConfig env,
  ) {
    return ExampleEndpoints(
      baseUrl: env.gatewayUriBuilder.http,
      apiVersion: 'api/v1',
      example: 'example',
    );
  }
```

If you need to add some queries to your endpoint you need to add special method.
For example add method called `fetchExample(String exampleId)`. 
Return type of this method should be `({Map<String, String> query, String url})`
Add `_byQueryId` to dependency and constructor.

As you can see your function has required param `exampleId`. So whenever you call method and provide `exampleId` of this class it will returns to you correct url with query

``` dart
  ({String url, Map<String, String> query}) fetchExample(
    String exampleId,
  ) {
    return (
      url: example, // this is defined getter
      query: {
        _byIdQuery: exampleId,
      },
    );
  }
```

After that you can call `fetchExample(String exampleId)` and take getters `url` and `query`.

Full example code:
``` dart
import 'package:boilerplate_app/core/endpoints.dart';

class ExampleEndpoints extends Endpoints {
/* -------------------------------------------------------------------------- */
  final String _example;
/* -------------------------------------------------------------------------- */
  final String _byIdQuery;
/* -------------------------------------------------------------------------- */
  String get example => '';
/* -------------------------------------------------------------------------- */
  ExampleEndpoints({
    required super.baseUrl,
    required super.apiVersion,
    required String example,
    required String byIdQuery,
  })  : _example = example,
        _byIdQuery = byIdQuery;
/* -------------------------------------------------------------------------- */
  ({String url, Map<String, String> query}) fetchExample(
    String exampleId,
  ) {
    return (
      url: example, // this is defined getter
      query: {
        _byIdQuery: exampleId,
      },
    );
  }
}

```
