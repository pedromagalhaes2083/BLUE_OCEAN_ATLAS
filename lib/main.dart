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

/// Tema único do app — antes cada tela decidia por conta própria a borda, o
/// raio e o preenchimento dos seus próprios campos (algumas com cantos
/// quadrados e sem fundo, outras com cantos arredondados e fundo cinza),
/// então a mesma tela de formulário parecia vir de dois apps diferentes.
/// Definir aqui uma vez — em vez de repetir `InputDecoration`/`border` em
/// cada tela — garante que todo campo, dropdown e botão do app puxe do
/// mesmo lugar.
ThemeData _buildTheme() {
  // Azul profundo — o mesmo tom já usado no fundo do mapa (ver
  // MbtilesTileProvider) e no ícone/splash do app — em vez do azul genérico
  // do Material, pra a identidade "oceano" aparecer também na UI comum.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D3B66),
    brightness: Brightness.light,
  );

  // Preenchido, sem borda visível em repouso e com um contorno grosso no
  // foco — o padrão que já existia (só em `embarcacao_configuracao_screen`)
  // e que vira a base pra todo campo do app agora.
  final raio = BorderRadius.circular(12);
  const semBorda = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF7F5FA),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: semBorda,
      enabledBorder: semBorda,
      focusedBorder: OutlineInputBorder(
        borderRadius: raio,
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: raio,
        borderSide: BorderSide(color: colorScheme.error),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class AtlasBlueOceanApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const AtlasBlueOceanApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Blue Ocean',
      theme: _buildTheme(),
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
