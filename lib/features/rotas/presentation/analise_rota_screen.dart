import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/limiares_alerta.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/proximidade.dart';
import '../../../core/utils/severidade_condicoes.dart';
import '../../metereologia/data/previsao_tempo_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';

/// Condições do mar buscadas pra um ponto específico da rota — cada campo
/// nulo significa "a API não trouxe esse dado nesse ponto" (comum em
/// pontos muito próximos da costa/terra), não necessariamente um erro.
class _CondicaoPonto {
  final int indice;
  final LatLng ponto;
  bool carregando = true;
  String? erro;

  double? ventoKmh;
  int? ventoDirecaoGraus;
  double? ondaAlturaM;
  double? swellAlturaM;
  double? correnteNos;
  double? temperaturaC;
  double? nivelMarM;

  _CondicaoPonto({required this.indice, required this.ponto});

  bool severo(LimiaresAlerta limiares) {
    if (limiares.ventoAtivo &&
        ventoKmh != null &&
        ventoSevero(ventoKmh!, limiares.ventoLimiarKmh)) {
      return true;
    }
    if (limiares.correnteAtivo &&
        correnteNos != null &&
        correnteSevera(correnteNos!, limiares.correnteLimiarNos)) {
      return true;
    }
    if (limiares.ondaAtivo &&
        ondaAlturaM != null &&
        alturaSevera(ondaAlturaM!, limiares.ondaLimiarM)) {
      return true;
    }
    if (limiares.ondaAtivo &&
        swellAlturaM != null &&
        alturaSevera(swellAlturaM!, limiares.ondaLimiarM)) {
      return true;
    }
    if (limiares.temperaturaAtivo &&
        temperaturaC != null &&
        temperaturaSevera(temperaturaC!, limiares.temperaturaLimiarC)) {
      return true;
    }
    return false;
  }
}

/// Busca as condições do mar (vento, onda/swell, corrente, maré) em cada
/// ponto de uma rota planejada e mostra, ponto a ponto, onde a viagem
/// cruza uma condição severa — usando os mesmos limiares configuráveis em
/// "Configurar Alertas" (ver [LimiaresAlerta]), pra não ter dois lugares
/// no app discordando do que conta como severo.
class AnaliseRotaScreen extends StatefulWidget {
  final String nomeRota;
  final List<LatLng> pontos;

  const AnaliseRotaScreen({
    super.key,
    required this.nomeRota,
    required this.pontos,
  });

  @override
  State<AnaliseRotaScreen> createState() => _AnaliseRotaScreenState();
}

class _AnaliseRotaScreenState extends State<AnaliseRotaScreen> {
  late List<_CondicaoPonto> _condicoes;
  LimiaresAlerta _limiares = LimiaresAlerta.padrao;
  bool _carregandoLimiares = true;

  @override
  void initState() {
    super.initState();
    _condicoes = [
      for (var i = 0; i < widget.pontos.length; i++)
        _CondicaoPonto(indice: i, ponto: widget.pontos[i]),
    ];
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    final limiares = await LimiaresAlerta.carregar();
    if (!mounted) return;
    setState(() {
      _limiares = limiares;
      _carregandoLimiares = false;
    });

    // Em paralelo — cada ponto é independente, e esperar em série
    // multiplicaria a espera por N pontos à toa.
    await Future.wait(_condicoes.map(_carregarPonto));
  }

  Future<void> _carregarPonto(_CondicaoPonto c) async {
    try {
      final previsaoFuture = PrevisaoTempoRepository()
          .buscar(latitude: c.ponto.latitude, longitude: c.ponto.longitude);
      final ondaFuture = WaveForecastRepository()
          .buscar(latitude: c.ponto.latitude, longitude: c.ponto.longitude);
      final previsao = await previsaoFuture;
      final onda = await ondaFuture;

      final velocidadeCorrenteKmh = onda.current?.oceanCurrentVelocity;
      c
        ..ventoKmh = previsao.atual?.velocidadeVento
        ..ventoDirecaoGraus = previsao.atual?.direcaoVento
        ..ondaAlturaM = onda.current?.waveHeight
        ..swellAlturaM = onda.current?.swellWaveHeight
        ..correnteNos = velocidadeCorrenteKmh != null
            ? velocidadeCorrenteKmh * 0.539957
            : null
        ..temperaturaC = onda.current?.seaSurfaceTemperature
        ..nivelMarM = onda.current?.seaLevelHeightMsl
        ..carregando = false;
    } catch (e) {
      c
        ..erro = mensagemErroAmigavel(e)
        ..carregando = false;
    }
    if (mounted) setState(() {});
  }

  double get _distanciaTotalMn {
    var soma = 0.0;
    for (var i = 1; i < widget.pontos.length; i++) {
      soma += calcularDistanciaNauticas(
        widget.pontos[i - 1].latitude,
        widget.pontos[i - 1].longitude,
        widget.pontos[i].latitude,
        widget.pontos[i].longitude,
      );
    }
    return soma;
  }

  bool get _aindaCarregando =>
      _carregandoLimiares || _condicoes.any((c) => c.carregando);

  List<_CondicaoPonto> get _pontosSeveros =>
      _condicoes.where((c) => !c.carregando && c.severo(_limiares)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Análise: ${widget.nomeRota}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildResumo(),
          const SizedBox(height: 20),
          for (var i = 0; i < _condicoes.length; i++) ...[
            _buildCardPonto(_condicoes[i], anterior: i > 0 ? _condicoes[i - 1] : null),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildResumo() {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final severos = _pontosSeveros;
    final temSevero = severos.isNotEmpty;
    final escuro = Theme.of(context).brightness == Brightness.dark;

    // Tons translúcidos em vez de um fundo claro fixo (ex: `Colors.red[50]`)
    // — sobre fundo escuro, aquele rosa/verde pastel ficava quase branco e
    // o texto padrão (também claro no tema escuro) ficava ilegível em cima.
    final corFundo = !_aindaCarregando
        ? (temSevero
            ? Colors.red.withValues(alpha: escuro ? 0.18 : 0.08)
            : Colors.green.withValues(alpha: escuro ? 0.15 : 0.08))
        : null;
    final corDestaque = temSevero
        ? (escuro ? Colors.red.shade200 : Colors.red.shade800)
        : (escuro ? Colors.green.shade300 : Colors.green.shade800);

    return Card(
      elevation: 3,
      color: corFundo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _aindaCarregando
                      ? Icons.hourglass_top
                      : (temSevero
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline),
                  color: _aindaCarregando ? onSurfaceVariant : corDestaque,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _aindaCarregando
                        ? 'Buscando condições ao longo da rota...'
                        : (temSevero
                            ? '${severos.length} de ${_condicoes.length} '
                                'pontos com condição severa'
                            : 'Nenhum ponto com condição severa'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _aindaCarregando ? null : corDestaque),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${_condicoes.length} pontos · '
              '${_distanciaTotalMn.toStringAsFixed(1)} mn no total',
              style: TextStyle(fontSize: 12, color: onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPonto(_CondicaoPonto c, {_CondicaoPonto? anterior}) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final severo = !c.carregando && c.severo(_limiares);
    final corDestaqueSevero = escuro ? Colors.red.shade200 : Colors.red.shade800;
    final trecho = anterior == null
        ? null
        : calcularDistanciaNauticas(anterior.ponto.latitude,
            anterior.ponto.longitude, c.ponto.latitude, c.ponto.longitude);

    return Card(
      elevation: 2,
      color: severo
          ? Colors.red.withValues(alpha: escuro ? 0.18 : 0.08)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: severo
            ? BorderSide(color: Colors.red.withValues(alpha: 0.4))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: severo ? Colors.red : Colors.purple,
                  child: Text('${c.indice + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatarCoordenadasDMSCompacta(
                        c.ponto.latitude, c.ponto.longitude),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: severo ? corDestaqueSevero : null),
                  ),
                ),
                if (severo)
                  Icon(Icons.warning_amber_rounded,
                      color: corDestaqueSevero, size: 20),
              ],
            ),
            if (trecho != null) ...[
              const SizedBox(height: 4),
              Text(
                '+${trecho.toStringAsFixed(1)} mn desde o ponto ${c.indice}',
                style: TextStyle(fontSize: 11, color: onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            if (c.carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (c.erro != null)
              Row(
                children: [
                  Icon(
                      c.erro == mensagemSemConexao
                          ? Icons.wifi_off_outlined
                          : Icons.error_outline,
                      size: 16,
                      color: corDestaqueSevero),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(c.erro!,
                        style: TextStyle(
                            fontSize: 12, color: corDestaqueSevero)),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _metrica(
                    Icons.air,
                    c.ventoKmh != null
                        ? '${c.ventoKmh!.toStringAsFixed(0)} km/h'
                        : '—',
                    'Vento',
                    c.ventoKmh != null &&
                        _limiares.ventoAtivo &&
                        ventoSevero(c.ventoKmh!, _limiares.ventoLimiarKmh),
                  ),
                  _metrica(
                    Icons.waves_outlined,
                    c.ondaAlturaM != null
                        ? '${c.ondaAlturaM!.toStringAsFixed(1)} m'
                        : '—',
                    'Onda',
                    c.ondaAlturaM != null &&
                        _limiares.ondaAtivo &&
                        alturaSevera(c.ondaAlturaM!, _limiares.ondaLimiarM),
                  ),
                  _metrica(
                    Icons.water_outlined,
                    c.correnteNos != null
                        ? '${c.correnteNos!.toStringAsFixed(1)} nós'
                        : '—',
                    'Corrente',
                    c.correnteNos != null &&
                        _limiares.correnteAtivo &&
                        correnteSevera(
                            c.correnteNos!, _limiares.correnteLimiarNos),
                  ),
                  _metrica(
                    Icons.thermostat_outlined,
                    c.temperaturaC != null
                        ? '${c.temperaturaC!.toStringAsFixed(1)}°C'
                        : '—',
                    'Água',
                    c.temperaturaC != null &&
                        _limiares.temperaturaAtivo &&
                        temperaturaSevera(
                            c.temperaturaC!, _limiares.temperaturaLimiarC),
                  ),
                  if (c.nivelMarM != null)
                    _metrica(Icons.waves, '${c.nivelMarM!.toStringAsFixed(2)} m',
                        'Maré', false),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _metrica(IconData icon, String valor, String label, bool severo) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cor =
        severo ? (escuro ? Colors.red.shade200 : Colors.red.shade800) : null;
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          Icon(icon, size: 16, color: cor ?? Colors.blueGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(valor,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: cor)),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cor ?? corRotulo(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
