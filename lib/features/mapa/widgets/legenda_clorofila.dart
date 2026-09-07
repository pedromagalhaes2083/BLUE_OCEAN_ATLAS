import 'package:flutter/material.dart';

/// Limiares da escala de classificação de clorofila-a — calibrados pro
/// litoral cearense (ver conversa de 2026-09): abaixo de [clorofilaMinimo]
/// é água pobre em nutrientes (oligotrófica), acima de [clorofilaOtimo] já é
/// excelente. O ponto médio entre os dois marca a fronteira bom/ótimo — os
/// dois únicos limiares que vieram do usuário, o do meio é interpolado.
const clorofilaMinimo = 0.094;
const clorofilaOtimo = 0.22;
const _clorofilaBomOtimo =
    clorofilaMinimo + (clorofilaOtimo - clorofilaMinimo) / 2;
// Mesmo espaçamento do meio (bom→ótimo) aplicado depois do ótimo, só pra
// saber onde a cor "excelente" já está 100% saturada — não é mais um
// limiar de classificação (tudo acima de [clorofilaOtimo] já é excelente).
const _clorofilaExcelenteSaturado =
    clorofilaOtimo + (clorofilaOtimo - clorofilaMinimo) / 2;

/// As 4 faixas da escala — da água mais pobre (ruim) à mais produtiva
/// (excelente). Nunca tratar como "quantidade de peixe": é só um indicador
/// de produtividade biológica (ver doc de `LeituraClorofilaPonto`).
enum NivelClorofila { ruim, bom, otimo, excelente }

extension NivelClorofilaLabel on NivelClorofila {
  String get rotulo => switch (this) {
        NivelClorofila.ruim => 'Ruim',
        NivelClorofila.bom => 'Bom',
        NivelClorofila.otimo => 'Ótimo',
        NivelClorofila.excelente => 'Excelente',
      };
}

NivelClorofila nivelClorofila(double valorMgM3) {
  if (valorMgM3 < clorofilaMinimo) return NivelClorofila.ruim;
  if (valorMgM3 < _clorofilaBomOtimo) return NivelClorofila.bom;
  if (valorMgM3 <= clorofilaOtimo) return NivelClorofila.otimo;
  return NivelClorofila.excelente;
}

/// Cor representativa de cada faixa — mesma paleta usada no degradê
/// contínuo de [corClorofila], só que sólida (pra badge/ícone).
Color corNivelClorofila(NivelClorofila nivel) => switch (nivel) {
      NivelClorofila.ruim => Colors.blue,
      NivelClorofila.bom => Colors.green,
      NivelClorofila.otimo => Colors.yellow,
      NivelClorofila.excelente => Colors.red,
    };

/// Degradê contínuo azul → verde → amarelo → vermelho, no mesmo estilo da
/// escala de temperatura (`corGradeTemperatura`), mas calibrado pelos
/// limiares de classificação em vez de normalizado pelo mín./máx. da
/// consulta — clorofila tem faixas biologicamente estabelecidas, então uma
/// escala fixa deixa comparável entre consultas diferentes.
Color corClorofila(double valorMgM3) {
  if (valorMgM3 <= clorofilaMinimo) return Colors.blue;
  if (valorMgM3 <= _clorofilaBomOtimo) {
    final t = (valorMgM3 - clorofilaMinimo) /
        (_clorofilaBomOtimo - clorofilaMinimo);
    return Color.lerp(Colors.blue, Colors.green, t)!;
  }
  if (valorMgM3 <= clorofilaOtimo) {
    final t = (valorMgM3 - _clorofilaBomOtimo) /
        (clorofilaOtimo - _clorofilaBomOtimo);
    return Color.lerp(Colors.green, Colors.yellow, t)!;
  }
  if (valorMgM3 <= _clorofilaExcelenteSaturado) {
    final t = (valorMgM3 - clorofilaOtimo) /
        (_clorofilaExcelenteSaturado - clorofilaOtimo);
    return Color.lerp(Colors.yellow, Colors.red, t)!;
  }
  return Colors.red;
}
