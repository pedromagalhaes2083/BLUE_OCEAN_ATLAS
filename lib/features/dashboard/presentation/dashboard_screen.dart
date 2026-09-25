import 'package:atlas/features/cartas/presentation/cartas_screen.dart';
import 'package:atlas/features/cartas/presentation/solicitar_cartas_screen.dart';
import 'package:atlas/features/mapa/presentation/mapa_widget.dart';
import 'package:atlas/features/embarcacao/presentation/embarcacao_screen.dart';
import 'package:atlas/features/metereologia/presentation/alerta_rota_screen.dart';
import 'package:atlas/features/metereologia/presentation/condicoes_mar_screen.dart';
import 'package:atlas/features/metereologia/presentation/fase_lua_screen.dart';
import 'package:atlas/features/metereologia/presentation/mare_pesca_atum_screen.dart';
import 'package:atlas/features/metereologia/presentation/tabua_mare_screen.dart';
import 'package:atlas/features/producao/presentation/producao_screen.dart';
import 'package:atlas/features/rotas/presentation/minhas_rotas_screen.dart';
import 'package:atlas/features/viagem/presentation/historico_localizacoes_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../metereologia/domain/models/leitura_profundidade.dart';
import '../../viagem/domain/models/viagem.dart';
import '../../../core/services/contexto_viagem_service.dart';
import 'package:atlas/core/auth/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/services/location_tracking_service.dart'; // ← Adicionado
import '../../../core/services/localizacao_reporter_service.dart';
import '../../../core/services/night_mode_service.dart';
import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../embarcacao/data/embarcacao_local_lookup.dart';
import '../../embarcacao/domain/models/embarcacao.dart';
import 'package:atlas/features/widgets/posicao_atual_widget.dart';
import 'package:atlas/features/widgets/web_view_screen.dart';
import 'package:atlas/l10n/gen/app_localizations.dart';
import '../../configuracoes/presentation/configuracoes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const DashboardScreen({super.key, required this.dbHelper});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<PosicaoAtualWidgetState> _posicaoKey = GlobalKey();

  // ==================== DADOS LOCAIS ====================
  bool isLoading = true;
  Viagem? viagemAtual;
  Embarcacao? embarcacaoAtual;

  // ==================== DADOS WINDY ====================
  Map<String, dynamic>? windyData;
  bool isLoadingWindy = false;
  String? windyError;

  // ==================== BATIMETRIA / SST (posição atual) ====================
  LeituraProfundidade? _profundidadeAtual;
  double? _sstAtual;

// ==================== RASTREAMENTO AUTOMÁTICO ====================
  final LocationTrackingService _trackingService = LocationTrackingService();
  bool isTracking = false;
  int _intervaloRastreamentoMinutos = intervaloMinimoMinutos;

  // ==================== SINCRONIZAÇÃO PENDENTE ====================
  int _posicoesPendentes = 0;
  bool _sincronizando = false;

  // ==================== ALERTAS (bateria / GPS desatualizado) ====================
  int? _ultimaBateria;
  DateTime? _ultimaPosicaoHora;

  bool get _bateriaBaixa => _ultimaBateria != null && _ultimaBateria! <= 20;

  /// Só alerta se o rastreamento estiver ativo e a última posição registrada
  /// tiver mais do que o dobro do intervalo configurado — evita falso alarme
  /// logo após ligar o rastreamento ou enquanto o próximo ciclo não rodou.
  bool get _gpsDesatualizado {
    if (!isTracking || _ultimaPosicaoHora == null) return false;
    final limite = Duration(minutes: _intervaloRastreamentoMinutos * 2);
    return DateTime.now().difference(_ultimaPosicaoHora!) > limite;
  }

  String _formatarTempoDecorrido(AppLocalizations l10n, DateTime data) {
    final decorrido = DateTime.now().difference(data);
    if (decorrido.inMinutes < 60) {
      return l10n.dashboardTempoMinutos(decorrido.inMinutes);
    }
    if (decorrido.inHours < 24) return l10n.dashboardTempoHoras(decorrido.inHours);
    return l10n.dashboardTempoDias(decorrido.inDays);
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarBatimetriaESst();
  }

  // ==================== BATIMETRIA / SST ====================
  Future<void> _carregarBatimetriaESst() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));

      final profundidade = await ProfundidadeRepository().buscarPonto(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );
      final wave = await WaveForecastRepository().buscar(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );

      if (!mounted) return;
      setState(() {
        _profundidadeAtual = profundidade;
        _sstAtual = wave.current?.seaSurfaceTemperature;
      });
    } catch (e) {
      debugPrint('❌ Erro ao buscar batimetria/SST do dashboard: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

// ==================== RASTREAMENTO ====================

  // O rastreamento (LocationTrackingService) só roda enquanto há viagem em
  // andamento — começa quando a viagem ativa é sincronizada (ver
  // ContextoViagemService) e para em
  // HistoricoLocalizacoesScreen._finalizarViagem. Aqui só refletimos o
  // status real do serviço (e o intervalo configurado) pra UI.
  Future<void> _atualizarStatusRastreamento() async {
    final ativo = await _trackingService.isTracking;
    final intervalo = int.tryParse(await Config.obtem(
          Constantes.intervaloRastreamentoMinutos,
          '$intervaloMinimoMinutos',
        )) ??
        intervaloMinimoMinutos;

    if (!mounted) return;
    if (ativo != isTracking || intervalo != _intervaloRastreamentoMinutos) {
      setState(() {
        isTracking = ativo;
        _intervaloRastreamentoMinutos = intervalo;
      });
    }
  }

  // ==================== CARREGAMENTO DE DADOS ====================
  Future<void> _carregarDados() async {
    setState(() => isLoading = true);

    try {
      final registroEmbarcacao = await buscarEmbarcacaoLocalAtual(widget.dbHelper);

      // Viagem em andamento — a mais recente, caso hajam registros antigos
      // de antes da viagem ter sido finalizada corretamente.
      final viagens = await widget.dbHelper.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
        orderBy: 'id DESC',
      );
      Viagem? viagem;
      Embarcacao? embarcacao;

      if (viagens.isNotEmpty) {
        viagem = Viagem.fromMap(viagens.first);
      }
      if (registroEmbarcacao != null) {
        embarcacao = Embarcacao.fromMap(registroEmbarcacao);
      }

      final pendentes = await widget.dbHelper.queryWhere(
        'localizacao_historico',
        where: 'sincronizado = ?',
        whereArgs: [0],
      );

      final db = await widget.dbHelper.database;
      final ultimaPosicao = await db.query(
        'localizacao_historico',
        orderBy: 'id DESC',
        limit: 1,
      );

      if (!mounted) return;
      setState(() {
        viagemAtual = viagem;
        embarcacaoAtual = embarcacao;
        _posicoesPendentes = pendentes.length;
        _ultimaBateria =
            ultimaPosicao.isEmpty ? null : ultimaPosicao.first['bateria_nivel'] as int?;
        _ultimaPosicaoHora = ultimaPosicao.isEmpty
            ? null
            : DateTime.tryParse(ultimaPosicao.first['data_hora'] as String);

        isLoading = false;
      });

      await _atualizarStatusRastreamento();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Erro ao carregar dashboard: $e');
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardErroCarregar),
          action: SnackBarAction(
            label: l10n.dashboardTentarNovamente,
            onPressed: _carregarDados,
          ),
        ),
      );
    }
  }

  Future<void> _sincronizarAgora() async {
    setState(() => _sincronizando = true);
    try {
      await LocalizacaoReporterService.sincronizarPendentes();
      final pendentes = await widget.dbHelper.queryWhere(
        'localizacao_historico',
        where: 'sincronizado = ?',
        whereArgs: [0],
      );
      if (!mounted) return;
      final enviadas = _posicoesPendentes - pendentes.length;
      setState(() => _posicoesPendentes = pendentes.length);
      final l10n = AppLocalizations.of(context);
      final mensagem = enviadas > 0
          ? '${l10n.dashboardPosicoesEnviadas(enviadas)}'
              '${pendentes.isNotEmpty ? ' — ${l10n.dashboardAindaPendentes(pendentes.length)}' : ''}.'
          : l10n.dashboardSincronizacaoFalhou;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).dashboardErroSincronizar('$e'))),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  // ==================== SOS ====================

  Future<void> _acionarSOS() async {
    final l10n = AppLocalizations.of(context);
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.dashboardSosTitulo),
        content: Text(l10n.dashboardSosTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.dashboardSosConfirmar,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      final agora = DateTime.now();
      final horario =
          '${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year} '
          '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

      final mensagem = l10n.dashboardSosMensagem(
        embarcacaoAtual?.nome ?? l10n.dashboardEmbarcacaoNaoInformada,
        formatarCoordenadasDMSCompacta(posicao.latitude, posicao.longitude),
        horario,
        'https://maps.google.com/?q=${posicao.latitude},${posicao.longitude}',
      );

      final contato =
          await Config.obtem(Constantes.contatoEmergenciaWhatsapp, '');
      if (contato.isNotEmpty) {
        final uri = Uri.parse(
            'https://wa.me/$contato?text=${Uri.encodeComponent(mensagem)}');
        final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!abriu) await Share.share(mensagem);
      } else {
        await Share.share(mensagem);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).dashboardSosErroPosicao('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(l10n.appTitulo),
        centerTitle: true,
        actions: [
          if (isTracking)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.location_on, color: Colors.green),
            ),
          ValueListenableBuilder<bool>(
            valueListenable: NightModeService.ativo,
            builder: (context, ativo, _) => IconButton(
              icon: Icon(ativo ? Icons.nightlight_round : Icons.nightlight_outlined),
              tooltip: ativo
                  ? l10n.dashboardDesativarModoNoturno
                  : l10n.dashboardAtivarModoNoturno,
              onPressed: () => NightModeService.alternar(!ativo),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _carregarDados();
                await _posicaoKey.currentState?.obterPosicaoAtual();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dashboardBoasVindas,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      l10n.dashboardEmbarcacaoLabel(
                          embarcacaoAtual?.nome ?? l10n.dashboardEmbarcacaoNaoDefinida),
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _acionarSOS,
                        icon: const Icon(Icons.sos),
                        label: Text(l10n.dashboardEmergenciaBotao),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Posição Atual
                    PosicaoAtualWidget(key: _posicaoKey),

                    if (isTracking) ...[
                      const SizedBox(height: 16),
                      Builder(builder: (context) {
                        // No claro, mantém o verde original — o tom azul do
                        // tema só entra no escuro, onde o verde pastel fixo
                        // ficava um bloco claro cego em cima do fundo escuro.
                        final escuro =
                            Theme.of(context).brightness == Brightness.dark;
                        final colorScheme = Theme.of(context).colorScheme;
                        final corFundo = escuro
                            ? colorScheme.primaryContainer
                            : Colors.green[50];
                        final corDestaque =
                            escuro ? colorScheme.onPrimaryContainer : Colors.green;
                        return Card(
                          color: corFundo,
                          child: ListTile(
                            leading: Icon(Icons.location_on, color: corDestaque),
                            title: Text(l10n.dashboardRastreamentoAtivo,
                                style: escuro
                                    ? TextStyle(color: corDestaque)
                                    : null),
                            subtitle: Text(
                              l10n.dashboardRastreamentoSubtitulo(
                                  _intervaloRastreamentoMinutos),
                              style: escuro
                                  ? TextStyle(
                                      color: corDestaque.withValues(alpha: 0.75))
                                  : null,
                            ),
                            trailing:
                                Icon(Icons.check_circle, color: corDestaque),
                          ),
                        );
                      }),
                    ],

                    if (_posicoesPendentes > 0) ...[
                      const SizedBox(height: 16),
                      Builder(builder: (context) {
                        final escuro =
                            Theme.of(context).brightness == Brightness.dark;
                        final colorScheme = Theme.of(context).colorScheme;
                        final corFundo = escuro
                            ? colorScheme.primaryContainer
                            : Colors.orange[50];
                        final corDestaque = escuro
                            ? colorScheme.onPrimaryContainer
                            : Colors.orange;
                        return Card(
                          color: corFundo,
                          child: ListTile(
                            leading: Icon(Icons.cloud_off, color: corDestaque),
                            title: Text(
                              l10n.dashboardPosicoesPendentes(_posicoesPendentes),
                              style: escuro
                                  ? TextStyle(color: corDestaque)
                                  : null,
                            ),
                            subtitle: Text(
                              l10n.dashboardPosicoesPendentesSubtitulo,
                              style: TextStyle(
                                fontSize: 12,
                                color: escuro
                                    ? corDestaque.withValues(alpha: 0.75)
                                    : null,
                              ),
                            ),
                            trailing: _sincronizando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.sync, color: corDestaque),
                                    tooltip: l10n.dashboardSincronizarAgora,
                                    onPressed: _sincronizarAgora,
                                  ),
                          ),
                        );
                      }),
                    ],

                    if (_bateriaBaixa) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.red.withValues(alpha: 0.15),
                        child: ListTile(
                          leading:
                              const Icon(Icons.battery_alert, color: Colors.red),
                          title: Text(l10n.dashboardBateriaBaixa(_ultimaBateria!)),
                          subtitle: Text(
                            l10n.dashboardBateriaBaixaSubtitulo,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],

                    if (_gpsDesatualizado) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.red.withValues(alpha: 0.15),
                        child: ListTile(
                          leading: const Icon(Icons.gps_off, color: Colors.red),
                          title: Text(l10n.dashboardSemPosicaoRecente),
                          subtitle: Text(
                            l10n.dashboardSemPosicaoRecenteSubtitulo(
                                _formatarTempoDecorrido(l10n, _ultimaPosicaoHora!)),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    // Cards de estatísticas e ações rápidas
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                icon: Icons.terrain,
                                title: l10n.dashboardBat,
                                value: _profundidadeAtual == null
                                    ? '--'
                                    : (_profundidadeAtual!.emAgua
                                        ? _profundidadeAtual!.profundidadeMetros
                                            .toStringAsFixed(0)
                                        : '--'),
                                subtitle: l10n.dashboardMetros,
                                color: Colors.indigo)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildStatCard(
                                icon: Icons.thermostat,
                                title: l10n.dashboardSst,
                                value: _sstAtual == null
                                    ? '--'
                                    : _sstAtual!.toStringAsFixed(1),
                                subtitle: '°C',
                                color: Colors.blue)),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text(l10n.dashboardMapa,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 450,
                      width: double.infinity,
                      // Preview leve — sem GPS/bússola contínuos nem o
                      // barco 3D (WebView), que só fazem sentido na aba
                      // Mapa em tela cheia (ver
                      // MapaWidget.navegacaoTempoReal). Evita rodar esse
                      // custo pesado toda vez que o app abre no Home.
                      child: const MapaWidget(navegacaoTempoReal: false),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        l10n.dashboardRodape,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _posicaoKey.currentState?.obterPosicaoAtual(),
        child: const Icon(Icons.my_location),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0A2A4A),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.anchor, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sailing),
              title: Text(l10n.drawerViagemAtual),
              onTap: () => _abrirHistoricoPosicoes(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(l10n.drawerProducao),
              onTap: () async {
                Navigator.pop(context);
                final temEmbarcacao = await _exigirEmbarcacaoCadastrada(
                    motivo: l10n.dashboardMotivoRegistrarProducao);
                if (!temEmbarcacao || !context.mounted) return;
                final temViagem = await _exigirViagemAtiva(
                    motivo: l10n.dashboardMotivoRegistrarProducao);
                if (!temViagem || !context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProducaoScreen(dbHelper: widget.dbHelper),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_link_rounded),
              title: Text(l10n.drawerSolicitarCarta),
              onTap: () => _abrirSolicitarCarta(context),
            ),
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: Text(l10n.drawerCartasNauticas),
              onTap: () => _abrirCartasNauticas(context),
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: Text(l10n.drawerMinhasRotas),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MinhasRotasScreen(dbHelper: widget.dbHelper),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation),
              title: Text(l10n.drawerEmbarcacao),
              onTap: () => _abrirCadastroEmbarcacao(context),
            ),
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: Text(l10n.drawerCondicoesMar),
              onTap: () => _abrirCondicoesMar(context),
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: Text(l10n.drawerAlertaRota),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertaRotaScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(l10n.drawerTabuaMare),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TabuaMareScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phishing),
              title: Text(l10n.drawerMareEPesca),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MareEPescaAtumScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: Text(l10n.drawerFaseLua),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaseLuaScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: Text(l10n.drawerAvisosNavegantes),
              onTap: () {
                Navigator.pop(context);
                _abrirAvisosAosNavegantes(context, l10n);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.drawerConfiguracoes),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfiguracoesScreen(dbHelper: widget.dbHelper),
                  ),
                );
                // Ao voltar, atualiza o intervalo exibido caso tenha mudado.
                await _atualizarStatusRastreamento();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(l10n.drawerSair, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

// ==================== WIDGETS AUXILIARES ====================
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

// ==================== MÉTODOS DE AÇÃO ====================
  /// Mostra um alerta se não houver embarcação vinculada, com atalho pra
  /// sincronizar com a viagem ativa na plataforma (não há mais cadastro
  /// manual — ver [ContextoViagemService]). Retorna true só quando já
  /// existe uma embarcação e a tela que chamou pode prosseguir.
  Future<bool> _exigirEmbarcacaoCadastrada({required String motivo}) async {
    if (embarcacaoAtual != null) return true;
    final l10n = AppLocalizations.of(context);

    final sincronizar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dashboardNenhumaEmbarcacaoTitulo),
        content: Text(l10n.dashboardNenhumaEmbarcacaoTexto(motivo)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.sincronizar),
          ),
        ],
      ),
    );
    if (sincronizar == true && mounted) {
      await _sincronizarContextoViagem();
    }
    return false;
  }

  /// Mostra um alerta se não houver viagem em andamento, com atalho pra
  /// sincronizar. Retorna true só quando já existe uma viagem ativa.
  Future<bool> _exigirViagemAtiva({required String motivo}) async {
    if (viagemAtual != null) return true;
    final l10n = AppLocalizations.of(context);

    final sincronizar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dashboardNenhumaViagemTitulo),
        content: Text(l10n.dashboardNenhumaViagemTexto(motivo)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.sincronizar),
          ),
        ],
      ),
    );
    if (sincronizar == true && mounted) {
      await _sincronizarContextoViagem();
    }
    return false;
  }

  /// Busca a viagem ativa do usuário na plataforma e resolve a embarcação a
  /// partir dela (ver [ContextoViagemService]) — não existe mais criação de
  /// viagem nem cadastro de embarcação dentro do app, as duas nascem na
  /// retaguarda. Dá feedback por SnackBar e recarrega o dashboard.
  Future<void> _sincronizarContextoViagem() async {
    final encontrou = await ContextoViagemService.sincronizar(widget.dbHelper);
    if (!mounted) return;
    _carregarDados();
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

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dashboardSairTitulo),
        content: Text(l10n.dashboardSairTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.sair, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _trackingService.pararRastreamento();
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(dbHelper: widget.dbHelper),
        ),
      );
    }
  }

  Future<void> _abrirSolicitarCarta(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolicitarCartaScreen(
          dbHelper: widget.dbHelper, // ou dbHelper se for variável local
        ),
      ),
    );

    // Se quiser fazer algo após voltar com sucesso
    if (resultado == true) {
      if (!context.mounted) return;
      // Recarrega a lista de cartas ou atualiza a tela
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).dashboardCartaSolicitadaSucesso)),
      );
    }
  }

  void _abrirAvisosAosNavegantes(BuildContext context, AppLocalizations l10n) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          titulo: l10n.drawerAvisosNavegantes,
          url:
              'https://www.marinha.mil.br/chm/dados-do-segnav-aviso-aos-navegantes-tela',
        ),
      ),
    );
  }

  void _abrirCondicoesMar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CondicoesMarScreen()),
    );
  }

  Future<void> _abrirHistoricoPosicoes(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoricoLocalizacoesScreen(
          dbHelper: widget.dbHelper,
          viagemAtiva: viagemAtual,
        ),
      ),
    );

    if (result == true) {
      _carregarDados();
    }
  }

  void _abrirCartasNauticas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartasScreen(dbHelper: widget.dbHelper),
      ),
    );
  }

  Future<void> _abrirCadastroEmbarcacao(BuildContext context) async {
    // Não há mais cadastro manual de embarcação — sem uma vinculada ainda,
    // EmbarcacaoScreen mostra o estado vazio com o atalho de sincronizar
    // (ver ContextoViagemService).
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmbarcacaoScreen(
          dbHelper: widget.dbHelper,
          embarcacao: embarcacaoAtual,
        ),
      ),
    );
    _carregarDados();
  }
}
