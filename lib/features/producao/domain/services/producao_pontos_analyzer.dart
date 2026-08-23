import '../../../../core/utils/proximidade.dart';
import '../../../mapa/domain/models/ponto_marcado.dart';
import '../models/producao_registro.dart';

/// Produção total associada a um ponto marcado — soma dos registros de
/// produção feitos dentro do raio de proximidade do ponto.
class ProducaoPorPonto {
  final PontoMarcado ponto;
  final double totalKg;
  final int totalRegistros;
  final Map<String, double> porEspecie;

  const ProducaoPorPonto({
    required this.ponto,
    required this.totalKg,
    required this.totalRegistros,
    required this.porEspecie,
  });
}

/// Raio (em milhas náuticas) dentro do qual um registro de produção é
/// considerado "perto o suficiente" de um ponto marcado para ser
/// associado a ele.
const double raioAssociacaoPontoNauticas = 5;

/// Agrupa os registros de produção pelo ponto marcado mais próximo,
/// dentro de [raioAssociacaoPontoNauticas]. Registros sem coordenada, ou
/// mais distantes de qualquer ponto do que o raio, são ignorados.
///
/// Retorna a lista ordenada do ponto mais produtivo (kg) para o menos.
List<ProducaoPorPonto> agruparProducaoPorPonto(
  List<ProducaoRegistro> registros,
  List<PontoMarcado> pontos,
) {
  if (pontos.isEmpty) return [];

  final totalKgPorPonto = <int, double>{};
  final totalRegistrosPorPonto = <int, int>{};
  final porEspeciePorPonto = <int, Map<String, double>>{};

  for (final registro in registros) {
    if (registro.latitude == null || registro.longitude == null) continue;

    PontoMarcado? maisProximo;
    double? menorDistancia;
    for (final ponto in pontos) {
      final distancia = calcularDistanciaNauticas(
        registro.latitude!,
        registro.longitude!,
        ponto.latitude,
        ponto.longitude,
      );
      if (distancia > raioAssociacaoPontoNauticas) continue;
      if (menorDistancia == null || distancia < menorDistancia) {
        menorDistancia = distancia;
        maisProximo = ponto;
      }
    }

    if (maisProximo == null || maisProximo.id == null) continue;
    final pontoId = maisProximo.id!;

    totalKgPorPonto.update(
      pontoId,
      (v) => v + registro.quantidadeKg,
      ifAbsent: () => registro.quantidadeKg,
    );
    totalRegistrosPorPonto.update(
      pontoId,
      (v) => v + 1,
      ifAbsent: () => 1,
    );
    final porEspecie = porEspeciePorPonto.putIfAbsent(pontoId, () => {});
    porEspecie.update(
      registro.especie,
      (v) => v + registro.quantidadeKg,
      ifAbsent: () => registro.quantidadeKg,
    );
  }

  final resultado = <ProducaoPorPonto>[];
  for (final ponto in pontos) {
    final totalKg = totalKgPorPonto[ponto.id];
    if (totalKg == null) continue;
    resultado.add(ProducaoPorPonto(
      ponto: ponto,
      totalKg: totalKg,
      totalRegistros: totalRegistrosPorPonto[ponto.id]!,
      porEspecie: porEspeciePorPonto[ponto.id]!,
    ));
  }

  resultado.sort((a, b) => b.totalKg.compareTo(a.totalKg));
  return resultado;
}
