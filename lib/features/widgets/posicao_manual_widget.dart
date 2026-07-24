import 'package:flutter/material.dart';

/// Widget reutilizável para buscar dados numa posição escolhida pelo
/// usuário (latitude/longitude), em vez da posição atual do GPS.
/// Uso: PosicaoManualWidget(onBuscar: (lat, lon) { ... })
class PosicaoManualWidget extends StatefulWidget {
  final void Function(double latitude, double longitude) onBuscar;

  const PosicaoManualWidget({super.key, required this.onBuscar});

  @override
  State<PosicaoManualWidget> createState() => _PosicaoManualWidgetState();
}

class _PosicaoManualWidgetState extends State<PosicaoManualWidget> {
  bool _expandido = false;
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _buscar() {
    final lat = double.tryParse(_latController.text.replaceAll(',', '.'));
    final lon = double.tryParse(_lonController.text.replaceAll(',', '.'));

    if (lat == null || lat < -90 || lat > 90) {
      setState(() => _erro = 'Latitude inválida (-90 a 90)');
      return;
    }
    if (lon == null || lon < -180 || lon > 180) {
      setState(() => _erro = 'Longitude inválida (-180 a 180)');
      return;
    }

    setState(() => _erro = null);
    widget.onBuscar(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expandido = !_expandido),
              child: Row(
                children: [
                  const Icon(Icons.edit_location_alt, color: Colors.blueGrey),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Buscar em outra posição',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(_expandido ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_expandido) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lonController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Text(_erro!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _buscar,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar nessa posição'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
