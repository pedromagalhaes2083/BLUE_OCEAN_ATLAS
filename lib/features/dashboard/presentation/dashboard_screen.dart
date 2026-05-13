import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../../../core/database/database_helper.dart';
import '../../viagem/presentation/nova_viagem_screen.dart';
import '../../viagem/domain/models/viagem.dart';
import 'package:atlas/core/auth/auth_service.dart';
import '../../auth/presentation/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const DashboardScreen({super.key, required this.dbHelper});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ==================== DADOS LOCAIS ====================
  int totalCartasBaixadas = 0;
  int totalRegistrosProducao = 0;
  bool isLoading = true;
  Viagem? viagemAtual;

  // ==================== POSIÇÃO DO DISPOSITIVO ====================
  Position? currentPosition;
  bool isLoadingPosition = false;
  String? positionError;

  // ==================== DADOS WINDY ====================
  Map<String, dynamic>? windyData;
  bool isLoadingWindy = false;
  String? windyError;

  // Coordenadas padrão (atualizadas pela geolocalização)
  double lat = -23.55;
  double lon = -46.63;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _getCurrentPosition(); // Carrega posição
  }

  // ==================== CARREGAMENTO DE DADOS LOCAIS ====================
  Future<void> _carregarDados() async {
    setState(() => isLoading = true);

    try {
      final cartas = await widget.dbHelper.query('carta_nautica');
      final cartasBaixadas = cartas.where((c) => c['esta_baixada'] == 1).length;

      final producoes = await widget.dbHelper.query('producao_registro');

      // CARREGAR VIAGENS
      final viagens = await widget.dbHelper.query('viagem');

      Viagem? viagem;

      if (viagens.isNotEmpty) {
        final viagemMap = viagens.first;

        viagem = Viagem.fromMap(viagemMap);
      }

      setState(() {
        totalCartasBaixadas = cartasBaixadas;
        totalRegistrosProducao = producoes.length;
        viagemAtual = viagem;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      print('Erro ao carregar dashboard: $e');
    }
  }

  // ==================== POSIÇÃO ====================
  Future<void> _getCurrentPosition() async {
    setState(() {
      isLoadingPosition = true;
      positionError = null;
    });

    try {
      print("🔄 Iniciando verificação de localização...");

      // Verifica se o serviço de localização está ativado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() =>
            positionError = "❌ Localização está desativada no dispositivo");
        print("❌ Serviço de localização desativado");
        return;
      }

      // Verifica permissões
      LocationPermission permission = await Geolocator.checkPermission();
      print("📍 Permissão atual: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("📍 Permissão após solicitação: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => positionError =
            "❌ Permissão negada permanentemente.\nVá em Configurações > Apps");
        return;
      }

      if (permission == LocationPermission.denied) {
        setState(() => positionError = "❌ Permissão de localização negada");
        return;
      }

      // Tenta pegar a posição
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        currentPosition = position;
        lat = position.latitude;
        lon = position.longitude;
        positionError = null;
      });

      print(
          "✅ Posição obtida com sucesso: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("❌ Erro no Geolocator: $e");
      setState(() => positionError = "❌ Erro: ${e.toString()}");
    } finally {
      setState(() => isLoadingPosition = false);
    }
  }

// ==================== FORMATO DMS (Graus, Minutos e Segundos) ====================
  String _formatCoordinates(double lat, double lon) {
    String formatDMS(double value, bool isLatitude) {
      String direction =
          isLatitude ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');

      value = value.abs();
      int degrees = value.floor();
      double minutesDecimal = (value - degrees) * 60;
      int minutes = minutesDecimal.floor();
      double seconds = (minutesDecimal - minutes) * 60;

      return '$degrees° ${minutes.toString().padLeft(2, '0')}\' ${seconds.toStringAsFixed(0).padLeft(2, '0')}" $direction';
    }

    String latDMS = formatDMS(lat, true);
    String lonDMS = formatDMS(lon, false);

    return '$latDMS\n$lonDMS';
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
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _carregarDados();
                await _getCurrentPosition();
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
                    const Text('Embarcação: PE-1234',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 32),

                    // Posição Atual
                    _buildPositionCard(),

                    const SizedBox(height: 32),

                    // Viagem Atual
                    _buildViagemCard(),

                    if (viagemAtual == null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _iniciarNovaViagem,
                        icon: const Icon(Icons.add),
                        label: const Text('Nova Viagem'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    // Cards de estatísticas e ações rápidas (mantidos iguais)
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                icon: Icons.map,
                                title: 'Cartas',
                                value: '$totalCartasBaixadas',
                                subtitle: 'baixadas',
                                color: Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildStatCard(
                                icon: Icons.set_meal,
                                title: 'Registros',
                                value: '$totalRegistrosProducao',
                                subtitle: 'de produção',
                                color: Colors.green)),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const Text('Ações Rápidas',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildActionButton(
                        icon: Icons.map_outlined,
                        label: 'Ver Cartas Náuticas',
                        color: Colors.blue,
                        onTap: () => _changeTab(context, 1)),
                    const SizedBox(height: 12),
                    _buildActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Registrar Produção',
                        color: Colors.green,
                        onTap: () => _changeTab(context, 2)),

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
        onPressed: _getCurrentPosition,
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
              leading: const Icon(Icons.map),
              title: const Text('Mapa de Navegação'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
                // Adicione navegação se necessário
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers),
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
              leading: const Icon(Icons.people),
              title: const Text('Compartilhar Localização'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
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
  Widget _buildViagemCard() {
    if (viagemAtual == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Nenhuma viagem em andamento',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final int diasEmViagem =
        DateTime.now().difference(viagemAtual!.dataInicio).inDays;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // LADO ESQUERDO - INFORMAÇÕES
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.sailing,
                        color: Colors.blue,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Viagem Atual',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    viagemAtual!.nome ?? 'Viagem em andamento',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Início: ${DateFormat('dd/MM/yyyy').format(viagemAtual!.dataInicio)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // LADO DIREITO - DIAS EM DESTAQUE
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '$diasEmViagem',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    'DIAS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                '📍 Posição Atual',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (isLoadingPosition)
                const CircularProgressIndicator()
              else if (positionError != null)
                Text(
                  positionError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              else if (currentPosition != null)
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    _formatCoordinates(
                      currentPosition!.latitude,
                      currentPosition!.longitude,
                    ),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Toque no botão para atualizar',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

// ==================== MÉTODOS DE AÇÃO ====================
  Future<void> _iniciarNovaViagem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovaViagemScreen(dbHelper: widget.dbHelper),
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
      await AuthService.instance.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(dbHelper: widget.dbHelper),
        ),
      );
    }
  }

  void _changeTab(BuildContext context, int index) {
    // Como estamos dentro de um Scaffold, precisamos acessar o estado do app
    // Por enquanto, mostramos um SnackBar (pode ser melhorado depois)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Indo para aba ${index + 1}...')),
    );
  }
}
