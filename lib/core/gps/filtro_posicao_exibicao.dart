import 'amostra_gps.dart';
import 'validador_posicao.dart';

/// Decide se uma posição do fluxo contínuo de GPS deve mover o marcador da
/// embarcação no mapa — a mesma triagem do histórico ([ValidadorPosicao]),
/// mantendo o estado entre leituras (última aceita, última suspeita por
/// salto). Uma leitura suspeita ou inválida não move o marcador: ele fica
/// na última posição confiável em vez de pular pra um ponto errado.
class FiltroPosicaoExibicao {
  final ConfigValidacaoGps config;

  AmostraGps? _ultimaAceita;
  AmostraGps? _ultimaSuspeitaPorSalto;

  FiltroPosicaoExibicao({this.config = const ConfigValidacaoGps()});

  AmostraGps? get ultimaAceita => _ultimaAceita;

  bool aceitar(AmostraGps amostra, {DateTime? agora}) {
    final resultado = ValidadorPosicao.validar(
      amostra,
      agora: agora ?? DateTime.now(),
      anteriorValida: _ultimaAceita,
      ultimaSuspeitaPorSalto: _ultimaSuspeitaPorSalto,
      config: config,
    );
    if (resultado.valida) {
      _ultimaAceita = amostra;
      _ultimaSuspeitaPorSalto = null;
      return true;
    }
    _ultimaSuspeitaPorSalto = resultado.suspeitaSoPorSalto ? amostra : null;
    return false;
  }

  /// Esquece o histórico — ao reassinar o fluxo depois de o app voltar do
  /// segundo plano, a embarcação pode ter andado bastante e a comparação
  /// com a última posição de antes não faz mais sentido.
  void reiniciar() {
    _ultimaAceita = null;
    _ultimaSuspeitaPorSalto = null;
  }
}
