import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/indice_influencia_mare.dart';

/// "Índice de Influência da Maré" — 0 a 100, mostrado com um medidor
/// circular simples. Ver a doc de [calcularIndiceInfluenciaMare]: isto NÃO
/// é chance de pegar atum, é só o quanto maré/lua/corrente de hoje somam
/// pra dinâmica oceanográfica — por isso o card sempre lista, ao lado do
/// número, quais fatores entraram e quais ficaram de fora por falta de
/// dado (nunca escondidos, nunca inventados).
class IndiceInfluenciaCard extends StatelessWidget {
  final IndiceInfluenciaMare indice;

  const IndiceInfluenciaCard({super.key, required this.indice});

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    final valor = indice.valor;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Potencial de Influência',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Quanto as condições de maré podem estar contribuindo para a '
              'dinâmica oceanográfica da região — não é chance de pegar atum.',
              style: TextStyle(fontSize: 11.5, color: corRot, height: 1.3),
            ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: valor == null
                    ? _semDado(corRot)
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: valor / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey.withValues(alpha: 0.15),
                              color: _corIndice(valor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(valor.round().toString(),
                                  style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: _corIndice(valor))),
                              Text('/ 100',
                                  style: TextStyle(fontSize: 12, color: corRot)),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            if (indice.classificacao != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _corIndice(valor!).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Potencial ${indice.classificacao!.label.toLowerCase()}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _corIndice(valor)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('FATORES CONSIDERADOS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: corRot)),
            const SizedBox(height: 8),
            ...indice.fatoresPontuados.map((f) => _linhaFator(corRot, f)),
            const SizedBox(height: 14),
            Text('INFORMATIVOS (NÃO ENTRAM NA PONTUAÇÃO)',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: corRot)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: indice.fatoresInformativos
                  .map((nome) => Chip(
                        label: Text(nome, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.grey.withValues(alpha: 0.12),
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _semDado(Color corRot) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, color: corRot, size: 32),
          const SizedBox(height: 8),
          Text('Dado indisponível',
              style: TextStyle(color: corRot, fontStyle: FontStyle.italic)),
        ],
      );

  // Nome do fator numa linha própria (alguns são longos, ex: "Fase lunar
  // (proximidade da sizígia)") e detalhe+pontuação embaixo, com o detalhe
  // dentro de um Expanded — sem isso, um detalhe comprido (ex: "Quarto
  // Minguante · dia 22 do ciclo") ao lado da pontuação num Row sem limite
  // estourava a largura do card (visto ao vivo no aparelho).
  Widget _linhaFator(Color corRot, FatorIndiceMare fator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fator.nome, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          if (fator.disponivel)
            Row(
              children: [
                Expanded(
                  child: Text(fator.detalhe ?? '',
                      style: TextStyle(fontSize: 11, color: corRot),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Text('${fator.pontuacao!.round()}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _corIndice(fator.pontuacao!))),
              ],
            )
          else
            Text('Dado indisponível',
                style: TextStyle(fontSize: 11, color: corRot, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Color _corIndice(double v) {
    if (v < 34) return Colors.blueGrey;
    if (v < 67) return Colors.amber.shade800;
    return Colors.orange.shade800;
  }
}
