import 'dart:convert';
import 'dart:math' as math;

/// Uma componente harmônica de maré (amplitude + fase, numa frequência
/// astronômica fixa e conhecida) — ver [constituintesPadrao].
class ConstituenteMare {
  final String nome;
  final double periodoHoras;
  final double amplitudeM;
  final double faseRad;

  const ConstituenteMare({
    required this.nome,
    required this.periodoHoras,
    required this.amplitudeM,
    required this.faseRad,
  });

  double get frequenciaRadPorHora => 2 * math.pi / periodoHoras;

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'periodoHoras': periodoHoras,
        'amplitudeM': amplitudeM,
        'faseRad': faseRad,
      };

  factory ConstituenteMare.fromJson(Map<String, dynamic> json) =>
      ConstituenteMare(
        nome: json['nome'] as String,
        periodoHoras: (json['periodoHoras'] as num).toDouble(),
        amplitudeM: (json['amplitudeM'] as num).toDouble(),
        faseRad: (json['faseRad'] as num).toDouble(),
      );
}

/// As 4 constituintes principais (semidiurnas + diurnas) — suficientes pra
/// uma previsão razoável sem exigir meses de dado histórico pra separar
/// constituintes vizinhas (M2/N2, K1/P1 etc. exigiriam muito mais série).
/// Períodos em horas solares médias (valores astronômicos padrão).
const List<double> periodosConstituintesPadrao = [
  12.4206012, // M2 — lunar principal semidiurna
  12.0, // S2 — solar principal semidiurna
  23.93447213, // K1 — luni-solar diurna
  25.81933871, // O1 — lunar principal diurna
];

const List<String> nomesConstituintesPadrao = ['M2', 'S2', 'K1', 'O1'];

/// Modelo de maré ajustado por harmônicos — depois de ajustado (ver
/// [ajustarModeloMareHarmonico]), prevê a altura da maré em qualquer
/// instante **sem precisar de rede**, é só cosseno/seno. É a mesma técnica
/// usada nas tábuas de maré oficiais (DHN), só que aqui as constituintes
/// são estimadas por regressão sobre a série que a Open-Meteo devolve, em
/// vez de vir de anos de observação num marégrafo — menos precisa, mas
/// funciona offline e não depende de nenhuma fonte paga.
class ModeloMareHarmonico {
  final double nivelMedioM;
  final List<ConstituenteMare> constituintes;
  final DateTime epoca;

  const ModeloMareHarmonico({
    required this.nivelMedioM,
    required this.constituintes,
    required this.epoca,
  });

  /// Altura prevista (m) num instante qualquer, passado ou futuro.
  double altura(DateTime instante) {
    final horas = instante.difference(epoca).inMilliseconds / 3600000.0;
    var soma = nivelMedioM;
    for (final c in constituintes) {
      soma += c.amplitudeM * math.cos(c.frequenciaRadPorHora * horas - c.faseRad);
    }
    return soma;
  }

  /// Preamares/baixa-mares entre [desde] e [desde] + [janela] — varre em
  /// passos de [passo] e marca cada troca de sinal na derivada (subida
  /// vira descida, ou vice-versa) como um evento. Como é síntese
  /// harmônica (não uma série amostrada), a resolução do horário do
  /// evento é o próprio [passo].
  List<({DateTime horario, double alturaM, bool alta})> proximosEventos(
    DateTime desde, {
    Duration janela = const Duration(days: 7),
    Duration passo = const Duration(minutes: 10),
  }) {
    final eventos = <({DateTime horario, double alturaM, bool alta})>[];
    final fim = desde.add(janela);

    var atual = altura(desde);
    var proximo = altura(desde.add(passo));
    var subindo = proximo > atual;
    var t = desde.add(passo);
    atual = proximo;

    while (t.isBefore(fim)) {
      proximo = altura(t.add(passo));
      final subindoAgora = proximo > atual;
      if (subindoAgora != subindo) {
        eventos.add((horario: t, alturaM: atual, alta: subindo));
        subindo = subindoAgora;
      }
      atual = proximo;
      t = t.add(passo);
    }
    return eventos;
  }

  Map<String, dynamic> toJson() => {
        'nivelMedioM': nivelMedioM,
        'constituintes': constituintes.map((c) => c.toJson()).toList(),
        'epoca': epoca.toIso8601String(),
      };

  factory ModeloMareHarmonico.fromJson(Map<String, dynamic> json) =>
      ModeloMareHarmonico(
        nivelMedioM: (json['nivelMedioM'] as num).toDouble(),
        constituintes: (json['constituintes'] as List)
            .map((e) => ConstituenteMare.fromJson(e as Map<String, dynamic>))
            .toList(),
        epoca: DateTime.parse(json['epoca'] as String),
      );

  String toJsonString() => jsonEncode(toJson());
  factory ModeloMareHarmonico.fromJsonString(String texto) =>
      ModeloMareHarmonico.fromJson(jsonDecode(texto) as Map<String, dynamic>);
}

/// Ajusta um [ModeloMareHarmonico] por mínimos quadrados a partir de uma
/// série de alturas observadas — `altura(t) ≈ Z0 + Σ [a_i·cos(ω_i·t) +
/// b_i·sin(ω_i·t)]`, linear nos coeficientes (Z0, a_i, b_i) já que as
/// frequências ω_i são fixas e conhecidas (ver [periodosConstituintesPadrao]),
/// então basta resolver um sistema linear (equações normais) — sem
/// nenhuma biblioteca de álgebra linear externa.
ModeloMareHarmonico ajustarModeloMareHarmonico({
  required List<DateTime> horarios,
  required List<double> alturas,
  DateTime? epoca,
}) {
  if (horarios.length != alturas.length || horarios.isEmpty) {
    throw ArgumentError('horarios e alturas precisam ter o mesmo tamanho, não vazio');
  }
  final referencia = epoca ?? horarios.first;
  final n = horarios.length;
  final k = periodosConstituintesPadrao.length;
  final p = 1 + 2 * k; // Z0 + (a_i, b_i) por constituinte

  final t = List<double>.generate(
      n, (i) => horarios[i].difference(referencia).inMilliseconds / 3600000.0);
  final omegas =
      periodosConstituintesPadrao.map((per) => 2 * math.pi / per).toList();

  // Linha i da matriz de projeto: [1, cos(w1 t), sin(w1 t), cos(w2 t), sin(w2 t), ...]
  double linha(int i, int coluna) {
    if (coluna == 0) return 1.0;
    final idx = (coluna - 1) ~/ 2;
    final par = (coluna - 1).isEven;
    return par ? math.cos(omegas[idx] * t[i]) : math.sin(omegas[idx] * t[i]);
  }

  // Equações normais: (XᵀX) c = Xᵀy
  final xtx = List.generate(p, (_) => List<double>.filled(p, 0));
  final xty = List<double>.filled(p, 0);
  for (var i = 0; i < n; i++) {
    final linhaValores = List<double>.generate(p, (c) => linha(i, c));
    for (var a = 0; a < p; a++) {
      xty[a] += linhaValores[a] * alturas[i];
      for (var b = 0; b < p; b++) {
        xtx[a][b] += linhaValores[a] * linhaValores[b];
      }
    }
  }

  final coeficientes = _resolverSistemaLinear(xtx, xty);

  final constituintes = <ConstituenteMare>[];
  for (var idx = 0; idx < k; idx++) {
    final a = coeficientes[1 + 2 * idx];
    final b = coeficientes[2 + 2 * idx];
    final amplitude = math.sqrt(a * a + b * b);
    final fase = math.atan2(b, a);
    constituintes.add(ConstituenteMare(
      nome: nomesConstituintesPadrao[idx],
      periodoHoras: periodosConstituintesPadrao[idx],
      amplitudeM: amplitude,
      faseRad: fase,
    ));
  }

  return ModeloMareHarmonico(
    nivelMedioM: coeficientes[0],
    constituintes: constituintes,
    epoca: referencia,
  );
}

/// Eliminação de Gauss com pivô parcial — sistema pequeno (9×9 pra 4
/// constituintes), não precisa de nada mais sofisticado.
List<double> _resolverSistemaLinear(List<List<double>> a, List<double> b) {
  final n = b.length;
  final m = List.generate(n, (i) => [...a[i], b[i]]);

  for (var col = 0; col < n; col++) {
    var pivo = col;
    for (var lin = col + 1; lin < n; lin++) {
      if (m[lin][col].abs() > m[pivo][col].abs()) pivo = lin;
    }
    final tmp = m[col];
    m[col] = m[pivo];
    m[pivo] = tmp;

    if (m[col][col].abs() < 1e-12) continue; // singular nessa coluna, pula

    for (var lin = 0; lin < n; lin++) {
      if (lin == col) continue;
      final fator = m[lin][col] / m[col][col];
      for (var c = col; c <= n; c++) {
        m[lin][c] -= fator * m[col][c];
      }
    }
  }

  return List.generate(n, (i) {
    if (m[i][i].abs() < 1e-12) return 0.0;
    return m[i][n] / m[i][i];
  });
}
