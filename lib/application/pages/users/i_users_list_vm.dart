import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';

import '../../../features/users/domain/entities/user.dart';

/// Screen-level IVm: contract [UsersListPage] builds against. [UsersListWM]
/// implements this.
abstract interface class IUsersListVm implements IWidgetModel {
  ValueListenable<UsersListScreenState> get screenState;

  void retry();
}

/// Snapshot the view reads via [IUsersListVm.screenState].
class UsersListScreenState {
  const UsersListScreenState({
    required this.isLoading,
    this.users,
    this.errorMessage,
  });

  final bool isLoading;
  final List<User>? users;
  final String? errorMessage;

  factory UsersListScreenState.loading() =>
      const UsersListScreenState(isLoading: true);

  factory UsersListScreenState.ready(List<User> users) =>
      UsersListScreenState(isLoading: false, users: users);

  factory UsersListScreenState.error(String message) =>
      UsersListScreenState(isLoading: false, errorMessage: message);
}
