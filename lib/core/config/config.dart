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

  static Future<String> obtem(String chave, [String valorPadrao = '']) async {
    await _inicia();
    return _box.get(chave) ?? valorPadrao;
  }

  static Future<void> grava(String chave, String valor) async {
    await _inicia();
    _box.put(chave, valor);
  }

  static Future<void> limpa(String chave) async {
    await _inicia();
    _box.delete(chave);
  }
}
