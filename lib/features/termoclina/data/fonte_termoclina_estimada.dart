import '../../metereologia/data/wave_forecast_repository.dart';
import '../domain/models/leitura_termoclina.dart';
import '../domain/models/perfil_temperatura_ponto.dart';
import 'fonte_termoclina.dart';

/// Fonte padrão de [TermoclinaRepository] hoje: usa a temperatura da
/// superfície do mar (SST) **real**, vinda da mesma API Open-Meteo Marine
/// que o resto do app já consome (ver [WaveForecastRepository] — mesma
/// usada pelo card de SST do mapa/dashboard), como âncora do perfil.
///
/// O perfil abaixo da superfície e a profundidade da termoclina em si
/// continuam sendo um **modelo estimado**, não um dado medido — nenhuma
/// API conectada hoje mede temperatura em profundidade de verdade. Por
/// isso `fonte` não é `'copernicus_marine'` (reservado pra quando existir
/// perfil vertical real) e [LeituraTermoclina.perfilEstimado] continua
/// `true`: só a SST de superfície é real, o resto é estimativa.
///
/// Se a SST real não estiver disponível pra essa coordenada (fora de
/// cobertura do modelo marinho, sem rede e sem cache — ver
/// [WaveForecastRepository.buscar]), propaga a exceção pra tela mostrar o
/// estado de erro já existente, em vez de inventar um valor.
class FonteTermoclinaEstimada implements FonteTermoclina {
  final WaveForecastRepository _waveForecastRepository;

  FonteTermoclinaEstimada({WaveForecastRepository? waveForecastRepository})
      : _waveForecastRepository =
            waveForecastRepository ?? WaveForecastRepository();

  @override
  Future<LeituraTermoclina> buscar({
    required double latitude,
    required double longitude,
    DateTime? data,
  }) async {
    final previsao = await _waveForecastRepository.buscar(
      latitude: latitude,
      longitude: longitude,
    );
    final sstReal = previsao.current?.seaSurfaceTemperature;
    if (sstReal == null) {
      throw Exception(
          'Sem dado de temperatura da superfície do mar para esta região.');
    }

    // Mesma variação determinística do modelo mock — só a SST no topo do
    // perfil é real agora; a forma da queda de temperatura com a
    // profundidade e a profundidade da termoclina continuam estimadas.
    final semente = (latitude * 1000 + longitude * 1000).abs();
    final variacaoProfundidade = (semente % 17).toInt() - 8; // ±8 m

    final perfil = <PerfilTemperaturaPonto>[
      PerfilTemperaturaPonto(profundidadeM: 0, temperaturaC: sstReal),
      PerfilTemperaturaPonto(profundidadeM: 10, temperaturaC: sstReal - 0.2),
      PerfilTemperaturaPonto(profundidadeM: 20, temperaturaC: sstReal - 0.5),
      PerfilTemperaturaPonto(profundidadeM: 30, temperaturaC: sstReal - 1.1),
      PerfilTemperaturaPonto(profundidadeM: 40, temperaturaC: sstReal - 2.5),
      PerfilTemperaturaPonto(profundidadeM: 50, temperaturaC: sstReal - 3.8),
      PerfilTemperaturaPonto(profundidadeM: 60, temperaturaC: sstReal - 4.3),
    ];

    final profundidadeTermoclina =
        (48 + variacaoProfundidade).clamp(25, 65).toDouble();
    final confianca =
        (0.82 - (variacaoProfundidade.abs() / 100)).clamp(0.5, 0.95);

    return LeituraTermoclina(
      latitude: latitude,
      longitude: longitude,
      instante: data ?? DateTime.now(),
      sst: double.parse(sstReal.toStringAsFixed(1)),
      profundidadeTermoclina: profundidadeTermoclina,
      confianca: double.parse(confianca.toStringAsFixed(2)),
      perfil: perfil,
      fonte: 'estimado_sst_open_meteo',
    );
  }
}
