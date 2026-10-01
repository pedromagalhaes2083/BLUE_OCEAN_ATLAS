import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import 'package:atlas/l10n/gen/app_localizations.dart';
import '../../../core/utils/cor_tema.dart';

/// Card com a salinidade de superfície — mapa global RFROM v2.3 da
/// NOAA/PMEL, derivado de bóias Argo (ver `RfromOceanRepository`). Mostra
/// um aviso de "sem cobertura" quando o ponto está fora do alcance das
/// bóias (comum perto da costa — ver doc de `RfromOceanRepository`),
/// nunca um valor inventado.
/// Uso: SalinidadeCard(salinidadeUps: perfil.salinidadeSuperficieUps)
class SalinidadeCard extends BaseMeteorologyCard {
  final double? salinidadeUps;

  const SalinidadeCard({super.key, required this.salinidadeUps})
      : super(
          cardColor: const Color(0xFFE0F2F1),
          borderRadius: 24,
        );

  @override
  bool get isLoading => false;

  @override
  String get loadingMessage => 'Carregando salinidade...';

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.water_drop_outlined,
          title: AppLocalizations.of(context).salinidadeTitulo,
          color: Colors.teal,
        ),
        const SizedBox(height: 24),
        if (salinidadeUps != null) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  salinidadeUps!.toStringAsFixed(1),
                  style:
                      const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 4),
                  child: Text('PSU', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ] else ...[
          const Icon(Icons.satellite_alt_outlined, size: 36, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).salinidadeSemCobertura,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).salinidadeSuperficieDoMar,
          style: TextStyle(color: corRotulo(context), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
