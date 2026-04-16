import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../common/failures/failure.dart';
import '../../../common/types/api_task.dart';
import '../entities/user.dart';
import '../repositories/i_users_repository.dart';

@injectable
class GetUsersUseCase {
  GetUsersUseCase(this._repository);

  final IUsersRepository _repository;

  ApiTask<List<User>> call() => _repository.getUsers();

  Future<Either<Failure, List<User>>> run() => call().run();
}
