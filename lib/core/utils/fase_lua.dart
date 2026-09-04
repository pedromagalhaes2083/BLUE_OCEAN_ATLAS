/// Fase da Lua a partir só da data/hora — a fase em si (Nova, Cheia etc.) é
/// praticamente a mesma em qualquer ponto da Terra num dado instante (a
/// diferença por paralaxe é irrelevante pra esse uso), então isso funciona
/// sem GPS e sem rede. O que depende de coordenada é o horário de
/// nascer/pôr da lua — ver [FaseLuaRepository], que busca isso na mesma
/// API (Open-Meteo) já usada pelo resto da meteorologia do app.
///
/// Método: idade da lua (dias desde a última lua nova) a partir de uma lua
/// nova de referência bem conhecida (2000-01-06 18:14 UTC) e do período
/// sinódico médio (29.530588853 dias) — a mesma técnica usada por
/// calculadoras de fase lunar simples. Validado em 2026-09 contra os
/// valores de `moon_phase` que a Open-Meteo devolve pra hoje e os próximos
/// dias: diferença de poucas horas a ~1 dia, esperado pra uma fórmula
/// sinódica simples (sem os termos de perturbação de uma efeméride
/// completa) — suficiente pra uso de pesca, não pra navegação astronômica
/// de precisão.
library;

import 'dart:math' as math;

const double diasMesSinodico = 29.530588853;

/// Lua nova de referência bem documentada, usada como época pra contar a
/// idade da lua em qualquer outra data (ver [_idadeDiasEm]).
final DateTime _novaLuaReferencia = DateTime.utc(2000, 1, 6, 18, 14);

/// As 8 fases nomeadas tradicionais, na ordem em que se sucedem a partir
/// da lua nova.
enum FaseLuaTipo {
  novaLua('Lua Nova', '🌑'),
  crescente('Lua Crescente', '🌒'),
  quartoCrescente('Quarto Crescente', '🌓'),
  gibosaCrescente('Gibosa Crescente', '🌔'),
  cheia('Lua Cheia', '🌕'),
  gibosaMinguante('Gibosa Minguante', '🌖'),
  quartoMinguante('Quarto Minguante', '🌗'),
  minguante('Lua Minguante', '🌘');

  final String label;
  final String emoji;
  const FaseLuaTipo(this.label, this.emoji);
}

/// Só as 4 fases "principais" (as que têm um instante exato, em vez de uma
/// faixa de dias) — usadas em [proximasFasesPrincipais].
const List<FaseLuaTipo> fasesPrincipais = [
  FaseLuaTipo.novaLua,
  FaseLuaTipo.quartoCrescente,
  FaseLuaTipo.cheia,
  FaseLuaTipo.quartoMinguante,
];

/// Fase da lua num instante — [idadeDias] vai de 0 (lua nova) a
/// ~[diasMesSinodico] (véspera da próxima lua nova).
class FaseLua {
  final DateTime instante;
  final double idadeDias;
  final FaseLuaTipo tipo;

  /// Fração iluminada do disco visível (0 = nova, 1 = cheia).
  final double fracaoIluminada;

  const FaseLua({
    required this.instante,
    required this.idadeDias,
    required this.tipo,
    required this.fracaoIluminada,
  });
}

/// Um próximo evento de fase principal (Nova/Quarto Crescente/Cheia/Quarto
/// Minguante) — sempre no futuro em relação a quem chamou
/// [proximasFasesPrincipais].
class ProximaFaseLua {
  final FaseLuaTipo tipo;
  final DateTime instante;

  const ProximaFaseLua({required this.tipo, required this.instante});
}

double _idadeDiasEm(DateTime instante) {
  final diasDesdeReferencia =
      instante.toUtc().difference(_novaLuaReferencia).inMilliseconds /
          86400000.0;
  var idade = diasDesdeReferencia % diasMesSinodico;
  if (idade < 0) idade += diasMesSinodico;
  return idade;
}

FaseLuaTipo _tipoFasePorIdade(double idadeDias) {
  // 8 fases de largura igual (~3.69 dias cada), centralizadas nas 4
  // principais (Nova em idade 0, Cheia em idade ~14.77 etc.) — não
  // simplesmente 8 faixas começando em 0, senão "Nova" só apareceria
  // depois do instante exato da lua nova, nunca antes.
  const passo = diasMesSinodico / 8;
  final indice = ((idadeDias + passo / 2) / passo).floor() % 8;
  return FaseLuaTipo.values[indice];
}

/// Fase da lua no [instante] dado (agora, por padrão).
FaseLua calcularFaseLua([DateTime? instante]) {
  final agora = instante ?? DateTime.now();
  final idade = _idadeDiasEm(agora);
  final fracaoIluminada =
      (1 - math.cos(2 * math.pi * idade / diasMesSinodico)) / 2;
  return FaseLua(
    instante: agora,
    idadeDias: idade,
    tipo: _tipoFasePorIdade(idade),
    fracaoIluminada: fracaoIluminada,
  );
}

/// As próximas ocorrências das 4 fases principais, a partir de [apartirDe]
/// (agora, por padrão) — sempre 4 datas no futuro, ordenadas da mais
/// próxima pra mais distante. A primeira da lista é "a próxima fase
/// lunar" que o app mostra em destaque.
List<ProximaFaseLua> proximasFasesPrincipais([DateTime? apartirDe]) {
  final agora = apartirDe ?? DateTime.now();
  final idadeAtual = _idadeDiasEm(agora);

  final alvos = <FaseLuaTipo, double>{
    FaseLuaTipo.novaLua: 0,
    FaseLuaTipo.quartoCrescente: diasMesSinodico / 4,
    FaseLuaTipo.cheia: diasMesSinodico / 2,
    FaseLuaTipo.quartoMinguante: diasMesSinodico * 3 / 4,
  };

  final resultado = <ProximaFaseLua>[];
  for (final entrada in alvos.entries) {
    var diasAte = entrada.value - idadeAtual;
    while (diasAte <= 1e-6) {
      diasAte += diasMesSinodico;
    }
    final instante =
        agora.add(Duration(minutes: (diasAte * 24 * 60).round()));
    resultado.add(ProximaFaseLua(tipo: entrada.key, instante: instante));
  }
  resultado.sort((a, b) => a.instante.compareTo(b.instante));
  return resultado;
}

/// Sizígia (maré de "lançante"/"águas vivas") acontece perto de lua nova
/// e lua cheia — Sol e Lua alinhados, forças de maré somadas, correntes
/// mais fortes, amplitude maior. Quadratura ("águas mortas") acontece
/// perto dos quartos — Sol e Lua em ângulo reto, forças se cancelando
/// parcialmente, correntes mais fracas.
enum TipoMareAstronomica {
  sizigia('Sizígia', 'Correntes mais fortes, maior amplitude de maré.'),
  quadratura('Quadratura', 'Correntes mais fracas, menor amplitude de maré.'),
  transicao('Transição', 'Nem sizígia nem quadratura — período de meio de caminho.');

  final String label;
  final String nota;
  const TipoMareAstronomica(this.label, this.nota);
}

/// Janela (em dias, pra cada lado) em que a fase já conta como sizígia ou
/// quadratura "de verdade" — perto o bastante do ponto exato (nova/cheia/
/// quarto) pra a diferença ser perceptível na força da corrente. Fora
/// dessa janela dos 4 pontos, é "transição": nem uma coisa nem outra com
/// clareza.
const double _janelaDiasMareAstronomica = 2.0;

/// Classifica a maré astronômica do dia a partir só da fase da lua — sem
/// precisar de nenhum modelo de maré ajustado, é geometria Sol-Terra-Lua.
/// Combina com `ModeloMareHarmonico` pra dizer não só "que horas é a
/// próxima preamar" mas também "essa preamar vai ser mais forte que a
/// média, ou mais fraca".
TipoMareAstronomica calcularTipoMareAstronomica(FaseLua fase) {
  const pontosSizigia = [0.0, diasMesSinodico / 2]; // nova, cheia
  const pontosQuadratura = [
    diasMesSinodico / 4, // quarto crescente
    diasMesSinodico * 3 / 4, // quarto minguante
  ];

  double distanciaCircular(double idade, double alvo) {
    var diferenca = (idade - alvo).abs();
    if (diferenca > diasMesSinodico / 2) diferenca = diasMesSinodico - diferenca;
    return diferenca;
  }

  final distanciaSizigia =
      pontosSizigia.map((p) => distanciaCircular(fase.idadeDias, p)).reduce(
          (a, b) => a < b ? a : b);
  final distanciaQuadratura =
      pontosQuadratura.map((p) => distanciaCircular(fase.idadeDias, p)).reduce(
          (a, b) => a < b ? a : b);

  if (distanciaSizigia <= _janelaDiasMareAstronomica) {
    return TipoMareAstronomica.sizigia;
  }
  if (distanciaQuadratura <= _janelaDiasMareAstronomica) {
    return TipoMareAstronomica.quadratura;
  }
  return TipoMareAstronomica.transicao;
}

/// Posição contínua de [fase] no eixo quadratura↔sizígia, de 0 (bem na
/// quadratura) a 100 (bem na sizígia) — usado tanto pro indicador visual
/// da barra "QUADRATURA ── SIZÍGIA" (ver [MareEPescaAtumScreen]) quanto
/// pelo fator "fase lunar" do [calcularIndiceInfluenciaMare]. Mesma
/// geometria de [calcularTipoMareAstronomica], só que como gradiente
/// contínuo em vez de 3 categorias.
double pontuacaoProximidadeSizigia(FaseLua fase) {
  const pontosSizigia = [0.0, diasMesSinodico / 2];
  double distanciaCircular(double idade, double alvo) {
    var diferenca = (idade - alvo).abs();
    if (diferenca > diasMesSinodico / 2) diferenca = diasMesSinodico - diferenca;
    return diferenca;
  }

  final distancia = pontosSizigia
      .map((p) => distanciaCircular(fase.idadeDias, p))
      .reduce((a, b) => a < b ? a : b);
  // Distância máxima possível até o ponto de sizígia mais próximo é 1/4 do
  // mês sinódico (bem no meio do caminho, na quadratura) — normaliza por
  // isso.
  const distanciaMaxima = diasMesSinodico / 4;
  final pontuacao = 100 * (1 - distancia / distanciaMaxima);
  return pontuacao < 0 ? 0 : (pontuacao > 100 ? 100 : pontuacao);
}
