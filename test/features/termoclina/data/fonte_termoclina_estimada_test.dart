import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/models/wave_forecast.dart';
import 'package:atlas/features/metereologia/data/profundidade_repository.dart';
import 'package:atlas/features/metereologia/data/wave_forecast_repository.dart';
import 'package:atlas/features/metereologia/domain/models/leitura_profundidade.dart';
import 'package:atlas/features/termoclina/data/fonte_termoclina_estimada.dart';
import 'package:atlas/features/termoclina/data/rfrom_ocean_repository.dart';
import 'package:atlas/features/termoclina/domain/models/perfil_temperatura_ponto.dart';

class _WaveForecastRepositoryFalso extends WaveForecastRepository {
  final double sst;
  _WaveForecastRepositoryFalso(this.sst);

  @override
  Future<WaveForecast> buscar({
    required double latitude,
    required double longitude,
  }) async {
    return WaveForecast(
      latitude: latitude,
      longitude: longitude,
      timezone: 'UTC',
      hourly: [
        WaveHourEntry(
          time: DateTime.now(),
          waveHeight: 1.0,
          waveDirection: 90,
          wavePeriod: 6.0,
          seaSurfaceTemperature: sst,
        ),
      ],
    );
  }
}

class _ProfundidadeRepositoryFalso extends ProfundidadeRepository {
  final double? profundidadeMetros;
  _ProfundidadeRepositoryFalso(this.profundidadeMetros);

  @override
  Future<LeituraProfundidade> buscarPonto({
    required double latitude,
    required double longitude,
  }) async {
    return LeituraProfundidade(
      latitude: latitude,
      longitude: longitude,
      elevacao: -(profundidadeMetros ?? 0),
    );
  }
}

class _ProfundidadeRepositoryComFalha extends ProfundidadeRepository {
  @override
  Future<LeituraProfundidade> buscarPonto({
    required double latitude,
    required double longitude,
  }) async {
    throw Exception('sem rede');
  }
}

/// Repositório RFROM falso, sempre sem dado (mesmo efeito de "sem
/// cobertura Argo aqui") — o padrão nos testes que não é o próprio alvo,
/// pra nunca bater na rede de verdade num teste unitário.
class _RfromOceanRepositoryVazio extends RfromOceanRepository {
  @override
  Future<PerfilOceanicoRfrom> buscarPerfil({
    required double latitude,
    required double longitude,
  }) async =>
      const PerfilOceanicoRfrom(temperatura: []);
}

class _RfromOceanRepositoryFalso extends RfromOceanRepository {
  final List<PerfilTemperaturaPonto> temperatura;
  final double? salinidadeSuperficieUps;
  _RfromOceanRepositoryFalso({
    required this.temperatura,
    this.salinidadeSuperficieUps,
  });

  @override
  Future<PerfilOceanicoRfrom> buscarPerfil({
    required double latitude,
    required double longitude,
  }) async =>
      PerfilOceanicoRfrom(
        temperatura: temperatura,
        salinidadeSuperficieUps: salinidadeSuperficieUps,
      );
}

class _RfromOceanRepositoryComFalha extends RfromOceanRepository {
  @override
  Future<PerfilOceanicoRfrom> buscarPerfil({
    required double latitude,
    required double longitude,
  }) async =>
      throw Exception('sem rede');
}

void main() {
  group('FonteTermoclinaEstimada — batimetria limita a estimativa', () {
    test(
        'em água rasa (13m), nunca estima termoclina/perfil abaixo do fundo real',
        () async {
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(13),
        rfromOceanRepository: _RfromOceanRepositoryVazio(),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeLocalM, 13);
      expect(leitura.profundidadeTermoclina, lessThanOrEqualTo(13));
      for (final ponto in leitura.perfil) {
        expect(ponto.profundidadeM, lessThanOrEqualTo(13));
      }
      // A superfície nunca some, mesmo em água rasa.
      expect(leitura.perfil.first.profundidadeM, 0);
    });

    test('em mar aberto (sem restrição de fundo), mantém a estimativa original',
        () async {
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(2000),
        rfromOceanRepository: _RfromOceanRepositoryVazio(),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeLocalM, 2000);
      expect(leitura.perfil.length, 7);
      expect(leitura.perfil.last.profundidadeM, 60);
    });

    test('quando a consulta de batimetria falha, segue sem o limite (best-effort)',
        () async {
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryComFalha(),
        rfromOceanRepository: _RfromOceanRepositoryVazio(),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeLocalM, isNull);
      expect(leitura.perfil.length, 7);
    });

    test(
        'em água rasadíssima (0.5m — beira de recife/estuário), a margem '
        'proporcional evita que a termoclina fique mais funda que o fundo',
        () async {
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(0.5),
        rfromOceanRepository: _RfromOceanRepositoryVazio(),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeLocalM, 0.5);
      expect(leitura.profundidadeTermoclina, lessThan(0.5));
    });
  });

  group('FonteTermoclinaEstimada — perfil real (RFROM/Argo)', () {
    test(
        'com cobertura Argo profunda e um gradiente acentuado, deriva a '
        'termoclina do dado real em vez do modelo estimado',
        () async {
      final pontosReais = [
        const PerfilTemperaturaPonto(
            profundidadeM: 2.5, temperaturaC: 28.0, medido: true),
        const PerfilTemperaturaPonto(
            profundidadeM: 20, temperaturaC: 27.8, medido: true),
        const PerfilTemperaturaPonto(
            profundidadeM: 40, temperaturaC: 26.5, medido: true),
        // Maior queda por metro está aqui: (26.5-18.0)/20 = 0.425 °C/m.
        const PerfilTemperaturaPonto(
            profundidadeM: 60, temperaturaC: 18.0, medido: true),
        const PerfilTemperaturaPonto(
            profundidadeM: 80, temperaturaC: 15.0, medido: true),
      ];
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(2000),
        rfromOceanRepository: _RfromOceanRepositoryFalso(
          temperatura: pontosReais,
          salinidadeSuperficieUps: 36.2,
        ),
      );

      final leitura = await fonte.buscar(latitude: 30.0, longitude: -40.0);

      expect(leitura.profundidadeTermoclinaMedida, isTrue);
      // Ponto médio do intervalo de maior queda (40-60m) = 50m.
      expect(leitura.profundidadeTermoclina, 50.0);
      expect(leitura.confianca, 0.93);
      // Os pontos reais substituem os sintéticos no mesmo nível.
      final ponto20m =
          leitura.perfil.firstWhere((p) => p.profundidadeM == 20);
      expect(ponto20m.medido, isTrue);
      expect(ponto20m.temperaturaC, 27.8);
    });

    test(
        'perto da costa, com só 1-2 pontos rasos (sem alcance suficiente), '
        'cai pro modelo estimado em vez de usar o gradiente raso como termoclina',
        () async {
      final pontosReaisRasos = [
        const PerfilTemperaturaPonto(
            profundidadeM: 2.5, temperaturaC: 28.0, medido: true),
        const PerfilTemperaturaPonto(
            profundidadeM: 10, temperaturaC: 27.9, medido: true),
      ];
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(59),
        rfromOceanRepository:
            _RfromOceanRepositoryFalso(temperatura: pontosReaisRasos),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeTermoclinaMedida, isFalse);
    });

    test(
        'a diferença entre a SST ao vivo (Open-Meteo) e o 1º nível da '
        'RFROM (média semanal) nunca é tratada como termoclina — só o '
        'gradiente entre pontos da própria RFROM conta',
        () async {
      final pontosReais = [
        // Bem mais fria que a SST de 28°C (diferença de fonte/instante
        // normal), mas o próprio perfil da RFROM aqui é raso e suave —
        // não deve gerar uma "termoclina" a poucos metros.
        const PerfilTemperaturaPonto(
            profundidadeM: 2.5, temperaturaC: 20.0, medido: true),
        const PerfilTemperaturaPonto(
            profundidadeM: 10, temperaturaC: 19.9, medido: true),
      ];
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(2000),
        rfromOceanRepository:
            _RfromOceanRepositoryFalso(temperatura: pontosReais),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeTermoclinaMedida, isFalse);
      // Não pode ter caído pro intervalo 0-2,5m (SST vs. 1º nível real).
      expect(leitura.profundidadeTermoclina, isNot(closeTo(1.25, 0.5)));
    });

    test('quando a consulta RFROM falha, segue só com o modelo estimado (best-effort)',
        () async {
      final fonte = FonteTermoclinaEstimada(
        waveForecastRepository: _WaveForecastRepositoryFalso(28.0),
        profundidadeRepository: _ProfundidadeRepositoryFalso(2000),
        rfromOceanRepository: _RfromOceanRepositoryComFalha(),
      );

      final leitura = await fonte.buscar(latitude: -2.9, longitude: -39.9);

      expect(leitura.profundidadeTermoclinaMedida, isFalse);
      expect(leitura.perfil.length, 7);
    });
  });
}
