import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/planos/grupo_permissao.dart';
import '../../../core/planos/grupo_permissao_label.dart';
import '../../../core/planos/plano_atlas.dart';
import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../core/planos/recurso_atlas_label.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Tela "Planos" — mostra o plano ativo, o que ele libera (os mesmos
/// grupos/recursos usados pelos gates espalhados pelo app, ver
/// `RecursoProtegido`), a comparação dos quatro planos e um jeito de
/// contato comercial. Acessível a partir de Configurações.
///
/// Não vende nem cobra nada dentro do app (ver
/// `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`, regra 4 do pedido
/// original — política de assinatura digital das lojas) — o CTA só
/// direciona pra um canal externo.
class PlanosScreen extends StatelessWidget {
  const PlanosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planoTelaTitulo)),
      body: ValueListenableBuilder<PlanoAtlas>(
        valueListenable: PlanoService.planoAtual,
        builder: (context, planoAtivo, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CardPlanoAtual(plano: planoAtivo),
            const SizedBox(height: 12),
            _AvisoApoioNavegacao(l10n: l10n),
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              _SeletorPlanoDebug(planoAtivo: planoAtivo, l10n: l10n),
            ],
            const SizedBox(height: 24),
            Text(l10n.planoRecursosLiberados,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._buildGruposERecursos(l10n),
            const SizedBox(height: 24),
            Text(l10n.planoCompararPlanos,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            for (final plano in PlanoAtlas.values)
              _CardComparativoPlano(plano: plano, ativo: plano == planoAtivo),
            const SizedBox(height: 24),
            _BotaoFalarComBlueOcean(l10n: l10n),
          ],
        ),
      ),
    );
  }

  /// Um card por grupo — dentro dele, os recursos específicos que
  /// pertencem àquele grupo (ver `RecursoAtlas.grupo`). Grupos sem nenhum
  /// recurso específico mapeado (ex: navegação essencial, cartas) só
  /// mostram o cabeçalho do grupo com o estado de liberado/bloqueado.
  List<Widget> _buildGruposERecursos(AppLocalizations l10n) {
    return [
      for (final grupo in GrupoPermissao.values)
        if (grupo != GrupoPermissao.frota) // sem superfície no mobile
          _CardGrupo(
            grupo: grupo,
            recursos: RecursoAtlas.values.where((r) => r.grupo == grupo).toList(),
            l10n: l10n,
          ),
    ];
  }
}

class _CardPlanoAtual extends StatelessWidget {
  final PlanoAtlas plano;
  const _CardPlanoAtual({required this.plano});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.blue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.planoSeuPlanoAtual,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  Text(plano.nomeComercial,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(plano.descricaoCurta, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoApoioNavegacao extends StatelessWidget {
  final AppLocalizations l10n;
  const _AvisoApoioNavegacao({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.planoAvisoApoioNavegacao,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

/// Só existe em modo debug (`kDebugMode`) — troca o plano ativo direto
/// (`PlanoService.definirPlano`), sem passar por cobrança/backend nenhum,
/// pra testar/demonstrar os gates de cada plano. Nunca aparece em build
/// de release.
class _SeletorPlanoDebug extends StatelessWidget {
  final PlanoAtlas planoAtivo;
  final AppLocalizations l10n;
  const _SeletorPlanoDebug({required this.planoAtivo, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report_outlined, size: 18, color: Colors.brown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.planoSeletorDebugTitulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.planoSeletorDebugSubtitulo,
                style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final plano in PlanoAtlas.values)
                  ChoiceChip(
                    label: Text(plano.nomeComercial),
                    selected: plano == planoAtivo,
                    onSelected: (_) => PlanoService.definirPlano(plano),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardGrupo extends StatelessWidget {
  final GrupoPermissao grupo;
  final List<RecursoAtlas> recursos;
  final AppLocalizations l10n;
  const _CardGrupo({required this.grupo, required this.recursos, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final grupoLiberado = PlanoService.possuiGrupo(grupo);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            leading: Icon(
              grupoLiberado ? Icons.check_circle : Icons.lock_outline,
              color: grupoLiberado ? Colors.green : Colors.grey,
            ),
            title: Text(grupo.rotulo(l10n),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final recurso in recursos)
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 16, bottom: 6),
              child: Row(
                children: [
                  Icon(
                    PlanoService.possui(recurso) ? Icons.check : Icons.lock_outline,
                    size: 16,
                    color: PlanoService.possui(recurso) ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(recurso.rotulo(l10n), style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          if (recursos.isNotEmpty) const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _CardComparativoPlano extends StatelessWidget {
  final PlanoAtlas plano;
  final bool ativo;
  const _CardComparativoPlano({required this.plano, required this.ativo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preco = plano == PlanoAtlas.fleet
        ? l10n.planoSobConsulta
        : 'R\$ ${plano.precoReferencia.toStringAsFixed(2).replaceAll('.', ',')}'
            '${l10n.planoPorMes}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: ativo ? const BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        title: Text(plano.nomeComercial,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(plano.descricaoCurta, style: const TextStyle(fontSize: 12)),
        trailing: Text(preco, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _BotaoFalarComBlueOcean extends StatelessWidget {
  final AppLocalizations l10n;
  const _BotaoFalarComBlueOcean({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.chat_outlined),
        label: Text(l10n.planoFalarComBlueOcean),
        onPressed: () {
          // Sem canal comercial (WhatsApp/e-mail) confirmado ainda —
          // fica só o aviso, pra não fabricar um contato que não existe
          // de verdade. Trocar por url_launcher assim que houver um
          // número/e-mail real (ver docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md §6.1).
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.planoFalarComBlueOceanEmBreve)),
          );
        },
      ),
    );
  }
}
