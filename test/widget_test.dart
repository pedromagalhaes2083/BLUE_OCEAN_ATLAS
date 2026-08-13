import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Tela de login exibida quando não há sessão',
      (WidgetTester tester) async {
    final dbHelper = DatabaseHelper.instance;

    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(dbHelper: dbHelper)),
    );

    expect(find.text('Atlas Blue Ocean'), findsOneWidget);
    expect(find.text('Login do Mestre'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });
}
