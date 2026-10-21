import 'package:flutter/foundation.dart';

/// Logs técnicos do GPS com um prefixo único (`[GPS]`), pra filtrar no
/// logcat (`adb logcat -s flutter | grep "\[GPS\]"`) ao diagnosticar um
/// aparelho de campo.
///
/// Nunca recebe token, senha ou credencial. Coordenadas só passam por
/// [coordenada], que no build de produção arredonda pra 1 casa decimal
/// (~11 km) — suficiente pra saber "em que região estava", sem expor a
/// posição exata da embarcação num log que qualquer app com acesso ao
/// logcat poderia ler.
class GpsLog {
  static void evento(String evento, [String? detalhe]) {
    debugPrint(detalhe == null ? '[GPS] $evento' : '[GPS] $evento — $detalhe');
  }

  static String coordenada(double latitude, double longitude) {
    final casas = kReleaseMode ? 1 : 5;
    return '${latitude.toStringAsFixed(casas)}, ${longitude.toStringAsFixed(casas)}';
  }
}
