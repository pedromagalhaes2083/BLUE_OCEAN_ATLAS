import '../utils/proximidade.dart';
import 'amostra_gps.dart';

/// Resultado da triagem de uma [AmostraGps]:
/// - [valida]: pode ser exibida, usada em análises e enviada à API;
/// - [suspeita]: é uma posição de verdade, mas com algo que a torna pouco
///   confiável (salto implausível, precisão ruim, antiga, simulada...) —
///   guardada localmente pra auditoria, nunca tratada como a posição atual;
/// - [invalida]: não é uma coordenada utilizável (fora da faixa, não
///   finita, sem instante válido) — não dá nem pra guardar.
enum StatusValidacaoGps { valida, suspeita, invalida }

/// Por que uma amostra foi marcada como [StatusValidacaoGps.suspeita] ou
/// [StatusValidacaoGps.invalida]. O `name` de cada valor é o que vai pro
/// banco (coluna `motivos_validacao`), então não renomear sem migração.
enum MotivoValidacaoGps {
  coordenadaNaoFinita,
  latitudeForaDaFaixa,
  longitudeForaDaFaixa,
  instanteInvalido,
  instanteNoFuturo,
  posicaoAntiga,
  precisaoInsuficiente,
  saltoImplausivel,
  origemSimulada,
  ilhaNula,

  /// Não é um problema: a amostra destoava da última posição válida, mas
  /// confirmou a amostra suspeita anterior — sinal de que o erro estava na
  /// posição válida antiga, não nas novas (ver [ValidadorPosicao.validar]).
  reancorada,
}

class ResultadoValidacaoGps {
  final StatusValidacaoGps status;
  final List<MotivoValidacaoGps> motivos;

  const ResultadoValidacaoGps(this.status, this.motivos);

  bool get valida => status == StatusValidacaoGps.valida;
  bool get invalida => status == StatusValidacaoGps.invalida;

  /// Suspeita só por salto — candidata a confirmar uma nova posição (ver
  /// [MotivoValidacaoGps.reancorada]).
  bool get suspeitaSoPorSalto =>
      status == StatusValidacaoGps.suspeita &&
      motivos.length == 1 &&
      motivos.single == MotivoValidacaoGps.saltoImplausivel;
}

/// Limites da triagem — o perfil da embarcação, não números mágicos
/// espalhados pelo código.
class ConfigValidacaoGps {
  /// Velocidade máxima plausível pra embarcação (nós). Um barco pesqueiro
  /// costuma navegar a 8–15 nós; 35 deixa folga pra lanchas de apoio sem
  /// aceitar saltos de quilômetros em segundos.
  final double velocidadeMaximaNos;

  /// Acima disso a posição é imprecisa demais pra representar a embarcação
  /// (fix de rede/torre, não de satélite).
  final double precisaoMaximaMetros;

  /// Idade máxima de uma posição pra ainda ser "atual" no momento em que é
  /// avaliada.
  final Duration idadeMaxima;

  /// Folga pra diferença entre o relógio do GPS e o do aparelho antes de
  /// considerar a posição "no futuro".
  final Duration toleranciaRelogio;

  const ConfigValidacaoGps({
    this.velocidadeMaximaNos = 35,
    this.precisaoMaximaMetros = 150,
    this.idadeMaxima = const Duration(minutes: 3),
    this.toleranciaRelogio = const Duration(minutes: 2),
  });

  double get velocidadeMaximaMs => velocidadeMaximaNos * 1852 / 3600;
}

/// Triagem de posições GPS antes de gravar, exibir ou enviar.
///
/// A detecção de salto compara a amostra com a última posição válida pela
/// **velocidade necessária** pra ir de uma à outra, não por uma distância
/// fixa: depois de horas sem sinal, a embarcação pode estar a dezenas de
/// milhas e isso é coerente; a mesma distância em 30 segundos não é. A
/// precisão das duas posições é descontada da distância antes do cálculo,
/// pra ruído normal do GPS não virar "salto".
class ValidadorPosicao {
  /// Instantes anteriores a isso não são de um GPS funcionando (relógio
  /// zerado/epoch).
  static final _instanteMinimo = DateTime.utc(2000);

  static ResultadoValidacaoGps validar(
    AmostraGps amostra, {
    required DateTime agora,
    AmostraGps? anteriorValida,
    AmostraGps? ultimaSuspeitaPorSalto,
    ConfigValidacaoGps config = const ConfigValidacaoGps(),
  }) {
    final lat = amostra.latitude;
    final lon = amostra.longitude;

    // ── Inválidas: nem dá pra guardar como coordenada ──────────────────────
    if (!lat.isFinite || !lon.isFinite) {
      return const ResultadoValidacaoGps(StatusValidacaoGps.invalida,
          [MotivoValidacaoGps.coordenadaNaoFinita]);
    }
    final invalidos = <MotivoValidacaoGps>[
      if (lat < -90 || lat > 90) MotivoValidacaoGps.latitudeForaDaFaixa,
      if (lon < -180 || lon > 180) MotivoValidacaoGps.longitudeForaDaFaixa,
      if (amostra.instante.isBefore(_instanteMinimo))
        MotivoValidacaoGps.instanteInvalido,
    ];
    if (invalidos.isNotEmpty) {
      return ResultadoValidacaoGps(StatusValidacaoGps.invalida, invalidos);
    }

    // ── Suspeitas: posição real, mas não confiável ─────────────────────────
    final motivos = <MotivoValidacaoGps>[];
    final idade = agora.toUtc().difference(amostra.instante.toUtc());
    if (idade > config.idadeMaxima) motivos.add(MotivoValidacaoGps.posicaoAntiga);
    if (-idade > config.toleranciaRelogio) {
      motivos.add(MotivoValidacaoGps.instanteNoFuturo);
    }
    final precisao = amostra.precisaoMetros;
    if (precisao != null && precisao > config.precisaoMaximaMetros) {
      motivos.add(MotivoValidacaoGps.precisaoInsuficiente);
    }
    if (amostra.simulada) motivos.add(MotivoValidacaoGps.origemSimulada);
    // (0, 0) é no meio do Atlântico, mas é sobretudo o valor que receptores
    // devolvem sem fix — nunca uma posição de uma embarcação desta frota.
    if (lat.abs() < 1e-6 && lon.abs() < 1e-6) {
      motivos.add(MotivoValidacaoGps.ilhaNula);
    }

    if (anteriorValida != null &&
        !_deslocamentoPlausivel(anteriorValida, amostra, config)) {
      // Confirma a suspeita anterior em vez de destoar dela → o ponto fora
      // da curva era a "última válida", não as amostras novas. Sem isso,
      // uma única posição ruim aceita travaria todas as seguintes como
      // "salto" pra sempre.
      final confirmaSuspeita = ultimaSuspeitaPorSalto != null &&
          ultimaSuspeitaPorSalto.instante.isBefore(amostra.instante) &&
          _deslocamentoPlausivel(ultimaSuspeitaPorSalto, amostra, config);
      motivos.add(confirmaSuspeita
          ? MotivoValidacaoGps.reancorada
          : MotivoValidacaoGps.saltoImplausivel);
    }

    final problemas =
        motivos.where((m) => m != MotivoValidacaoGps.reancorada).toList();
    return ResultadoValidacaoGps(
      problemas.isEmpty ? StatusValidacaoGps.valida : StatusValidacaoGps.suspeita,
      motivos,
    );
  }

  /// Distância em metros entre duas amostras (haversine).
  static double distanciaMetros(AmostraGps a, AmostraGps b) =>
      calcularDistanciaNauticas(a.latitude, a.longitude, b.latitude, b.longitude) *
      1852;

  static bool _deslocamentoPlausivel(
      AmostraGps de, AmostraGps para, ConfigValidacaoGps config) {
    final distancia = distanciaMetros(de, para);
    // Desconta o raio de incerteza das duas leituras: duas posições
    // imprecisas do mesmo lugar parecem distantes sem a embarcação mover.
    final efetiva = (distancia - (de.precisaoMetros ?? 0) - (para.precisaoMetros ?? 0))
        .clamp(0.0, double.infinity);
    final segundos =
        para.instante.difference(de.instante).inMilliseconds / 1000;
    if (segundos <= 0) return efetiva == 0;
    return efetiva <= config.velocidadeMaximaMs * segundos;
  }
}
