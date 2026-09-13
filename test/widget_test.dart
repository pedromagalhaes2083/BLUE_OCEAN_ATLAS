import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/features/auth/presentation/login_screen.dart';
import 'package:atlas/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('Tela de login exibida quando não há sessão',
      (WidgetTester tester) async {
    final dbHelper = DatabaseHelper.instance;

    await tester.pumpWidget(
      MaterialApp(
        // Mesmos delegates/locales de main.dart — sem eles,
        // AppLocalizations.of(context) não encontra nada pra resolver e a
        // tela nem chega a construir (ver LoginScreen, que já usa l10n).
        // `locale` fixo em pt — sem isso, o ambiente de teste resolve pro
        // locale padrão dele (en_US), e os textos esperados abaixo (em
        // português) não batem.
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginScreen(dbHelper: dbHelper),
      ),
    );

    expect(find.text('Atlas Blue Ocean'), findsOneWidget);
    expect(find.text('Login do Mestre'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });
}
