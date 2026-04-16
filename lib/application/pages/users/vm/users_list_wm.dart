import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';

import '../../../../features/common/failures/failure.dart'
    show Failure, UnknownFailure;
import '../../../../features/users/domain/failures/users_failure.dart';
import '../../../models/users/users_list_model.dart';
import '../i_users_list_vm.dart';

class UsersListWM extends WidgetModel<ElementaryWidget<IUsersListVm>, UsersListModel>
    implements IUsersListVm {
  UsersListWM(super.model);

  final ValueNotifier<UsersListScreenState> _screenState =
      ValueNotifier(UsersListScreenState.loading());

  @override
  ValueListenable<UsersListScreenState> get screenState => _screenState;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _load();
  }

  Future<void> _load() async {
    _screenState.value = UsersListScreenState.loading();
    final result = await model.loadUsers();
    result.fold(
      _onFailure,
      (users) => _screenState.value = UsersListScreenState.ready(users),
    );
  }

  void _onFailure(Failure failure) {
    final message = switch (failure) {
      UsersFailure(:final message) => message ?? 'Network error',
      UnknownFailure(:final cause) => cause?.toString() ?? 'Unknown error',
      _ => failure.toString(),
    };
    _screenState.value = UsersListScreenState.error(message);
  }

  @override
  void retry() => _load();

  @override
  void dispose() {
    _screenState.dispose();
    super.dispose();
  }
}
