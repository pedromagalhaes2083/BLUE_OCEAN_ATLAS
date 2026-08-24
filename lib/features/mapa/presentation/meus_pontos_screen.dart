import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/proximidade.dart';
import '../../cartas/presentation/solicitar_cartas_screen.dart';
import '../../metereologia/presentation/condicoes_ponto_screen.dart';
import '../../recomendacao/data/recomendacao_repository.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../../recomendacao/widgets/recomendacao_card.dart';
import '../../recomendacao/widgets/recomendacao_list_tile.dart';
import '../../producao/domain/models/producao_registro.dart';
import '../../producao/domain/services/producao_pontos_analyzer.dart';
import '../domain/models/ponto_marcado.dart';
import '../widgets/dados_oceanicos_ponto.dart';
import '../widgets/ponto_marcado_list_tile.dart';

/// Pontos marcados manualmente e recomendações, juntos numa lista só — no
/// mesmo estilo visual da aba "Recomendações" em `CartasScreen` (linhas com
/// acento lateral colorido, divisor fino, toque abre um card flutuante de
/// detalhe), em vez do mapa com marcadores que essa tela usava antes.
class MeusPontosScreen extends StatefulWidget {
  const MeusPontosScreen({super.key});

  @override
  State<MeusPontosScreen> createState() => _MeusPontosScreenState();
}

class _MeusPontosScreenState extends State<MeusPontosScreen> {
  List<PontoMarcado> _pontosMarcados = [];
  List<Recomendacao> _recomendacoes = [];
  Map<int, ProducaoPorPonto> _producaoPorPontoId = {};
  bool _carregando = true;
  String? _erro;
  Position? _gpsPosition;
  bool _offline = false;
  DateTime? _cacheEm;

  @override
  void initState() {
    super.initState();
    _carregarGps();
    _carregar();
  }

  /// Só pra distância/rumo no detalhe de um ponto marcado — best-effort,
  /// não bloqueia a lista se falhar ou demorar.
  Future<void> _carregarGps() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() => _gpsPosition = posicao);
    } catch (_) {
      // Sem GPS, o detalhe do ponto simplesmente não mostra distância/rumo.
    }
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final maps = await DatabaseHelper.instance.query('ponto_marcado');
      final pontos = maps.map(PontoMarcado.fromMap).toList()
        ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
      final repositorioRecomendacoes = RecomendacaoRepository();
      final recomendacoes = await repositorioRecomendacoes.listar();

      final mapsRegistros = await DatabaseHelper.instance.query('producao_registro');
      final registros = mapsRegistros.map(ProducaoRegistro.fromMap).toList();
      final producaoPorPonto = agruparProducaoPorPonto(registros, pontos);

      if (!mounted) return;
      setState(() {
        _pontosMarcados = pontos;
        _recomendacoes = recomendacoes;
        _offline = repositorioRecomendacoes.ultimoResultadoOffline;
        _cacheEm = repositorioRecomendacoes.ultimaAtualizacaoCache;
        _producaoPorPontoId = {
          for (final item in producaoPorPonto)
            if (item.ponto.id != null) item.ponto.id!: item,
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = mensagemErroAmigavel(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  String _formatarDataHora(DateTime d) {
    final data = '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    final hora = '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
    return '$data $hora';
  }

  void _abrirDetalheRecomendacao(Recomendacao recomendacao) {
    _abrirCardFlutuante(RecomendacaoCard(recomendacao: recomendacao));
  }

  void _abrirDetalhePontoMarcado(PontoMarcado ponto) {
    double? distanciaNm;
    double? rumoGraus;
    final gps = _gpsPosition;
    if (gps != null) {
      distanciaNm = calcularDistanciaNauticas(
        gps.latitude,
        gps.longitude,
        ponto.latitude,
        ponto.longitude,
      );
      rumoGraus = Geolocator.bearingBetween(
        gps.latitude,
        gps.longitude,
        ponto.latitude,
        ponto.longitude,
      );
      if (rumoGraus < 0) rumoGraus += 360;
    }

    _abrirCardFlutuante(
      _DetalhePontoMarcado(
        ponto: ponto,
        distanciaNm: distanciaNm,
        rumoGraus: rumoGraus,
        producao: ponto.id != null ? _producaoPorPontoId[ponto.id] : null,
        formatarDataHora: _formatarDataHora,
        onRemovido: () async {
          if (ponto.id != null) {
            await DatabaseHelper.instance.delete('ponto_marcado', id: ponto.id!);
          }
          if (!mounted) return;
          setState(() => _pontosMarcados.remove(ponto));
        },
      ),
    );
  }

  /// Mesmo chrome do card flutuante da aba "Recomendações" (Dialog
  /// arredondado, largura máxima, X no canto) — usado tanto pra uma
  /// recomendação quanto pra um ponto marcado, pra as duas listas abrirem
  /// o detalhe do mesmo jeito.
  void _abrirCardFlutuante(Widget conteudo) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 44, 20),
                child: conteudo,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pontos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  _erro == mensagemSemConexao
                      ? Icons.wifi_off_outlined
                      : Icons.error_outline,
                  size: 48,
                  color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregar,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pontosMarcados.isEmpty && _recomendacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pin_drop_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              const Text(
                'Nenhum ponto marcado nem recomendação ainda',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_offline) ...[
            _buildBannerOffline(),
            const SizedBox(height: 12),
          ],
          if (_pontosMarcados.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'PONTOS MARCADOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: onSurfaceVariant,
                ),
              ),
            ),
            for (var i = 0; i < _pontosMarcados.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              PontoMarcadoListTile(
                ponto: _pontosMarcados[i],
                onTap: () => _abrirDetalhePontoMarcado(_pontosMarcados[i]),
              ),
            ],
            const SizedBox(height: 20),
          ],
          if (_recomendacoes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'RECOMENDAÇÕES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: onSurfaceVariant,
                ),
              ),
            ),
            for (var i = 0; i < _recomendacoes.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              RecomendacaoListTile(
                recomendacao: _recomendacoes[i],
                onTap: () => _abrirDetalheRecomendacao(_recomendacoes[i]),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBannerOffline() {
    final horario = _cacheEm != null
        ? '${_cacheEm!.day.toString().padLeft(2, '0')}/${_cacheEm!.month.toString().padLeft(2, '0')} '
            '${_cacheEm!.hour.toString().padLeft(2, '0')}:${_cacheEm!.minute.toString().padLeft(2, '0')}'
        : 'data desconhecida';
    return Card(
      color: Colors.amber.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.amber.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sem conexão — mostrando as últimas recomendações sincronizadas em $horario',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo do card flutuante de um ponto marcado — mesma estrutura do
/// `RecomendacaoCard` (sem Card/elevação própria, o Dialog já cuida disso):
/// coordenadas, data, distância/rumo do GPS atual, dados oceânicos ao vivo
/// e as ações que só fazem sentido pra um ponto marcado (pedir carta,
/// consultar condições ali, remover).
class _DetalhePontoMarcado extends StatelessWidget {
  final PontoMarcado ponto;
  final double? distanciaNm;
  final double? rumoGraus;
  final ProducaoPorPonto? producao;
  final String Function(DateTime) formatarDataHora;
  final VoidCallback onRemovido;

  const _DetalhePontoMarcado({
    required this.ponto,
    required this.distanciaNm,
    required this.rumoGraus,
    required this.producao,
    required this.formatarDataHora,
    required this.onRemovido,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.push_pin, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ponto.nome?.isNotEmpty == true ? ponto.nome! : 'Ponto marcado',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LinhaInfoPonto(
          icon: Icons.explore_outlined,
          label: 'Coordenadas',
          valor: formatarCoordenadasDMS(ponto.latitude, ponto.longitude),
        ),
        const Divider(height: 20),
        LinhaInfoPonto(
          icon: Icons.event_outlined,
          label: 'Marcado em',
          valor: formatarDataHora(ponto.dataCriacao),
        ),
        if (distanciaNm != null && rumoGraus != null) ...[
          const Divider(height: 20),
          LinhaInfoPonto(
            icon: Icons.social_distance_outlined,
            label: 'Distância',
            valor: '${distanciaNm!.toStringAsFixed(1)} mn',
          ),
          const SizedBox(height: 8),
          LinhaInfoPonto(
            icon: Icons.navigation_outlined,
            label: 'Rumo',
            valor: '${rumoGraus!.toStringAsFixed(0)}°',
          ),
        ],
        if (producao != null) ...[
          const Divider(height: 20),
          LinhaInfoPonto(
            icon: Icons.set_meal_outlined,
            label: 'Produção aqui',
            valor: '${producao!.totalKg.toStringAsFixed(1)} kg'
                ' (${producao!.totalRegistros} registro(s))',
          ),
        ],
        const Divider(height: 20),
        DadosOceanicosPonto(latitude: ponto.latitude, longitude: ponto.longitude),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SolicitarCartaScreen(
                    dbHelper: DatabaseHelper.instance,
                    latitudeInicial: ponto.latitude,
                    longitudeInicial: ponto.longitude,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Solicitar Carta'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CondicoesPontoScreen(
                    latitude: ponto.latitude,
                    longitude: ponto.longitude,
                    nome: ponto.nome,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.water_outlined, size: 18),
            label: const Text('Consultar aqui'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRemovido();
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
