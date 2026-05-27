import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionCard extends StatelessWidget {
  final bool isLoadingPosition;
  final String? positionError;
  final Position? currentPosition;
  final String Function(double lat, double lon) formatCoordinates;

  const PositionCard({
    super.key,
    required this.isLoadingPosition,
    required this.positionError,
    required this.currentPosition,
    required this.formatCoordinates,
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
              const Text(
                '📍 Posição Atual',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              const Text(
                'Toque no botão para atualizar',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
