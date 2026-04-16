import '../../../common/types/api_task.dart';
import '../entities/user.dart';

/// Contract for loading users (implemented in data layer).
abstract class IUsersRepository {
  ApiTask<List<User>> getUsers();
}
