import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/constantes.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/location_service.dart';
import 'package:atlas/core/services/location_tracking_service.dart';
import 'package:atlas/features/viagem/domain/models/viagem.dart';

class NovaViagemScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final String embarcacao;

  const NovaViagemScreen({
    super.key,
    required this.dbHelper,
    required this.embarcacao,
  });

  @override
  State<NovaViagemScreen> createState() => _NovaViagemScreenState();
}

class _NovaViagemScreenState extends State<NovaViagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  DateTime _dataInicio = DateTime.now();
  DateTime? _dataTermino;

  Future<void> _salvarViagem() async {
    if (!_formKey.currentState!.validate()) return;

    await _confirmarPermissaoSegundoPlano();
    if (!mounted) return;

    final viagem = Viagem(
      id: 0,
      nome: _nomeController.text.trim().isEmpty
          ? null
          : _nomeController.text.trim(),
      dataInicio: _dataInicio,
      dataTermino: _dataTermino,
      embarcacaoId: widget.embarcacao,
      status: 'em_andamento',
    );

    await widget.dbHelper.insert('viagem', viagem.toMap());

    // O rastreamento em segundo plano só roda enquanto houver viagem em
    // andamento — começa aqui e para em `_finalizarViagem`
    // (HistoricoLocalizacoesScreen), em vez de acompanhar login/logout.
    try {
      final intervalo = int.tryParse(await Config.obtem(
            Constantes.intervaloRastreamentoMinutos,
            '$intervaloMinimoMinutos',
          )) ??
          intervaloMinimoMinutos;
      await LocationTrackingService()
          .iniciarRastreamento(intervaloMinutos: intervalo);
    } catch (e) {
      debugPrint('Erro ao iniciar rastreamento de localização: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viagem iniciada com sucesso!')),
    );

    Navigator.pop(context, true); // Retorna sucesso
  }

  /// Explica por que o app precisa da localização "o tempo todo" antes de
  /// pedir — obrigatório pela política do Android/Play a partir da API 30 —
  /// e então tenta elevar a permissão. Nunca bloqueia o início da viagem:
  /// sem "sempre", o rastreamento simplesmente só funciona com o app
  /// aberto, então só avisa em vez de impedir.
  Future<void> _confirmarPermissaoSegundoPlano() async {
    final permissaoAtual = await Geolocator.checkPermission();
    if (permissaoAtual == LocationPermission.always) return;
    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(child: Text('Localização em segundo plano')),
          ],
        ),
        content: const Text(
          'Enquanto a viagem estiver em andamento, o Atlas envia sua '
          'posição periodicamente para o servidor — inclusive com o app '
          'fechado, pra manter o rastreamento de segurança da embarcação. '
          'Isso exige a permissão "Permitir o tempo todo" e a exceção de '
          'otimização de bateria nas próximas telas. Fora de uma viagem, '
          'a posição não é enviada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final resultado = await LocationService().solicitarPermissaoSempre();
    if (!mounted) return;
    if (resultado != LocationPermission.always) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sem "Permitir o tempo todo", o envio de posição só funciona '
            'com o app aberto. Pode ativar depois nas configurações do '
            'aparelho.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }

    // Pedido separado — Android trata otimização de bateria e permissão de
    // localização como coisas distintas, cada uma com seu próprio diálogo.
    final ignoraOtimizacao =
        await LocationService().solicitarIgnorarOtimizacaoBateria();
    if (!mounted) return;
    if (!ignoraOtimizacao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sem a exceção de otimização de bateria, o aparelho pode '
            'interromper o envio de posição em segundo plano. Pode ativar '
            'depois nas configurações de bateria do app.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Viagem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Viagem (opcional)',
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Data de Início'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataInicio)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataInicio,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _dataInicio = date);
                },
              ),
              ListTile(
                title: const Text('Data de Término (opcional)'),
                subtitle: Text(_dataTermino != null
                    ? DateFormat('dd/MM/yyyy').format(_dataTermino!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataTermino ?? _dataInicio,
                    firstDate: _dataInicio,
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _dataTermino = date);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvarViagem,
                child: const Text('INICIAR VIAGEM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
