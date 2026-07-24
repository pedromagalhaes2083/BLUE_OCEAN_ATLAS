import 'package:flutter/material.dart';
import 'base_meteorology_card.dart';
import '../metereologia/domain/models/leitura_profundidade.dart';

/// Card com a profundidade (batimetria GEBCO2020) num ponto. Se o ponto
/// estiver em terra, mostra um aviso em vez de um valor de profundidade.
/// Uso: ProfundidadeCard(leitura: leitura)
class ProfundidadeCard extends BaseMeteorologyCard {
  final LeituraProfundidade leitura;

  const ProfundidadeCard({super.key, required this.leitura})
      : super(
          cardColor: const Color(0xFFE8EAF6),
          borderRadius: 24,
        );

  @override
  bool get isLoading => false;

  @override
  String get loadingMessage => 'Carregando profundidade...';

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.water,
          title: 'Profundidade',
          color: Colors.indigo,
        ),
        const SizedBox(height: 24),
        if (leitura.emAgua) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                leitura.profundidadeMetros.toStringAsFixed(0),
                style:
                    const TextStyle(fontSize: 62, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10, left: 4),
                child: Text('m', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ] else ...[
          const Icon(Icons.terrain, size: 48, color: Colors.brown),
          const SizedBox(height: 8),
          const Text(
            'Ponto em terra — sem profundidade',
            style: TextStyle(color: Colors.brown),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '${leitura.latitude.toStringAsFixed(2)}°, ${leitura.longitude.toStringAsFixed(2)}°',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
