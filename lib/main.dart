import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/database/database_helper.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final dbHelper = DatabaseHelper.instance;

  await Hive.initFlutter();
  await Hive.openBox('api_responses');

  FlutterNativeSplash.remove();

  runApp(AtlasBlueOceanApp(dbHelper: dbHelper));
}

class AtlasBlueOceanApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const AtlasBlueOceanApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Blue Ocean',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(dbHelper: dbHelper),
    );
  }
}
