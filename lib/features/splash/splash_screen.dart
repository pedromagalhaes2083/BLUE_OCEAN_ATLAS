import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_shell.dart';
import '../../core/auth/auth_service.dart';
import '../../core/database/database_helper.dart';
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

    final estaLogado = await AuthService.isLoggedIn();

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
