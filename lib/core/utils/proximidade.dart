import 'dart:math' as math;

/// Distância em milhas náuticas entre duas coordenadas (fórmula de haversine).
double calcularDistanciaNauticas(
    double lat1, double lon1, double lat2, double lon2) {
  const double raioTerraMilhasNauticas = 3440.065; // 6371 km ÷ 1.852
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return raioTerraMilhasNauticas * c;
}

/// Projeta um ponto a [distanciaNauticas] milhas náuticas de
/// (lat, lon), seguindo o rumo [rumoGraus] (0° = Norte, sentido horário) —
/// fórmula de geodésia direta (esférica), o "inverso" da haversine usada em
/// [calcularDistanciaNauticas]. Usada para achar o ponto à frente da
/// embarcação num alerta de rota (ver `AlertaRotaScreen`).
({double latitude, double longitude}) projetarPontoNoRumo(
  double lat,
  double lon,
  double rumoGraus,
  double distanciaNauticas,
) {
  const double raioTerraMilhasNauticas = 3440.065;
  final anguloDistancia = distanciaNauticas / raioTerraMilhasNauticas;
  final rumoRad = rumoGraus * math.pi / 180;
  final latRad = lat * math.pi / 180;
  final lonRad = lon * math.pi / 180;

  final lat2Rad = math.asin(
    math.sin(latRad) * math.cos(anguloDistancia) +
        math.cos(latRad) * math.sin(anguloDistancia) * math.cos(rumoRad),
  );
  final lon2Rad = lonRad +
      math.atan2(
        math.sin(rumoRad) * math.sin(anguloDistancia) * math.cos(latRad),
        math.cos(anguloDistancia) - math.sin(latRad) * math.sin(lat2Rad),
      );

  return (
    latitude: lat2Rad * 180 / math.pi,
    longitude: lon2Rad * 180 / math.pi,
  );
}

/// Ordena uma lista bruta (cada item com campos `latitude`/`longitude`)
/// pela proximidade a uma origem — mais perto primeiro.
List<dynamic> ordenarPorProximidade(
  List<dynamic> lista, {
  required double originLat,
  required double originLon,
}) {
  final copia = List<dynamic>.from(lista);
  copia.sort((a, b) {
    final distA = calcularDistanciaNauticas(
        originLat, originLon, a['latitude'], a['longitude']);
    final distB = calcularDistanciaNauticas(
        originLat, originLon, b['latitude'], b['longitude']);
    return distA.compareTo(distB);
  });
  return copia;
}
