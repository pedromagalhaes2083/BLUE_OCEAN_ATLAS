import 'package:flutter/foundation.dart';

import '../config/config.dart';
import '../config/constantes.dart';

/// Modo noturno: aplica um filtro monocromático vermelho sobre o app
/// inteiro — convenção náutica clássica pra preservar a visão noturna do
/// mestre ao consultar o app no escuro, sem precisar redesenhar cada tela.
///
/// Estado global simples (`ValueNotifier`) porque só existe um app rodando
/// por vez; persistido via [Config] (Hive) pra sobreviver a reaberturas.
class NightModeService {
  static final ValueNotifier<bool> ativo = ValueNotifier(false);

  static Future<void> carregar() async {
    final valor = await Config.obtem(Constantes.modoNoturno, '0');
    ativo.value = valor == '1';
  }

  static Future<void> alternar(bool valor) async {
    ativo.value = valor;
    await Config.grava(Constantes.modoNoturno, valor ? '1' : '0');
  }
}
