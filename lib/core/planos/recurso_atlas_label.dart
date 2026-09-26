import '../../l10n/gen/app_localizations.dart';
import 'recurso_atlas.dart';

/// Rótulo traduzido de cada [RecursoAtlas] — separado do enum em si
/// (`recurso_atlas.dart` não depende de `l10n`, mantém o domínio puro).
extension RecursoAtlasLabel on RecursoAtlas {
  String rotulo(AppLocalizations l10n) => switch (this) {
        RecursoAtlas.mapaSst => l10n.planoRecursoMapaSst,
        RecursoAtlas.oceanografiaCorrentes => l10n.planoRecursoOceanografiaCorrentes,
        RecursoAtlas.oceanografiaAlertasAvancados =>
          l10n.planoRecursoOceanografiaAlertasAvancados,
        RecursoAtlas.oceanografiaConfigurarAlertas =>
          l10n.planoRecursoOceanografiaConfigurarAlertas,
        RecursoAtlas.mapaClorofila => l10n.planoRecursoMapaClorofila,
        RecursoAtlas.mapaIndiceProdutividade => l10n.planoRecursoMapaIndiceProdutividade,
        RecursoAtlas.oceanografiaMareEPescaAtum =>
          l10n.planoRecursoOceanografiaMareEPescaAtum,
        RecursoAtlas.oceanografiaTermoclina => l10n.planoRecursoOceanografiaTermoclina,
        RecursoAtlas.rotasAnaliseRota => l10n.planoRecursoRotasAnaliseRota,
        RecursoAtlas.recomendacaoScoreEConfianca =>
          l10n.planoRecursoRecomendacaoScoreEConfianca,
        RecursoAtlas.mapaTrilhaViagem => l10n.planoRecursoMapaTrilhaViagem,
        RecursoAtlas.producaoHistorico => l10n.planoRecursoProducaoHistorico,
        RecursoAtlas.producaoPorPonto => l10n.planoRecursoProducaoPorPonto,
        RecursoAtlas.rotasHistorico => l10n.planoRecursoRotasHistorico,
        RecursoAtlas.rotasInteligente => l10n.planoRecursoRotasInteligente,
        RecursoAtlas.viagemTripulacao => l10n.planoRecursoViagemTripulacao,
      };
}
