import '../domain/models/leitura_termoclina.dart';

/// De onde [TermoclinaRepository] busca a leitura de termoclina — abstraído
/// de propósito (mesmo padrão de `core/planos/fonte_plano.dart`). Hoje a
/// padrão é [FonteTermoclinaEstimada] (SST real da Open-Meteo Marine,
/// perfil/profundidade ainda modelados); [FonteTermoclinaMock] segue
/// disponível pra testes/uso totalmente offline. A tela
/// (`TermoclinaScreen`) só conhece [TermoclinaRepository], nunca uma
/// [FonteTermoclina] diretamente — trocar por um perfil vertical real é
/// escrever uma nova implementação aqui e apontar [TermoclinaRepository]
/// pra ela, sem tocar em nenhuma linha de UI.
///
/// ## Onde conectar a API real (Copernicus Marine ou outra)
///
/// Quando existir uma fonte oceanográfica real com perfil vertical medido,
/// criar por exemplo `fonte_termoclina_copernicus.dart` com uma classe
/// `FonteTermoclinaCopernicus implements FonteTermoclina`, chamando algo
/// conceitualmente equivalente a `GET /oceanografia?lat=..&lon=..&date=..`
/// e devolvendo o corpo via `LeituraTermoclina.fromJson` (o formato já foi
/// desenhado em `leitura_termoclina.dart` pensando nisso). Depois, trocar
/// a instância padrão em `TermoclinaRepository`.
///
/// Profundidade da termoclina e perfil de temperatura em profundidade
/// **não são algo que o app calcula** a partir da SST isolada — sempre
/// vêm prontos da fonte (mock, estimada ou real), incluindo a confiança
/// da estimativa.
abstract class FonteTermoclina {
  Future<LeituraTermoclina> buscar({
    required double latitude,
    required double longitude,
    DateTime? data,
  });
}
