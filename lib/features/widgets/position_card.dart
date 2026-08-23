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
    final colorScheme = Theme.of(context).colorScheme;
    final escuro = Theme.of(context).brightness == Brightness.dark;
    // No claro, mantém a cor neutra original — o tom azul (mesmo dos
    // outros cards de status) só entra no escuro, onde o pastel neutro
    // antigo ficava um bloco claro cego em cima do fundo escuro.
    final corFundo =
        escuro ? colorScheme.primaryContainer : const Color(0xFFEDF1F3);
    final onContainer =
        escuro ? colorScheme.onPrimaryContainer : Colors.black87;
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: corFundo,
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
                  Text(
                    '📍 Posição Atual',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onContainer),
                  ),
                  if (onRefresh != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.refresh, color: onContainer),
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
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: onContainer),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Text(
                onRefresh != null
                    ? 'Toque no ícone para atualizar'
                    : 'Toque no botão para atualizar',
                style: TextStyle(color: onContainer.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
