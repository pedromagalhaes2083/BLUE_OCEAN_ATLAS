import '../../../core/config/calibracao_intelligence.dart';
import '../../metereologia/data/previsao_tempo_repository.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../mapa/data/clorofila_repository.dart';
import '../../termoclina/data/rfrom_ocean_repository.dart';
import '../../termoclina/data/termoclina_repository.dart';
import '../domain/models/intelligence_result.dart';
import '../domain/models/ocean_conditions.dart';
import '../domain/services/intelligence_engine.dart';

/// Única classe que a tela (`IntelligenceScreen`) conhece pra montar um
/// [IntelligenceResult] — reaproveita os repositories que o app já tem
/// (`WaveForecastRepository`, `PrevisaoTempoRepository`,
/// `ProfundidadeRepository`, `ClorofilaRepository`, `TermoclinaRepository`,
/// `RfromOceanRepository` pra salinidade) em vez de qualquer chamada nova,
/// e entrega tudo pro [IntelligenceEngine] calcular — esta classe só busca
/// e monta [OceanConditions], nunca calcula score/confiança ela mesma.
///
/// Cada fonte é buscada em paralelo e isolada num `try/catch` próprio (ver
/// [_tentar]) — a falha de uma (ex: clorofila fora de cobertura) nunca
/// derruba as outras; o campo correspondente em [OceanConditions] simplesmente
/// fica nulo, e o engine trata isso como fator indisponível. Só lança de
/// fato quando **nenhuma** fonte responde — aí sim a tela mostra o estado
/// de erro.
class IntelligenceRepository {
  final WaveForecastRepository _waveForecastRepository;
  final PrevisaoTempoRepository _previsaoTempoRepository;
  final ProfundidadeRepository _profundidadeRepository;
  final ClorofilaRepository _clorofilaRepository;
  final TermoclinaRepository _termoclinaRepository;
  final RfromOceanRepository _rfromOceanRepository;

  IntelligenceRepository({
    WaveForecastRepository? waveForecastRepository,
    PrevisaoTempoRepository? previsaoTempoRepository,
    ProfundidadeRepository? profundidadeRepository,
    ClorofilaRepository? clorofilaRepository,
    TermoclinaRepository? termoclinaRepository,
    RfromOceanRepository? rfromOceanRepository,
  })  : _waveForecastRepository =
            waveForecastRepository ?? WaveForecastRepository(),
        _previsaoTempoRepository =
            previsaoTempoRepository ?? PrevisaoTempoRepository(),
        _profundidadeRepository =
            profundidadeRepository ?? ProfundidadeRepository(),
        _clorofilaRepository = clorofilaRepository ?? ClorofilaRepository(),
        _termoclinaRepository =
            termoclinaRepository ?? TermoclinaRepository(),
        _rfromOceanRepository = rfromOceanRepository ?? RfromOceanRepository();

  Future<IntelligenceResult> avaliarPonto({
    required double latitude,
    required double longitude,
  }) async {
    // Cada chamada começa a executar já aqui (antes do `await`) — os 5
    // `Future`s rodam em paralelo, não em sequência.
    final ondaFuture = _tentar(() => _waveForecastRepository.buscar(
        latitude: latitude, longitude: longitude));
    final previsaoFuture = _tentar(() => _previsaoTempoRepository.buscar(
        latitude: latitude, longitude: longitude));
    final profundidadeFuture = _tentar(() => _profundidadeRepository
        .buscarPonto(latitude: latitude, longitude: longitude));
    final clorofilaFuture = _tentar(() => _clorofilaRepository.buscarPonto(
        latitude: latitude, longitude: longitude));
    final termoclinaFuture = _tentar(() => _termoclinaRepository.buscar(
        latitude: latitude, longitude: longitude));
    final salinidadeFuture = _tentar(() => _rfromOceanRepository.buscarPerfil(
        latitude: latitude, longitude: longitude));

    final onda = await ondaFuture;
    final previsao = await previsaoFuture;
    final profundidade = await profundidadeFuture;
    final clorofila = await clorofilaFuture;
    final termoclina = await termoclinaFuture;
    final perfilRfrom = await salinidadeFuture;
    final calibracao = await CalibracaoIntelligence.carregar();

    if (onda == null &&
        previsao == null &&
        profundidade == null &&
        clorofila == null &&
        termoclina == null &&
        perfilRfrom == null) {
      throw Exception(
          'Não foi possível obter nenhuma condição ambiental para esta região.');
    }

    final ondaAtual = onda?.current;
    final previsaoAtual = previsao?.atual;
    final velocidadeCorrenteKmh = ondaAtual?.oceanCurrentVelocity;

    final conditions = OceanConditions(
      sst: ondaAtual?.seaSurfaceTemperature ?? termoclina?.sst,
      correnteNos: velocidadeCorrenteKmh != null
          ? velocidadeCorrenteKmh * 0.539957
          : null,
      correnteDirecaoGraus: ondaAtual?.oceanCurrentDirection,
      ondaAlturaM: ondaAtual?.waveHeight,
      ondaDirecaoGraus: ondaAtual?.waveDirection,
      swellAlturaM: ondaAtual?.swellWaveHeight,
      ventoKmh: previsaoAtual?.velocidadeVento,
      ventoDirecaoGraus: previsaoAtual?.direcaoVento,
      mareAlturaM: ondaAtual?.seaLevelHeightMsl,
      profundidadeM: (profundidade != null && profundidade.emAgua)
          ? profundidade.profundidadeMetros
          : null,
      clorofilaMgM3: clorofila?.valorMgM3,
      salinidadeUps: perfilRfrom?.salinidadeSuperficieUps,
    );

    return IntelligenceEngine.avaliar(
      latitude: latitude,
      longitude: longitude,
      instante: DateTime.now(),
      conditions: conditions,
      thermocline: termoclina,
      calibracao: calibracao,
    );
  }

  Future<T?> _tentar<T>(Future<T> Function() buscar) async {
    try {
      return await buscar();
    } catch (_) {
      return null;
    }
  }
}
