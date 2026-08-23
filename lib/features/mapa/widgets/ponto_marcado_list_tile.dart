import 'package:flutter/material.dart';

import '../../../core/utils/coordenadas_format.dart';
import '../domain/models/ponto_marcado.dart';

/// Linha compacta de um ponto marcado, no mesmo estilo visual de
/// [RecomendacaoListTile] — usada em "Meus Pontos" pra que as duas listas
/// (pontos marcados e recomendações) leiam como uma coisa só, em vez de
/// telas com linguagem visual diferente.
class PontoMarcadoListTile extends StatelessWidget {
  final PontoMarcado ponto;
  final VoidCallback? onTap;

  const PontoMarcadoListTile({
    super.key,
    required this.ponto,
    this.onTap,
  });

  String _formatarData(DateTime d) {
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    final hora =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data $hora';
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mesmo acento lateral colorido da RecomendacaoListTile — verde
            // fixo aqui, já que um ponto marcado não tem uma faixa/score
            // pra colorir por ela.
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ponto.nome?.isNotEmpty == true
                        ? ponto.nome!
                        : 'Ponto marcado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        _formatarData(ponto.dataCriacao),
                        style:
                            TextStyle(fontSize: 12, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatarCoordenadasDMSCompacta(
                        ponto.latitude, ponto.longitude),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.push_pin, color: Colors.green, size: 20),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
