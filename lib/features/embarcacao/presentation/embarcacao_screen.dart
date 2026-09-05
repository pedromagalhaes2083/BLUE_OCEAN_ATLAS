import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/contexto_viagem_service.dart';
import '../../mapa/presentation/mapa_screen.dart';
import '../data/embarcacao_local_lookup.dart';
import '../domain/models/embarcacao.dart';

const _kgPorTonelada = 1000.0;

class EmbarcacaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Embarcacao? embarcacao;

  const EmbarcacaoScreen({
    super.key,
    required this.dbHelper,
    this.embarcacao,
  });

  @override
  State<EmbarcacaoScreen> createState() => _EmbarcacaoScreenState();
}

class _EmbarcacaoScreenState extends State<EmbarcacaoScreen> {
  Embarcacao? _embarcacao;
  String? _embarcacaoId;
  bool _isLoading = true;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic>? registro;
      if (widget.embarcacao?.id != null) {
        final db = await widget.dbHelper.database;
        final registros = await db.query(
          'embarcacao',
          where: 'id = ?',
          whereArgs: [widget.embarcacao!.id],
        );
        registro = registros.isNotEmpty ? registros.first : null;
      } else {
        registro = await buscarEmbarcacaoLocalAtual(widget.dbHelper);
      }

      final embarcacaoId = await Config.obtem(Constantes.embarcacaoId, '');

      if (!mounted) return;
      setState(() {
        _embarcacao = registro != null ? Embarcacao.fromMap(registro) : null;
        _embarcacaoId = embarcacaoId.trim().isEmpty ? null : embarcacaoId.trim();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar embarcação: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Busca a viagem ativa do usuário na plataforma de novo e resolve a
  /// embarcação a partir dela — não existe mais cadastro/edição manual de
  /// embarcação no app (ver [ContextoViagemService]).
  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    final encontrou = await ContextoViagemService.sincronizar(widget.dbHelper);
    if (!mounted) return;
    await _carregar();
    if (!mounted) return;
    setState(() => _sincronizando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          encontrou
              ? 'Embarcação sincronizada com a viagem ativa.'
              : 'Nenhuma viagem ativa encontrada na plataforma agora.',
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _rastrear() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapaScreen()),
    );
  }

  void _copiarId() {
    if (_embarcacaoId == null) return;
    Clipboard.setData(ClipboardData(text: _embarcacaoId!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copiado para a área de transferência')),
    );
  }

  String _formatarNumero(double valor) {
    return valor == valor.roundToDouble()
        ? valor.toStringAsFixed(0)
        : valor.toStringAsFixed(2);
  }

  String _formatarGelo(double? kg) {
    if (kg == null) return '--';
    return kg >= _kgPorTonelada
        ? '${_formatarNumero(kg / _kgPorTonelada)} t'
        : '${_formatarNumero(kg)} kg';
  }

  // ====================== Hero ======================

  Widget _buildFotoHero(String? fotoPath) {
    final temFoto = fotoPath != null && File(fotoPath).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        height: 64,
        child: temFoto
            ? Image.file(File(fotoPath), fit: BoxFit.cover)
            : _buildFotoGenerica(),
      ),
    );
  }

  /// Placeholder exibido quando a embarcação ainda não tem foto cadastrada.
  Widget _buildFotoGenerica() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.directions_boat_filled,
            color: Colors.blue.shade900, size: 32),
      ),
    );
  }

  Widget _buildHero(Embarcacao embarcacao) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFotoHero(embarcacao.foto),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  embarcacao.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  embarcacao.dono ?? 'Sem proprietário cadastrado',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                      embarcacao.ativo ? 'Ativa' : 'Inativa',
                      embarcacao.ativo
                          ? Colors.greenAccent.shade400
                          : Colors.white.withValues(alpha: 0.2),
                      embarcacao.ativo ? Colors.black : Colors.white,
                    ),
                    if (embarcacao.registro != null &&
                        embarcacao.registro!.isNotEmpty)
                      _buildChip(embarcacao.registro!,
                          Colors.white.withValues(alpha: 0.15), Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String texto, Color fundo, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(30)),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ====================== Seções ======================

  Widget _buildSectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String valor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            maxLines: 1,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacidades(Embarcacao embarcacao) {
    // Fundo do ícone como tinta translúcida (não mais o tom pastel fixo
    // "shade50", que ficava lavado demais em cima de um card escuro) — a
    // cor do ícone acompanha, mais clara no escuro pra manter contraste.
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CAPACIDADES E TRIPULAÇÃO'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatTile(
              icon: Icons.inventory_2,
              iconBg: Colors.indigo.withValues(alpha: 0.15),
              iconColor: escuro ? Colors.indigo.shade200 : Colors.indigo.shade700,
              valor: '${embarcacao.quantidadeUrnas}',
              label: 'Urnas',
            ),
            _buildStatTile(
              icon: Icons.ac_unit,
              iconBg: Colors.lightBlue.withValues(alpha: 0.15),
              iconColor:
                  escuro ? Colors.lightBlue.shade200 : Colors.lightBlue.shade700,
              valor: _formatarGelo(embarcacao.capacidadeGeloKg),
              label: 'Gelo',
            ),
            _buildStatTile(
              icon: Icons.local_gas_station,
              iconBg: Colors.orange.withValues(alpha: 0.15),
              iconColor: escuro ? Colors.orange.shade200 : Colors.orange.shade800,
              valor: embarcacao.capacidadeDieselLitros == null
                  ? '--'
                  : '${_formatarNumero(embarcacao.capacidadeDieselLitros!)} L',
              label: 'Diesel',
            ),
            _buildStatTile(
              icon: Icons.groups,
              iconBg: Colors.green.withValues(alpha: 0.15),
              iconColor: escuro ? Colors.green.shade200 : Colors.green.shade700,
              valor: embarcacao.numeroTripulantes?.toString() ?? '--',
              label: 'Tripulantes',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetalheRow(IconData icon, String label, String valor, {bool ultimo = false}) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: onSurfaceVariant),
                ),
              ),
              Flexible(
                child: Text(
                  valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!ultimo) Divider(height: 1, color: Theme.of(context).dividerColor),
      ],
    );
  }

  Widget _buildDetalhes(Embarcacao embarcacao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('DETALHES'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetalheRow(Icons.settings, 'Motor Usado', embarcacao.motorUsado ?? '--'),
              _buildDetalheRow(
                Icons.badge,
                'ID Mestre / Capitão',
                embarcacao.mestreId ?? '--',
                ultimo: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentificacao() {
    if (_embarcacaoId == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ID DE RASTREIO'),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _copiarId,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.tag,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _embarcacaoId!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.copy,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConteudo(Embarcacao embarcacao) {
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildHero(embarcacao),
          const SizedBox(height: 24),
          _buildCapacidades(embarcacao),
          const SizedBox(height: 24),
          _buildDetalhes(embarcacao),
          const SizedBox(height: 24),
          _buildIdentificacao(),
        ],
      ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sailing,
                size: 100,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma embarcação vinculada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'A embarcação é vinculada automaticamente a partir da sua '
              'viagem ativa na plataforma.',
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
              label: const Text('Sincronizar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraAcoes() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade900,
                  side: BorderSide(color: Colors.blue.shade900),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _sincronizando ? null : _sincronizar,
                icon: _sincronizando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: const Text('Sincronizar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _rastrear,
                icon: const Icon(Icons.map),
                label: const Text('Rastrear'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Embarcação'),
        actions: [
          IconButton(onPressed: _carregar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _embarcacao == null
              ? _buildVazio()
              : _buildConteudo(_embarcacao!),
      bottomNavigationBar: _embarcacao == null ? null : _buildBarraAcoes(),
    );
  }
}
