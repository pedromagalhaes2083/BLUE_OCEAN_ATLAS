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

  /// Conteúdo mostrado enquanto [isLoading] é true. Subclasses podem
  /// sobrescrever pra usar um spinner/ícone em vez do texto padrão.
  Widget buildLoading(BuildContext context) =>
      Text(loadingMessage, style: const TextStyle(fontSize: 18));

  /// Cada card tem sua própria cor pastel de identidade (temperatura =
  /// azul, profundidade = índigo, vento = cinza) — fixa demais pra virar
  /// um bloco claro cego em cima de um tema escuro. Em vez de usar o
  /// literal puro, funde a cor como uma tinta translúcida sobre o
  /// `cardColor` do tema: no claro isso reproduz a cor original
  /// (alpha 1.0 = o próprio literal), no escuro vira um card escuro com
  /// um leve matiz da cor da marca, mantendo a identidade sem cegar.
  Color _corResolvida(BuildContext context, Color base) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Color.alphaBlend(
      base.withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        color: _corResolvida(context, const Color(0xFFEDF1F3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: buildLoading(context)),
        ),
      );
    }

    return Card(
      elevation: 6,
      color: _corResolvida(context, cardColor),
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
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
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
