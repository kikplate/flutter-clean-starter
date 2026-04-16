import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_clean_boilerplate/features/common/failures/failure.dart';
import 'package:flutter_clean_boilerplate/features/users/domain/entities/user.dart';
import 'package:flutter_clean_boilerplate/features/users/domain/repositories/i_users_repository.dart';
import 'package:flutter_clean_boilerplate/features/users/domain/usecases/get_users_usecase.dart';

class _MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  test('delegates to repository', () async {
    final repo = _MockUsersRepository();
    const users = [User(id: 1, name: 'A', email: 'a@b.com')];
    when(() => repo.getUsers()).thenReturn(
      TaskEither<Failure, List<User>>.right(users),
    );

    final useCase = GetUsersUseCase(repo);
    final result = await useCase.run();

    result.fold(
      (l) => fail('unexpected Left: $l'),
      (r) => expect(r, users),
    );
    verify(() => repo.getUsers()).called(1);
  });
}
