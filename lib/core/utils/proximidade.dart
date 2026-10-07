import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

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

/// Resultado de [projetarNaRota]: onde a posição atual cai em relação a uma
/// rota planejada (sequência de pontos, `pontos[0]` = início).
class ProjecaoNaRota {
  /// Índice do ponto que inicia o segmento mais próximo da posição atual
  /// (o segmento é `pontos[indiceSegmento]` → `pontos[indiceSegmento + 1]`).
  final int indiceSegmento;

  /// Distância perpendicular (desvio lateral) da posição atual até a rota,
  /// em milhas náuticas — 0 significa exatamente em cima da rota.
  final double desvioNauticas;

  /// Distância já percorrida ao longo da rota, do primeiro ponto até a
  /// projeção da posição atual no segmento mais próximo — soma dos
  /// segmentos inteiros já passados mais a parte percorrida do atual.
  final double distanciaPercorridaNauticas;

  /// Comprimento total da rota (soma de todos os segmentos).
  final double distanciaTotalNauticas;

  /// Próximo ponto da rota à frente da posição projetada — fim do segmento
  /// mais próximo, ou o último ponto da rota se já passou de todos.
  final LatLng proximoWaypoint;

  const ProjecaoNaRota({
    required this.indiceSegmento,
    required this.desvioNauticas,
    required this.distanciaPercorridaNauticas,
    required this.distanciaTotalNauticas,
    required this.proximoWaypoint,
  });

  /// Fração 0.0-1.0 da rota já percorrida — `null` quando a rota tem
  /// comprimento zero (um único ponto repetido), caso em que "percentual
  /// percorrido" não faz sentido.
  double? get progresso => distanciaTotalNauticas > 0
      ? (distanciaPercorridaNauticas / distanciaTotalNauticas).clamp(0.0, 1.0)
      : null;
}

/// Projeta [posicaoAtual] sobre a rota [pontos] (sequência ordenada de
/// waypoints) — acha o segmento mais próximo e, dentro dele, o ponto exato
/// mais próximo da posição atual, pra calcular desvio lateral, distância já
/// percorrida e o próximo waypoint (ver `ProjecaoNaRota`). Usado pela
/// navegação ao vivo de uma rota planejada (ver `NavegacaoRotaScreen`).
///
/// A projeção ponto-em-segmento usa uma aproximação planar local
/// (equirretangular, centrada em cada segmento) — a Terra é tratada como
/// plana só pra achar o ponto mais próximo dentro de um segmento de rota
/// (poucas milhas de extensão, tipicamente), nunca pra medir distância de
/// verdade: toda distância reportada (desvio, percorrida, total) usa
/// [calcularDistanciaNauticas] (haversine) no fim. Suficiente pra rotas de
/// pesca costeira; não é geodésia de precisão pra travessias oceânicas
/// longas.
///
/// Retorna `null` se [pontos] tiver menos de 2 pontos (não dá pra ter um
/// segmento).
ProjecaoNaRota? projetarNaRota(LatLng posicaoAtual, List<LatLng> pontos) {
  if (pontos.length < 2) return null;

  const milhasPorGrauLatitude = 60.00721; // 1' de latitude = 1 milha náutica

  int melhorIndice = 0;
  double melhorDesvio = double.infinity;
  double melhorDistanciaPercorrida = 0;
  double distanciaAcumulada = 0;

  for (var i = 0; i < pontos.length - 1; i++) {
    final a = pontos[i];
    final b = pontos[i + 1];

    // Projeção equirretangular local, centrada em "a" — longitude escalada
    // por cos(latitude) pra compensar o encolhimento dos meridianos longe
    // do equador. Unidade final: milhas náuticas.
    final latMediaRad = a.latitude * math.pi / 180;
    final ax = 0.0, ay = 0.0;
    final bx = (b.longitude - a.longitude) *
        math.cos(latMediaRad) *
        milhasPorGrauLatitude;
    final by = (b.latitude - a.latitude) * milhasPorGrauLatitude;
    final px = (posicaoAtual.longitude - a.longitude) *
        math.cos(latMediaRad) *
        milhasPorGrauLatitude;
    final py = (posicaoAtual.latitude - a.latitude) * milhasPorGrauLatitude;

    final segmentoComprimentoQuadrado = (bx - ax) * (bx - ax) + (by - ay) * (by - ay);
    double t = segmentoComprimentoQuadrado > 0
        ? (((px - ax) * (bx - ax) + (py - ay) * (by - ay)) / segmentoComprimentoQuadrado)
        : 0;
    t = t.clamp(0.0, 1.0);

    final projX = ax + t * (bx - ax);
    final projY = ay + t * (by - ay);
    final projLat = a.latitude + (projY / milhasPorGrauLatitude);
    final projLon =
        a.longitude + (projX / (math.cos(latMediaRad) * milhasPorGrauLatitude));

    final desvio = calcularDistanciaNauticas(
        posicaoAtual.latitude, posicaoAtual.longitude, projLat, projLon);
    final distanciaSegmento =
        calcularDistanciaNauticas(a.latitude, a.longitude, b.latitude, b.longitude);
    final distanciaNoSegmento = calcularDistanciaNauticas(
        a.latitude, a.longitude, projLat, projLon);

    if (desvio < melhorDesvio) {
      melhorDesvio = desvio;
      melhorIndice = i;
      melhorDistanciaPercorrida = distanciaAcumulada + distanciaNoSegmento;
    }

    distanciaAcumulada += distanciaSegmento;
  }

  return ProjecaoNaRota(
    indiceSegmento: melhorIndice,
    desvioNauticas: melhorDesvio,
    distanciaPercorridaNauticas: melhorDistanciaPercorrida,
    distanciaTotalNauticas: distanciaAcumulada,
    proximoWaypoint: pontos[melhorIndice + 1],
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
