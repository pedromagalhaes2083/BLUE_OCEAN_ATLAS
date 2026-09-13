import 'package:flutter/material.dart';

import '../config/config.dart';
import '../config/constantes.dart';

/// Idioma do app — Português, English, Español, Italiano ou Français, com
/// opção de seguir o idioma do sistema. Mesmo padrão do [ThemeModeService]
/// (que também é um estado global simples persistido via [Config]/Hive).
///
/// `null` em [locale] significa "seguir o idioma do sistema" — é o valor
/// que o `MaterialApp.locale` espera pra delegar em
/// `localeResolutionCallback`/`supportedLocales` (ver `main.dart`).
class LocaleService {
  static final ValueNotifier<Locale?> locale = ValueNotifier(null);

  /// Idiomas com tradução própria (ver `lib/l10n/app_*.arb`) — mesma ordem
  /// exibida no seletor de Configurações.
  static const idiomasSuportados = [
    Locale('pt'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('fr'),
  ];

  static Future<void> carregar() async {
    final valor = await Config.obtem(Constantes.idioma, '');
    locale.value = valor.isEmpty ? null : Locale(valor);
  }

  static Future<void> alternar(Locale? valor) async {
    locale.value = valor;
    await Config.grava(Constantes.idioma, valor?.languageCode ?? '');
  }
}
