import 'package:atlas/features/api_tester/presentation/api_tester_screen.dart';
import 'package:atlas/features/cartas/presentation/solicitar_cartas_screen.dart';
import 'package:atlas/features/mapa/presentation/mapa_screen.dart';
import 'package:atlas/features/mapa/presentation/mapa_widget.dart';
import 'package:atlas/features/embarcacao/presentation/cadastrar_embarcaao_screen.dart';
import 'package:atlas/features/embarcacao/presentation/embarcacao_screen.dart';
import 'package:atlas/features/metereologia/presentation/gribs_screen.dart';
import 'package:atlas/features/metereologia/presentation/condicoes_mar_screen.dart';
import 'package:atlas/features/viagem/presentation/historico_localizacoes_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/database/database_helper.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../metereologia/domain/models/leitura_profundidade.dart';
import '../../viagem/presentation/nova_viagem_screen.dart';
import '../../viagem/domain/models/viagem.dart';
import 'package:atlas/core/auth/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/services/location_tracking_service.dart'; // ← Adicionado
import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../embarcacao/domain/models/embarcacao.dart';
import 'package:atlas/features/widgets/posicao_atual_widget.dart';
import '../../configuracoes/presentation/configuracoes_screen.dart';
import '../../dispositivo/presentation/dispositivo_teste_screen.dart';

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

  // O rastreamento único já roda desde o login (LocationTrackingService),
  // com ou sem viagem ativa — aqui só refletimos o status real do serviço
  // (e o intervalo configurado) pra UI. Cada execução periódica já associa
  // os pontos à viagem em andamento automaticamente, sem precisar iniciar
  // nada específico por viagem.
  Future<void> _atualizarStatusRastreamento() async {
    final ativo = _trackingService.isTracking;
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
      final embarcacoes = await widget.dbHelper.query('embarcacao');

      // Carrega viagem atual
      final viagens = await widget.dbHelper.query('viagem');
      Viagem? viagem;
      Embarcacao? embarcacao;

      if (viagens.isNotEmpty) {
        viagem = Viagem.fromMap(viagens.first);
      }
      if (embarcacoes.isNotEmpty) {
        embarcacao = Embarcacao.fromMap(embarcacoes.first);
      }

      if (!mounted) return;
      setState(() {
        viagemAtual = viagem;
        embarcacaoAtual = embarcacao;

        isLoading = false;
      });

      await _atualizarStatusRastreamento();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint('Erro ao carregar dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Atlas Blue Ocean'),
        centerTitle: true,
        actions: [
          if (isTracking)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.location_on, color: Colors.green),
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
                    const Text('Bem-vindo, Mestre!',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Embarcação: ${embarcacaoAtual?.nome ?? "Não definida"}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    // Posição Atual
                    PosicaoAtualWidget(key: _posicaoKey),

                    if (isTracking) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.green[50],
                        child: ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.green),
                          title: const Text('Rastreamento Ativo'),
                          subtitle: Text(
                              'Registrando posição a cada $_intervaloRastreamentoMinutos minutos'),
                          trailing: const Icon(Icons.check_circle,
                              color: Colors.green),
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
                                title: 'BAT',
                                value: _profundidadeAtual == null
                                    ? '--'
                                    : (_profundidadeAtual!.emAgua
                                        ? _profundidadeAtual!.profundidadeMetros
                                            .toStringAsFixed(0)
                                        : '--'),
                                subtitle: 'metros',
                                color: Colors.indigo)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildStatCard(
                                icon: Icons.thermostat,
                                title: 'SST',
                                value: _sstAtual == null
                                    ? '--'
                                    : _sstAtual!.toStringAsFixed(1),
                                subtitle: '°C',
                                color: Colors.blue)),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Text('Mapa',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 450,
                      width: double.infinity,
                      child: const MapaWidget(),
                    ),

                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Todos os dados são salvos localmente.\n'
                        'A sincronização com o servidor será feita quando houver conexão.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0A2A4A),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.anchor, size: 60, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Atlas Blue Ocean',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(viagemAtual == null ? Icons.add : Icons.sailing),
              title: Text(
                  viagemAtual == null ? 'Nova Viagem' : 'Viagem Atual'),
              onTap: () => viagemAtual == null
                  ? _iniciarNovaViagem()
                  : _abrirHistoricoPosicoes(context),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Mapa de Navegação'),
              onTap: () => _abrirHistoricoPosicoes(context),
            ),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('Mapa Offline (MBTiles)'),
              onTap: () => _abrirMapaOffline(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_link_rounded),
              title: const Text('Solicitar Carta'),
              onTap: () => _abrirSolicitarCarta(context),
            ),
            ListTile(
              leading: const Icon(Icons.layers_outlined),
              title: const Text('Cartas Náuticas'),
              onTap: () {
                Navigator.pop(context);
                // Navigator.pushNamed(context, '/charts');
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Minhas Rotas'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.navigation),
              title: const Text('Embarcação'),
              onTap: () => _abrirCadastroEmbarcacao(context),
            ),
            ListTile(
              leading: const Icon(Icons.api_outlined),
              title: const Text('Gribs'),
              onTap: () => _abrirSolicitarGrib(context),
            ),
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: const Text('Condições do Mar'),
              onTap: () => _abrirCondicoesMar(context),
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('Teste de API'),
              onTap: () => _abrirApiTester(context),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('Teste — Dispositivo & Recomendações'),
              onTap: () => _abrirDispositivoTeste(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
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
              title: const Text('Sair', style: TextStyle(color: Colors.red)),
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
  Future<void> _iniciarNovaViagem() async {
    final nomeBarco = embarcacaoAtual?.nome.toString() ?? "Não definida";
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NovaViagemScreen(dbHelper: widget.dbHelper, embarcacao: nomeBarco),
      ),
    );

    if (result == true) {
      _carregarDados();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Sistema'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text('Carta solicitada com sucesso!')),
      );
    }
  }

  void _abrirMapaOffline(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapaScreen()),
    );
  }

  Future<void> _abrirSolicitarGrib(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GribProcessorScreen(),
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
        ),
      ),
    );

    if (result == true) {
      _carregarDados();
    }
  }

  void _abrirApiTester(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApiTesterScreen()),
    );
  }

  void _abrirDispositivoTeste(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DispositivoTesteScreen()),
    );
  }

  Future<void> _abrirCadastroEmbarcacao(BuildContext context) async {
    if (embarcacaoAtual?.nome.isNotEmpty ?? false) {
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
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CadastrarEmbarcacaoScreen(
            dbHelper: widget.dbHelper,
          ),
        ),
      );
      _carregarDados();
    }
  }
}
