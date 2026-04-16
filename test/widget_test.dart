import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:flutter_clean_boilerplate/bootstrap/di/injection.dart';
import 'package:flutter_clean_boilerplate/main.dart';

void main() {
  setUp(() {
    getIt.reset();
    configureDependencies();
    final dio = getIt<Dio>();
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/users', (server) {
      server.reply(
        200,
        [
          {
            'id': 1,
            'name': 'Test User',
            'username': 'test',
            'email': 'test@example.com',
            'phone': '000',
          },
        ],
      );
    });
  });

  testWidgets('MyApp builds and shows users screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Test User'), findsOneWidget);
  });
}
