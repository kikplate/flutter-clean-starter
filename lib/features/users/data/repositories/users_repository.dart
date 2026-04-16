import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../common/failures/failure.dart';
import '../../../common/types/api_task.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/users_failure.dart';
import '../../domain/repositories/i_users_repository.dart';
import '../dtos/user_dto.dart';

@LazySingleton(as: IUsersRepository)
class UsersRepository implements IUsersRepository {
  UsersRepository(this._dio);

  final Dio _dio;

  @override
  ApiTask<List<User>> getUsers() {
    return TaskEither.tryCatch(
      () async {
        final response = await _dio.get<List<dynamic>>('/users');
        final data = response.data ?? <dynamic>[];
        return data
            .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
            .map((dto) => dto.toEntity())
            .toList();
      },
      (error, stackTrace) {
        if (error is DioException) {
          return UsersFailure.network(error.message);
        }
        return UnknownFailure(error);
      },
    );
  }
}
