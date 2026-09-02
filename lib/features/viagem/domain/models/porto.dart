/// Um porto cadastrado no backend (`base/operacao/portos`) — usado como
/// origem/destino de uma viagem. Diferente de `PortoMare` (só um ponto
/// salvo localmente pra tábua de maré offline, sem nenhuma relação com
/// este).
///
/// A resposta de listagem (`GET .../indice`) traz bem mais campos de
/// auditoria (`criadoEm`, `versao` etc.) que não interessam ao app —
/// [fromJson] só lê o que é usado. A coordenada vem tanto como GeoJSON
/// (`coordenadas: {type, coordinates: [lon, lat]}`) quanto como
/// `latitude`/`longitude` soltos — lemos só os soltos, mais simples.
class Porto {
  final String id;
  final String nome;
  final String? codigo;
  final String? sigla;
  final String? pais;
  final int status;
  final double latitude;
  final double longitude;

  const Porto({
    required this.id,
    required this.nome,
    this.codigo,
    this.sigla,
    this.pais,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory Porto.fromJson(Map<String, dynamic> json) {
    return Porto(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '',
      codigo: json['codigo'] as String?,
      sigla: json['sigla'] as String?,
      pais: json['pais'] as String?,
      status: (json['status'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
