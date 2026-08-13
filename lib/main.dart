import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/database/database_helper.dart';
import 'core/services/night_mode_service.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final dbHelper = DatabaseHelper.instance;

  await Hive.initFlutter();
  await Hive.openBox('api_responses');
  await NightModeService.carregar();

  FlutterNativeSplash.remove();

  runApp(AtlasBlueOceanApp(dbHelper: dbHelper));
}

// Converte pra escala de cinza (luminância) e joga tudo no canal vermelho —
// o "modo noturno" clássico de embarcações, que preserva a visão no escuro.
const _filtroModoNoturno = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0,
  0, 0, 0, 1, 0,
]);

class AtlasBlueOceanApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const AtlasBlueOceanApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Blue Ocean',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ValueListenableBuilder<bool>(
        valueListenable: NightModeService.ativo,
        builder: (context, modoNoturno, _) => modoNoturno
            ? ColorFiltered(colorFilter: _filtroModoNoturno, child: child)
            : child!,
      ),
      home: SplashScreen(dbHelper: dbHelper),
    );
  }
}
