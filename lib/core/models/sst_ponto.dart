/// Um ponto de temperatura da superfície do mar (SST) — usado pela grade de
/// temperatura sobreposta ao mapa (ver `MapaWidget`), diferente do
/// `WaveForecast` completo (que carrega a previsão horária inteira de um
/// único ponto).
class SstPonto {
  final double latitude;
  final double longitude;

  /// Nulo quando a API não retorna leitura pra esse ponto (ex: em terra).
  final double? temperaturaC;

  const SstPonto({
    required this.latitude,
    required this.longitude,
    this.temperaturaC,
  });

  factory SstPonto.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>?;
    return SstPonto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperaturaC: (current?['sea_surface_temperature'] as num?)?.toDouble(),
    );
  }
}
