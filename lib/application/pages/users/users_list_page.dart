import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';

import '../../../bootstrap/di/injection.dart';
import '../../../features/users/domain/entities/user.dart';
import '../../models/users/users_list_model.dart';
import 'i_users_list_vm.dart';
import 'vm/users_list_wm.dart';

UsersListWM _defaultUsersListWmFactory(BuildContext context) {
  return UsersListWM(getIt<UsersListModel>());
}

class UsersListPage extends ElementaryWidget<IUsersListVm> {
  const UsersListPage({
    super.key,
    WidgetModelFactory<UsersListWM> wmFactory = _defaultUsersListWmFactory,
  }) : super(wmFactory);

  @override
  Widget build(IUsersListVm wm) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: ValueListenableBuilder<UsersListScreenState>(
        valueListenable: wm.screenState,
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: wm.retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final users = state.users;
          if (users == null || users.isEmpty) {
            return const Center(child: Text('No users'));
          }
          return _UsersListView(users: users);
        },
      ),
    );
  }
}

class _UsersListView extends StatelessWidget {
  const _UsersListView({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final u = users[index];
        return ListTile(
          title: Text(u.name),
          subtitle: Text(u.email),
        );
      },
    );
  }
}
