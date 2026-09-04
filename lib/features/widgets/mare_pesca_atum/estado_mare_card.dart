import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/fase_lua.dart';
import '../../../core/models/wave_forecast.dart';

/// Card principal da tela "Maré e Pesca de Atum" — estado atual da maré
/// astronômica (sizígia/quadratura/transição), fase da lua, amplitude
/// prevista pras próximas 24h e a barra QUADRATURA↔SIZÍGIA posicionada
/// pela fase lunar real (ver [pontuacaoProximidadeSizigia]).
///
/// Tudo aqui é DADO (fase da lua, horários de preamar/baixa-mar) ou
/// geometria pura (sizígia/quadratura) — nenhuma inferência sobre pesca
/// entra neste card, só no restante da tela.
class EstadoMareCard extends StatelessWidget {
  final FaseLua fase;
  final TipoMareAstronomica tipoMare;
  final List<MareEvento> eventos;

  /// Amplitude (m) entre a maior preamar e a menor baixa-mar previstas nas
  /// próximas 24h — `null` quando não há preamar e baixa-mar suficientes
  /// na janela (mostra "Dado indisponível", nunca um valor inventado).
  final double? amplitudeMareM;

  const EstadoMareCard({
    super.key,
    required this.fase,
    required this.tipoMare,
    required this.eventos,
    required this.amplitudeMareM,
  });

  Color get _corTipo => switch (tipoMare) {
        TipoMareAstronomica.sizigia => Colors.orange.shade800,
        TipoMareAstronomica.quadratura => Colors.blueGrey,
        TipoMareAstronomica.transicao => Colors.teal,
      };

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = Color.alphaBlend(
      const Color(0xFFE0F7FA).withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );

    final proximaPreamar =
        eventos.where((e) => e.tipo == TipoMare.alta).firstOrNull;
    final proximaBaixamar =
        eventos.where((e) => e.tipo == TipoMare.baixa).firstOrNull;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: corCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ESTADO ATUAL',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: corRot)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.water, color: _corTipo, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MARÉ DE ${tipoMare.label.toUpperCase()}',
                    style: TextStyle(
                        fontSize: 21, fontWeight: FontWeight.bold, color: _corTipo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(tipoMare.nota, style: TextStyle(fontSize: 12, color: corRot)),
            const SizedBox(height: 18),
            _barraQuadraturaSizigia(context),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _dado(
                  corRot,
                  label: 'FASE DA LUA',
                  valor: '${fase.tipo.emoji} ${fase.tipo.label}',
                  sub: 'dia ${fase.idadeDias.round()} do ciclo',
                ),
                _dado(
                  corRot,
                  label: 'AMPLITUDE PREVISTA (24H)',
                  valor: amplitudeMareM == null
                      ? null
                      : '${amplitudeMareM!.toStringAsFixed(2)} m',
                ),
                _dado(
                  corRot,
                  label: 'PRÓXIMA PREAMAR',
                  valor: proximaPreamar == null ? null : _hm(proximaPreamar.time),
                  sub: proximaPreamar == null
                      ? null
                      : '${proximaPreamar.alturaM.toStringAsFixed(2)} m',
                ),
                _dado(
                  corRot,
                  label: 'PRÓXIMA BAIXA-MAR',
                  valor: proximaBaixamar == null ? null : _hm(proximaBaixamar.time),
                  sub: proximaBaixamar == null
                      ? null
                      : '${proximaBaixamar.alturaM.toStringAsFixed(2)} m',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _dado(Color corRot,
      {required String label, required String? valor, String? sub}) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: corRot)),
          const SizedBox(height: 4),
          Text(
            valor ?? 'Dado indisponível',
            style: TextStyle(
                fontSize: valor == null ? 13 : 16,
                fontWeight: valor == null ? FontWeight.normal : FontWeight.bold,
                fontStyle: valor == null ? FontStyle.italic : FontStyle.normal,
                color: valor == null ? corRot : null),
          ),
          if (sub != null)
            Text(sub, style: TextStyle(fontSize: 11, color: corRot)),
        ],
      ),
    );
  }

  /// Barra QUADRATURA ── SIZÍGIA: a bolinha fica posicionada pela
  /// proximidade real da fase lunar de hoje a um ponto de sizígia (0 = bem
  /// na quadratura, 100 = bem na sizígia) — não é decorativa, é a mesma
  /// conta usada no Índice de Influência da Maré.
  Widget _barraQuadraturaSizigia(BuildContext context) {
    final corRot = corRotulo(context);
    final pontos = pontuacaoProximidadeSizigia(fase); // 0-100

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final largura = constraints.maxWidth;
          // Bolinha de 16px — mantém centro dentro dos limites da barra.
          final x = (pontos / 100) * (largura - 16);
          return SizedBox(
            height: 22,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(colors: [
                      Colors.blueGrey.withValues(alpha: 0.5),
                      Colors.orange.shade800.withValues(alpha: 0.7),
                    ]),
                  ),
                ),
                Positioned(
                  left: x.clamp(0, largura - 16),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _corTipo,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: _corTipo.withValues(alpha: 0.5),
                            blurRadius: 4)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('QUADRATURA',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: corRot)),
            Text('SIZÍGIA',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade800)),
          ],
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
