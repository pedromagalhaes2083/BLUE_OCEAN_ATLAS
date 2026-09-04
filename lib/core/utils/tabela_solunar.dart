/// Tabela solunar — períodos do dia em que a atividade de alimentação dos
/// peixes tende a ser maior, segundo a teoria solunar (John Alden Knight):
/// picos ligados à posição da lua no céu, não ao sol.
///
/// - **Período maior** (~2h): a lua está no meridiano — bem "por cima"
///   (culminação superior) ou bem "por baixo", do lado oposto da Terra
///   (culminação inferior). Efeito mais forte.
/// - **Período menor** (~1h): a lua está nascendo ou se pondo no
///   horizonte. Efeito mais fraco que o maior, mas ainda relevante.
///
/// Sem uma efeméride de posição lunar completa (ver a ressalva em
/// `core/utils/fase_lua.dart` sobre não inventar cálculo de posição sem
/// forma de validar), os horários de culminação são estimados
/// interpolando entre nascer e pôr da lua reais (ver [FaseLuaRepository])
/// — o ponto médio do arco que a lua percorre no céu entre nascer e pôr é
/// uma aproximação padrão usada por calculadoras solunares simples
/// quando não se calcula a posição exata da lua a cada instante.
library;

import '../../features/metereologia/domain/models/dia_lunar.dart';

enum TipoPeriodoSolunar {
  maior('Período Maior', 'Lua no meridiano — efeito mais forte, ~2h.'),
  menor('Período Menor', 'Lua nascendo ou se pondo — efeito mais fraco, ~1h.');

  final String label;
  final String nota;
  const TipoPeriodoSolunar(this.label, this.nota);
}

class PeriodoSolunar {
  final DateTime inicio;
  final DateTime fim;
  final TipoPeriodoSolunar tipo;

  const PeriodoSolunar({
    required this.inicio,
    required this.fim,
    required this.tipo,
  });

  Duration get duracao => fim.difference(inicio);
}

const Duration _duracaoMaior = Duration(hours: 2);
const Duration _duracaoMenor = Duration(hours: 1);

/// Calcula os períodos solunares a partir de uma sequência de dias com
/// nascer/pôr da lua (ver [DiaLunar]) — precisa de pelo menos os dias que
/// cobrem [desde] a [desde] + [janela], mais um pouco de folga antes/
/// depois (o algoritmo olha o evento de lua anterior e posterior a cada
/// ponto pra interpolar a culminação corretamente perto das bordas).
///
/// [dias] não precisa estar ordenado nem sem duplicata — a função ordena
/// e filtra internamente.
List<PeriodoSolunar> calcularPeriodosSolunares(
  List<DiaLunar> dias, {
  required DateTime desde,
  Duration janela = const Duration(days: 1),
}) {
  // Lista plana de todo evento de lua (nascer ou pôr), em ordem
  // cronológica — a partir daqui, "dia lunar" deixa de existir como
  // conceito: só importa a sequência de nascer/pôr, seja ela qual for.
  final eventos = <({DateTime instante, bool ehNascer})>[];
  for (final dia in dias) {
    if (dia.nascer != null) {
      eventos.add((instante: dia.nascer!, ehNascer: true));
    }
    if (dia.poesta != null) {
      eventos.add((instante: dia.poesta!, ehNascer: false));
    }
  }
  eventos.sort((a, b) => a.instante.compareTo(b.instante));
  if (eventos.length < 2) return [];

  final fim = desde.add(janela);
  final periodos = <PeriodoSolunar>[];

  // Períodos menores: o próprio instante de cada nascer/pôr dentro da
  // janela, ±metade da duração do período.
  for (final evento in eventos) {
    if (evento.instante.isBefore(desde) || evento.instante.isAfter(fim)) {
      continue;
    }
    final metade = Duration(minutes: _duracaoMenor.inMinutes ~/ 2);
    periodos.add(PeriodoSolunar(
      inicio: evento.instante.subtract(metade),
      fim: evento.instante.add(metade),
      tipo: TipoPeriodoSolunar.menor,
    ));
  }

  // Períodos maiores: o ponto médio entre cada par de eventos
  // consecutivos (nascer→pôr ou pôr→nascer) — aproxima a culminação,
  // superior ou inferior, sem diferenciar qual é qual (não muda o que o
  // mestre precisa saber: "é um período maior, agora").
  for (var i = 0; i < eventos.length - 1; i++) {
    final a = eventos[i].instante;
    final b = eventos[i + 1].instante;
    final meio = a.add(Duration(milliseconds: b.difference(a).inMilliseconds ~/ 2));
    if (meio.isBefore(desde) || meio.isAfter(fim)) continue;

    final metade = Duration(minutes: _duracaoMaior.inMinutes ~/ 2);
    periodos.add(PeriodoSolunar(
      inicio: meio.subtract(metade),
      fim: meio.add(metade),
      tipo: TipoPeriodoSolunar.maior,
    ));
  }

  periodos.sort((a, b) => a.inicio.compareTo(b.inicio));
  return periodos;
}
