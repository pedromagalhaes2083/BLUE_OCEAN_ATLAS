import 'package:flutter/material.dart';

import '../../../core/models/wave_forecast.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../metereologia/domain/models/leitura_profundidade.dart';

/// Profundidade, temperatura (SST) e corrente de um ponto qualquer — busca
/// ao vivo (não depende do GPS atual), usada no diálogo de detalhe tanto de
/// um ponto marcado quanto de um ponto de recomendação, no mapa e na tela
/// "Meus Pontos".
class DadosOceanicosPonto extends StatefulWidget {
  final double latitude;
  final double longitude;

  const DadosOceanicosPonto({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DadosOceanicosPonto> createState() => _DadosOceanicosPontoState();
}

class _DadosOceanicosPontoState extends State<DadosOceanicosPonto> {
  bool _carregandoProfundidade = true;
  bool _carregandoTemperatura = true;
  LeituraProfundidade? _profundidade;
  double? _temperatura;

  /// Nós — convertido do km/h que a Open-Meteo retorna, mesma conversão
  /// usada em `CondicoesAtuaisCard` (`* 0.539957`).
  double? _correnteVelocidadeNos;
  int? _correnteDirecaoGraus;
  double? _nivelMarM;
  MareEvento? _proximoEventoMare;

  @override
  void initState() {
    super.initState();
    _carregarProfundidade();
    _carregarTemperatura();
  }

  Future<void> _carregarProfundidade() async {
    try {
      final resultado = await ProfundidadeRepository().buscarPonto(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (!mounted) return;
      setState(() {
        _profundidade = resultado;
        _carregandoProfundidade = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoProfundidade = false);
    }
  }

  Future<void> _carregarTemperatura() async {
    try {
      final forecast = await WaveForecastRepository().buscar(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (!mounted) return;
      setState(() {
        _temperatura = forecast.current?.seaSurfaceTemperature;
        final velocidadeKmh = forecast.current?.oceanCurrentVelocity;
        _correnteVelocidadeNos =
            velocidadeKmh != null ? velocidadeKmh * 0.539957 : null;
        _correnteDirecaoGraus = forecast.current?.oceanCurrentDirection;
        _nivelMarM = forecast.current?.seaLevelHeightMsl;
        final eventos = forecast.eventosMare;
        _proximoEventoMare = eventos.isNotEmpty ? eventos.first : null;
        _carregandoTemperatura = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoTemperatura = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinhaInfoPonto(
          icon: Icons.waves_outlined,
          label: 'Profundidade',
          valor: _valorProfundidade(),
          carregando: _carregandoProfundidade,
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.thermostat_outlined,
          label: 'Temperatura (SST)',
          valor: _temperatura != null
              ? '${_temperatura!.toStringAsFixed(1)}°C'
              : '—',
          carregando: _carregandoTemperatura,
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.water_outlined,
          label: 'Corrente',
          valor: _valorCorrente(),
          // Mesma chamada da temperatura (WaveForecastRepository.buscar) —
          // não tem loading próprio, os dois chegam juntos.
          carregando: _carregandoTemperatura,
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.waves_outlined,
          label: 'Maré',
          valor: _valorMare(),
          carregando: _carregandoTemperatura,
        ),
      ],
    );
  }

  String _valorCorrente() {
    final velocidade = _correnteVelocidadeNos;
    if (velocidade == null) return '—';
    final direcao = _correnteDirecaoGraus;
    return direcao != null
        ? '${velocidade.toStringAsFixed(1)} nós, $direcao°'
        : '${velocidade.toStringAsFixed(1)} nós';
  }

  String _valorMare() {
    final nivel = _nivelMarM;
    if (nivel == null) return '—';
    final evento = _proximoEventoMare;
    if (evento == null) return '${nivel.toStringAsFixed(2)} m';
    final tipo = evento.tipo == TipoMare.alta ? 'preamar' : 'baixa-mar';
    final h = evento.time.hour.toString().padLeft(2, '0');
    final m = evento.time.minute.toString().padLeft(2, '0');
    return '${nivel.toStringAsFixed(2)} m ($tipo às $h:$m)';
  }

  String _valorProfundidade() {
    final p = _profundidade;
    if (p == null) return '—';
    if (!p.emAgua) return 'Em terra';
    return '${p.profundidadeMetros.toStringAsFixed(0)} m';
  }
}

/// Linha "ícone + rótulo + valor" usada nos diálogos de detalhe de ponto
/// (coordenadas, data, distância, rumo, profundidade, temperatura, corrente).
class LinhaInfoPonto extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final bool carregando;

  const LinhaInfoPonto({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: carregando
              ? const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Text(
                  valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
        ),
      ],
    );
  }
}
