/// Nascer/pôr do sol e da lua num dia, num ponto — só isso depende de
/// coordenada (a fase da lua em si não, ver `core/utils/fase_lua.dart`).
/// Vem da Open-Meteo (`daily=sunrise,sunset,moonrise,moonset`), a mesma
/// API usada pro resto da meteorologia do app — os 4 horários vêm juntos
/// na mesma chamada, sem custo extra de rede.
class DiaLunar {
  final DateTime data;

  final DateTime? nascerSol;
  final DateTime? porSol;

  /// Nulo em dias em que a lua não nasce (acontece perto da lua nova, em
  /// certas latitudes — a API devolve `null` nesse caso, não um erro).
  final DateTime? nascer;

  /// Mesma observação de [nascer] — nulo é um dia válido sem pôr da lua.
  final DateTime? poesta;

  const DiaLunar({
    required this.data,
    this.nascerSol,
    this.porSol,
    this.nascer,
    this.poesta,
  });
}
