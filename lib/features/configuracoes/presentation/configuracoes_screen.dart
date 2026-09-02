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
import '../../../core/services/location_tracking_service.dart';
import '../../../core/services/night_mode_service.dart';
import '../../../core/services/theme_mode_service.dart';
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
        text: 'Backup do Atlas Blue Ocean — $carimbo',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar backup: $e')),
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
      const SnackBar(content: Text('Contato de emergência salvo')),
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
    if (service.isTracking) {
      await service.iniciarRastreamento(intervaloMinutos: novoValor);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Intervalo de rastreamento: $novoValor min')),
    );
  }

  Future<void> _copiarId() async {
    if (_deviceId == null) return;
    await Clipboard.setData(ClipboardData(text: _deviceId!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copiado para a área de transferência')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _deviceId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Identificação do Aparelho',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          const Row(
                            children: [
                              Icon(Icons.smartphone, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'ID do Dispositivo',
                                style: TextStyle(
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
                              label: const Text('Copiar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Embarcação',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.directions_boat, color: Colors.blue),
                      title: const Text(
                        'Configurar Embarcação',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Capacidades, tripulação, mestre e ID de envio de localização.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _abrirConfiguracaoEmbarcacao,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Rastreamento de Localização',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          const Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Intervalo de captura e envio',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'A cada intervalo, o app captura a posição, grava '
                            'localmente e envia pra API. Sem internet, fica '
                            'guardado e é enviado assim que a conexão voltar.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _intervaloMinutos,
                            items: _opcoesIntervalo
                                .map((min) => DropdownMenuItem(
                                      value: min,
                                      child: Text('$min minutos'),
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
                                    'Otimização de bateria pode interromper o rastreamento',
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
                              'O aparelho pode parar de registrar a posição a cada '
                              '15 minutos durante uma viagem, sem nenhum aviso, se o '
                              'Atlas não estiver isento da otimização de bateria do '
                              'sistema.',
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
                                label: const Text('Isentar o app'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Aparência',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              const Expanded(
                                child: Text(
                                  'Tema Escuro',
                                  style: TextStyle(
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
                                segments: const [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text('Claro'),
                                    icon: Icon(Icons.light_mode_outlined),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text('Sistema'),
                                    icon: Icon(
                                        Icons.brightness_auto_outlined),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text('Escuro'),
                                    icon: Icon(Icons.dark_mode_outlined),
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
                            title: const Text(
                              'Modo Noturno',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'Tela em vermelho para preservar a visão no '
                              'escuro.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            value: ativo,
                            onChanged: NightModeService.alternar,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Recomendações',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      secondary: const Icon(Icons.event_busy, color: Colors.blue),
                      title: const Text(
                        'Ocultar recomendações expiradas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Some da lista em "Cartas Náuticas" quem já passou '
                        'da validade — continuam salvas, só não aparecem.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: _ocultarRecomendacoesExpiradas,
                      onChanged: _alternarOcultarRecomendacoesExpiradas,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Emergência',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          const Row(
                            children: [
                              Icon(Icons.sos, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                'Contato de emergência (WhatsApp)',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Se preenchido, o botão de EMERGÊNCIA no painel '
                            'abre direto uma conversa com esse número. Vazio, '
                            'ele deixa você escolher o app na hora.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _contatoEmergenciaController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Número com DDD e país',
                              hintText: 'Ex: 5588999998888',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _salvarContatoEmergencia,
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Salvar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Dados e Backup',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          const Row(
                            children: [
                              Icon(Icons.backup_outlined, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Backup manual',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Rotas planejadas, pontos marcados, pedidos de '
                            'carta e produção só existem neste aparelho — '
                            'nada disso é enviado a um servidor. Gere um '
                            'backup de vez em quando e guarde num lugar '
                            'seguro (e-mail, nuvem, outro aparelho).',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
                              label: const Text('Gerar e compartilhar backup'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_deviceInfo != null) ...[
                    const Text(
                      'Detalhes do Aparelho',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          _linha('Modelo', _deviceInfo!.modelo),
                          const Divider(height: 1),
                          _linha('Fabricante', _deviceInfo!.fabricante),
                          const Divider(height: 1),
                          _linha(
                            'Sistema Operacional',
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
                    label: const Text('Teste — Dispositivo & Recomendações'),
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
}
