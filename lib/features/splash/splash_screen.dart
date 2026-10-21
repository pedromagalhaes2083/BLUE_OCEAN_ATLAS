import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_shell.dart';
import '../../core/auth/auth_service.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/location_tracking_service.dart';
import '../../core/services/sincronizacao_service.dart';
import '../auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const SplashScreen({super.key, required this.dbHelper});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _iniciar();
  }

  Future<void> _iniciar() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    var estaLogado = await AuthService.isLoggedIn();

    // Token salvo expirou (ou nunca existiu nesta sessão), mas o usuário
    // pediu pra "lembrar" a credencial da última vez — tenta logar de novo
    // silenciosamente antes de cair na tela de login.
    if (!estaLogado) {
      estaLogado = await AuthService.tentarLoginAutomatico();
      if (estaLogado) {
        try {
          await SincronizacaoService.sincronizar();
        } catch (e) {
          debugPrint('Erro ao sincronizar dados do dispositivo: $e');
        }
      }
    }

    // O rastreamento só roda com uma viagem em andamento (ver
    // NovaViagemScreen/HistoricoLocalizacoesScreen), não do login até o
    // logout — reconfirma a cada abertura (o serviço pode ter sido morto
    // pelo sistema). Também quando a sessão só venceu e o login automático
    // falhou por falta de rede (credencial lembrada continua lá): offshore,
    // isso é o normal, e as posições são gravadas localmente sem precisar
    // de sessão. Depois de um logout explícito (que apaga a credencial
    // lembrada), não retoma. Sem pedir permissão aqui — a splash roda a
    // cada abertura e não pode perguntar toda vez.
    if (estaLogado || await AuthService.lembrarCredenciaisAtivo()) {
      try {
        await LocationTrackingService().garantirRastreamentoSeViagemAtiva();
      } catch (e) {
        debugPrint('Erro ao reconfirmar rastreamento de localização: $e');
      }
    }

    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => estaLogado
            ? AppShell(dbHelper: widget.dbHelper)
            : LoginScreen(dbHelper: widget.dbHelper),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/icons/splash_screen.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
