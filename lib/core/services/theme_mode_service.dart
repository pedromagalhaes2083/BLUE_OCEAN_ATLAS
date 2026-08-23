import 'package:flutter/material.dart';

import '../config/config.dart';
import '../config/constantes.dart';

/// Tema claro/escuro do app — diferente do "Modo Noturno"
/// ([NightModeService]), que é um filtro vermelho pra preservar a visão no
/// escuro. Aqui é o tema de verdade (`ThemeData` claro ou escuro do
/// Material), com opção de seguir o tema do sistema.
///
/// Mesmo padrão do [NightModeService]: estado global simples (`ValueNotifier`,
/// só existe um app rodando por vez) persistido via [Config] (Hive).
class ThemeModeService {
  static final ValueNotifier<ThemeMode> modo = ValueNotifier(ThemeMode.system);

  static Future<void> carregar() async {
    final valor = await Config.obtem(Constantes.temaModo, 'system');
    modo.value = _fromString(valor);
  }

  static Future<void> alternar(ThemeMode valor) async {
    modo.value = valor;
    await Config.grava(Constantes.temaModo, _toString(valor));
  }

  static ThemeMode _fromString(String valor) {
    switch (valor) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
