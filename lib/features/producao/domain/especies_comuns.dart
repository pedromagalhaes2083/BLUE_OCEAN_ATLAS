/// Espécies mais comuns na pesca artesanal/costeira brasileira — usadas como
/// sugestão de autocompletar no registro de produção. Não é uma lista
/// fechada: qualquer texto digitado continua sendo aceito, isso só reduz
/// variações de grafia (ex: "tainha" vs "Tainha" vs "TAINHA") que
/// fragmentariam os totais por espécie e o calor de produção no mapa.
const especiesComuns = <String>[
  'Tainha',
  'Camurupim',
  'Pescada Amarela',
  'Pescada Branca',
  'Robalo',
  'Curimã',
  'Cavala',
  'Serra',
  'Xaréu',
  'Carapeba',
  'Camarão',
  'Lagosta',
  'Caranguejo',
  'Sururu',
  'Ostra',
  'Tilápia',
  'Dourado',
  'Garoupa',
  'Cioba',
  'Vermelho',
  'Guaiúba',
  'Bagre',
  'Corvina',
  'Anchova',
  'Arraia',
  'Cação',
  'Atum',
  'Agulha',
  'Sardinha',
  'Peixe-voador',
  'Polvo',
  'Lula',
];

/// Normaliza um texto de espécie digitado à mão (tira espaços nas pontas e
/// deixa a primeira letra de cada palavra maiúscula), pra reduzir variações
/// de grafia mesmo quando não está na lista de sugestões.
String normalizarEspecie(String valor) {
  final texto = valor.trim();
  if (texto.isEmpty) return texto;
  return texto
      .split(RegExp(r'\s+'))
      .map((palavra) => palavra.isEmpty
          ? palavra
          : palavra[0].toUpperCase() + palavra.substring(1).toLowerCase())
      .join(' ');
}
