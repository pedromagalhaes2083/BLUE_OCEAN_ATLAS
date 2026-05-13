import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/main.dart'; // ajuste se o nome do pacote for diferente
import 'package:atlas/core/database/database_helper.dart';

void main() {
  testWidgets('App deve iniciar sem erros', (WidgetTester tester) async {
    // Inicializa o DatabaseHelper para o teste
    final dbHelper = DatabaseHelper.instance;

    // Constrói o app
    await tester.pumpWidget(
      AtlasBlueOceanApp(dbHelper: dbHelper),
    );

    // Verifica se o app carregou corretamente
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Atlas Blue Ocean'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cartas'), findsOneWidget);
    expect(find.text('Produção'), findsOneWidget);

    // Verifica se a Dashboard está visível (aba 0)
    expect(find.text('Bem-vindo, Mestre!'), findsOneWidget);
  });
}
