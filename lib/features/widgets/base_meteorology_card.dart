import 'package:flutter/material.dart';

abstract class BaseMeteorologyCard extends StatelessWidget {
  final Color cardColor;
  final double borderRadius;

  const BaseMeteorologyCard({
    super.key,
    this.cardColor = const Color(0xFFEDF1F3),
    this.borderRadius = 24,
  });

  /// Subclasses definem o conteúdo interno
  Widget buildContent(BuildContext context);

  /// Estado de loading enquanto dados não chegam
  String get loadingMessage;

  /// Se true, mostra o placeholder de loading
  bool get isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        color: const Color(0xFFEDF1F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text(loadingMessage, style: const TextStyle(fontSize: 18)),
          ),
        ),
      );
    }

    return Card(
      elevation: 6,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: buildContent(context),
      ),
    );
  }

  /// Helper compartilhado: linha de título com ícone
  static Widget buildHeader({
    required IconData icon,
    required String title,
    required Color color,
    double iconSize = 28,
    double fontSize = 22,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: iconSize),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Helper compartilhado: container branco interno (coordenadas, vetores, etc.)
  static Widget buildWhiteContainer({
    required Widget child,
    double borderRadius = 16,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
