/// Registro do dispositivo (aparelho) no backend, identificado pelo
/// [DeviceIdService.obtemId] local.
///
/// Espelha a resposta de
/// `GET base/estrutura/dispositivos/identificador/{identificador}`:
/// ```json
/// {
///   "id": "1697e053-1763-4c97-a8f4-264896bd43ca",
///   "organizacaoId": "11111111-1111-1111-1111-111111111111",
///   "empresaId": null,
///   "identificador": "6b0aeb079ee1b3c6",
///   "nome": "Dispositivo-29a93583",
///   "sigla": "DISP",
///   "status": 0,
///   "atuante": false,
///   "tipo": 0,
///   "ambiente": 0,
///   "criadoEm": "2026-07-09T01:01:00.145Z",
///   "atualizadoEm": "2026-07-12T14:20:26.964Z"
/// }
/// ```
class Dispositivo {
  final String id;
  final String organizacaoId;
  final String? empresaId;
  final String identificador;
  final String nome;
  final String? sigla;
  final int status;
  final bool atuante;
  final int tipo;
  final int ambiente;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  const Dispositivo({
    required this.id,
    required this.organizacaoId,
    this.empresaId,
    required this.identificador,
    required this.nome,
    this.sigla,
    required this.status,
    required this.atuante,
    required this.tipo,
    required this.ambiente,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    return Dispositivo(
      id: json['id'] as String,
      organizacaoId: json['organizacaoId'] as String,
      empresaId: json['empresaId'] as String?,
      identificador: json['identificador'] as String,
      nome: json['nome'] as String? ?? '',
      sigla: json['sigla'] as String?,
      status: (json['status'] as num?)?.toInt() ?? 0,
      atuante: json['atuante'] as bool? ?? false,
      tipo: (json['tipo'] as num?)?.toInt() ?? 0,
      ambiente: (json['ambiente'] as num?)?.toInt() ?? 0,
      criadoEm: DateTime.tryParse(json['criadoEm'] as String? ?? ''),
      atualizadoEm: DateTime.tryParse(json['atualizadoEm'] as String? ?? ''),
    );
  }
}
