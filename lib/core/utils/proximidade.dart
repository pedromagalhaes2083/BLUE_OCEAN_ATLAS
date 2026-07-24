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
