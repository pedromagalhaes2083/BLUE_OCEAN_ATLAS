import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/fase_lua.dart';
import '../../metereologia/domain/models/dia_lunar.dart';

/// Card de fase da lua — fase atual (calculada localmente, sem rede, ver
/// [calcularFaseLua]) + nascer/pôr de hoje (vem da rede, pode ainda não
/// ter chegado) + as próximas 4 fases principais.
///
/// [diaHoje] é opcional de propósito: a fase em si não depende de rede
/// nem de posição, então o card já mostra algo útil mesmo sem GPS/sinal —
/// só o nascer/pôr fica em branco até a Open-Meteo responder.
/// Uso: FaseLuaCard(faseAtual: calcularFaseLua(), diaHoje: diaHoje, proximasFases: proximasFasesPrincipais())
class FaseLuaCard extends StatelessWidget {
  final FaseLua faseAtual;
  final DiaLunar? diaHoje;
  final List<ProximaFaseLua> proximasFases;
  final VoidCallback? onTap;

  const FaseLuaCard({
    super.key,
    required this.faseAtual,
    this.diaHoje,
    this.proximasFases = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = Color.alphaBlend(
      const Color(0xFFEDE7F6).withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: corCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.nightlight_round,
                      color: Colors.deepPurple, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Lua',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  if (onTap != null) ...[
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        size: 18, color: corRotulo(context)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(faseAtual.tipo.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faseAtual.tipo.label,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${(faseAtual.fracaoIluminada * 100).round()}% iluminada'
                          ' · dia ${faseAtual.idadeDias.floor() + 1} do ciclo',
                          style:
                              TextStyle(fontSize: 12, color: corRotulo(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (diaHoje?.nascer != null || diaHoje?.poesta != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (diaHoje?.nascer != null)
                      Expanded(
                        child: _HorarioLua(
                          icone: Icons.arrow_upward,
                          rotulo: 'Nascer',
                          horario: diaHoje!.nascer!,
                        ),
                      ),
                    if (diaHoje?.poesta != null)
                      Expanded(
                        child: _HorarioLua(
                          icone: Icons.arrow_downward,
                          rotulo: 'Pôr',
                          horario: diaHoje!.poesta!,
                        ),
                      ),
                  ],
                ),
              ],
              if (proximasFases.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('PRÓXIMAS FASES',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: corRotulo(context))),
                const SizedBox(height: 8),
                SizedBox(
                  // 78 estourava pra rótulos de 2 linhas ("Quarto
                  // Minguante", "Gibosa Crescente" etc.) — mais largos
                  // que os da maré ("Preamar"/"Baixa-mar"), que é de onde
                  // essa altura tinha sido copiada.
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: proximasFases.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) =>
                        _ProximaFaseChip(proxima: proximasFases[i]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HorarioLua extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final DateTime horario;

  const _HorarioLua({
    required this.icone,
    required this.rotulo,
    required this.horario,
  });

  @override
  Widget build(BuildContext context) {
    final h = horario.hour.toString().padLeft(2, '0');
    final m = horario.minute.toString().padLeft(2, '0');
    return Row(
      children: [
        Icon(icone, size: 16, color: Colors.deepPurple.shade300),
        const SizedBox(width: 6),
        Text('$rotulo $h:$m',
            style: TextStyle(fontSize: 13, color: corRotulo(context))),
      ],
    );
  }
}

class _ProximaFaseChip extends StatelessWidget {
  final ProximaFaseLua proxima;

  const _ProximaFaseChip({required this.proxima});

  @override
  Widget build(BuildContext context) {
    final dias = proxima.instante.difference(DateTime.now()).inHours / 24;
    final d = proxima.instante.day.toString().padLeft(2, '0');
    final mes = proxima.instante.month.toString().padLeft(2, '0');

    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(proxima.tipo.emoji, style: const TextStyle(fontSize: 18)),
          Text(
            proxima.tipo.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.1,
                color: Colors.deepPurple),
          ),
          Text('$d/$mes',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, height: 1)),
          Text(
            dias < 1 ? 'hoje' : 'em ${dias.round()}d',
            style: TextStyle(fontSize: 10, color: corRotulo(context)),
          ),
        ],
      ),
    );
  }
}
