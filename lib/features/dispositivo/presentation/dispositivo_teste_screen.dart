import 'package:flutter/material.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/utils/cor_tema.dart';
import '../../../core/services/recomendacao_notification_service.dart';
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

  bool _testandoNotificacao = false;
  String? _resultadoTesteNotificacao;

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
      if (!mounted) return;
      setState(() => _dispositivo = dispositivo);
    } catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() => _recomendacoes = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroRecomendacoes = e.toString());
    } finally {
      if (mounted) setState(() => _carregandoRecomendacoes = false);
    }
  }

  /// Força a checagem de recomendações novas a tratar tudo que a API
  /// retornar agora como "novo" — zera a marca d'água salva (ver
  /// [RecomendacaoNotificationService]) antes de checar, senão a 1ª
  /// checagem depois do reset só grava a marca d'água de novo, sem
  /// notificar. Só pra QA manual: em uso normal, essa marca avança sozinha
  /// a cada checagem em segundo plano.
  Future<void> _testarNotificacao() async {
    setState(() {
      _testandoNotificacao = true;
      _resultadoTesteNotificacao = null;
    });
    try {
      await Config.grava(
        Constantes.ultimaVerificacaoRecomendacoes,
        DateTime(2000).toIso8601String(),
      );
      await RecomendacaoNotificationService.verificarNovas();
      if (!mounted) return;
      setState(() => _resultadoTesteNotificacao =
          'Checagem disparada — se houver recomendação com data, a notificação já deve ter aparecido.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _resultadoTesteNotificacao = 'Erro: $e');
    } finally {
      if (mounted) setState(() => _testandoNotificacao = false);
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
          const SizedBox(height: 28),
          _buildSecaoNotificacao(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSecaoNotificacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Notificação de recomendação nova',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _testandoNotificacao ? null : _testarNotificacao,
          icon: _testandoNotificacao
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_active_outlined, size: 18),
          label: const Text('Testar notificação'),
        ),
        if (_resultadoTesteNotificacao != null) ...[
          const SizedBox(height: 8),
          Text(
            _resultadoTesteNotificacao!,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ],
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
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corDestaque = escuro ? Colors.green.shade200 : null;
    return Card(
      color: escuro ? Colors.green.withValues(alpha: 0.15) : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linha('id', d.id, cor: corDestaque),
            _linha('identificador', d.identificador, cor: corDestaque),
            _linha('nome', d.nome, cor: corDestaque),
            _linha('organizacaoId', d.organizacaoId, cor: corDestaque),
            _linha('empresaId', d.empresaId ?? '—', cor: corDestaque),
            _linha('status', '${d.status}', cor: corDestaque),
            _linha('tipo', '${d.tipo}', cor: corDestaque),
            _linha('ambiente', '${d.ambiente}', cor: corDestaque),
            _linha('atuante', '${d.atuante}', cor: corDestaque),
            _linha('atualizadoEm', '${d.atualizadoEm ?? '—'}', cor: corDestaque),
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

  Widget _linha(String label, String valor, {Color? cor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(color: corRotulo(context), fontSize: 12)),
          ),
          Expanded(
            child: Text(valor,
                style: TextStyle(
                    fontSize: 13, fontFamily: 'monospace', color: cor)),
          ),
        ],
      ),
    );
  }
}
