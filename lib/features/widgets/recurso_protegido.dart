import 'package:flutter/material.dart';

import '../../core/planos/matriz_entitlements.dart';
import '../../core/planos/plano_service.dart';
import '../../core/planos/recurso_atlas.dart';
import '../../core/planos/recurso_atlas_label.dart';
import '../../l10n/gen/app_localizations.dart';

/// Gate genérico de plano — mostra [child] se o plano ativo tiver
/// [recurso] liberado (`PlanoService.possui`), senão mostra [fallback]
/// (por padrão, um card de upgrade — [CardUpgradePlano]).
///
/// Hoje ([matrizRecursos] libera tudo pra todos os planos, ver
/// `core/planos/matriz_entitlements.dart`) isso sempre mostra [child] — o
/// gate já está aplicado nos pontos certos, só esperando a matriz real
/// ser fechada pra passar a bloquear de verdade.
class RecursoProtegido extends StatelessWidget {
  final RecursoAtlas recurso;
  final Widget child;
  final Widget? fallback;

  const RecursoProtegido({
    super.key,
    required this.recurso,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (PlanoService.possui(recurso)) return child;
    return fallback ?? CardUpgradePlano(recurso: recurso);
  }
}

/// Card mostrado no lugar de um recurso não liberado pelo plano atual —
/// nunca um erro, sempre um convite claro: qual recurso é, qual plano
/// libera, e um botão pra saber mais (ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`
/// regra 3/6.1 — sem cobrança nem "compra" dentro do app, só direciona pra
/// tela Planos).
class CardUpgradePlano extends StatelessWidget {
  final RecursoAtlas recurso;
  final EdgeInsetsGeometry padding;

  const CardUpgradePlano({
    super.key,
    required this.recurso,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final planoMinimo = planoMinimoPara(recurso);
    final nomePlano = planoMinimo?.nomeComercial ?? '';
    return Card(
      color: Colors.blueGrey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blueGrey[100]!),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recurso.rotulo(l10n),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.planoRecursoBloqueadoDescricao(nomePlano),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _abrirTelaPlanos(context),
              child: Text(l10n.planoConhecerPlanos),
            ),
          ],
        ),
      ),
    );
  }

  /// Versão centralizada do mesmo card — pra telas inteiras gateadas por
  /// um único recurso (ex: `AlertaConfigScreen`, `AnaliseRotaScreen`): usar
  /// como corpo de um `Scaffold` que já tem `AppBar` própria, a tela
  /// continua com o título certo mesmo bloqueada.
  static Widget telaCheia(BuildContext context, RecursoAtlas recurso) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CardUpgradePlano(recurso: recurso),
      ),
    );
  }

  void _abrirTelaPlanos(BuildContext context) {
    // A tela "Planos" ainda não existe (ver plano de implementação da
    // Fase 2, item 2.4) — quando existir, troca por
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanosScreen())).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).planoConhecerPlanos)),
    );
  }
}
