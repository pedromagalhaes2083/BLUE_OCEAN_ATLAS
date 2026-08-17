import '../classificacao_peso.dart';

/// Dados de um registro de produção a enviar para a API
/// (`POST base/operacao/producao/salva` — endpoint ainda placeholder, ver
/// `Endpoints.producaoRegistro`).
///
/// Mesmo contrato estável que [LocalizacaoEnvio] segue pra localização: se
/// a rota, os nomes de campo ou o formato do corpo mudarem no backend, só
/// [ProducaoRepository] precisa mudar — este modelo e quem o utiliza
/// permanecem os mesmos.
class ProducaoEnvio {
  final String embarcacaoId;
  final String dispositivoId;
  final DateTime instante;
  final TipoPeixe tipoPeixe;
  final Classificacao classificacao;
  final int quantidadeUnidades;
  final double pesoMedioUnitario;
  final double quantidadeKg; // total = quantidadeUnidades * pesoMedioUnitario
  final double? latitude;
  final double? longitude;
  final double? precisaoMetros;
  final int? viagemId;
  final String? observacao;

  const ProducaoEnvio({
    required this.embarcacaoId,
    required this.dispositivoId,
    required this.instante,
    required this.tipoPeixe,
    required this.classificacao,
    required this.quantidadeUnidades,
    required this.pesoMedioUnitario,
    required this.quantidadeKg,
    this.latitude,
    this.longitude,
    this.precisaoMetros,
    this.viagemId,
    this.observacao,
  });
}
