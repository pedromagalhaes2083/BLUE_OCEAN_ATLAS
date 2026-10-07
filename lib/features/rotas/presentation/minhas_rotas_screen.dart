import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/database_helper.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../mapa/presentation/mapa_screen.dart';
import '../domain/models/rota_planejada.dart';
import 'analise_rota_screen.dart';
import 'navegacao_rota_screen.dart';

/// Lista as rotas planejadas manualmente pelo mestre (sequência de pontos
/// marcados no mapa antes de sair) — diferente do histórico de GPS, que é
/// o trajeto já percorrido durante uma viagem.
class MinhasRotasScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const MinhasRotasScreen({super.key, required this.dbHelper});

  @override
  State<MinhasRotasScreen> createState() => _MinhasRotasScreenState();
}

enum _AcaoRota { analisar, editar, apagar }

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
      // Mais recente primeiro, mas a rota em uso na viagem atual (ver
      // `_seguirRota`) sempre vai pro topo — é a que o mestre quer achar
      // de cara, não importa há quanto tempo foi criada.
      rotas.sort((a, b) {
        final ativaA = a.viagemId != null;
        final ativaB = b.viagemId != null;
        if (ativaA != ativaB) return ativaA ? -1 : 1;
        return b.dataCriacao.compareTo(a.dataCriacao);
      });
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

  /// Vincula [rota] à viagem em andamento (`rota_planejada.viagem_id`,
  /// campo que existia no esquema mas nunca era preenchido) e abre a
  /// navegação ao vivo sobre ela — só uma rota ativa por viagem, então
  /// desvincula qualquer outra marcada pra essa mesma viagem antes.
  Future<void> _seguirRota(RotaPlanejada rota) async {
    final l10n = AppLocalizations.of(context);
    final ativas = await widget.dbHelper.queryWhere(
      'viagem',
      where: 'status = ?',
      whereArgs: ['em_andamento'],
    );
    if (ativas.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rotasSeguirSemViagemAtiva)),
      );
      return;
    }
    final viagemId = ativas.first['id'] as int;

    final outrasVinculadas = await widget.dbHelper.queryWhere(
      'rota_planejada',
      where: 'viagem_id = ?',
      whereArgs: [viagemId],
    );
    for (final outra in outrasVinculadas) {
      await widget.dbHelper.update(
        'rota_planejada',
        {'viagem_id': null},
        id: outra['id'] as int,
      );
    }
    await widget.dbHelper.update(
      'rota_planejada',
      {'viagem_id': viagemId},
      id: rota.id!,
    );
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavegacaoRotaScreen(
          rota: RotaPlanejada(
            id: rota.id,
            nome: rota.nome,
            dataCriacao: rota.dataCriacao,
            pontos: rota.pontos,
            embarcacaoId: rota.embarcacaoId,
            viagemId: viagemId,
          ),
        ),
      ),
    );
    if (mounted) _carregar();
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
                      final ativa = rota.viagemId != null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        // Fundo azulado na rota em uso — junto com o círculo
                        // do ícone (abaixo) e o badge "Em uso" já existente,
                        // dá pra bater o olho na lista e achar qual rota tá
                        // ativa sem precisar ler o texto de cada card.
                        color: ativa
                            ? Colors.blue.withValues(alpha: 0.12)
                            : null,
                        shape: ativa
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.blue, width: 1.2),
                              )
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ativa
                                ? Colors.blue
                                : (deProducao ? Colors.deepOrange : Colors.purple),
                            child: Icon(
                              ativa
                                  ? Icons.navigation
                                  : (deProducao ? Icons.set_meal : Icons.route),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(rota.nome),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.rotasPontosEData(rota.pontos.length,
                                    DateFormat('dd/MM/yyyy HH:mm').format(rota.dataCriacao)),
                              ),
                              if (rota.viagemId != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    l10n.rotasEmUso,
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => _abrirRota(rota),
                          // Só "Seguir rota" fica visível (ação principal) —
                          // com os 4 ícones de antes lado a lado, o nome da
                          // rota ficava espremido a ponto de quebrar letra
                          // por letra e estourar a largura do card num
                          // aparelho comum (visto no teste em dispositivo).
                          // Analisar/editar/apagar viram menu, não somem.
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (rota.pontos.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.navigation_outlined),
                                  tooltip: l10n.rotasSeguirTooltip,
                                  onPressed: () => _seguirRota(rota),
                                ),
                              PopupMenuButton<_AcaoRota>(
                                onSelected: (acao) {
                                  switch (acao) {
                                    case _AcaoRota.analisar:
                                      _analisarRota(rota);
                                    case _AcaoRota.editar:
                                      _editarRota(rota);
                                    case _AcaoRota.apagar:
                                      _apagarRota(rota);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: _AcaoRota.analisar,
                                    child: ListTile(
                                      leading: const Icon(
                                          Icons.health_and_safety_outlined),
                                      title: Text(l10n.rotasAnalisarTooltip),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _AcaoRota.editar,
                                    child: ListTile(
                                      leading: const Icon(Icons.edit_outlined),
                                      title: Text(l10n.rotasEditarTooltip),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: _AcaoRota.apagar,
                                    child: ListTile(
                                      leading: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      title: Text(l10n.rotasApagarTooltip,
                                          style: const TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                ],
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
