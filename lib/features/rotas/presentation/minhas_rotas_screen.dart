import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/database_helper.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../mapa/presentation/mapa_screen.dart';
import '../domain/models/rota_planejada.dart';
import 'analise_rota_screen.dart';

/// Lista as rotas planejadas manualmente pelo mestre (sequência de pontos
/// marcados no mapa antes de sair) — diferente do histórico de GPS, que é
/// o trajeto já percorrido durante uma viagem.
class MinhasRotasScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const MinhasRotasScreen({super.key, required this.dbHelper});

  @override
  State<MinhasRotasScreen> createState() => _MinhasRotasScreenState();
}

class _MinhasRotasScreenState extends State<MinhasRotasScreen> {
  List<RotaPlanejada> _rotas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final rotasMap = await widget.dbHelper.query('rota_planejada');
      final rotas = <RotaPlanejada>[];
      for (final map in rotasMap) {
        final pontosMap = await widget.dbHelper.queryWhere(
          'rota_planejada_ponto',
          where: 'rota_planejada_id = ?',
          whereArgs: [map['id']],
          orderBy: 'ordem ASC',
        );
        rotas.add(RotaPlanejada.fromMap(
          map,
          pontos: pontosMap
              .map((p) => LatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ))
              .toList(),
        ));
      }
      rotas.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
      if (!mounted) return;
      setState(() => _rotas = rotas);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).rotasErroCarregar('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _criarNovaRota() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapaScreen(modoPlanejarRota: true),
      ),
    );
    if (salvou == true) _carregar();
  }

  void _abrirRota(RotaPlanejada rota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen(rota: rota.pontos),
      ),
    );
  }

  void _analisarRota(RotaPlanejada rota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnaliseRotaScreen(
          nomeRota: rota.nome,
          pontos: rota.pontos,
        ),
      ),
    );
  }

  Future<void> _editarRota(RotaPlanejada rota) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen(modoPlanejarRota: true, rotaParaEditar: rota),
      ),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _apagarRota(RotaPlanejada rota) async {
    final l10n = AppLocalizations.of(context);
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.rotasApagarTitulo),
        content: Text(l10n.rotasApagarTexto(rota.nome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.apagar, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await widget.dbHelper.deleteWhere(
      'rota_planejada_ponto',
      where: 'rota_planejada_id = ?',
      whereArgs: [rota.id],
    );
    await widget.dbHelper.delete('rota_planejada', id: rota.id!);
    if (!mounted) return;
    setState(() => _rotas.remove(rota));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawerMinhasRotas),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarNovaRota,
        icon: const Icon(Icons.add),
        label: Text(l10n.rotasNovaRota),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rotas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.route, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.rotasNenhumaAinda),
                      const SizedBox(height: 8),
                      Text(
                        l10n.rotasTocarNovaRota,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                    itemCount: _rotas.length,
                    itemBuilder: (context, index) {
                      final rota = _rotas[index];
                      final deProducao = rota.embarcacaoId != null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                deProducao ? Colors.deepOrange : Colors.purple,
                            child: Icon(
                              deProducao ? Icons.set_meal : Icons.route,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(rota.nome),
                          subtitle: Text(
                            l10n.rotasPontosEData(rota.pontos.length,
                                DateFormat('dd/MM/yyyy HH:mm').format(rota.dataCriacao)),
                          ),
                          onTap: () => _abrirRota(rota),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.health_and_safety_outlined),
                                tooltip: l10n.rotasAnalisarTooltip,
                                onPressed: () => _analisarRota(rota),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: l10n.rotasEditarTooltip,
                                onPressed: () => _editarRota(rota),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: l10n.rotasApagarTooltip,
                                onPressed: () => _apagarRota(rota),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
