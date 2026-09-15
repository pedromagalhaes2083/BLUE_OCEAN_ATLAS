import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/contexto_viagem_service.dart';
import '../../../core/services/localizacao_reporter_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../data/embarcacao_local_lookup.dart';
import '../domain/models/embarcacao.dart';

const _kgPorTonelada = 1000.0;

/// Tela só de leitura: embarcação e viagem agora são criadas e vinculadas
/// na retaguarda/plataforma, não mais cadastradas ou escolhidas à mão no
/// app (ver [ContextoViagemService]) — aqui o mestre só confere o que foi
/// sincronizado e pode forçar uma nova sincronização.
class EmbarcacaoConfiguracaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const EmbarcacaoConfiguracaoScreen({super.key, required this.dbHelper});

  @override
  State<EmbarcacaoConfiguracaoScreen> createState() =>
      _EmbarcacaoConfiguracaoScreenState();
}

class _EmbarcacaoConfiguracaoScreenState
    extends State<EmbarcacaoConfiguracaoScreen> {
  Embarcacao? _embarcacao;
  String? _embarcacaoId;
  bool _isLoading = true;
  bool _sincronizando = false;
  bool _testandoEnvio = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final registro = await buscarEmbarcacaoLocalAtual(widget.dbHelper);
      final embarcacaoIdSalvo = await Config.obtem(Constantes.embarcacaoId, '');

      if (!mounted) return;
      setState(() {
        _embarcacao = registro != null ? Embarcacao.fromMap(registro) : null;
        _embarcacaoId =
            embarcacaoIdSalvo.trim().isEmpty ? null : embarcacaoIdSalvo.trim();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).embarcacaoErroCarregar('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Busca a viagem ativa do usuário na plataforma de novo e resolve a
  /// embarcação a partir dela (ver [ContextoViagemService.sincronizar]) —
  /// é como o app "descobre" ou atualiza a embarcação agora, em vez de um
  /// cadastro manual.
  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    final encontrou = await ContextoViagemService.sincronizar(widget.dbHelper);
    if (!mounted) return;
    await _carregar();
    if (!mounted) return;
    setState(() => _sincronizando = false);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          encontrou
              ? l10n.embarcacaoSincronizadaSucesso
              : l10n.dashboardNenhumaViagemEncontrada,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _testarEnvioLocalizacao() async {
    setState(() => _testandoEnvio = true);
    await LocalizacaoReporterService.registrarESincronizar();
    if (!mounted) return;
    setState(() => _testandoEnvio = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context).embarcacaoConfigTesteDisparado)),
    );
  }

  void _copiarId() {
    if (_embarcacaoId == null) return;
    Clipboard.setData(ClipboardData(text: _embarcacaoId!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).configIdCopiado)),
    );
  }

  String _formatarNumero(double valor) {
    return valor == valor.roundToDouble()
        ? valor.toStringAsFixed(0)
        : valor.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.embarcacaoTitulo),
        actions: [
          IconButton(
            onPressed: _sincronizando ? null : _sincronizar,
            icon: _sincronizando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: l10n.embarcacaoConfigTooltipSincronizar,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _embarcacao == null
              ? _buildSemEmbarcacao()
              : _buildDetalhes(_embarcacao!),
    );
  }

  Widget _buildSemEmbarcacao() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sailing,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.dashboardNenhumaEmbarcacaoTitulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.embarcacaoConfigSemEmbarcacaoTexto,
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

  Widget _buildDetalhes(Embarcacao embarcacao) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 8,
            shadowColor: Colors.blue.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.directions_boat_filled,
                      size: 56, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    embarcacao.nome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      l10n.embarcacaoConfigVinculadaTexto,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_embarcacaoId != null) ...[
                    InkWell(
                      onTap: _copiarId,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.embarcacaoConfigIdLabel,
                          prefixIcon: const Icon(Icons.tag, size: 20),
                          suffixIcon: const Icon(Icons.copy, size: 18),
                        ),
                        child: Text(
                          _embarcacaoId!,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  _linhaDetalhe(
                    Icons.ac_unit,
                    l10n.embarcacaoConfigCapacidadeGelo,
                    embarcacao.capacidadeGeloKg == null
                        ? '—'
                        : '${_formatarNumero(embarcacao.capacidadeGeloKg! / _kgPorTonelada)} t',
                  ),
                  _linhaDetalhe(
                    Icons.local_gas_station,
                    l10n.embarcacaoConfigCapacidadeDiesel,
                    embarcacao.capacidadeDieselLitros == null
                        ? '—'
                        : '${_formatarNumero(embarcacao.capacidadeDieselLitros!)} L',
                  ),
                  _linhaDetalhe(Icons.settings, l10n.embarcacaoConfigMotorUsado,
                      embarcacao.motorUsado ?? '—'),
                  _linhaDetalhe(Icons.groups, l10n.embarcacaoConfigNumeroTripulantes,
                      embarcacao.numeroTripulantes?.toString() ?? '—'),
                  _linhaDetalhe(Icons.badge, l10n.embarcacaoIdMestre,
                      embarcacao.mestreId ?? '—'),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _testandoEnvio ? null : _testarEnvioLocalizacao,
                    icon: _testandoEnvio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(l10n.embarcacaoConfigTestarEnvio),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _linhaDetalhe(IconData icon, String label, String valor) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: onSurfaceVariant)),
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
    );
  }
}
