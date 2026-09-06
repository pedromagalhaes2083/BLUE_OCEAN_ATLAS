import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Escala contínua de clorofila-a (mg/m³) — azul-esverdeado escuro (baixa
/// produtividade) → verde → amarelo-esverdeado (alta), a paleta mais comum
/// pra Ocean Colour (ex: a própria Copernicus/NASA usam variações disso) e
/// deliberadamente diferente da paleta verde→laranja da grade de
/// temperatura (ver `legenda_grade_temperatura.dart`), pra nunca serem
/// confundidas quando as duas estiverem ativas ao mesmo tempo.
///
/// Escala fixa (não normalizada pelo min/max da consulta, diferente da
/// grade de temperatura): concentração de clorofila tem faixas
/// biologicamente estabelecidas (águas oligotróficas vs. eutróficas), então
/// uma escala fixa deixa comparável entre consultas diferentes — normalizar
/// pelo min/max de cada bbox faria uma mancha de 0.3 mg/m³ parecer "alta"
/// só porque o resto da área consultada tinha menos ainda.
const _clorofilaMinMgM3 = 0.0;
const _clorofilaMaxMgM3 = 10.0;

Color corClorofila(double valorMgM3) {
  final t = (valorMgM3 / (_clorofilaMaxMgM3 - _clorofilaMinMgM3)).clamp(0.0, 1.0);
  if (t < 0.5) {
    return Color.lerp(const Color(0xFF0D2B45), const Color(0xFF1E8F6E), t * 2)!;
  }
  return Color.lerp(const Color(0xFF1E8F6E), const Color(0xFFE8E04A), (t - 0.5) * 2)!;
}

/// Card com a legenda da camada de Clorofila-a — escala de cor, unidade,
/// data do dado utilizado e fonte (Copernicus Marine). A spec pede
/// explicitamente pra nunca a legenda sugerir que a cor representa
/// quantidade de peixe — por isso só fala de "produtividade", nunca de
/// biomassa/pesca.
class LegendaClorofila extends StatelessWidget {
  final DateTime? dataDoDado;

  const LegendaClorofila({super.key, this.dataDoDado});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 56,
      left: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CLOROFILA-a',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Baixa',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                  const SizedBox(width: 6),
                  Container(
                    width: 90,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: List.generate(
                          5,
                          (i) => corClorofila(
                              i / 4 * (_clorofilaMaxMgM3 - _clorofilaMinMgM3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Alta',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Clorofila-a (mg/m³)',
                  style: TextStyle(color: Colors.white70, fontSize: 10)),
              // Produtividade biológica, nunca "quantidade de peixe" — ver
              // doc da classe.
              const Text('Indicador de produtividade oceânica',
                  style: TextStyle(color: Colors.white54, fontSize: 9)),
              if (dataDoDado != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Dados de ${DateFormat('dd/MM/yyyy').format(dataDoDado!)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
              const Text('Fonte: Copernicus Marine',
                  style: TextStyle(color: Colors.white54, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}
