import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:flutter_clean_boilerplate/features/users/data/repositories/users_repository.dart';

void main() {
  late Dio dio;
  late UsersRepository repository;

  setUp(() {
    dio = Dio(
      BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),
    );
    final adapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = adapter;
    adapter.onGet('/users', (server) {
      server.reply(
        200,
        [
          {
            'id': 1,
            'name': 'Leanne Graham',
            'username': 'Bret',
            'email': 'leanne@example.com',
            'phone': '1-770-736-8031',
          },
        ],
      );
    });
    repository = UsersRepository(dio);
  });

  test('getUsers maps JSON to entities', () async {
    final result = await repository.getUsers().run();

    expect(result.isRight(), isTrue);
    result.fold(
      (l) => fail('expected Right'),
      (users) {
        expect(users, hasLength(1));
        expect(users.first.name, 'Leanne Graham');
        expect(users.first.email, 'leanne@example.com');
      },
    );
  });
}
