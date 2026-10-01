import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../domain/models/leitura_termoclina.dart';
import '../domain/models/perfil_temperatura_ponto.dart';
import 'fonte_termoclina.dart';
import 'rfrom_ocean_repository.dart';

/// Faixa mínima de profundidade (m) que os pontos medidos da RFROM (ver
/// [RfromOceanRepository]) precisam cobrir pra [FonteTermoclinaEstimada]
/// confiar no gradiente real em vez do modelo estimado — bóias Argo não
/// cobrem a plataforma continental, então perto da costa é comum só vir
/// 1-2 níveis rasos (ex: 2,5m e 10m), o que não é suficiente pra localizar
/// uma termoclina de verdade (tipicamente entre 20-100m).
const _faixaMinimaParaTermoclinaReal = 30.0;

/// Quantos pontos medidos, no mínimo, pra considerar o gradiente real
/// (junto com [_faixaMinimaParaTermoclinaReal]) — 2 pontos só dão uma
/// reta, não é suficiente pra achar o nível de maior queda com confiança.
const _pontosMinimosParaTermoclinaReal = 4;

/// Queda mínima (°C por metro) no intervalo mais acentuado do perfil
/// medido pra contar como uma termoclina de verdade, não só o gradiente
/// suave que a água tem em qualquer profundidade.
const _quedaMinimaPorMetro = 0.05;

/// Fonte padrão de [TermoclinaRepository] hoje: combina dado real de duas
/// APIs — a temperatura da superfície do mar (SST), da mesma Open-Meteo
/// Marine que o resto do app já consome (ver [WaveForecastRepository]) —
/// e, quando a região tiver cobertura, o perfil vertical de temperatura
/// medido por bóias Argo (mapa global RFROM v2.3 da NOAA/PMEL, ver
/// [RfromOceanRepository]) — com o modelo estimado preenchendo só o que
/// nenhuma das duas cobre.
///
/// Em mar aberto, onde a RFROM tem boa cobertura vertical, a profundidade
/// da termoclina é **derivada do gradiente real** (ver
/// [LeituraTermoclina.profundidadeTermoclinaMedida]). Perto da costa —
/// onde bóias Argo não operam — normalmente só sobra 1-2 pontos rasos
/// reais, e a profundidade da termoclina cai pro modelo estimado (mesmo
/// comportamento de antes desta integração). Por isso `fonte` continua
/// `'estimado_sst_open_meteo'` (nunca `'copernicus_marine'`, reservado pra
/// uma fonte com perfil vertical medido garantido em qualquer ponto) —
/// [LeituraTermoclina.perfilEstimado] reflete que ainda pode haver trechos
/// modelados no perfil, mesmo quando a termoclina em si já é medida.
///
/// Se a SST real não estiver disponível pra essa coordenada (fora de
/// cobertura do modelo marinho, sem rede e sem cache — ver
/// [WaveForecastRepository.buscar]), propaga a exceção pra tela mostrar o
/// estado de erro já existente, em vez de inventar um valor.
class FonteTermoclinaEstimada implements FonteTermoclina {
  final WaveForecastRepository _waveForecastRepository;
  final ProfundidadeRepository _profundidadeRepository;
  final RfromOceanRepository _rfromOceanRepository;

  FonteTermoclinaEstimada({
    WaveForecastRepository? waveForecastRepository,
    ProfundidadeRepository? profundidadeRepository,
    RfromOceanRepository? rfromOceanRepository,
  })  : _waveForecastRepository =
            waveForecastRepository ?? WaveForecastRepository(),
        _profundidadeRepository =
            profundidadeRepository ?? ProfundidadeRepository(),
        _rfromOceanRepository = rfromOceanRepository ?? RfromOceanRepository();

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

    // Batimetria e perfil RFROM são só best-effort (não fazem parte do
    // contrato mínimo desta fonte, que é a SST acima) — cada um falha em
    // silêncio e a estimativa segue sem ele, como antes desta integração.
    double? profundidadeLocal;
    try {
      final leituraProfundidade = await _profundidadeRepository.buscarPonto(
        latitude: latitude,
        longitude: longitude,
      );
      if (leituraProfundidade.emAgua) {
        profundidadeLocal = leituraProfundidade.profundidadeMetros;
      }
    } catch (_) {
      // Sem batimetria disponível — segue sem o limite.
    }

    var pontosReaisRfrom = const <PerfilTemperaturaPonto>[];
    try {
      final perfilRfrom = await _rfromOceanRepository.buscarPerfil(
        latitude: latitude,
        longitude: longitude,
      );
      pontosReaisRfrom = perfilRfrom.temperatura;
    } catch (_) {
      // Sem perfil real disponível — segue só com o modelo estimado.
    }

    // Mesma variação determinística do modelo mock — usada só onde não
    // sobrar dado real (SST/RFROM), preenchendo o resto do perfil e a
    // profundidade da termoclina quando a RFROM não tiver cobertura
    // suficiente nesse ponto.
    final semente = (latitude * 1000 + longitude * 1000).abs();
    final variacaoProfundidade = (semente % 17).toInt() - 8; // ±8 m

    final perfilEstimadoBase = <PerfilTemperaturaPonto>[
      PerfilTemperaturaPonto(profundidadeM: 0, temperaturaC: sstReal, medido: true),
      PerfilTemperaturaPonto(profundidadeM: 10, temperaturaC: sstReal - 0.2),
      PerfilTemperaturaPonto(profundidadeM: 20, temperaturaC: sstReal - 0.5),
      PerfilTemperaturaPonto(profundidadeM: 30, temperaturaC: sstReal - 1.1),
      PerfilTemperaturaPonto(profundidadeM: 40, temperaturaC: sstReal - 2.5),
      PerfilTemperaturaPonto(profundidadeM: 50, temperaturaC: sstReal - 3.8),
      PerfilTemperaturaPonto(profundidadeM: 60, temperaturaC: sstReal - 4.3),
    ];

    // Onde a RFROM tiver dado real no mesmo nível de profundidade, ele
    // substitui o ponto estimado; níveis reais que não têm par no perfil
    // sintético (ex: 70m, 80m — a RFROM cobre mais fundo que o modelo
    // interno) são acrescentados à parte.
    final perfilCompleto = perfilEstimadoBase.map((estimado) {
      for (final real in pontosReaisRfrom) {
        if (real.profundidadeM == estimado.profundidadeM) return real;
      }
      return estimado;
    }).toList();
    for (final real in pontosReaisRfrom) {
      final jaExiste =
          perfilCompleto.any((p) => p.profundidadeM == real.profundidadeM);
      if (!jaExiste) perfilCompleto.add(real);
    }
    perfilCompleto.sort((a, b) => a.profundidadeM.compareTo(b.profundidadeM));

    // Nunca mostra um ponto do perfil abaixo do fundo real — a superfície
    // (0m) sempre fica, mesmo em água muito rasa.
    final perfil = profundidadeLocal == null
        ? perfilCompleto
        : perfilCompleto
            .where((p) => p.profundidadeM == 0 || p.profundidadeM <= profundidadeLocal!)
            .toList();

    // Deriva só a partir dos pontos da RFROM entre si — nunca misturando
    // com a SST de superfície (Open-Meteo, ao vivo): são fontes/instantes
    // diferentes (RFROM é uma média semanal), então mesmo sem nenhuma
    // termoclina de verdade ali, a diferença entre as duas já cria um
    // "gradiente" enorme nos primeiros metros que não representa nada
    // físico — teria disparado uma "termoclina medida" a 1m de qualquer
    // jeito. Também respeita o filtro de fundo acima (perfil, não
    // pontosReaisRfrom bruto).
    final tetoFundo = profundidadeLocal;
    final pontosRfromFiltrados = pontosReaisRfrom
        .where((p) => tetoFundo == null || p.profundidadeM <= tetoFundo)
        .toList();
    final termoclinaMedida = _derivarTermoclinaReal(pontosRfromFiltrados);

    var profundidadeTermoclina = termoclinaMedida ??
        (48 + variacaoProfundidade).clamp(25, 65).toDouble();
    if (termoclinaMedida == null &&
        profundidadeLocal != null &&
        profundidadeLocal > 0) {
      // Margem proporcional (10%-90% da coluna d'água), não fixa em metros
      // — uma margem fixa (ex: sempre 2m acima do fundo, piso em 1m) ainda
      // deixava a termoclina mais funda que o próprio fundo em água
      // rasadíssima (ex: fundo de 0.5m: teto viraria 1m, acima do fundo).
      // Proporcional garante piso <= teto pra qualquer profundidade > 0,
      // sem precisar de caso especial. Só se aplica à estimativa — uma
      // termoclina já derivada do gradiente real dos pontos medidos (que
      // já foram filtrados pelo fundo acima) não precisa dessa margem.
      final pisoTermoclina = profundidadeLocal * 0.1;
      final tetoTermoclina = profundidadeLocal * 0.9;
      profundidadeTermoclina =
          profundidadeTermoclina.clamp(pisoTermoclina, tetoTermoclina);
    }
    final confianca = termoclinaMedida != null
        ? 0.93
        : (0.82 - (variacaoProfundidade.abs() / 100)).clamp(0.5, 0.95);

    return LeituraTermoclina(
      latitude: latitude,
      longitude: longitude,
      instante: data ?? DateTime.now(),
      sst: double.parse(sstReal.toStringAsFixed(1)),
      profundidadeTermoclina: profundidadeTermoclina,
      confianca: double.parse(confianca.toStringAsFixed(2)),
      perfil: perfil,
      fonte: 'estimado_sst_open_meteo',
      profundidadeLocalM: profundidadeLocal,
      profundidadeTermoclinaMedida: termoclinaMedida != null,
    );
  }

  /// Acha o nível de maior queda de temperatura por metro entre pontos
  /// consecutivos **da própria RFROM** — a definição usual de profundidade
  /// da termoclina — e devolve o ponto médio do intervalo onde ela ocorre.
  ///
  /// Só entre pontos da mesma fonte (nunca incluindo a SST de superfície
  /// do Open-Meteo aqui, mesmo que também seja um dado real): RFROM é uma
  /// média semanal e o Open-Meteo é ao vivo, então a diferença natural
  /// entre os dois já cria um "gradiente" nos primeiros metros que não é
  /// uma termoclina de verdade — só um descompasso entre fontes.
  ///
  /// `null` quando não há pontos suficientes (ver
  /// [_pontosMinimosParaTermoclinaReal]/[_faixaMinimaParaTermoclinaReal]) ou
  /// quando a maior queda encontrada é rasa demais pra ser uma termoclina
  /// de verdade (ver [_quedaMinimaPorMetro]), não só o gradiente suave que
  /// a coluna d'água tem em qualquer profundidade.
  double? _derivarTermoclinaReal(List<PerfilTemperaturaPonto> pontosRfrom) {
    final medidos = pontosRfrom.toList()
      ..sort((a, b) => a.profundidadeM.compareTo(b.profundidadeM));

    if (medidos.length < _pontosMinimosParaTermoclinaReal) return null;
    if (medidos.last.profundidadeM - medidos.first.profundidadeM <
        _faixaMinimaParaTermoclinaReal) {
      return null;
    }

    var maiorQuedaPorMetro = 0.0;
    double? profundidadeDaMaiorQueda;
    for (var i = 0; i < medidos.length - 1; i++) {
      final a = medidos[i];
      final b = medidos[i + 1];
      final deltaProfundidade = b.profundidadeM - a.profundidadeM;
      if (deltaProfundidade <= 0) continue;
      final quedaPorMetro = (a.temperaturaC - b.temperaturaC) / deltaProfundidade;
      if (quedaPorMetro > maiorQuedaPorMetro) {
        maiorQuedaPorMetro = quedaPorMetro;
        profundidadeDaMaiorQueda = (a.profundidadeM + b.profundidadeM) / 2;
      }
    }

    if (profundidadeDaMaiorQueda == null ||
        maiorQuedaPorMetro < _quedaMinimaPorMetro) {
      return null;
    }
    return profundidadeDaMaiorQueda;
  }
}
