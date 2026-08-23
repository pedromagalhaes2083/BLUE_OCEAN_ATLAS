import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/proximidade.dart';
import '../../mapa/domain/models/ponto_marcado.dart';
import '../data/previsao_tempo_repository.dart';
import '../data/wave_forecast_repository.dart';

const double _alcanceMinimoMn = 5;
const double _alcanceMaximoMn = 100;
const double _alcancePassoMn = 5;
const double _alcancePadraoMn = 30;

/// Alerta de vento e corrente fortes num ponto à frente da embarcação —
/// projeta um ponto a [alcance] milhas náuticas no rumo atual do GPS (ver
/// [projetarPontoNoRumo]) e busca as condições ali, em vez de mostrar uma
/// grade de valores no mapa: a pergunta que importa pra decisão de
/// navegação é "o que tem no meu caminho", não "como está toda a região".
class AlertaRotaScreen extends StatefulWidget {
  const AlertaRotaScreen({super.key});

  @override
  State<AlertaRotaScreen> createState() => _AlertaRotaScreenState();
}

class _AlertaRotaScreenState extends State<AlertaRotaScreen> {
  double _alcanceMn = _alcancePadraoMn;

  Position? _posicao;
  bool _carregandoPosicao = true;
  String? _erroPosicao;

  double? _ventoKmh;
  int? _ventoDirecaoGraus;
  double? _correnteNos;
  int? _correnteDirecaoGraus;
  double? _ondaAlturaM;
  int? _ondaDirecaoGraus;
  double? _ondaPeriodoS;
  double? _swellAlturaM;
  int? _swellDirecaoGraus;
  double? _swellPeriodoS;
  bool _carregandoCondicoes = false;
  String? _erroCondicoes;

  /// Rumo magnético — do sensor de bússola do aparelho (magnetômetro), não
  /// do GPS. Diferente de [Position.heading] (usado só pra projetar o
  /// ponto à frente), esse funciona com a embarcação parada: é o rumo pra
  /// onde o aparelho está apontando agora, não o curso sobre o solo.
  double? _headingMagnetico;
  StreamSubscription<CompassEvent>? _compassSubscription;

  /// Quando true, [_posicao] é sintética (não vem do GPS real) — montada a
  /// partir de um ponto marcado + rumo escolhido, pra dar pra testar o
  /// alerta sem precisar da embarcação de verdade em movimento. Some
  /// automaticamente ao tocar em "Atualizar" (volta pro GPS real).
  bool _emSimulacao = false;
  String? _nomePontoSimulado;

  @override
  void initState() {
    super.initState();
    _carregarAlcanceSalvo();
    _atualizar();
    _compassSubscription = FlutterCompass.events?.listen((evento) {
      if (!mounted) return;
      setState(() => _headingMagnetico = evento.heading);
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _carregarAlcanceSalvo() async {
    final salvo = await Config.obtem(Constantes.alcanceAlertaRotaMn);
    final valor = double.tryParse(salvo);
    if (valor != null && mounted) {
      setState(() => _alcanceMn = valor.clamp(_alcanceMinimoMn, _alcanceMaximoMn));
    }
  }

  Future<void> _alterarAlcance(double novoValor) async {
    final clamped = novoValor.clamp(_alcanceMinimoMn, _alcanceMaximoMn);
    setState(() => _alcanceMn = clamped);
    await Config.grava(Constantes.alcanceAlertaRotaMn, clamped.toString());
    _buscarCondicoesNoPonto();
  }

  Future<void> _atualizar() async {
    setState(() {
      _carregandoPosicao = true;
      _erroPosicao = null;
      _emSimulacao = false;
      _nomePontoSimulado = null;
    });
    try {
      final posicao = await LocationService().getCurrentPosition();
      if (!mounted) return;
      setState(() => _posicao = posicao);
      await _buscarCondicoesNoPonto();
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroPosicao = 'Erro ao obter posição: $e');
    } finally {
      if (mounted) setState(() => _carregandoPosicao = false);
    }
  }

  /// Rumo válido exige a embarcação em movimento — parada, o GPS não tem
  /// como derivar curso sobre o solo, e `heading` costuma vir zerado ou
  /// obsoleto (ver `Position.heading` do geolocator). Em simulação, o rumo
  /// é escolhido manualmente, então sempre vale.
  bool get _rumoValido =>
      _posicao != null &&
      (_emSimulacao || (_posicao!.speed > 0.5 && _posicao!.heading >= 0));

  /// Abre a lista de pontos marcados e, depois de escolher um, um seletor
  /// de rumo — monta uma posição sintética nesse ponto (com o rumo
  /// escolhido e velocidade fixa só pra passar na checagem de
  /// [_rumoValido]) e roda o mesmo pipeline de busca de vento/corrente
  /// usado pra posição real do GPS. Só pra teste/planejamento: nunca é
  /// enviada a lugar nenhum, fica só no estado local da tela.
  Future<void> _simularComPontoMarcado() async {
    final maps = await DatabaseHelper.instance.query('ponto_marcado');
    if (!mounted) return;
    if (maps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum ponto marcado ainda')),
      );
      return;
    }
    final pontos = maps.map(PontoMarcado.fromMap).toList()
      ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

    final pontoEscolhido = await showDialog<PontoMarcado>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Simular a partir de qual ponto?'),
        children: pontos
            .map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, p),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.nome?.isNotEmpty == true ? p.nome! : 'Ponto marcado',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatarCoordenadasDMSCompacta(p.latitude, p.longitude),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
    if (pontoEscolhido == null || !mounted) return;

    final rumoEscolhido = await _escolherRumoSimulado();
    if (rumoEscolhido == null || !mounted) return;

    final posicaoSimulada = Position(
      latitude: pontoEscolhido.latitude,
      longitude: pontoEscolhido.longitude,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: rumoEscolhido,
      headingAccuracy: 0,
      speed: 5,
      speedAccuracy: 0,
      floor: null,
      isMocked: true,
    );

    setState(() {
      _posicao = posicaoSimulada;
      _emSimulacao = true;
      _nomePontoSimulado =
          pontoEscolhido.nome?.isNotEmpty == true ? pontoEscolhido.nome! : 'Ponto marcado';
      _erroPosicao = null;
    });
    await _buscarCondicoesNoPonto();
  }

  Future<double?> _escolherRumoSimulado() async {
    var rumo = 0.0;
    return showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rumo simulado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${rumo.toStringAsFixed(0)}°',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Slider(
                value: rumo,
                min: 0,
                max: 359,
                divisions: 359,
                label: '${rumo.toStringAsFixed(0)}°',
                onChanged: (v) => setDialogState(() => rumo = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, rumo),
              child: const Text('Simular'),
            ),
          ],
        ),
      ),
    );
  }

  ({double latitude, double longitude})? get _pontoProjetado {
    final posicao = _posicao;
    if (posicao == null || !_rumoValido) return null;
    return projetarPontoNoRumo(
      posicao.latitude,
      posicao.longitude,
      posicao.heading,
      _alcanceMn,
    );
  }

  Future<void> _buscarCondicoesNoPonto() async {
    final ponto = _pontoProjetado;
    if (ponto == null) return;

    setState(() {
      _carregandoCondicoes = true;
      _erroCondicoes = null;
    });
    try {
      final previsaoFuture = PrevisaoTempoRepository()
          .buscar(latitude: ponto.latitude, longitude: ponto.longitude);
      final ondaFuture = WaveForecastRepository()
          .buscar(latitude: ponto.latitude, longitude: ponto.longitude);
      final previsao = await previsaoFuture;
      final onda = await ondaFuture;
      if (!mounted) return;
      final velocidadeCorrenteKmh = onda.current?.oceanCurrentVelocity;
      setState(() {
        _ventoKmh = previsao.atual?.velocidadeVento;
        _ventoDirecaoGraus = previsao.atual?.direcaoVento;
        _correnteNos = velocidadeCorrenteKmh != null
            ? velocidadeCorrenteKmh * 0.539957
            : null;
        _correnteDirecaoGraus = onda.current?.oceanCurrentDirection;
        _ondaAlturaM = onda.current?.waveHeight;
        _ondaDirecaoGraus = onda.current?.waveDirection;
        _ondaPeriodoS = onda.current?.wavePeriod;
        _swellAlturaM = onda.current?.swellWaveHeight;
        _swellDirecaoGraus = onda.current?.swellWaveDirection;
        _swellPeriodoS = onda.current?.swellWavePeriod;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroCondicoes = 'Erro ao buscar condições: $e');
    } finally {
      if (mounted) setState(() => _carregandoCondicoes = false);
    }
  }

  Color _corVento(double kmh) {
    if (kmh < 10) return Colors.green.shade600;
    if (kmh < 20) return Colors.lightGreen.shade700;
    if (kmh < 30) return Colors.amber.shade800;
    if (kmh < 45) return Colors.orange;
    return Colors.redAccent;
  }

  String _labelVento(double kmh) {
    if (kmh < 10) return 'Calmo';
    if (kmh < 20) return 'Leve';
    if (kmh < 30) return 'Moderado';
    if (kmh < 45) return 'Forte';
    return 'Muito forte';
  }

  Color _corCorrente(double nos) {
    if (nos < 0.5) return Colors.green.shade600;
    if (nos < 1.0) return Colors.lightGreen.shade700;
    if (nos < 1.5) return Colors.amber.shade800;
    if (nos < 2.0) return Colors.orange;
    return Colors.redAccent;
  }

  String _labelCorrente(double nos) {
    if (nos < 0.5) return 'Fraca';
    if (nos < 1.0) return 'Moderada';
    if (nos < 1.5) return 'Forte';
    if (nos < 2.0) return 'Muito forte';
    return 'Extrema';
  }

  // Mesmas faixas usadas em CondicoesAtuaisCard (altura de onda) —
  // servem também pro swell, que é medido na mesma unidade (m).
  Color _corAltura(double m) {
    if (m < 0.5) return Colors.green.shade600;
    if (m < 1.0) return Colors.lightGreen.shade700;
    if (m < 2.0) return Colors.amber.shade800;
    if (m < 3.0) return Colors.orange.shade800;
    return Colors.redAccent.shade700;
  }

  String _labelAltura(double m) {
    if (m < 0.5) return 'Calmo';
    if (m < 1.0) return 'Leve';
    if (m < 2.0) return 'Moderado';
    if (m < 3.0) return 'Agitado';
    if (m < 4.0) return 'Muito agitado';
    return 'Tempestuoso';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerta de Rota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined),
            tooltip: 'Simular com ponto marcado',
            onPressed: _simularComPontoMarcado,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregandoPosicao ? null : _atualizar,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_emSimulacao) ...[
            _buildBannerSimulacao(),
            const SizedBox(height: 16),
          ],
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildAlcanceCard()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildBussolaCard()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_carregandoPosicao)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erroPosicao != null)
            _buildErroCard(_erroPosicao!)
          else if (!_rumoValido)
            _buildSemRumoCard()
          else ...[
            _buildPontoProjetadoCard(),
            const SizedBox(height: 16),
            if (_carregandoCondicoes)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_erroCondicoes != null)
              _buildErroCard(_erroCondicoes!)
            else ...[
              if (_ventoKmh != null) _buildAlertaCard(
                icon: Icons.air,
                titulo: 'Vento à frente',
                valor: '${_ventoKmh!.toStringAsFixed(0)} km/h',
                direcaoGraus: _ventoDirecaoGraus,
                cor: _corVento(_ventoKmh!),
                label: _labelVento(_ventoKmh!),
              ),
              const SizedBox(height: 12),
              if (_correnteNos != null) _buildAlertaCard(
                icon: Icons.water,
                titulo: 'Corrente à frente',
                valor: '${_correnteNos!.toStringAsFixed(1)} nós',
                direcaoGraus: _correnteDirecaoGraus,
                cor: _corCorrente(_correnteNos!),
                label: _labelCorrente(_correnteNos!),
              ),
              const SizedBox(height: 12),
              if (_ondaAlturaM != null) _buildAlertaCard(
                icon: Icons.waves,
                titulo: 'Onda à frente',
                valor: '${_ondaAlturaM!.toStringAsFixed(1)} m',
                subtitulo: _ondaPeriodoS != null
                    ? 'Período ${_ondaPeriodoS!.toStringAsFixed(1)} s'
                    : null,
                direcaoGraus: _ondaDirecaoGraus,
                cor: _corAltura(_ondaAlturaM!),
                label: _labelAltura(_ondaAlturaM!),
              ),
              const SizedBox(height: 12),
              if (_swellAlturaM != null) _buildAlertaCard(
                icon: Icons.tsunami_outlined,
                titulo: 'Swell à frente',
                valor: '${_swellAlturaM!.toStringAsFixed(1)} m',
                subtitulo: _swellPeriodoS != null
                    ? 'Período ${_swellPeriodoS!.toStringAsFixed(1)} s'
                    : null,
                direcaoGraus: _swellDirecaoGraus,
                cor: _corAltura(_swellAlturaM!),
                label: _labelAltura(_swellAlturaM!),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Rótulo cardinal (8 pontos) pro rumo em graus — N/NE/L/SE/S/SO/O/NO.
  String _direcaoCardinal(double graus) {
    const direcoes = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
    final normalizado = ((graus % 360) + 360) % 360;
    final indice = ((normalizado + 22.5) / 45).floor() % 8;
    return direcoes[indice];
  }

  /// Card com o rumo magnético — usa o magnetômetro do aparelho, não o
  /// rumo do GPS (esse último só existe com a embarcação em movimento,
  /// então um indicador baseado nele ficaria sempre vazio parado no cais).
  /// Só o número em graus + o rótulo cardinal, sem ponteiro/gráfico.
  Widget _buildBussolaCard() {
    final heading = _headingMagnetico;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            const Text('Bússola',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            if (heading != null) ...[
              Text(
                '${heading.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                _direcaoCardinal(heading),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceVariant),
              ),
            ] else ...[
              const Text('—',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('Sem sinal',
                  style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlcanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.social_distance_outlined,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Alcance do alerta',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${_alcanceMn.toStringAsFixed(0)} mn',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _alcanceMn <= _alcanceMinimoMn
                      ? null
                      : () => _alterarAlcance(_alcanceMn - _alcancePassoMn),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    ),
                    child: Slider(
                      value: _alcanceMn,
                      min: _alcanceMinimoMn,
                      max: _alcanceMaximoMn,
                      divisions:
                          ((_alcanceMaximoMn - _alcanceMinimoMn) / _alcancePassoMn)
                              .round(),
                      label: '${_alcanceMn.toStringAsFixed(0)} mn',
                      onChanged: (v) => setState(() => _alcanceMn = v),
                      onChangeEnd: _alterarAlcance,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: _alcanceMn >= _alcanceMaximoMn
                      ? null
                      : () => _alterarAlcance(_alcanceMn + _alcancePassoMn),
                ),
              ],
            ),
            Text(
              'Distância à frente da embarcação, no rumo atual, onde as '
              'condições são checadas.',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPontoProjetadoCard() {
    final ponto = _pontoProjetado!;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.navigation, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rumo ${_posicao!.heading.toStringAsFixed(0)}° · '
                      '${_alcanceMn.toStringAsFixed(0)} mn à frente'),
                  const SizedBox(height: 4),
                  Text(
                    formatarCoordenadasDMSCompacta(
                        ponto.latitude, ponto.longitude),
                    style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertaCard({
    required IconData icon,
    required String titulo,
    required String valor,
    String? subtitulo,
    required int? direcaoGraus,
    required Color cor,
    required String label,
  }) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: cor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(valor,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: cor)),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo,
                        style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: cor)),
                if (direcaoGraus != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('$direcaoGraus°',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: direcaoGraus * 3.14159265 / 180.0,
                        child: const Icon(Icons.navigation, size: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemRumoCard() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.explore_off_outlined, size: 48, color: onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Rumo indisponível — a embarcação precisa estar em movimento '
              'para o GPS calcular um rumo válido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _simularComPontoMarcado,
              icon: const Icon(Icons.science_outlined, size: 18),
              label: const Text('Simular com ponto marcado'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSimulacao() {
    return Card(
      color: Colors.amber.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.science_outlined, color: Colors.amber.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Simulação ativa — usando "$_nomePontoSimulado" com rumo '
                '${_posicao!.heading.toStringAsFixed(0)}° (não é o GPS real)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900),
              ),
            ),
            TextButton(
              onPressed: _atualizar,
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErroCard(String erro) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(erro,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
