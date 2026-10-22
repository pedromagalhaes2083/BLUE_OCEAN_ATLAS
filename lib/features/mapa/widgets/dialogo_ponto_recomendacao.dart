import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../cartas/presentation/solicitar_cartas_screen.dart';
import '../../metereologia/presentation/condicoes_ponto_screen.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../../recomendacao/widgets/recomendacao_variavel_chip.dart';
import '../../termoclina/presentation/termoclina_screen.dart';
import 'dados_oceanicos_ponto.dart';
import 'dialogo_info_mapa.dart';

/// Mesmo padrão do detalhe de um ponto marcado — coordenadas, quando o dado
/// foi recebido, distância/rumo a partir do GPS atual ([distanciaNm] e
/// [rumoGraus], nulos sem GPS) — trocando o "nome"/"remover" (não fazem
/// sentido pra um ponto que veio pronto da API) pelas variáveis ambientais
/// amostradas ali (vento, corrente, temperatura etc.).
void mostrarDetalhePontoRecomendacao(
  BuildContext context, {
  required PontoRecomendacao ponto,
  required DatabaseHelper dbHelper,
  DateTime? criadoEm,
  double? distanciaNm,
  double? rumoGraus,
}) {
  final l10n = AppLocalizations.of(context);

  void abrir(BuildContext dialogo, Widget tela) {
    Navigator.pop(dialogo);
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
  }

  mostrarDialogoInfoMapa(
    context,
    icone: Icons.location_on,
    titulo: l10n.mapaPontoRecomendacaoTitulo,
    conteudo: [
      LinhaInfoPonto(
        icon: Icons.explore_outlined,
        label: l10n.mapaLabelCoordenadas,
        valor: formatarCoordenadasDMS(ponto.latitude, ponto.longitude),
      ),
      if (criadoEm != null) ...[
        const Divider(height: 20),
        LinhaInfoPonto(
          icon: Icons.event_outlined,
          label: l10n.mapaLabelRecebidoEm,
          valor: formatarDataHoraPonto(criadoEm),
        ),
      ],
      if (distanciaNm != null && rumoGraus != null) ...[
        const Divider(height: 20),
        LinhaInfoPonto(
          icon: Icons.social_distance_outlined,
          label: l10n.mapaLabelDistancia,
          valor: '${distanciaNm.toStringAsFixed(1)} mn',
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.navigation_outlined,
          label: l10n.mapaLabelRumo,
          valor: '${rumoGraus.toStringAsFixed(0)}°',
        ),
      ],
      const Divider(height: 20),
      DadosOceanicosPonto(
        latitude: ponto.latitude,
        longitude: ponto.longitude,
      ),
      if (ponto.variaveis.isNotEmpty) ...[
        const Divider(height: 20),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ponto.variaveis
              .map((v) => RecomendacaoVariavelChip(variavel: v))
              .toList(),
        ),
      ],
    ],
    acoesExtras: (dialogo) => [
      TextButton(
        onPressed: () => abrir(
          dialogo,
          SolicitarCartaScreen(
            dbHelper: dbHelper,
            latitudeInicial: ponto.latitude,
            longitudeInicial: ponto.longitude,
          ),
        ),
        child: Text(l10n.drawerSolicitarCarta),
      ),
      TextButton(
        onPressed: () => abrir(
          dialogo,
          CondicoesPontoScreen(
            latitude: ponto.latitude,
            longitude: ponto.longitude,
          ),
        ),
        child: Text(l10n.mapaConsultarAqui),
      ),
      TextButton(
        onPressed: () => abrir(
          dialogo,
          TermoclinaScreen(
            latitude: ponto.latitude,
            longitude: ponto.longitude,
          ),
        ),
        child: Text(l10n.termoclinaTelaTitulo),
      ),
    ],
  );
}
