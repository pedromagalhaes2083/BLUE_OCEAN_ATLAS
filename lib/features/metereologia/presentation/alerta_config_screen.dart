import 'package:flutter/material.dart';

import '../../../core/config/limiares_alerta.dart';

/// Tela pra configurar quando o app deve disparar a notificação de
/// "condição severa à frente" (ver `AlertaCondicaoNotificationService`) —
/// um cartão por condição (vento, altura de onda/swell, corrente e
/// temperatura), cada um com um interruptor pra ligar/desligar e um
/// slider pro limiar. Salva a cada mudança, sem botão "Salvar" separado.
class AlertaConfigScreen extends StatefulWidget {
  const AlertaConfigScreen({super.key});

  @override
  State<AlertaConfigScreen> createState() => _AlertaConfigScreenState();
}

class _AlertaConfigScreenState extends State<AlertaConfigScreen> {
  LimiaresAlerta _limiares = LimiaresAlerta.padrao;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final limiares = await LimiaresAlerta.carregar();
    if (!mounted) return;
    setState(() {
      _limiares = limiares;
      _carregando = false;
    });
  }

  Future<void> _atualizar(LimiaresAlerta novo) async {
    setState(() => _limiares = novo);
    await novo.salvar();
  }

  /// Só atualiza o estado local, sem gravar — usado no `onChanged` do
  /// slider, que dispara a cada pixel arrastado; gravar no Hive a cada
  /// tick travaria o gesto à toa. A gravação de verdade fica pro
  /// `onChangeEnd` (ver [_atualizar]), quando o usuário solta o dedo.
  void _atualizarLocal(LimiaresAlerta novo) {
    setState(() => _limiares = novo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Alertas')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Escolha a partir de que ponto cada condição no caminho '
                  'da embarcação dispara uma notificação (com vibração). '
                  'Vale tanto pra checagem manual em "Alerta de Rota" '
                  'quanto pro rastreamento em segundo plano durante uma '
                  'viagem.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _CardLimiar(
                  icon: Icons.air,
                  titulo: 'Vento',
                  subtitulo: 'Alerta quando o vento à frente passar de',
                  ativo: _limiares.ventoAtivo,
                  onAtivoChanged: (v) =>
                      _atualizar(_limiares.copyWith(ventoAtivo: v)),
                  valor: _limiares.ventoLimiarKmh,
                  min: 15,
                  max: 100,
                  divisoes: 17,
                  unidade: 'km/h',
                  onValorChanged: (v) =>
                      _atualizarLocal(_limiares.copyWith(ventoLimiarKmh: v)),
                  onValorChangedFim: (v) =>
                      _atualizar(_limiares.copyWith(ventoLimiarKmh: v)),
                ),
                const SizedBox(height: 16),
                _CardLimiar(
                  icon: Icons.waves_outlined,
                  titulo: 'Altura de onda e swell',
                  subtitulo: 'Alerta quando onda ou swell passarem de',
                  ativo: _limiares.ondaAtivo,
                  onAtivoChanged: (v) =>
                      _atualizar(_limiares.copyWith(ondaAtivo: v)),
                  valor: _limiares.ondaLimiarM,
                  min: 0.5,
                  max: 6.0,
                  divisoes: 11,
                  unidade: 'm',
                  casasDecimais: 1,
                  onValorChanged: (v) =>
                      _atualizarLocal(_limiares.copyWith(ondaLimiarM: v)),
                  onValorChangedFim: (v) =>
                      _atualizar(_limiares.copyWith(ondaLimiarM: v)),
                ),
                const SizedBox(height: 16),
                _CardLimiar(
                  icon: Icons.water_outlined,
                  titulo: 'Corrente de maré',
                  subtitulo: 'Alerta quando a corrente passar de',
                  ativo: _limiares.correnteAtivo,
                  onAtivoChanged: (v) =>
                      _atualizar(_limiares.copyWith(correnteAtivo: v)),
                  valor: _limiares.correnteLimiarNos,
                  min: 0.5,
                  max: 4.0,
                  divisoes: 14,
                  unidade: 'nós',
                  casasDecimais: 1,
                  onValorChanged: (v) => _atualizarLocal(
                      _limiares.copyWith(correnteLimiarNos: v)),
                  onValorChangedFim: (v) =>
                      _atualizar(_limiares.copyWith(correnteLimiarNos: v)),
                ),
                const SizedBox(height: 16),
                _CardLimiar(
                  icon: Icons.thermostat_outlined,
                  titulo: 'Temperatura da água',
                  subtitulo: 'Alerta quando a temperatura passar de',
                  ativo: _limiares.temperaturaAtivo,
                  onAtivoChanged: (v) =>
                      _atualizar(_limiares.copyWith(temperaturaAtivo: v)),
                  valor: _limiares.temperaturaLimiarC,
                  min: 20,
                  max: 32,
                  divisoes: 60,
                  unidade: '°C',
                  casasDecimais: 1,
                  onValorChanged: (v) => _atualizarLocal(
                      _limiares.copyWith(temperaturaLimiarC: v)),
                  onValorChangedFim: (v) =>
                      _atualizar(_limiares.copyWith(temperaturaLimiarC: v)),
                ),
              ],
            ),
    );
  }
}

class _CardLimiar extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool ativo;
  final ValueChanged<bool> onAtivoChanged;
  final double valor;
  final double min;
  final double max;
  final int divisoes;
  final String unidade;
  final int casasDecimais;

  /// Chamado a cada tick do arrasto — só deve atualizar o estado local
  /// (pra o número acompanhar o dedo), sem gravar no Hive.
  final ValueChanged<double> onValorChanged;

  /// Chamado uma vez, quando o usuário solta o slider — é aqui que o
  /// valor é persistido.
  final ValueChanged<double> onValorChangedFim;

  const _CardLimiar({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.ativo,
    required this.onAtivoChanged,
    required this.valor,
    required this.min,
    required this.max,
    required this.divisoes,
    required this.unidade,
    required this.onValorChanged,
    required this.onValorChangedFim,
    this.casasDecimais = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            secondary: Icon(icon,
                color: ativo ? Colors.blue : Colors.grey),
            title: Text(titulo,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            value: ativo,
            onChanged: onAtivoChanged,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: valor.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisoes,
                    label: '${valor.toStringAsFixed(casasDecimais)} $unidade',
                    onChanged: ativo ? onValorChanged : null,
                    onChangeEnd: ativo ? onValorChangedFim : null,
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    '${valor.toStringAsFixed(casasDecimais)} $unidade',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ativo
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
