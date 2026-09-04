import 'package:flutter/material.dart';

import '../../../core/models/wave_forecast.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/fase_lua.dart';
import '../../../core/utils/indice_influencia_mare.dart';
import '../../../core/utils/nivel_operacional_mare.dart';
import '../../mapa/presentation/meus_pontos_screen.dart';
import '../../widgets/mare_pesca_atum/comparacao_sizigia_quadratura_widget.dart';
import '../../widgets/mare_pesca_atum/estado_mare_card.dart';
import '../../widgets/mare_pesca_atum/explicacao_mare_dialogs.dart';
import '../../widgets/mare_pesca_atum/fluxo_influencia_widget.dart';
import '../../widgets/mare_pesca_atum/grafico_mare_24h.dart';
import '../../widgets/mare_pesca_atum/indice_influencia_card.dart';
import '../../widgets/mare_pesca_atum/janela_operacional_widget.dart';
import '../../widgets/mare_pesca_atum/nivel_operacional_card.dart';
import '../../widgets/posicao_atual_widget.dart';
import '../data/previsao_tempo_repository.dart';
import '../data/wave_forecast_repository.dart';
import '../domain/models/previsao_tempo.dart';

/// Tela "Maré e Pesca de Atum" — inteligência oceanográfica de apoio à
/// decisão: explica sizígia/quadratura e relaciona a maré com a dinâmica
/// que pode afetar a disponibilidade de atum (correntes, mistura,
/// distribuição de presas), sem nunca afirmar uma correlação direta entre
/// fase da maré e captura (ver a doc de [calcularIndiceInfluenciaMare] e
/// [calcularNivelOperacionalMare] — os dois pontos onde essa regra mais
/// importa).
///
/// Segue a mesma separação DADO / INTERPRETAÇÃO / RECOMENDAÇÃO pedida:
/// - DADO: [EstadoMareCard], [GraficoMare24h], [JanelaOperacionalWidget]
///   (tudo vem de [WaveForecastRepository]/[PrevisaoTempoRepository] ou de
///   geometria lunar pura, calculada localmente);
/// - INTERPRETAÇÃO: [ComparacaoSizigiaQuadraturaWidget],
///   [IndiceInfluenciaCard], [FluxoInfluenciaWidget];
/// - RECOMENDAÇÃO: [NivelOperacionalCard] e o aviso científico no rodapé.
class MareEPescaAtumScreen extends StatefulWidget {
  /// Ponto fixo opcional — mesmo padrão de [CondicoesPontoScreen]: quando
  /// informado (vindo de "Meus Pontos", ver [MeusPontosScreen]), a tela
  /// consulta esse ponto direto, sem GPS nem `PosicaoAtualWidget`, então
  /// não tem como o usuário trocar sem querer de posição no meio da
  /// consulta. Quando `null` (padrão, entrada pelo menu), continua usando
  /// a posição atual da embarcação como sempre.
  final double? latitude;
  final double? longitude;

  /// Nome do ponto marcado/recomendação, se tiver — vira parte do
  /// cabeçalho no lugar do card de GPS.
  final String? nomePonto;

  const MareEPescaAtumScreen({super.key, this.latitude, this.longitude, this.nomePonto});

  bool get _pontoFixo => latitude != null && longitude != null;

  @override
  State<MareEPescaAtumScreen> createState() => _MareEPescaAtumScreenState();
}

class _MareEPescaAtumScreenState extends State<MareEPescaAtumScreen> {
  double? _lat;
  double? _lon;

  WaveForecast? _waveForecast;
  PrevisaoTempo? _previsaoTempo;
  bool _carregando = false;
  String? _erro;

  // A fase da lua não depende de GPS nem de rede — mesma decisão de
  // `CondicoesMarScreen`/`FaseLuaScreen` (ver `calcularFaseLua`).
  late final FaseLua _fase = calcularFaseLua();
  late final TipoMareAstronomica _tipoMare = calcularTipoMareAstronomica(_fase);

  @override
  void initState() {
    super.initState();
    // Ponto fixo (vindo de "Meus Pontos") já busca de cara — não espera
    // nenhum GPS, igual `CondicoesPontoScreen`.
    if (widget._pontoFixo) {
      _lat = widget.latitude;
      _lon = widget.longitude;
      _buscarDados();
    }
  }

  Future<void> _buscarDados() async {
    if (_lat == null || _lon == null) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final wave =
          await WaveForecastRepository().buscar(latitude: _lat!, longitude: _lon!);
      final tempo =
          await PrevisaoTempoRepository().buscar(latitude: _lat!, longitude: _lon!);
      if (!mounted) return;
      setState(() {
        _waveForecast = wave;
        _previsaoTempo = tempo;
      });
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _erro = mensagemErroAmigavel(e, prefixo: 'Erro ao buscar previsão de maré'));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _atualizarPosicao(double lat, double lon) {
    setState(() {
      _lat = lat;
      _lon = lon;
    });
    _buscarDados();
  }

  /// Amplitude entre a maior preamar e a menor baixa-mar previstas nas
  /// próximas 24h — `null` (nunca um valor inventado) quando não há pelo
  /// menos uma de cada na janela.
  double? get _amplitude24h {
    final forecast = _waveForecast;
    if (forecast == null) return null;
    final eventos = forecast.eventosMare
        .where((e) => e.time.isBefore(DateTime.now().add(const Duration(hours: 24))))
        .toList();
    final preamares = eventos.where((e) => e.tipo == TipoMare.alta).map((e) => e.alturaM);
    final baixamares = eventos.where((e) => e.tipo == TipoMare.baixa).map((e) => e.alturaM);
    if (preamares.isEmpty || baixamares.isEmpty) return null;
    return preamares.reduce((a, b) => a > b ? a : b) -
        baixamares.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    final forecast = _waveForecast;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget._pontoFixo
            ? (widget.nomePonto?.isNotEmpty == true ? widget.nomePonto! : 'Maré e Pesca')
            : 'Maré e Pesca'),
        actions: [
          if (widget._pontoFixo)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
              onPressed: _carregando ? null : _buscarDados,
            )
          else
            IconButton(
              icon: const Icon(Icons.pin_drop),
              tooltip: 'Meus Pontos',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeusPontosScreen()),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _cabecalho(context, corRot),
          const SizedBox(height: 20),
          if (widget._pontoFixo)
            _cardPontoFixo(context)
          else
            PosicaoAtualWidget(
              onPosicaoObtida: (posicao) =>
                  _atualizarPosicao(posicao.latitude, posicao.longitude),
            ),
          const SizedBox(height: 20),
          if (_lat == null || _lon == null)
            _mensagemCentral('Aguardando posição atual da embarcação...')
          else if (_carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erro != null)
            _cardErro(context)
          else if (forecast != null) ...[
            // 1. Estado atual da maré.
            EstadoMareCard(
              fase: _fase,
              tipoMare: _tipoMare,
              eventos: forecast.eventosMare,
              amplitudeMareM: _amplitude24h,
            ),
            const SizedBox(height: 20),
            // 2. Potencial de Influência (ex-Índice de Influência da Maré).
            IndiceInfluenciaCard(
              indice: calcularIndiceInfluenciaMare(
                fase: _fase,
                amplitudeMareM: _amplitude24h,
                correnteVelocidadeMs: forecast.current?.oceanCurrentVelocity,
              ),
            ),
            const SizedBox(height: 20),
            // 3. Classificação Atual (🟢🟡🔴).
            NivelOperacionalCard(
              nivelAtual: calcularNivelOperacionalMare(
                tipoMare: _tipoMare,
                correnteVelocidadeMs: forecast.current?.oceanCurrentVelocity,
              ),
            ),
            const SizedBox(height: 20),
            // 4. Gráfico de maré nas 24h.
            _cardGrafico24h(forecast),
            const SizedBox(height: 20),
            // 5. Janela operacional.
            JanelaOperacionalWidget(waveForecast: forecast, previsaoTempo: _previsaoTempo),
            const SizedBox(height: 20),
            // 6. Fluxo de Influência.
            const FluxoInfluenciaWidget(),
            const SizedBox(height: 20),
            // 7. Comparação sizígia × quadratura.
            const ComparacaoSizigiaQuadraturaWidget(),
            const SizedBox(height: 20),
            _botoesExplicacao(context),
          ],
          const SizedBox(height: 20),
          _avisoCientifico(corRot),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Card de pin no lugar do `PosicaoAtualWidget` quando a tela foi aberta
  /// num ponto fixo (ver [MareEPescaAtumScreen.latitude]) — mesmo visual
  /// do card correspondente em `CondicoesPontoScreen`, pra quem usa as
  /// duas telas reconhecer o padrão.
  Widget _cardPontoFixo(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cor = escuro ? Colors.blue.shade200 : Colors.blue.shade900;
    return Card(
      color: escuro ? Colors.blue.withValues(alpha: 0.18) : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.push_pin, color: cor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatarCoordenadasDMSCompacta(widget.latitude!, widget.longitude!),
                style: TextStyle(fontWeight: FontWeight.w600, color: cor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context, Color corRot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Influência da Maré na Pesca de Atum',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Entenda como a amplitude das marés pode alterar correntes, mistura da '
          'água e condições de alimentação dos atuns.',
          style: TextStyle(fontSize: 13, color: corRot, height: 1.4),
        ),
        const SizedBox(height: 12),
        _seloTipoMare(),
      ],
    );
  }

  Widget _seloTipoMare() {
    final cor = switch (_tipoMare) {
      TipoMareAstronomica.sizigia => Colors.orange.shade800,
      TipoMareAstronomica.quadratura => Colors.blueGrey,
      TipoMareAstronomica.transicao => Colors.teal,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water, size: 14, color: cor),
          const SizedBox(width: 6),
          Text('Condição atual da maré: ${_tipoMare.label}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cor)),
        ],
      ),
    );
  }

  /// Card do gráfico de maré nas 24h — título dentro do card, mesmo
  /// padrão de [NivelOperacionalCard]/[JanelaOperacionalWidget] (era um
  /// `Text` solto fora do card antes).
  Widget _cardGrafico24h(WaveForecast forecast) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Maré nas próximas 24h',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            GraficoMare24h(forecast: forecast, eventos: forecast.eventosMare),
          ],
        ),
      ),
    );
  }

  Widget _botoesExplicacao(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () => mostrarExplicacaoSizigia(context),
          icon: const Icon(Icons.nightlight_round, size: 16),
          label: const Text('Entenda a sizígia'),
        ),
        OutlinedButton.icon(
          onPressed: () => mostrarExplicacaoQuadratura(context),
          icon: const Icon(Icons.nightlight_round, size: 16),
          label: const Text('Entenda a quadratura'),
        ),
      ],
    );
  }

  Widget _avisoCientifico(Color corRot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 18),
            const SizedBox(width: 8),
            const Text('Importante',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          const Text(
            'A fase da maré não deve ser utilizada isoladamente para determinar '
            'uma área de pesca. A resposta do ambiente varia conforme localização, '
            'profundidade, topografia, regime de correntes, temperatura, '
            'disponibilidade de alimento, vento e outros fatores oceanográficos.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 6),
          const Text(
            'Utilize a maré como um dos indicadores dentro de uma análise integrada.',
            style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _mensagemCentral(String texto) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      );

  Widget _cardErro(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
                _erro == mensagemSemConexao ? Icons.wifi_off_outlined : Icons.error_outline,
                color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
