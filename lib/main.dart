import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/cartas/presentation/cartas_screen.dart';
import 'features/producao/presentation/producao_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o banco SQLite
  final dbHelper = DatabaseHelper.instance;

  runApp(AtlasBlueOceanApp(dbHelper: dbHelper));
}

class AtlasBlueOceanApp extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const AtlasBlueOceanApp({super.key, required this.dbHelper});

  @override
  State<AtlasBlueOceanApp> createState() => _AtlasBlueOceanAppState();
}

class _AtlasBlueOceanAppState extends State<AtlasBlueOceanApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Blue Ocean',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildCurrentScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.blue[700],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Cartas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle), label: 'Produção'),
          ],
        ),
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
        return ProducaoScreen(dbHelper: widget.dbHelper);
      default:
        return DashboardScreen(dbHelper: widget.dbHelper);
    }
  }
}
