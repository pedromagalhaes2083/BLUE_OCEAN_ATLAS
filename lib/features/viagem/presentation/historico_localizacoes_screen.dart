import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/contexto_viagem_service.dart';
import '../../../core/services/location_tracking_service.dart';
import '../../../core/utils/proximidade.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../mapa/presentation/mapa_screen.dart';
import '../domain/models/viagem.dart';

class HistoricoLocalizacoesScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int? viagemId; // opcional: filtrar por viagem específica

  /// Se informada e ainda em andamento, exibe um cartão no topo com a opção
  /// de finalizar a viagem.
  final Viagem? viagemAtiva;

  const HistoricoLocalizacoesScreen({
    super.key,
    required this.dbHelper,
    this.viagemId,
    this.viagemAtiva,
  });

  @override
  State<HistoricoLocalizacoesScreen> createState() =>
      _HistoricoLocalizacoesScreenState();
}

class _HistoricoLocalizacoesScreenState
    extends State<HistoricoLocalizacoesScreen> {
  List<Map<String, dynamic>> _historico = [];
  bool _isLoading = true;
  bool _finalizando = false;
  bool _viagemFinalizada = false;
  bool _sincronizando = false;

  // Viagem ativa exibida — começa com a que a tela recebeu, mas pode ser
  // atualizada em memória depois de um "Sincronizar" (ver [_sincronizar]),
  // sem precisar fechar e reabrir a tela.
  late Viagem? _viagemAtiva;

  // Estatísticas calculadas sobre o histórico carregado.
  double? _distanciaMn;
  Duration? _duracao;
  double? _velMediaKmh;
  double? _velMaxKmh;

  @override
  void initState() {
    super.initState();
    _viagemAtiva = widget.viagemAtiva;
    _viagemFinalizada = widget.viagemAtiva?.isFinalizada ?? false;
    _carregarHistorico();
  }

  /// Busca a viagem ativa na plataforma de novo (ver [ContextoViagemService])
  /// — não há mais criação de viagem no app, só esse "puxar de novo" quando
  /// a tela abre sem nenhuma viagem em andamento.
  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    final encontrou = await ContextoViagemService.sincronizar(widget.dbHelper);
    if (!mounted) return;

    if (encontrou) {
      final ativas = await widget.dbHelper.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      if (!mounted) return;
      setState(() {
        _viagemAtiva = ativas.isEmpty ? null : Viagem.fromMap(ativas.first);
        _viagemFinalizada = false;
      });
      await _carregarHistorico();
      if (!mounted) return;
    }

    setState(() => _sincronizando = false);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          encontrou
              ? l10n.dashboardViagemSincronizada
              : l10n.dashboardNenhumaViagemEncontrada,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _carregarHistorico() async {
    setState(() => _isLoading = true);
    try {
      final db = await widget.dbHelper.database;

      final List<Map<String, dynamic>> result = await db.query(
        'localizacao_historico',
        where: widget.viagemId != null ? 'viagem_id = ?' : null,
        whereArgs: widget.viagemId != null ? [widget.viagemId] : null,
        orderBy: 'data_hora DESC',
      );

      if (!mounted) return;
      setState(() {
        _historico = result;
        _calcularEstatisticas();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).viagemErroCarregarHistorico('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Soma a distância entre pontos consecutivos (ordem cronológica) e tira
  /// duração/velocidades a partir dos mesmos campos já carregados — nenhuma
  /// consulta extra é necessária.
  void _calcularEstatisticas() {
    if (_historico.length < 2) {
      _distanciaMn = null;
      _duracao = null;
      _velMediaKmh = null;
      _velMaxKmh = null;
      return;
    }

    final cronologico = _historico.reversed.toList();

    var distancia = 0.0;
    for (var i = 1; i < cronologico.length; i++) {
      final anterior = cronologico[i - 1];
      final atual = cronologico[i];
      distancia += calcularDistanciaNauticas(
        (anterior['latitude'] as num).toDouble(),
        (anterior['longitude'] as num).toDouble(),
        (atual['latitude'] as num).toDouble(),
        (atual['longitude'] as num).toDouble(),
      );
    }

    final inicio = DateTime.parse(cronologico.first['data_hora']);
    final fim = DateTime.parse(cronologico.last['data_hora']);

    final velocidades = cronologico
        .map((p) => (p['velocidade'] as num?)?.toDouble())
        .whereType<double>()
        .map((ms) => ms * 3.6)
        .toList();

    _distanciaMn = distancia;
    _duracao = fim.difference(inicio);
    _velMediaKmh = velocidades.isEmpty
        ? null
        : velocidades.reduce((a, b) => a + b) / velocidades.length;
    _velMaxKmh =
        velocidades.isEmpty ? null : velocidades.reduce((a, b) => a > b ? a : b);
  }

  void _verRotaNaCarta() {
    // _historico vem ordenado do mais recente para o mais antigo; a rota
    // precisa da ordem cronológica para a linha seguir o trajeto real.
    final pontos = _historico.reversed
        .map((item) => LatLng(
              (item['latitude'] as num).toDouble(),
              (item['longitude'] as num).toDouble(),
            ))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapaScreen(rota: pontos)),
    );
  }

  Future<void> _compartilharResumo() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final viagem = _viagemAtiva;

    var producaoTexto = '';
    if (viagem != null) {
      final db = await widget.dbHelper.database;
      final registros = await db.query(
        'producao_registro',
        where: 'viagem_id = ?',
        whereArgs: [viagem.id],
      );
      if (registros.isNotEmpty) {
        final porEspecie = <String, double>{};
        for (final r in registros) {
          final especie = r['especie'] as String? ?? l10n.mapaEspecieNaoInformada;
          final kg = (r['quantidade_kg'] as num).toDouble();
          porEspecie.update(especie, (v) => v + kg, ifAbsent: () => kg);
        }
        final linhas = porEspecie.entries
            .map((e) => '  ${e.key}: ${e.value.toStringAsFixed(1)} kg')
            .join('\n');
        producaoTexto = '\n\n${l10n.viagemCompartilharProducaoTitulo}\n$linhas';
      }
    }

    final duracaoTexto = _duracao == null
        ? '--'
        : '${_duracao!.inHours}h ${_duracao!.inMinutes.remainder(60)}min';

    final mensagem = '⛵ ${viagem?.nome?.isNotEmpty == true ? viagem!.nome : l10n.viagemResumoDaViagemFallback}\n'
        '${viagem != null ? "${l10n.viagemCompartilharInicio(DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataInicio))}\n" : ""}'
        '${l10n.viagemCompartilharDistancia(_distanciaMn!.toStringAsFixed(1))}\n'
        '${l10n.viagemCompartilharDuracao(duracaoTexto)}\n'
        '${_velMediaKmh != null ? "${l10n.viagemCompartilharVelMedia(_velMediaKmh!.toStringAsFixed(1))}\n" : ""}'
        '${_velMaxKmh != null ? l10n.viagemCompartilharVelMaxima(_velMaxKmh!.toStringAsFixed(1)) : ""}'
        '$producaoTexto';

    await Share.share(mensagem.trim());
  }

  Future<void> _finalizarViagem() async {
    final viagem = _viagemAtiva;
    if (viagem == null) return;

    final l10n = AppLocalizations.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.viagemFinalizarTitulo),
        content: Text(l10n.viagemFinalizarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.viagemFinalizarBotao),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _finalizando = true);
    try {
      await widget.dbHelper.update(
        'viagem',
        {
          'status': 'finalizada',
          'data_termino': DateTime.now().toIso8601String(),
        },
        id: viagem.id,
      );
      await _salvarRotaDeProducao(viagem);

      // O rastreamento em segundo plano só existe enquanto há viagem em
      // andamento — para aqui, simetricamente ao início em NovaViagemScreen.
      try {
        await LocationTrackingService().pararRastreamento();
      } catch (e) {
        debugPrint('Erro ao parar rastreamento de localização: $e');
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _finalizando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).viagemErroFinalizar('$e'))),
      );
    }
  }

  /// Ao finalizar a viagem, transforma os registros de produção com
  /// coordenada dessa viagem numa rota planejada — o mesmo trajeto que
  /// apareceria em "Rota de Produção" no mapa (ver `MapaWidget`), mas salvo
  /// automaticamente em "Minhas Rotas" em vez de exigir uma ação manual.
  /// Não pede nome: a rota já fica identificada pela embarcação/viagem.
  /// Best-effort — se falhar, não impede a viagem de ser finalizada.
  Future<void> _salvarRotaDeProducao(Viagem viagem) async {
    try {
      final registros = await widget.dbHelper.queryWhere(
        'producao_registro',
        where:
            'viagem_id = ? AND latitude IS NOT NULL AND longitude IS NOT NULL',
        whereArgs: [viagem.id],
        orderBy: 'data_hora ASC',
      );
      if (registros.length < 2) return;

      final rotaId = await widget.dbHelper.insert('rota_planejada', {
        'nome':
            'Produção · ${viagem.embarcacaoId} · ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
        'data_criacao': DateTime.now().toIso8601String(),
        'embarcacao_id': viagem.embarcacaoId,
        'viagem_id': viagem.id,
      });
      for (var i = 0; i < registros.length; i++) {
        await widget.dbHelper.insert('rota_planejada_ponto', {
          'rota_planejada_id': rotaId,
          'latitude': registros[i]['latitude'],
          'longitude': registros[i]['longitude'],
          'ordem': i,
        });
      }
    } catch (e) {
      debugPrint('Erro ao salvar rota de produção da viagem: $e');
    }
  }

  String _formatarDataHora(String dataIso) {
    // Gravado em UTC (ver LocalizacaoReporterService) — sem o .toLocal(),
    // mostrava a hora UTC como se já fosse hora local (3h atrasada no
    // Brasil, e às vezes até a data errada, pra registros feitos à noite).
    final date = DateTime.parse(dataIso).toLocal();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  String _formatarDuracao(Duration d) {
    final horas = d.inHours;
    final minutos = d.inMinutes.remainder(60);
    if (horas == 0) return '${minutos}min';
    return '${horas}h ${minutos}min';
  }

  String _formatarCoordenadaDMS(double lat, double lon) {
    String formatDMS(double value, bool isLat) {
      String dir = isLat ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
      value = value.abs();
      int deg = value.floor();
      double minDec = (value - deg) * 60;
      int min = minDec.floor();
      double sec = (minDec - min) * 60;
      return '$deg° ${min.toString().padLeft(2, '0')}\' ${sec.toStringAsFixed(1)}" $dir';
    }

    return '${formatDMS(lat, true)}\n${formatDMS(lon, false)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viagemEmAndamento =
        _viagemAtiva != null && !_viagemFinalizada;

    // Sem `viagemId` (filtro de uma viagem específica já encerrada), esta
    // tela é "a viagem em andamento" — sem nenhuma ativa, mostra o
    // tratamento de erro dedicado em vez do histórico solto sem contexto
    // (ver ContextoViagemService: não existe mais criar viagem no app, só
    // sincronizar com o que está ativo na plataforma).
    final semViagemAtiva = widget.viagemId == null && !viagemEmAndamento;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawerViagemAtual),
        actions: [
          if (!semViagemAtiva && _historico.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.route),
              tooltip: l10n.viagemVerRotaTooltip,
              onPressed: _verRotaNaCarta,
            ),
          if (!semViagemAtiva && _distanciaMn != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.viagemCompartilharTooltip,
              onPressed: _compartilharResumo,
            ),
          IconButton(
            icon: _sincronizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: semViagemAtiva
                ? l10n.embarcacaoConfigTooltipSincronizar
                : l10n.viagemAtualizarTooltip,
            onPressed: _sincronizando
                ? null
                : (semViagemAtiva ? _sincronizar : _carregarHistorico),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : semViagemAtiva
              ? _buildSemViagemAtiva()
              : Column(
              children: [
                if (viagemEmAndamento) _buildCardViagemAtiva(),
                if (_distanciaMn != null) _buildCardEstatisticas(),
                Expanded(
                  child: _historico.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_off,
                                  size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(l10n.viagemNenhumRegistro),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _carregarHistorico,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _historico.length,
                            itemBuilder: (context, index) {
                              final item = _historico[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.location_on,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    _formatarDataHora(item['data_hora']),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    _formatarCoordenadaDMS(
                                      item['latitude'],
                                      item['longitude'],
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (item['velocidade'] != null)
                                        Text(
                                          '${(item['velocidade'] * 3.6).toStringAsFixed(1)} km/h',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      Text(
                                        l10n.viagemPrecLabel(
                                            (item['precisao'] as num?)?.toStringAsFixed(0) ?? '--'),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSemViagemAtiva() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sailing_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.dashboardNenhumaViagemTitulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.viagemCriadasNaPlataforma,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sincronizando ? null : _sincronizar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
              icon: _sincronizando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync),
              label: Text(l10n.sincronizar),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardViagemAtiva() {
    final l10n = AppLocalizations.of(context);
    final viagem = _viagemAtiva!;
    // No claro, mantém o verde original — o tom azul do tema só entra no
    // escuro, onde o verde pastel fixo ficava um bloco claro cego em cima
    // do fundo escuro.
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final corFundo = escuro ? colorScheme.primaryContainer : Colors.green[50];
    final corDestaque = escuro ? colorScheme.onPrimaryContainer : Colors.green;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      color: corFundo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.sailing, color: corDestaque, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viagem.nome?.isNotEmpty == true
                        ? viagem.nome!
                        : l10n.viagemEmAndamentoFallback,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: escuro ? corDestaque : null),
                  ),
                  Text(
                    l10n.viagemIniciadaEm(
                        DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataInicio)),
                    style: TextStyle(
                        color: escuro
                            ? corDestaque.withValues(alpha: 0.75)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _finalizando ? null : _finalizarViagem,
              child: _finalizando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.viagemFinalizarBotao),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEstatisticas() {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _estatistica(Icons.straighten, '${_distanciaMn!.toStringAsFixed(1)} mn',
                l10n.mapaLabelDistancia),
            _estatistica(Icons.timer_outlined,
                _duracao != null ? _formatarDuracao(_duracao!) : '—', l10n.viagemDuracaoLabel),
            _estatistica(
                Icons.speed,
                _velMediaKmh != null
                    ? '${_velMediaKmh!.toStringAsFixed(1)} km/h'
                    : '—',
                l10n.viagemVelMediaLabel),
            _estatistica(
                Icons.speed_outlined,
                _velMaxKmh != null ? '${_velMaxKmh!.toStringAsFixed(1)} km/h' : '—',
                l10n.viagemVelMaximaLabel),
          ],
        ),
      ),
    );
  }

  Widget _estatistica(IconData icon, String valor, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
