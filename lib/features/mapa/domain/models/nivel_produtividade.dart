import 'package:flutter/material.dart';

/// Escala genérica de 4 faixas usada por qualquer indicador de
/// produtividade pesqueira do mapa — clorofila-a isolada (ver
/// [nivelClorofila]) e o índice combinado (ver
/// `IndiceProdutividadeBlueOcean`) usam a mesma escala e cor, pra nunca
/// confundir o mestre com paletas diferentes pra conceitos parecidos.
///
/// Nunca tratar como "quantidade de peixe": é sempre um indicador indireto
/// de produtividade biológica/ambiental, nunca uma garantia de cardume.
enum NivelProdutividade { ruim, bom, otimo, excelente }

extension NivelProdutividadeLabel on NivelProdutividade {
  String get rotulo => switch (this) {
        NivelProdutividade.ruim => 'Ruim',
        NivelProdutividade.bom => 'Bom',
        NivelProdutividade.otimo => 'Ótimo',
        NivelProdutividade.excelente => 'Excelente',
      };
}

/// Cor de cada faixa da escala — azul (ruim) → verde (bom) → amarelo
/// (ótimo) → vermelho (excelente). Mesma cor no marcador do ponto no mapa
/// e no badge do diálogo, pra escala e ponto baterem.
Color corNivelProdutividade(NivelProdutividade nivel) => switch (nivel) {
      NivelProdutividade.ruim => Colors.blue,
      NivelProdutividade.bom => Colors.green,
      NivelProdutividade.otimo => Colors.yellow,
      NivelProdutividade.excelente => Colors.red,
    };

/// Limiares da escala de classificação de clorofila-a — calibrados pro
/// litoral cearense (ver conversa de 2026-09): abaixo de [clorofilaMinimo]
/// é água pobre em nutrientes (oligotrófica), acima de [clorofilaOtimo] já é
/// excelente. O ponto médio entre os dois marca a fronteira bom/ótimo — os
/// dois únicos limiares que vieram do usuário, o do meio é interpolado.
const clorofilaMinimo = 0.094;
const clorofilaOtimo = 0.22;
const _clorofilaBomOtimo =
    clorofilaMinimo + (clorofilaOtimo - clorofilaMinimo) / 2;

NivelProdutividade nivelClorofila(double valorMgM3) {
  if (valorMgM3 < clorofilaMinimo) return NivelProdutividade.ruim;
  if (valorMgM3 < _clorofilaBomOtimo) return NivelProdutividade.bom;
  if (valorMgM3 <= clorofilaOtimo) return NivelProdutividade.otimo;
  return NivelProdutividade.excelente;
}
