import 'config.dart';
import 'constantes.dart';

/// Limiares (e se cada um está ativo) que definem quando uma condição no
/// ponto à frente da embarcação é severa o bastante pra notificar (ver
/// `AlertaCondicaoNotificationService`) — configuráveis pelo usuário na
/// tela "Configurar Alertas" e persistidos via [Config]. Os valores padrão
/// reproduzem os limiares fixos originais (faixa mais alta de cada escala
/// já usada nos cards de `AlertaRotaScreen`).
class LimiaresAlerta {
  final bool ventoAtivo;
  final double ventoLimiarKmh;
  final bool ondaAtivo;
  final double ondaLimiarM;
  final bool correnteAtivo;
  final double correnteLimiarNos;

  /// Alerta de temperatura é sobre água quente demais, não sobre risco de
  /// navegação como os outros três — por isso desligado por padrão.
  final bool temperaturaAtivo;
  final double temperaturaLimiarC;

  const LimiaresAlerta({
    required this.ventoAtivo,
    required this.ventoLimiarKmh,
    required this.ondaAtivo,
    required this.ondaLimiarM,
    required this.correnteAtivo,
    required this.correnteLimiarNos,
    required this.temperaturaAtivo,
    required this.temperaturaLimiarC,
  });

  static const LimiaresAlerta padrao = LimiaresAlerta(
    ventoAtivo: true,
    ventoLimiarKmh: 45,
    ondaAtivo: true,
    ondaLimiarM: 3.0,
    correnteAtivo: true,
    correnteLimiarNos: 1.5,
    temperaturaAtivo: false,
    temperaturaLimiarC: 27.4,
  );

  LimiaresAlerta copyWith({
    bool? ventoAtivo,
    double? ventoLimiarKmh,
    bool? ondaAtivo,
    double? ondaLimiarM,
    bool? correnteAtivo,
    double? correnteLimiarNos,
    bool? temperaturaAtivo,
    double? temperaturaLimiarC,
  }) {
    return LimiaresAlerta(
      ventoAtivo: ventoAtivo ?? this.ventoAtivo,
      ventoLimiarKmh: ventoLimiarKmh ?? this.ventoLimiarKmh,
      ondaAtivo: ondaAtivo ?? this.ondaAtivo,
      ondaLimiarM: ondaLimiarM ?? this.ondaLimiarM,
      correnteAtivo: correnteAtivo ?? this.correnteAtivo,
      correnteLimiarNos: correnteLimiarNos ?? this.correnteLimiarNos,
      temperaturaAtivo: temperaturaAtivo ?? this.temperaturaAtivo,
      temperaturaLimiarC: temperaturaLimiarC ?? this.temperaturaLimiarC,
    );
  }

  static Future<LimiaresAlerta> carregar() async {
    return LimiaresAlerta(
      ventoAtivo:
          await _obterBool(Constantes.alertaVentoAtivo, padrao.ventoAtivo),
      ventoLimiarKmh: await _obterDouble(
          Constantes.alertaVentoLimiarKmh, padrao.ventoLimiarKmh),
      ondaAtivo:
          await _obterBool(Constantes.alertaOndaAtivo, padrao.ondaAtivo),
      ondaLimiarM: await _obterDouble(
          Constantes.alertaOndaLimiarM, padrao.ondaLimiarM),
      correnteAtivo: await _obterBool(
          Constantes.alertaCorrenteAtivo, padrao.correnteAtivo),
      correnteLimiarNos: await _obterDouble(
          Constantes.alertaCorrenteLimiarNos, padrao.correnteLimiarNos),
      temperaturaAtivo: await _obterBool(
          Constantes.alertaTemperaturaAtivo, padrao.temperaturaAtivo),
      temperaturaLimiarC: await _obterDouble(
          Constantes.alertaTemperaturaLimiarC, padrao.temperaturaLimiarC),
    );
  }

  Future<void> salvar() async {
    await Config.grava(Constantes.alertaVentoAtivo, ventoAtivo.toString());
    await Config.grava(
        Constantes.alertaVentoLimiarKmh, ventoLimiarKmh.toString());
    await Config.grava(Constantes.alertaOndaAtivo, ondaAtivo.toString());
    await Config.grava(Constantes.alertaOndaLimiarM, ondaLimiarM.toString());
    await Config.grava(
        Constantes.alertaCorrenteAtivo, correnteAtivo.toString());
    await Config.grava(
        Constantes.alertaCorrenteLimiarNos, correnteLimiarNos.toString());
    await Config.grava(
        Constantes.alertaTemperaturaAtivo, temperaturaAtivo.toString());
    await Config.grava(
        Constantes.alertaTemperaturaLimiarC, temperaturaLimiarC.toString());
  }

  static Future<bool> _obterBool(String chave, bool padrao) async {
    final valor = await Config.obtem(chave);
    if (valor.isEmpty) return padrao;
    return valor == 'true';
  }

  static Future<double> _obterDouble(String chave, double padrao) async {
    final valor = await Config.obtem(chave);
    return double.tryParse(valor) ?? padrao;
  }
}
