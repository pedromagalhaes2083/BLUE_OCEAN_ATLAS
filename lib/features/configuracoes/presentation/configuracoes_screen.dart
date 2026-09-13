import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/battery_optimization_service.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/location_tracking_service.dart';
import '../../../core/services/night_mode_service.dart';
import '../../../core/services/theme_mode_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../dispositivo/presentation/dispositivo_teste_screen.dart';
import '../../embarcacao/presentation/embarcacao_configuracao_screen.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const ConfiguracoesScreen({super.key, required this.dbHelper});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  String? _deviceId;
  DeviceInfoResumo? _deviceInfo;
  int _intervaloMinutos = intervaloMinimoMinutos;
  final TextEditingController _contatoEmergenciaController =
      TextEditingController();

  static const _opcoesIntervalo = [15, 30, 60, 120];

  bool _fazendoBackup = false;
  bool _ocultarRecomendacoesExpiradas = false;

  /// `null` enquanto ainda não checou — `true`/`false` depois. Só é
  /// preocupante quando `false`: o Android pode matar o rastreamento em
  /// segundo plano sem avisar (ver [BatteryOptimizationService]).
  bool? _ignorandoOtimizacaoBateria;
  bool _pedindoIsencaoBateria = false;

  @override
  void initState() {
    super.initState();
    _carregar();
    _checarOtimizacaoBateria();
  }

  @override
  void dispose() {
    _contatoEmergenciaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final id = await DeviceIdService.obtemId();
    final info = await DeviceIdService.obtemInfo();
    final intervalo = int.tryParse(await Config.obtem(
          Constantes.intervaloRastreamentoMinutos,
          '$intervaloMinimoMinutos',
        )) ??
        intervaloMinimoMinutos;
    final contatoEmergencia =
        await Config.obtem(Constantes.contatoEmergenciaWhatsapp, '');
    final ocultarExpiradas = await Config.obtem(
      Constantes.ocultarRecomendacoesExpiradas,
      'false',
    );
    if (!mounted) return;
    setState(() {
      _deviceId = id;
      _deviceInfo = info;
      _intervaloMinutos =
          _opcoesIntervalo.contains(intervalo) ? intervalo : intervaloMinimoMinutos;
      _contatoEmergenciaController.text = contatoEmergencia;
      _ocultarRecomendacoesExpiradas = ocultarExpiradas == 'true';
    });
  }

  Future<void> _checarOtimizacaoBateria() async {
    final ignorando = await BatteryOptimizationService.estaIgnorandoOtimizacao();
    if (!mounted) return;
    setState(() => _ignorandoOtimizacaoBateria = ignorando);
  }

  Future<void> _pedirIsencaoBateria() async {
    setState(() => _pedindoIsencaoBateria = true);
    await BatteryOptimizationService.solicitarIsencao();
    if (!mounted) return;
    // O resultado do diálogo do sistema não vem no retorno da chamada em
    // todo fabricante — reconsulta o status de verdade em vez de confiar
    // no valor devolvido.
    await _checarOtimizacaoBateria();
    if (mounted) setState(() => _pedindoIsencaoBateria = false);
  }

  Future<void> _alternarOcultarRecomendacoesExpiradas(bool valor) async {
    setState(() => _ocultarRecomendacoesExpiradas = valor);
    await Config.grava(
      Constantes.ocultarRecomendacoesExpiradas,
      valor ? 'true' : 'false',
    );
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  // Rotas planejadas, pontos marcados, solicitações de carta e registros de
  // produção só existem localmente — nada disso sincroniza com um servidor
  // (só o histórico de localização sincroniza). Sem essa cópia manual, tudo
  // se perde se o aparelho quebrar, for roubado ou resetado.
  Future<void> _fazerBackup() async {
    setState(() => _fazendoBackup = true);
    try {
      final origem = File(await widget.dbHelper.caminhoArquivo());
      if (!await origem.exists()) {
        throw Exception('Banco de dados ainda não foi criado');
      }

      final tempDir = await getTemporaryDirectory();
      final carimbo = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final copia = await origem.copy('${tempDir.path}/atlas_backup_$carimbo.db');

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(copia.path)],
        text: AppLocalizations.of(context).configBackupCompartilhado(carimbo),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).configErroBackup('$e'))),
      );
    } finally {
      if (mounted) setState(() => _fazendoBackup = false);
    }
  }

  Future<void> _salvarContatoEmergencia() async {
    await Config.grava(
      Constantes.contatoEmergenciaWhatsapp,
      _contatoEmergenciaController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).configContatoSalvo)),
    );
  }

  Future<void> _abrirConfiguracaoEmbarcacao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmbarcacaoConfiguracaoScreen(dbHelper: widget.dbHelper),
      ),
    );
  }

  Future<void> _alterarIntervalo(int? novoValor) async {
    if (novoValor == null) return;
    setState(() => _intervaloMinutos = novoValor);
    await Config.grava(
        Constantes.intervaloRastreamentoMinutos, '$novoValor');

    // Se o rastreamento já estiver rodando, reinicia com o novo intervalo.
    final service = LocationTrackingService();
    if (await service.isTracking) {
      await service.iniciarRastreamento(intervaloMinutos: novoValor);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context).configIntervaloSalvo(novoValor))),
    );
  }

  Future<void> _copiarId() async {
    if (_deviceId == null) return;
    await Clipboard.setData(ClipboardData(text: _deviceId!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).configIdCopiado)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.configuracoesTitulo)),
      body: _deviceId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.configIdentificacaoAparelho,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.smartphone, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                l10n.configIdDispositivo,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _deviceId!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _copiarId,
                              icon: const Icon(Icons.copy, size: 18),
                              label: Text(l10n.configCopiar),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.configEmbarcacao,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.directions_boat, color: Colors.blue),
                      title: Text(
                        l10n.configConfigurarEmbarcacao,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        l10n.configConfigurarEmbarcacaoSubtitulo,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _abrirConfiguracaoEmbarcacao,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.configRastreamentoLocalizacao,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                l10n.configIntervaloCapturaEnvio,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.configIntervaloExplicacao,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _intervaloMinutos,
                            items: _opcoesIntervalo
                                .map((min) => DropdownMenuItem(
                                      value: min,
                                      child: Text(l10n.configMinutos(min)),
                                    ))
                                .toList(),
                            onChanged: _alterarIntervalo,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_ignorandoOtimizacaoBateria == false) ...[
                    const SizedBox(height: 12),
                    Card(
                      elevation: 3,
                      color: Colors.orange[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                            color: Colors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.battery_alert,
                                    color: Colors.orange[900]),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.configOtimizacaoBateriaTitulo,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange[900]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.configOtimizacaoBateriaTexto,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.orange[900]),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _pedindoIsencaoBateria
                                    ? null
                                    : _pedirIsencaoBateria,
                                icon: _pedindoIsencaoBateria
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.battery_charging_full),
                                label: Text(l10n.configIsentarApp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    l10n.configAparencia,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Row(
                            children: [
                              const Icon(Icons.dark_mode_outlined,
                                  color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.configTemaEscuro,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ValueListenableBuilder<ThemeMode>(
                              valueListenable: ThemeModeService.modo,
                              builder: (context, modo, _) =>
                                  SegmentedButton<ThemeMode>(
                                segments: [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text(l10n.configTemaClaro),
                                    icon: const Icon(Icons.light_mode_outlined),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text(l10n.configTemaSistema),
                                    icon: const Icon(
                                        Icons.brightness_auto_outlined),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text(l10n.configTemaEscuroSegmento),
                                    icon: const Icon(Icons.dark_mode_outlined),
                                  ),
                                ],
                                selected: {modo},
                                onSelectionChanged: (selecionado) =>
                                    ThemeModeService.alternar(
                                        selecionado.first),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ValueListenableBuilder<bool>(
                          valueListenable: NightModeService.ativo,
                          builder: (context, ativo, _) => SwitchListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            secondary: Icon(
                              Icons.nightlight_round,
                              color: ativo ? Colors.red[700] : Colors.blue,
                            ),
                            title: Text(
                              l10n.configModoNoturno,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              l10n.configModoNoturnoSubtitulo,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            value: ativo,
                            onChanged: NightModeService.alternar,
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Row(
                            children: [
                              const Icon(Icons.language, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.configIdioma,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          child: Text(
                            l10n.configIdiomaSubtitulo,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: ValueListenableBuilder<Locale?>(
                            valueListenable: LocaleService.locale,
                            builder: (context, localeAtual, _) =>
                                DropdownButtonFormField<Locale?>(
                              initialValue: localeAtual,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem<Locale?>(
                                  value: null,
                                  child: Text(l10n.idiomaSistema),
                                ),
                                for (final locale
                                    in LocaleService.idiomasSuportados)
                                  DropdownMenuItem<Locale?>(
                                    value: locale,
                                    child: Text(_rotuloIdioma(l10n, locale)),
                                  ),
                              ],
                              onChanged: LocaleService.alternar,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.configRecomendacoes,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      secondary: const Icon(Icons.event_busy, color: Colors.blue),
                      title: Text(
                        l10n.configOcultarRecomendacoesExpiradas,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        l10n.configOcultarRecomendacoesExpiradasSubtitulo,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: _ocultarRecomendacoesExpiradas,
                      onChanged: _alternarOcultarRecomendacoesExpiradas,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.configEmergencia,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sos, color: Colors.red),
                              const SizedBox(width: 10),
                              Text(
                                l10n.configContatoEmergencia,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.configContatoEmergenciaSubtitulo,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _contatoEmergenciaController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l10n.configNumeroLabel,
                              hintText: l10n.configNumeroHint,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _salvarContatoEmergencia,
                              icon: const Icon(Icons.save, size: 18),
                              label: Text(l10n.salvar),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.configDadosBackup,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.backup_outlined, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                l10n.configBackupManual,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.configBackupExplicacao,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _fazendoBackup ? null : _fazerBackup,
                              icon: _fazendoBackup
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.ios_share),
                              label: Text(l10n.configGerarBackup),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_deviceInfo != null) ...[
                    Text(
                      l10n.configDetalhesAparelho,
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _linha(l10n.configModelo, _deviceInfo!.modelo),
                          const Divider(height: 1),
                          _linha(l10n.configFabricante, _deviceInfo!.fabricante),
                          const Divider(height: 1),
                          _linha(
                            l10n.configSistemaOperacional,
                            '${_deviceInfo!.sistemaOperacional} ${_deviceInfo!.versaoSO}',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DispositivoTesteScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: Text(l10n.configTesteDispositivo),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _linha(String label, String valor) {
    return ListTile(
      title: Text(label),
      trailing: Text(valor, style: const TextStyle(color: Colors.grey)),
    );
  }

  /// Rótulo de cada idioma suportado no próprio idioma dele (ex: "English"
  /// mesmo quando o app está em português) — assim quem trocou de idioma
  /// sem querer ainda reconhece o nome do idioma certo pra voltar.
  String _rotuloIdioma(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'pt':
        return l10n.idiomaPortugues;
      case 'en':
        return l10n.idiomaIngles;
      case 'es':
        return l10n.idiomaEspanhol;
      case 'it':
        return l10n.idiomaItaliano;
      case 'fr':
        return l10n.idiomaFrances;
      default:
        return locale.languageCode;
    }
  }
}
