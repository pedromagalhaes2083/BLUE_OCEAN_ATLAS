import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../cartas/presentation/solicitar_cartas_screen.dart';
import '../../intelligence/presentation/intelligence_screen.dart';
import '../../metereologia/presentation/condicoes_ponto_screen.dart';
import '../../metereologia/presentation/mare_pesca_atum_screen.dart';
import '../../producao/domain/services/producao_pontos_analyzer.dart';
import '../../termoclina/presentation/termoclina_screen.dart';
import '../../widgets/grade_acoes_ponto.dart';
import '../domain/models/ponto_marcado.dart';
import 'dados_oceanicos_ponto.dart';

/// Conteúdo de detalhe de um ponto marcado — usado tanto por
/// `MeusPontosScreen` (lista) quanto por `MapaWidget` (toque num marcador
/// no mapa), pra as duas telas mostrarem o mesmo padrão de informações e
/// as mesmas ações em vez de cada uma ter o seu próprio layout. Sempre
/// aberto dentro de [abrirCardFlutuantePonto].
class DetalhePontoMarcado extends StatelessWidget {
  final PontoMarcado ponto;
  final double? distanciaNm;
  final double? rumoGraus;
  final ProducaoPorPonto? producao;
  final String Function(DateTime) formatarDataHora;
  final VoidCallback onRemovido;

  const DetalhePontoMarcado({
    super.key,
    required this.ponto,
    required this.distanciaNm,
    required this.rumoGraus,
    required this.producao,
    required this.formatarDataHora,
    required this.onRemovido,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.push_pin, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ponto.nome?.isNotEmpty == true
                    ? ponto.nome!
                    : l10n.mapaPontoMarcadoTitulo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LinhaInfoPonto(
          icon: Icons.explore_outlined,
          label: l10n.mapaLabelCoordenadas,
          valor: formatarCoordenadasDMS(ponto.latitude, ponto.longitude),
        ),
        const Divider(height: 20),
        LinhaInfoPonto(
          icon: Icons.event_outlined,
          label: l10n.meusPontosMarcadoEm,
          valor: formatarDataHora(ponto.dataCriacao),
        ),
        if (distanciaNm != null && rumoGraus != null) ...[
          const Divider(height: 20),
          LinhaInfoPonto(
            icon: Icons.social_distance_outlined,
            label: l10n.mapaLabelDistancia,
            valor: '${distanciaNm!.toStringAsFixed(1)} mn',
          ),
          const SizedBox(height: 8),
          LinhaInfoPonto(
            icon: Icons.navigation_outlined,
            label: l10n.mapaLabelRumo,
            valor: '${rumoGraus!.toStringAsFixed(0)}°',
          ),
        ],
        if (producao != null) ...[
          const Divider(height: 20),
          LinhaInfoPonto(
            icon: Icons.set_meal_outlined,
            label: l10n.meusPontosProducaoAqui,
            valor: l10n.meusPontosProducaoAquiValor(
                producao!.totalKg.toStringAsFixed(1), producao!.totalRegistros),
          ),
        ],
        const Divider(height: 20),
        DadosOceanicosPonto(latitude: ponto.latitude, longitude: ponto.longitude),
        const SizedBox(height: 16),
        GradeAcoesPonto(acoes: [
          AcaoPonto(
            icon: Icons.map_outlined,
            label: l10n.drawerSolicitarCarta,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SolicitarCartaScreen(
                    dbHelper: DatabaseHelper.instance,
                    latitudeInicial: ponto.latitude,
                    longitudeInicial: ponto.longitude,
                  ),
                ),
              );
            },
          ),
          AcaoPonto(
            icon: Icons.water_outlined,
            label: l10n.meusPontosConsultarAqui,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CondicoesPontoScreen(
                    latitude: ponto.latitude,
                    longitude: ponto.longitude,
                    nome: ponto.nome,
                  ),
                ),
              );
            },
          ),
          AcaoPonto(
            icon: Icons.phishing,
            label: l10n.meusPontosMareEPescaAqui,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MareEPescaAtumScreen(
                    latitude: ponto.latitude,
                    longitude: ponto.longitude,
                    nomePonto: ponto.nome,
                  ),
                ),
              );
            },
          ),
          AcaoPonto(
            icon: Icons.thermostat_outlined,
            label: l10n.termoclinaTelaTitulo,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TermoclinaScreen(
                    latitude: ponto.latitude,
                    longitude: ponto.longitude,
                    nomePonto: ponto.nome,
                  ),
                ),
              );
            },
          ),
          AcaoPonto(
            icon: Icons.auto_awesome_outlined,
            label: l10n.intelligenceTelaTitulo,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IntelligenceScreen(
                    latitude: ponto.latitude,
                    longitude: ponto.longitude,
                    nomePonto: ponto.nome,
                  ),
                ),
              );
            },
          ),
          AcaoPonto(
            icon: Icons.delete_outline,
            label: l10n.remover,
            cor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              onRemovido();
            },
          ),
        ]),
      ],
    );
  }
}

/// Mesmo chrome do card flutuante da aba "Recomendações"/"Meus Pontos"
/// (Dialog arredondado, largura máxima, X no canto) — usado por
/// `MeusPontosScreen` e `MapaWidget`, pra abrir o detalhe de um ponto
/// (ou de uma recomendação) sempre do mesmo jeito, não importa de onde
/// veio o toque.
void abrirCardFlutuantePonto(BuildContext context, Widget conteudo) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 44, 20),
              child: conteudo,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
