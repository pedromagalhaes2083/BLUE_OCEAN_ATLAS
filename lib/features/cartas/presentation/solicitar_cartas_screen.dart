import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:atlas/core/services/location_service.dart';
import 'package:atlas/core/database/database_helper.dart';

class SolicitarCartaScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const SolicitarCartaScreen({super.key, required this.dbHelper});

  @override
  State<SolicitarCartaScreen> createState() => _SolicitarCartaScreenState();
}

class _SolicitarCartaScreenState extends State<SolicitarCartaScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  bool _isLoadingLocation = false;

  Future<void> _getCurrentPosition() async {
    setState(() => _isLoadingLocation = true);

    try {
      Position? position = await _locationService.getCurrentPosition();
      if (!mounted) return;

      if (position != null) {
        setState(() {
          _latController.text = _locationService.decimalToDMS(
            position.latitude,
            true,
          );
          _lonController.text = _locationService.decimalToDMS(
            position.longitude,
            false,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Posição atual obtida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String message = e.toString().contains('negada permanentemente')
          ? 'Permissão de localização negada permanentemente. Ative nas configurações.'
          : 'Não foi possível obter a localização: $e';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _solicitarCarta() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // TODO: Salvar solicitação no banco ou enviar para API
      // await widget.dbHelper.insert('solicitacoes_carta', { ... });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação de carta náutica enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retorna sucesso
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar carta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Carta Náutica'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Coordenada Geográfica (DMS)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Informe o local desejado para a carta',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Latitude
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'Ex: 23° 45\' 12.3" S',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Informe a latitude' : null,
              ),

              const SizedBox(height: 16),

              // Longitude
              TextFormField(
                controller: _lonController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'Ex: 45° 12\' 34.5" W',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Informe a longitude' : null,
              ),

              const SizedBox(height: 24),

              // Botão de Posição Atual
              ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentPosition,
                icon: const Icon(Icons.my_location),
                label: _isLoadingLocation
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('USAR MINHA POSIÇÃO ATUAL'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 40),

              // Botão Principal
              ElevatedButton(
                onPressed: _solicitarCarta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'SOLICITAR CARTA NÁUTICA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
