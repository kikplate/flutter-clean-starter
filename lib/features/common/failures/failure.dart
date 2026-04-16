/// Base type for domain failures (left side of [TaskEither]).
abstract class Failure implements Exception {
  const Failure();
}

/// Generic failure when no specific case applies.
class UnknownFailure extends Failure {
  const UnknownFailure([this.cause]);

  final Object? cause;
}
