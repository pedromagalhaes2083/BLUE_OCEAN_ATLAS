import 'package:flutter/material.dart';

/// Chip com a validade da recomendação, calculada a partir de [validoAte]
/// comparado com o momento atual (a API não expõe um status "expirada"
/// próprio — isso é derivado no app).
class RecomendacaoValidadeChip extends StatelessWidget {
  final DateTime? validoAte;

  const RecomendacaoValidadeChip({super.key, required this.validoAte});

  bool get _expirada =>
      validoAte != null && validoAte!.isBefore(DateTime.now());

  String _formatar(DateTime d) {
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    final hora =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data $hora';
  }

  @override
  Widget build(BuildContext context) {
    if (validoAte == null) return const SizedBox.shrink();

    final cor = _expirada ? Colors.grey : Colors.green;
    final texto =
        _expirada ? 'Expirada' : 'Válida até ${_formatar(validoAte!)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_expirada ? Icons.event_busy : Icons.event_available,
              size: 13, color: cor),
          const SizedBox(width: 5),
          Text(texto,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: cor)),
        ],
      ),
    );
  }
}
