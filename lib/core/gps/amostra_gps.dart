import 'package:geolocator/geolocator.dart';

/// Uma leitura de GPS já normalizada para o resto do app — independente do
/// plugin (`geolocator`), pra o validador ([ValidadorPosicao]) e os testes
/// não dependerem de um aparelho de verdade.
///
/// Os campos opcionais ficam nulos quando o sistema não informa o valor —
/// nunca viram `0` ou `-1`, que são valores reais diferentes de "não sei"
/// (no iOS, velocidade e rumo `-1` significam "indisponível"; no Android,
/// precisão `0` aparece quando o fix não traz estimativa).
class AmostraGps {
  final double latitude;
  final double longitude;

  /// Instante em que o GPS obteve a posição (UTC) — não o instante em que o
  /// app a recebeu ou gravou.
  final DateTime instante;

  /// Precisão horizontal estimada, em metros (raio de confiança).
  final double? precisaoMetros;

  /// Velocidade em m/s.
  final double? velocidadeMs;

  /// Rumo em graus (0–360, a partir do norte verdadeiro).
  final double? rumoGraus;
  final double? altitude;

  /// Posição fornecida por um app de localização simulada (Android).
  final bool simulada;

  const AmostraGps({
    required this.latitude,
    required this.longitude,
    required this.instante,
    this.precisaoMetros,
    this.velocidadeMs,
    this.rumoGraus,
    this.altitude,
    this.simulada = false,
  });

  factory AmostraGps.dePosition(Position p) {
    double? positivoOuNulo(double v) => v.isFinite && v >= 0 ? v : null;
    return AmostraGps(
      latitude: p.latitude,
      longitude: p.longitude,
      instante: p.timestamp.toUtc(),
      precisaoMetros:
          p.accuracy.isFinite && p.accuracy > 0 ? p.accuracy : null,
      velocidadeMs: positivoOuNulo(p.speed),
      rumoGraus: positivoOuNulo(p.heading) == null ? null : p.heading % 360,
      altitude: p.altitude.isFinite ? p.altitude : null,
      simulada: p.isMocked,
    );
  }
}
