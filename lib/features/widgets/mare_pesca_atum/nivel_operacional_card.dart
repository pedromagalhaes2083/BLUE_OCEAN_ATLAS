import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/nivel_operacional_mare.dart';

/// Seção "Classificação Atual" (como interpretar a maré na operação) — os 3 níveis
/// (🟢 favorável / 🟡 atenção / 🔴 baixa evidência), com o nível calculado
/// pra agora ([nivelAtual], ver [calcularNivelOperacionalMare]) destacado
/// e os outros dois exibidos de forma mais discreta, só como referência.
class NivelOperacionalCard extends StatelessWidget {
  final NivelOperacionalMare nivelAtual;

  const NivelOperacionalCard({super.key, required this.nivelAtual});

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Classificação Atual',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Classificação a partir dos indicadores que o app tem hoje '
              '(maré astronômica + corrente medida) — não é previsão de captura.',
              style: TextStyle(fontSize: 11.5, color: corRot),
            ),
            const SizedBox(height: 16),
            _linhaNivel(
              context,
              nivel: NivelOperacionalMare.favoravel,
              emoji: '🟢',
              cor: Colors.green.shade700,
            ),
            const SizedBox(height: 10),
            _linhaNivel(
              context,
              nivel: NivelOperacionalMare.atencao,
              emoji: '🟡',
              cor: Colors.amber.shade800,
            ),
            const SizedBox(height: 10),
            _linhaNivel(
              context,
              nivel: NivelOperacionalMare.baixaEvidencia,
              emoji: '🔴',
              cor: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaNivel(
    BuildContext context, {
    required NivelOperacionalMare nivel,
    required String emoji,
    required Color cor,
  }) {
    final ativo = nivel == nivelAtual;
    final corRot = corRotulo(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ativo ? cor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ativo ? cor.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
          width: ativo ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(nivel.titulo,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ativo ? cor : null)),
                    ),
                    if (ativo)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('AGORA',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(nivel.textoOperacional,
                    style: TextStyle(
                        fontSize: 12,
                        color: ativo ? null : corRot,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
