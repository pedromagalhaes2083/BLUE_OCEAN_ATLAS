import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/location_tracking_service.dart';
import '../../../core/services/night_mode_service.dart';
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

  @override
  void initState() {
    super.initState();
    _carregar();
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
    if (!mounted) return;
    setState(() {
      _deviceId = id;
      _deviceInfo = info;
      _intervaloMinutos =
          _opcoesIntervalo.contains(intervalo) ? intervalo : intervaloMinimoMinutos;
      _contatoEmergenciaController.text = contatoEmergencia;
    });
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
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
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
                    child: ValueListenableBuilder<bool>(
                      valueListenable: NightModeService.ativo,
                      builder: (context, ativo, _) => SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        secondary: Icon(
                          Icons.nightlight_round,
                          color: ativo ? Colors.red[700] : Colors.blue,
                        ),
                        title: const Text(
                          'Modo Noturno',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Tela em vermelho para preservar a visão no escuro.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        value: ativo,
                        onChanged: NightModeService.alternar,
                      ),
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
                              border: OutlineInputBorder(),
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
