import 'package:flutter/material.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../mapa/presentation/mapa_screen.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_confianca_dots.dart';
import 'recomendacao_pontos_list.dart';
import 'recomendacao_score_badge.dart';
import 'recomendacao_validade_chip.dart';

/// Card de detalhe de uma recomendação: título, score, confiança, data de
/// recebimento, coordenada e os pontos amostrados com suas variáveis.
class RecomendacaoCard extends StatelessWidget {
  final Recomendacao recomendacao;

  const RecomendacaoCard({super.key, required this.recomendacao});

  String _formatarData(DateTime d) {
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final hora =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data $hora';
  }

  @override
  Widget build(BuildContext context) {
    final r = recomendacao;

    // Sem Card/elevação própria — o conteúdo já vive dentro do bottom
    // sheet em CartasScreen, que fornece o fundo e o cantinho arredondado;
    // duplicar isso aqui é o que fazia a folha parecer "card dentro de
    // card".
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecomendacaoScoreBadge(score: r.score),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.titulo.isEmpty ? '(sem título)' : r.titulo,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  RecomendacaoConfiancaDots(confianca: r.confianca),
                ],
              ),
            ),
          ],
        ),
        if (r.descricao != null && r.descricao!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            r.descricao!,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
        const SizedBox(height: 14),

        // Data de recebimento e coordenada
        Row(
          children: [
            if (r.criadoEm != null) ...[
              const Icon(Icons.schedule, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _formatarData(r.criadoEm!),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (r.criadoEm != null && r.centroide != null)
              const SizedBox(width: 12),
            if (r.centroide != null) ...[
              const Icon(Icons.place, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                formatarCoordenadasDMSCompacta(
                  r.centroide!.latitude,
                  r.centroide!.longitude,
                ),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),

        if (r.temCoordenadas) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapaScreen(recomendacao: r),
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Ver na Carta'),
            ),
          ),
        ],

        if (r.estimativaCapturaKg != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.set_meal, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 5),
              Text(
                '${r.estimativaCapturaKg} kg estimados',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],

        if (r.validoAte != null) ...[
          const SizedBox(height: 10),
          RecomendacaoValidadeChip(validoAte: r.validoAte),
        ],

        if (r.pontos != null && r.pontos!.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Divider(height: 24),
          Text(
            '${r.pontos!.length} pontos amostrados',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          RecomendacaoPontosList(
            pontos: r.pontos!,
            dataRecebimento: r.criadoEm,
          ),
        ],
      ],
    );
  }
}
