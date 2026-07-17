import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionCard extends StatelessWidget {
  final bool isLoadingPosition;
  final String? positionError;
  final Position? currentPosition;
  final String Function(double lat, double lon) formatCoordinates;

  /// Se informado, mostra um botão de atualizar embutido no card —
  /// dispensa a tela que hospeda o card de ter seu próprio FAB/botão.
  final VoidCallback? onRefresh;

  const PositionCard({
    super.key,
    required this.isLoadingPosition,
    required this.positionError,
    required this.currentPosition,
    required this.formatCoordinates,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFFEDF1F3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '📍 Posição Atual',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (onRefresh != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Atualizar posição',
                      onPressed: isLoadingPosition ? null : onRefresh,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (isLoadingPosition)
                const CircularProgressIndicator()
              else if (positionError != null)
                Text(
                  positionError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              else if (currentPosition != null)
                Text(
                  formatCoordinates(
                      currentPosition!.latitude, currentPosition!.longitude),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Text(
                onRefresh != null
                    ? 'Toque no ícone para atualizar'
                    : 'Toque no botão para atualizar',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
