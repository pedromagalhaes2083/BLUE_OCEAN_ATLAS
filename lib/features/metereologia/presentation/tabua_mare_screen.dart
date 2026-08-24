import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/mare_harmonica.dart';
import '../../widgets/seletor_coordenada_widget.dart';
import '../data/wave_forecast_repository.dart';
import '../domain/models/porto_mare.dart';
import 'tabua_mare_detalhe_screen.dart';

/// Lista de portos salvos pelo usuário pra consulta de maré (ex: "Porto de
/// Itarema", "Acaraú", "Camocim") — cada porto guarda um modelo de maré
/// ajustado por harmônicos (ver `ModeloMareHarmonico`) a partir da série da
/// Open-Meteo, permitindo prever a maré **offline** depois de sincronizado
/// pelo menos uma vez (ver [TabuaMareDetalheScreen]).
class TabuaMareScreen extends StatefulWidget {
  const TabuaMareScreen({super.key});

  @override
  State<TabuaMareScreen> createState() => _TabuaMareScreenState();
}

class _TabuaMareScreenState extends State<TabuaMareScreen> {
  List<PortoMare> _portos = [];
  bool _carregando = true;
  String? _erro;
  final Set<int> _sincronizando = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final maps = await DatabaseHelper.instance.query('porto_mare');
      final portos = maps.map(PortoMare.fromMap).toList()
        ..sort((a, b) => a.nome.compareTo(b.nome));
      if (!mounted) return;
      setState(() => _portos = portos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Erro ao carregar portos: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Busca a série, ajusta o modelo e grava no banco — sem nenhuma UI (sem
  /// SnackBar, sem tocar em [_sincronizando]/[_portos]). Separado de
  /// [_sincronizarPorto] porque também é chamado a partir da tela de
  /// detalhe do porto (ver `onSincronizar` no `ListTile` abaixo) — se essa
  /// função mostrasse o SnackBar direto, ele apareceria grudado nesta tela
  /// (a lista), que fica escondida atrás da tela de detalhe quando é de lá
  /// que o usuário chamou a sincronização, deixando erro de conexão sem
  /// nenhum feedback visível pra quem estava na tela de detalhe.
  Future<PortoMare> _sincronizarPortoSemUI(PortoMare porto) async {
    final serie = await WaveForecastRepository().buscarSerieNivelMar(
      latitude: porto.latitude,
      longitude: porto.longitude,
    );
    if (serie.length < 24) {
      throw Exception('Poucos dados de maré retornados pra esse ponto');
    }
    final modelo = ajustarModeloMareHarmonico(
      horarios: serie.map((e) => e.horario).toList(),
      alturas: serie.map((e) => e.alturaM).toList(),
    );
    final agora = DateTime.now();
    await DatabaseHelper.instance.update(
      'porto_mare',
      {
        'constantes_json': modelo.toJsonString(),
        'sincronizado_em': agora.toIso8601String(),
      },
      id: porto.id!,
    );
    return porto.copyWith(modelo: modelo, sincronizadoEm: agora);
  }

  Future<void> _sincronizarPorto(PortoMare porto) async {
    if (porto.id == null || _sincronizando.contains(porto.id)) return;
    setState(() => _sincronizando.add(porto.id!));
    try {
      final atualizado = await _sincronizarPortoSemUI(porto);
      if (!mounted) return;
      setState(() {
        _portos =
            _portos.map((p) => p.id == porto.id ? atualizado : p).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(mensagemErroAmigavel(e,
                prefixo: 'Erro ao sincronizar "${porto.nome}"'))),
      );
    } finally {
      if (mounted) setState(() => _sincronizando.remove(porto.id));
    }
  }

  Future<void> _removerPorto(PortoMare porto) async {
    if (porto.id == null) return;
    await DatabaseHelper.instance.delete('porto_mare', id: porto.id!);
    if (!mounted) return;
    setState(() => _portos.removeWhere((p) => p.id == porto.id));
  }

  Future<void> _adicionarPorto() async {
    final nomeController = TextEditingController();
    double lat = 0;
    double lon = 0;

    final salvar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo porto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex: Porto de Itarema',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              SeletorCoordenadaWidget(
                onAlterado: (novaLat, novaLon) {
                  lat = novaLat;
                  lon = novaLon;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nomeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha o nome do porto')),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (salvar != true || !mounted) return;

    final id = await DatabaseHelper.instance.insert('porto_mare', {
      'nome': nomeController.text.trim(),
      'latitude': lat,
      'longitude': lon,
      'data_criacao': DateTime.now().toIso8601String(),
      'constantes_json': null,
      'sincronizado_em': null,
    });

    final novoPorto = PortoMare(
      id: id,
      nome: nomeController.text.trim(),
      latitude: lat,
      longitude: lon,
      dataCriacao: DateTime.now(),
    );
    if (!mounted) return;
    setState(() {
      _portos = [..._portos, novoPorto]..sort((a, b) => a.nome.compareTo(b.nome));
    });
    _sincronizarPorto(novoPorto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tábua de Maré'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregando ? null : _carregar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarPorto,
        icon: const Icon(Icons.add),
        label: const Text('Porto'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(child: Text(_erro!));
    }
    if (_portos.isEmpty) {
      final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_outlined, size: 64, color: onSurfaceVariant),
              const SizedBox(height: 16),
              const Text(
                'Nenhum porto salvo ainda',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Salve a coordenada de um porto (ex: Itarema, Acaraú, Camocim) '
                'pra consultar a maré prevista, mesmo offline depois de sincronizado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        itemCount: _portos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _buildPortoTile(_portos[index]),
      ),
    );
  }

  Widget _buildPortoTile(PortoMare porto) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final sincronizando = porto.id != null && _sincronizando.contains(porto.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TabuaMareDetalheScreen(
              porto: porto,
              onSincronizar: () async {
                final atualizado = await _sincronizarPortoSemUI(porto);
                if (mounted) {
                  setState(() {
                    _portos = _portos
                        .map((p) => p.id == porto.id ? atualizado : p)
                        .toList();
                  });
                }
                return atualizado;
              },
              onRemover: () async {
                await _removerPorto(porto);
              },
            ),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: porto.temModeloOffline
              ? Colors.teal.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.15),
          child: Icon(Icons.anchor,
              color: porto.temModeloOffline ? Colors.teal : onSurfaceVariant),
        ),
        title: Text(porto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          formatarCoordenadasDMSCompacta(porto.latitude, porto.longitude),
          style: TextStyle(fontSize: 12, color: onSurfaceVariant),
        ),
        trailing: sincronizando
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(
                porto.temModeloOffline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                color: porto.temModeloOffline ? Colors.teal : onSurfaceVariant,
              ),
      ),
    );
  }
}
