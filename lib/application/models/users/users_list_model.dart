import 'package:elementary/elementary.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../features/common/failures/failure.dart';
import '../../../features/users/domain/entities/user.dart';
import '../../../features/users/domain/usecases/get_users_usecase.dart';

@injectable
class UsersListModel extends ElementaryModel {
  UsersListModel(this._getUsersUseCase);

  final GetUsersUseCase _getUsersUseCase;

  Future<Either<Failure, List<User>>> loadUsers() => _getUsersUseCase.run();
}
