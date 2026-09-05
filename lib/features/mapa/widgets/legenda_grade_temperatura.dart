import 'package:flutter/material.dart';

/// Verde (mais fria) → amarelo → laranja (mais quente), normalizado pelo
/// mínimo/máximo encontrados na própria grade de temperatura da superfície
/// do mar — não uma escala fixa, pra sempre aproveitar a variação real do
/// trecho de mar consultado (ver `MapaWidgetState._buildCamadaGradeTemperatura`,
/// que usa essa mesma função pra colorir cada célula da grade).
Color corGradeTemperatura(double temperatura, double min, double max) {
  if (max <= min) return Colors.orange;
  final t = ((temperatura - min) / (max - min)).clamp(0.0, 1.0);
  return t < 0.5
      ? Color.lerp(Colors.green, Colors.yellow, t * 2)!
      : Color.lerp(Colors.yellow, Colors.deepOrange, (t - 0.5) * 2)!;
}

/// Barra compacta com a escala de cores da grade de temperatura (mín. →
/// máx.), sobreposta ao canto superior direito do mapa — sem ela, os
/// números espremidos nas células (ou escondidos, em zoom baixo) não dão
/// pra entender a variação de temperatura sozinhos.
///
/// Extraída de `mapa_widget.dart` (ver auditoria BOA-010 — arquivo grande
/// demais, concentrando responsabilidades que não precisam do estado do
/// mapa) — widget puro, só depende dos dois números que já vêm prontos de
/// [MapaWidgetState._gradeTemperaturaMinMax].
class LegendaGradeTemperatura extends StatelessWidget {
  final double min;
  final double max;

  const LegendaGradeTemperatura({
    super.key,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 56,
      right: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('SST',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: 90,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: [
                    Colors.green,
                    Colors.yellow,
                    Colors.deepOrange,
                  ]),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${min.toStringAsFixed(0)}°',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                  const SizedBox(width: 74),
                  Text('${max.toStringAsFixed(0)}°',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
