import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Config {
  static bool _iniciado = false;
  static late Box<String> _box;

  static Future<void> _inicia() async {
    if (_iniciado) return;
    await Hive.openBox<String>('config');
    _box = Hive.box<String>('config');
    _iniciado = true;
  }

  /// Descarta o estado cacheado — só pra teste, entre um caso e outro, já
  /// que [_iniciado]/[_box] são estado de processo (sem isso, o 2º teste
  /// reaproveitaria a box do 1º mesmo depois de `Hive.deleteFromDisk()`
  /// apontar pra um diretório temporário diferente, e quebraria com a box
  /// já fechada).
  @visibleForTesting
  static void resetForTesting() {
    _iniciado = false;
  }

  static Future<String> obtem(String chave, [String valorPadrao = '']) async {
    await _inicia();
    return _box.get(chave) ?? valorPadrao;
  }

  static Future<void> grava(String chave, String valor) async {
    await _inicia();
    // Sem o `await` aqui, quem chama `Config.grava` acredita que o valor já
    // está salvo assim que o método retorna, mas a escrita em disco do Hive
    // ainda pode estar em andamento — um kill do processo bem nessa janela
    // perderia o valor silenciosamente (auditoria de 2026-09).
    await _box.put(chave, valor);
  }

  static Future<void> limpa(String chave) async {
    await _inicia();
    await _box.delete(chave);
  }
}
