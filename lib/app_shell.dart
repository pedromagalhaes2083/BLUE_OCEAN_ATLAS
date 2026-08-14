import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/cartas/presentation/cartas_screen.dart';
import 'features/mapa/presentation/mapa_screen.dart';

class AppShell extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const AppShell({super.key, required this.dbHelper});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

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
