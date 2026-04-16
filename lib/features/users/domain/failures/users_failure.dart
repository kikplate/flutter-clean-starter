import '../../../common/failures/failure.dart';

/// Failures specific to the users feature.
final class UsersFailure extends Failure {
  const UsersFailure.network([this.message]);

  final String? message;
}
