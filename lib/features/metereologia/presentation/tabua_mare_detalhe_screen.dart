import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/mare_harmonica.dart';
import '../domain/models/porto_mare.dart';

/// Tábua de maré de um porto salvo — altura prevista agora e a lista de
/// preamares/baixa-mares dos próximos dias, calculadas pelo modelo
/// harmônico local (`porto.modelo`). Funciona **sem internet** depois de
/// sincronizado ao menos uma vez; [onSincronizar] busca uma série nova da
/// Open-Meteo e reajusta o modelo (precisa de conexão).
class TabuaMareDetalheScreen extends StatefulWidget {
  final PortoMare porto;
  final Future<PortoMare> Function() onSincronizar;
  final Future<void> Function() onRemover;

  const TabuaMareDetalheScreen({
    super.key,
    required this.porto,
    required this.onSincronizar,
    required this.onRemover,
  });

  @override
  State<TabuaMareDetalheScreen> createState() => _TabuaMareDetalheScreenState();
}

class _TabuaMareDetalheScreenState extends State<TabuaMareDetalheScreen> {
  late PortoMare _porto;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _porto = widget.porto;
  }

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    try {
      final atualizado = await widget.onSincronizar();
      if (!mounted) return;
      setState(() => _porto = atualizado);
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _confirmarRemocao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover porto?'),
        content: Text('"${_porto.nome}" será removido da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await widget.onRemover();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final modelo = _porto.modelo;

    return Scaffold(
      appBar: AppBar(
        title: Text(_porto.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remover porto',
            onPressed: _confirmarRemocao,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.anchor, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formatarCoordenadasDMSCompacta(_porto.latitude, _porto.longitude),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _porto.temModeloOffline
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        size: 16,
                        color: _porto.temModeloOffline ? Colors.teal : onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _porto.sincronizadoEm != null
                              ? 'Sincronizado em ${DateFormat('dd/MM/yyyy HH:mm').format(_porto.sincronizadoEm!)} · disponível offline'
                              : 'Ainda não sincronizado — precisa de internet na 1ª vez',
                          style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _sincronizando ? null : _sincronizar,
                      icon: _sincronizando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sync, size: 18),
                      label: Text(_sincronizando
                          ? 'Sincronizando...'
                          : (modelo == null ? 'Sincronizar' : 'Sincronizar de novo')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (modelo == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Sincronize pelo menos uma vez, com internet, pra calcular '
                  'a tábua de maré offline deste porto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onSurfaceVariant),
                ),
              ),
            )
          else ...[
            _buildAlturaAtualCard(modelo),
            const SizedBox(height: 16),
            _buildTabuaEventos(modelo),
          ],
        ],
      ),
    );
  }

  Widget _buildAlturaAtualCard(ModeloMareHarmonico modelo) {
    final agora = DateTime.now();
    final alturaAtual = modelo.altura(agora);
    // Compara com 1 min à frente pra saber se a maré tá subindo (rumo à
    // preamar) ou descendo (rumo à baixa-mar) agora — não é um dos eventos
    // de pico/vale de `proximosEventos`, é só a direção instantânea.
    final subindo = modelo.altura(agora.add(const Duration(minutes: 1))) > alturaAtual;
    final corMomento = subindo ? Colors.greenAccent.shade400 : Colors.orangeAccent.shade200;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.waves, color: onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nível agora', style: TextStyle(color: onPrimaryContainer)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(subindo ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14, color: corMomento),
                      const SizedBox(width: 4),
                      Text(
                        subindo ? 'Preamar' : 'Baixa-mar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: corMomento),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${alturaAtual.toStringAsFixed(2)} m',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabuaEventos(ModeloMareHarmonico modelo) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final eventos = modelo.proximosEventos(
      DateTime.now(),
      janela: const Duration(days: 7),
    );

    if (eventos.isEmpty) {
      return const SizedBox.shrink();
    }

    String? diaAtual;
    final linhas = <Widget>[];
    for (final evento in eventos) {
      final diaFormatado = _formatarDiaSemana(evento.horario);
      if (diaFormatado != diaAtual) {
        diaAtual = diaFormatado;
        linhas.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            diaFormatado,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: onSurfaceVariant),
          ),
        ));
      }
      linhas.add(_buildLinhaEvento(evento));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: linhas,
        ),
      ),
    );
  }

  static const _diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  // `DateTime.weekday` é 1=segunda..7=domingo — evita depender de
  // `initializeDateFormatting` (intl) só pra exibir o nome do dia.
  String _formatarDiaSemana(DateTime data) {
    final nome = _diasSemana[data.weekday - 1];
    final dataFormatada = DateFormat('dd/MM').format(data);
    return '$nome, $dataFormatada';
  }

  Widget _buildLinhaEvento(({DateTime horario, double alturaM, bool alta}) evento) {
    final cor = evento.alta ? Colors.teal.shade700 : Colors.blueGrey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(evento.alta ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: cor),
          const SizedBox(width: 8),
          Text(
            evento.alta ? 'Preamar' : 'Baixa-mar',
            style: TextStyle(fontWeight: FontWeight.w600, color: cor),
          ),
          const Spacer(),
          Text(DateFormat('HH:mm').format(evento.horario),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Text('${evento.alturaM.toStringAsFixed(2)} m',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
