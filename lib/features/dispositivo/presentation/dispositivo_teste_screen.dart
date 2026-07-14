import 'package:flutter/material.dart';

import '../../../core/services/device_id_service.dart';
import '../data/dispositivo_repository.dart';
import '../domain/models/dispositivo.dart';
import '../../recomendacao/data/recomendacao_repository.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../../recomendacao/widgets/recomendacao_card.dart';

/// Tela de teste manual para o módulo dispositivo → recomendações:
/// GET base/estrutura/dispositivos/identificador/{id} e
/// GET base/inteligencia/recomendacoes.
class DispositivoTesteScreen extends StatefulWidget {
  const DispositivoTesteScreen({super.key});

  @override
  State<DispositivoTesteScreen> createState() =>
      _DispositivoTesteScreenState();
}

class _DispositivoTesteScreenState extends State<DispositivoTesteScreen> {
  String? _deviceId;

  Dispositivo? _dispositivo;
  String? _erroDispositivo;
  bool _carregandoDispositivo = false;

  List<Recomendacao>? _recomendacoes;
  String? _erroRecomendacoes;
  bool _carregandoRecomendacoes = false;

  @override
  void initState() {
    super.initState();
    _carregarDeviceId();
  }

  Future<void> _carregarDeviceId() async {
    final id = await DeviceIdService.obtemId();
    if (mounted) setState(() => _deviceId = id);
  }

  Future<void> _buscarDispositivo() async {
    setState(() {
      _carregandoDispositivo = true;
      _erroDispositivo = null;
      _dispositivo = null;
    });
    try {
      final id = _deviceId ?? await DeviceIdService.obtemId();
      final dispositivo =
          await DispositivoRepository().buscarPorIdentificador(id);
      setState(() => _dispositivo = dispositivo);
    } catch (e) {
      setState(() => _erroDispositivo = e.toString());
    } finally {
      if (mounted) setState(() => _carregandoDispositivo = false);
    }
  }

  Future<void> _buscarRecomendacoes() async {
    setState(() {
      _carregandoRecomendacoes = true;
      _erroRecomendacoes = null;
      _recomendacoes = null;
    });
    try {
      final lista = await RecomendacaoRepository().listar();
      setState(() => _recomendacoes = lista);
    } catch (e) {
      setState(() => _erroRecomendacoes = e.toString());
    } finally {
      if (mounted) setState(() => _carregandoRecomendacoes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste — Dispositivo & Recomendações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDeviceIdCard(),
          const SizedBox(height: 20),
          _buildSecaoDispositivo(),
          const SizedBox(height: 28),
          _buildSecaoRecomendacoes(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── ID local ─────────────────────────────────────────────────────────────

  Widget _buildDeviceIdCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.smartphone, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Identificador local (DeviceIdService)',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    _deviceId ?? 'Carregando...',
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dispositivo ──────────────────────────────────────────────────────────

  Widget _buildSecaoDispositivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCabecalhoSecao(
          'GET dispositivos/identificador/{id}',
          _carregandoDispositivo,
          _buscarDispositivo,
        ),
        const SizedBox(height: 8),
        if (_erroDispositivo != null) _buildErroCard(_erroDispositivo!),
        if (_dispositivo != null) _buildDispositivoCard(_dispositivo!),
      ],
    );
  }

  Widget _buildDispositivoCard(Dispositivo d) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linha('id', d.id),
            _linha('identificador', d.identificador),
            _linha('nome', d.nome),
            _linha('organizacaoId', d.organizacaoId),
            _linha('empresaId', d.empresaId ?? '—'),
            _linha('status', '${d.status}'),
            _linha('tipo', '${d.tipo}'),
            _linha('ambiente', '${d.ambiente}'),
            _linha('atuante', '${d.atuante}'),
            _linha('atualizadoEm', '${d.atualizadoEm ?? '—'}'),
          ],
        ),
      ),
    );
  }

  // ── Recomendações ────────────────────────────────────────────────────────

  Widget _buildSecaoRecomendacoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCabecalhoSecao(
          'GET recomendacoes',
          _carregandoRecomendacoes,
          _buscarRecomendacoes,
        ),
        const SizedBox(height: 8),
        if (_erroRecomendacoes != null) _buildErroCard(_erroRecomendacoes!),
        if (_recomendacoes != null) ...[
          Text(
            '${_recomendacoes!.length} recomendações',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 8),
          ..._recomendacoes!.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RecomendacaoCard(recomendacao: r),
              )),
        ],
      ],
    );
  }

  // ── Widgets compartilhados ───────────────────────────────────────────────

  Widget _buildCabecalhoSecao(
    String titulo,
    bool carregando,
    VoidCallback onBuscar,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ),
        ElevatedButton.icon(
          onPressed: carregando ? null : onBuscar,
          icon: carregando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search, size: 18),
          label: const Text('Buscar'),
        ),
      ],
    );
  }

  Widget _buildErroCard(String erro) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(erro,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(valor,
                style:
                    const TextStyle(fontSize: 13, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
