class WaveHourEntry {
  final DateTime time;
  final double waveHeight;
  final int waveDirection;
  final double wavePeriod;

  const WaveHourEntry({
    required this.time,
    required this.waveHeight,
    required this.waveDirection,
    required this.wavePeriod,
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

  factory WaveForecast.fromJson(Map<String, dynamic> json) {
    final times = (json['hourly']['time'] as List).cast<String>();
    final heights = (json['hourly']['wave_height'] as List)
        .map((v) => (v as num).toDouble())
        .toList();
    final directions = (json['hourly']['wave_direction'] as List)
        .map((v) => (v as num).toInt())
        .toList();
    final periods = (json['hourly']['wave_period'] as List)
        .map((v) => (v as num).toDouble())
        .toList();

    final entries = List.generate(times.length, (i) => WaveHourEntry(
      time: DateTime.parse(times[i]),
      waveHeight: heights[i],
      waveDirection: directions[i],
      wavePeriod: periods[i],
    ));

    return WaveForecast(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? '',
      hourly: entries,
    );
  }
}
