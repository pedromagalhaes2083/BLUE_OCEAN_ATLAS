import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'core/services/alerta_condicao_notification_service.dart';
import 'core/services/recomendacao_notification_service.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/cartas/presentation/cartas_screen.dart';
import 'features/mapa/presentation/mapa_screen.dart';

class AppShell extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const AppShell({super.key, required this.dbHelper});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verificarCondicoesAoRetomar();
    }
  }

  /// Roda a mesma checagem de condição severa/recomendação nova que o
  /// WorkManager faz a cada 15 min, mas na hora em que o app volta ao
  /// primeiro plano — sem isso, reabrir o app durante uma viagem podia
  /// mostrar uma condição já ultrapassada por até 15 minutos (o pior caso
  /// do ciclo periódico do Android). Só dispara com viagem em andamento —
  /// mesmo escopo do rastreamento em segundo plano; fora de viagem não tem
  /// ponto à frente pra projetar.
  Future<void> _verificarCondicoesAoRetomar() async {
    try {
      final emAndamento = await widget.dbHelper.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      if (emAndamento.isEmpty) return;
      await AlertaCondicaoNotificationService.verificarCondicoesAFrente();
      await RecomendacaoNotificationService.verificarNovas();
    } catch (_) {
      // Melhor esforço — o ciclo periódico do WorkManager cobre o resto.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue[700],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Cartas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(dbHelper: widget.dbHelper);
      case 1:
        return CartasScreen(dbHelper: widget.dbHelper);
      case 2:
        return const MapaScreen();
      default:
        return DashboardScreen(dbHelper: widget.dbHelper);
    }
  }
}
