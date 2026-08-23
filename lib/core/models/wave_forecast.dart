class WaveHourEntry {
  final DateTime time;
  final double waveHeight;
  final int waveDirection;
  final double wavePeriod;

  // Só vêm preenchidos se a URL pedir os parâmetros correspondentes
  // (`swell_wave_*`, `ocean_current_*`, `sea_surface_temperature`) —
  // por isso são opcionais.
  final double? swellWaveHeight;
  final int? swellWaveDirection;
  final double? swellWavePeriod;
  final double? oceanCurrentVelocity;
  final int? oceanCurrentDirection;
  final double? seaSurfaceTemperature;

  /// Altura do nível do mar (m) acima do nível médio — `sea_level_height_msl`
  /// da Open-Meteo Marine. É a série que usamos como maré: sobe e desce ao
  /// longo do dia por causa da maré astronômica, então os picos/vales dessa
  /// curva são os horários de preamar/baixa-mar (ver [WaveForecast.eventosMare]).
  final double? seaLevelHeightMsl;

  const WaveHourEntry({
    required this.time,
    required this.waveHeight,
    required this.waveDirection,
    required this.wavePeriod,
    this.swellWaveHeight,
    this.swellWaveDirection,
    this.swellWavePeriod,
    this.oceanCurrentVelocity,
    this.oceanCurrentDirection,
    this.seaSurfaceTemperature,
    this.seaLevelHeightMsl,
  });

  // Converte graus para abreviação de ponto cardeal
  String get directionLabel {
    const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
                  'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((waveDirection + 11.25) / 22.5).floor() % 16;
    return dirs[index];
  }

  // Ângulo em radianos para rodar o ícone de seta
  double get directionRadians => waveDirection * 3.14159265 / 180.0;
}

enum TipoMare { alta, baixa }

/// Um evento de preamar ou baixa-mar — horário e altura do pico/vale da
/// curva de maré (ver [WaveForecast.eventosMare]).
class MareEvento {
  final DateTime time;
  final double alturaM;
  final TipoMare tipo;

  const MareEvento({
    required this.time,
    required this.alturaM,
    required this.tipo,
  });
}

class WaveForecast {
  final double latitude;
  final double longitude;
  final String timezone;
  final List<WaveHourEntry> hourly;

  const WaveForecast({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourly,
  });

  /// Entrada mais próxima do horário atual.
  WaveHourEntry? get current {
    if (hourly.isEmpty) return null;
    final now = DateTime.now();
    return hourly.reduce((a, b) =>
        a.time.difference(now).abs() < b.time.difference(now).abs() ? a : b);
  }

  /// Entradas a partir da hora atual.
  List<WaveHourEntry> get upcoming {
    final now = DateTime.now().subtract(const Duration(minutes: 30));
    return hourly.where((e) => e.time.isAfter(now)).toList();
  }

  /// Preamares e baixa-mares (picos/vales de [WaveHourEntry.seaLevelHeightMsl])
  /// entre as entradas de [upcoming] — cada ponto onde a curva muda de
  /// direção (sobe deixa de subir, ou desce deixa de descer) é uma maré alta
  /// ou baixa. A Open-Meteo Marine não expõe esses horários prontos, só a
  /// série horária, então calculamos aqui comparando cada hora com a vizinha.
  List<MareEvento> get eventosMare {
    final serie = upcoming.where((e) => e.seaLevelHeightMsl != null).toList();
    if (serie.length < 3) return [];

    final eventos = <MareEvento>[];
    for (var i = 1; i < serie.length - 1; i++) {
      final anterior = serie[i - 1].seaLevelHeightMsl!;
      final atual = serie[i].seaLevelHeightMsl!;
      final proximo = serie[i + 1].seaLevelHeightMsl!;

      if (atual >= anterior && atual > proximo) {
        eventos.add(MareEvento(
            time: serie[i].time, alturaM: atual, tipo: TipoMare.alta));
      } else if (atual <= anterior && atual < proximo) {
        eventos.add(MareEvento(
            time: serie[i].time, alturaM: atual, tipo: TipoMare.baixa));
      }
    }
    return eventos;
  }

  factory WaveForecast.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>;

    // Cada item pode vir `null` (ex: posição em terra, fora da cobertura
    // do modelo marinho) — por isso preserva nulos item a item aqui, em
    // vez de forçar um cast que quebraria a lista inteira.
    List<num?>? valores(String chave) =>
        (hourly[chave] as List?)?.map((v) => v as num?).toList();

    final times = (hourly['time'] as List).cast<String>();
    final heights = valores('wave_height');
    final directions = valores('wave_direction');
    final periods = valores('wave_period');

    final swellHeights = valores('swell_wave_height');
    final swellDirections = valores('swell_wave_direction');
    final swellPeriods = valores('swell_wave_period');
    final correnteVelocidade = valores('ocean_current_velocity');
    final correnteDirecao = valores('ocean_current_direction');
    final temperaturaSuperficie = valores('sea_surface_temperature');
    final nivelMar = valores('sea_level_height_msl');

    final entries = <WaveHourEntry>[];
    for (var i = 0; i < times.length; i++) {
      final altura = heights?[i];
      final direcao = directions?[i];
      final periodo = periods?[i];
      // Sem dado de onda nesse horário — não dá pra montar uma entrada
      // válida (acontece fora de cobertura do modelo marinho).
      if (altura == null || direcao == null || periodo == null) continue;

      entries.add(WaveHourEntry(
        time: DateTime.parse(times[i]),
        waveHeight: altura.toDouble(),
        waveDirection: direcao.toInt(),
        wavePeriod: periodo.toDouble(),
        swellWaveHeight: swellHeights?[i]?.toDouble(),
        swellWaveDirection: swellDirections?[i]?.toInt(),
        swellWavePeriod: swellPeriods?[i]?.toDouble(),
        oceanCurrentVelocity: correnteVelocidade?[i]?.toDouble(),
        oceanCurrentDirection: correnteDirecao?[i]?.toInt(),
        seaSurfaceTemperature: temperaturaSuperficie?[i]?.toDouble(),
        seaLevelHeightMsl: nivelMar?[i]?.toDouble(),
      ));
    }

    return WaveForecast(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? '',
      hourly: entries,
    );
  }
}
