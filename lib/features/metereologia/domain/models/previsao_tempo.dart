/// Uma entrada horária de previsão do tempo.
class PrevisaoTempoHoraria {
  final DateTime horario;
  final double velocidadeVento; // km/h
  final int direcaoVento; // graus
  final double precipitacao; // mm
  final double temperatura; // °C
  final double pressao; // hPa
  final double umidadeRelativa; // %

  const PrevisaoTempoHoraria({
    required this.horario,
    required this.velocidadeVento,
    required this.direcaoVento,
    required this.precipitacao,
    required this.temperatura,
    required this.pressao,
    required this.umidadeRelativa,
  });

  // Converte graus para abreviação de ponto cardeal
  String get direcaoLabel {
    const dirs = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((direcaoVento + 11.25) / 22.5).floor() % 16;
    return dirs[index];
  }

  double get direcaoRadianos => direcaoVento * 3.14159265 / 180.0;
}

/// Condição atual, retornada separadamente pela API (`current_weather`).
class PrevisaoTempoAtual {
  final DateTime horario;
  final double temperatura;
  final double velocidadeVento;
  final int direcaoVento;

  const PrevisaoTempoAtual({
    required this.horario,
    required this.temperatura,
    required this.velocidadeVento,
    required this.direcaoVento,
  });

  factory PrevisaoTempoAtual.fromJson(Map<String, dynamic> json) {
    return PrevisaoTempoAtual(
      horario: DateTime.parse(json['time'] as String),
      temperatura: (json['temperature'] as num).toDouble(),
      velocidadeVento: (json['windspeed'] as num).toDouble(),
      direcaoVento: (json['winddirection'] as num).toInt(),
    );
  }
}

class PrevisaoTempo {
  final double latitude;
  final double longitude;
  final String timezone;
  final PrevisaoTempoAtual? atual;
  final List<PrevisaoTempoHoraria> horaria;

  const PrevisaoTempo({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.atual,
    required this.horaria,
  });

  /// Entradas a partir da hora atual.
  List<PrevisaoTempoHoraria> get proximasHoras {
    final agora = DateTime.now().subtract(const Duration(minutes: 30));
    return horaria.where((h) => h.horario.isAfter(agora)).toList();
  }

  factory PrevisaoTempo.fromJson(Map<String, dynamic> json) {
    // `hourly` só vem se o parâmetro `hourly=...` for pedido na URL —
    // com uma chamada só de `current_weather`, essa chave não existe.
    final hourly = json['hourly'] as Map<String, dynamic>?;
    final entradas = <PrevisaoTempoHoraria>[];

    if (hourly != null) {
      final times = (hourly['time'] as List).cast<String>();
      final velocidades = (hourly['windspeed_10m'] as List)
          .map((v) => (v as num).toDouble())
          .toList();
      final direcoes = (hourly['winddirection_10m'] as List)
          .map((v) => (v as num).toInt())
          .toList();
      final precipitacoes = (hourly['precipitation'] as List)
          .map((v) => (v as num).toDouble())
          .toList();
      final temperaturas = (hourly['temperature_2m'] as List)
          .map((v) => (v as num).toDouble())
          .toList();
      final pressoes = (hourly['pressure_msl'] as List)
          .map((v) => (v as num).toDouble())
          .toList();
      final umidades = (hourly['relativehumidity_2m'] as List)
          .map((v) => (v as num).toDouble())
          .toList();

      entradas.addAll(List.generate(
        times.length,
        (i) => PrevisaoTempoHoraria(
          horario: DateTime.parse(times[i]),
          velocidadeVento: velocidades[i],
          direcaoVento: direcoes[i],
          precipitacao: precipitacoes[i],
          temperatura: temperaturas[i],
          pressao: pressoes[i],
          umidadeRelativa: umidades[i],
        ),
      ));
    }

    return PrevisaoTempo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? '',
      atual: json['current_weather'] != null
          ? PrevisaoTempoAtual.fromJson(
              json['current_weather'] as Map<String, dynamic>)
          : null,
      horaria: entradas,
    );
  }
}
