/// Formata uma única coordenada em graus, minutos e segundos (DMS).
/// Ex: `23° 33' 00" S`.
String formatarCoordenadaDMS(double valor, {required bool isLatitude}) {
  final direcao =
      isLatitude ? (valor >= 0 ? 'N' : 'S') : (valor >= 0 ? 'E' : 'W');
  final abs = valor.abs();
  final graus = abs.floor();
  final minutosDecimal = (abs - graus) * 60;
  final minutos = minutosDecimal.floor();
  final segundos = (minutosDecimal - minutos) * 60;
  return '$graus° ${minutos.toString().padLeft(2, '0')}\' '
      '${segundos.toStringAsFixed(0).padLeft(2, '0')}" $direcao';
}

/// Formata latitude e longitude em DMS, uma por linha.
String formatarCoordenadasDMS(double lat, double lon) {
  return '${formatarCoordenadaDMS(lat, isLatitude: true)}\n'
      '${formatarCoordenadaDMS(lon, isLatitude: false)}';
}

/// Formata latitude e longitude em DMS numa linha só, separadas por vírgula
/// — útil em cards/chips compactos.
String formatarCoordenadasDMSCompacta(double lat, double lon) {
  return '${formatarCoordenadaDMS(lat, isLatitude: true)}, '
      '${formatarCoordenadaDMS(lon, isLatitude: false)}';
}
