import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/database/database_helper.dart';
import 'core/services/night_mode_service.dart';
import 'core/services/recomendacao_notification_service.dart';
import 'core/services/theme_mode_service.dart';
import 'features/mapa/presentation/meus_pontos_screen.dart';
import 'features/splash/splash_screen.dart';

/// Permite navegar a partir de fora da árvore de widgets — usado só pelo
/// toque numa notificação de recomendação nova, que pode chegar com o app
/// em qualquer tela (ou recém-aberto pela notificação).
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Porta de comunicação com o serviço em primeiro plano do rastreamento
  // (ver LocationTrackingService/LocationForegroundTaskHandler) — precisa
  // ser chamado cedo, antes de qualquer outra coisa que dependa do estado
  // do serviço, mesmo que este app não troque dados com ele hoje.
  FlutterForegroundTask.initCommunicationPort();

  final dbHelper = DatabaseHelper.instance;

  await Hive.initFlutter();
  await Hive.openBox('api_responses');
  await NightModeService.carregar();
  await ThemeModeService.carregar();
  await RecomendacaoNotificationService.inicializar(
    aoTocarNotificacao: (_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const MeusPontosScreen()),
      );
    },
  );

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
/// mesmo lugar. [brightness] gera a variante clara ou escura a partir da
/// mesma base (ver [ThemeModeService], selecionável em Configurações).
ThemeData _buildTheme(Brightness brightness) {
  final claro = brightness == Brightness.light;

  // Azul profundo — o mesmo tom já usado no fundo do mapa (ver
  // MbtilesTileProvider) e no ícone/splash do app — em vez do azul genérico
  // do Material, pra a identidade "oceano" aparecer também na UI comum.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0D3B66),
    brightness: brightness,
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
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: claro
        ? const Color(0xFFF7F5FA)
        : const Color(0xFF10161D),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: claro ? const Color(0xFFF5F7FA) : const Color(0xFF1C2530),
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeService.modo,
      builder: (context, temaModo, _) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Atlas Blue Ocean',
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: temaModo,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => ValueListenableBuilder<bool>(
          valueListenable: NightModeService.ativo,
          builder: (context, modoNoturno, _) => modoNoturno
              ? ColorFiltered(colorFilter: _filtroModoNoturno, child: child)
              : child!,
        ),
        home: SplashScreen(dbHelper: dbHelper),
      ),
    );
  }
}
