import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/localizacao_reporter_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  String? _deviceId;
  DeviceInfoResumo? _deviceInfo;
  final _embarcacaoIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _embarcacaoIdController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final id = await DeviceIdService.obtemId();
    final info = await DeviceIdService.obtemInfo();
    final embarcacaoId = await Config.obtem(
      Constantes.embarcacaoId,
      '9b2aac19-ad31-4e6d-baf5-fb101a976c1b',
    );
    if (!mounted) return;
    setState(() {
      _deviceId = id;
      _deviceInfo = info;
      _embarcacaoIdController.text = embarcacaoId;
    });
  }

  Future<void> _copiarId() async {
    if (_deviceId == null) return;
    await Clipboard.setData(ClipboardData(text: _deviceId!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID copiado para a área de transferência')),
    );
  }

  Future<void> _salvarEmbarcacaoId() async {
    await Config.grava(Constantes.embarcacaoId, _embarcacaoIdController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID da embarcação salvo')),
    );
  }

  bool _testandoEnvio = false;

  Future<void> _testarEnvioLocalizacao() async {
    setState(() => _testandoEnvio = true);
    await LocalizacaoReporterService.enviarLocalizacaoAtual();
    if (!mounted) return;
    setState(() => _testandoEnvio = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Teste disparado — veja o resultado no console/log')),
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
                    'Embarcação (envio de localização)',
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
                              Icon(Icons.directions_boat, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'ID da Embarcação (backend)',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'UUID cadastrado no backend, usado no envio periódico '
                            'de localização da embarcação.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _embarcacaoIdController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'ex: a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                            ),
                            style: const TextStyle(
                                fontSize: 14, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed:
                                    _testandoEnvio ? null : _testarEnvioLocalizacao,
                                icon: _testandoEnvio
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send, size: 18),
                                label: const Text('Testar envio agora'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: _salvarEmbarcacaoId,
                                icon: const Icon(Icons.save, size: 18),
                                label: const Text('Salvar'),
                              ),
                            ],
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
