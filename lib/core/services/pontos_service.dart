import 'dart:convert';
import 'package:flutter/services.dart';

class Meteorologia {
  final double? twsKts;
  final double? twdDeg;
  final double? twaDeg;
  final double? stwKts;
  final double? ctwDeg;
  final double? sogKts;
  final double? cogDeg;
  final double? awsKts;
  final double? awaDeg;
  final double? gustsKts;
  final double? rainMmH;
  final double? cloudsPct;
  final double? airtempC;
  final double? pressureHpa;
  final double? combWavesHeightM;
  final double? windWavesHeightM;
  final double? windWavesDirDeg;
  final double? windWavesPeriodS;
  final double? swellHeightM;
  final double? swellDirDeg;
  final double? swellPeriodS;

  const Meteorologia({
    this.twsKts,
    this.twdDeg,
    this.twaDeg,
    this.stwKts,
    this.ctwDeg,
    this.sogKts,
    this.cogDeg,
    this.awsKts,
    this.awaDeg,
    this.gustsKts,
    this.rainMmH,
    this.cloudsPct,
    this.airtempC,
    this.pressureHpa,
    this.combWavesHeightM,
    this.windWavesHeightM,
    this.windWavesDirDeg,
    this.windWavesPeriodS,
    this.swellHeightM,
    this.swellDirDeg,
    this.swellPeriodS,
  });

  factory Meteorologia.fromJson(Map<String, dynamic> j) => Meteorologia(
        twsKts: (j['tws_kts'] as num?)?.toDouble(),
        twdDeg: (j['twd_deg'] as num?)?.toDouble(),
        twaDeg: (j['twa_deg'] as num?)?.toDouble(),
        stwKts: (j['stw_kts'] as num?)?.toDouble(),
        ctwDeg: (j['ctw_deg'] as num?)?.toDouble(),
        sogKts: (j['sog_kts'] as num?)?.toDouble(),
        cogDeg: (j['cog_deg'] as num?)?.toDouble(),
        awsKts: (j['aws_kts'] as num?)?.toDouble(),
        awaDeg: (j['awa_deg'] as num?)?.toDouble(),
        gustsKts: (j['gusts_kts'] as num?)?.toDouble(),
        rainMmH: (j['rain_mm_h'] as num?)?.toDouble(),
        cloudsPct: (j['clouds_pct'] as num?)?.toDouble(),
        airtempC: (j['airtemp_c'] as num?)?.toDouble(),
        pressureHpa: (j['pressure_hpa'] as num?)?.toDouble(),
        combWavesHeightM: (j['comb_waves_height_m'] as num?)?.toDouble(),
        windWavesHeightM: (j['wind_waves_height_m'] as num?)?.toDouble(),
        windWavesDirDeg: (j['wind_waves_dir_deg'] as num?)?.toDouble(),
        windWavesPeriodS: (j['wind_waves_period_s'] as num?)?.toDouble(),
        swellHeightM: (j['swell_height_m'] as num?)?.toDouble(),
        swellDirDeg: (j['swell_dir_deg'] as num?)?.toDouble(),
        swellPeriodS: (j['swell_period_s'] as num?)?.toDouble(),
      );
}

class PontoMapa {
  final double latitude;
  final double longitude;
  final String? embarcacao;
  final String? instante;
  final Meteorologia? meteorologia;

  const PontoMapa({
    required this.latitude,
    required this.longitude,
    this.embarcacao,
    this.instante,
    this.meteorologia,
  });

  factory PontoMapa.fromJson(Map<String, dynamic> j) => PontoMapa(
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        embarcacao:
            (j['embarcacao'] as Map<String, dynamic>?)?['nome'] as String?,
        instante: j['instante'] as String?,
        meteorologia: j['meteorologia'] != null
            ? Meteorologia.fromJson(
                j['meteorologia'] as Map<String, dynamic>)
            : null,
      );

  String get label {
    final lat = latitude.abs().toStringAsFixed(2);
    final lon = longitude.abs().toStringAsFixed(2);
    final ns = latitude >= 0 ? 'N' : 'S';
    final ew = longitude >= 0 ? 'E' : 'W';
    return '$lat°$ns, $lon°$ew';
  }
}

class PontosService {
  Future<List<PontoMapa>> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PontoMapa.fromJson)
          .toList();
    }
    if (decoded is Map<String, dynamic> &&
        decoded.containsKey('latitude') &&
        decoded.containsKey('longitude')) {
      return [PontoMapa.fromJson(decoded)];
    }
    return [];
  }
}
