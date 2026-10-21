import 'package:geolocator/geolocator.dart';

import 'amostra_gps.dart';

/// Acesso ao GPS do aparelho atrás de uma interface — o código de
/// rastreamento depende disto, não do `Geolocator` direto, pra os testes
/// simularem permissão negada, serviço desligado, sem sinal etc. sem um
/// aparelho de verdade.
abstract class FonteGps {
  Future<bool> servicoHabilitado();
  Future<LocationPermission> verificarPermissao();
  Future<LocationPermission> solicitarPermissao();

  /// Uma posição nova, ou lança se não vier dentro de [limite].
  Future<AmostraGps> posicaoAtual({required Duration limite});

  /// A última posição que o sistema já tinha (pode ser antiga), ou null.
  Future<AmostraGps?> ultimaPosicaoConhecida();
}

/// Implementação real, sobre o plugin `geolocator`.
class FonteGpsGeolocator implements FonteGps {
  const FonteGpsGeolocator();

  @override
  Future<bool> servicoHabilitado() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LocationPermission> verificarPermissao() =>
      Geolocator.checkPermission();

  @override
  Future<LocationPermission> solicitarPermissao() =>
      Geolocator.requestPermission();

  @override
  Future<AmostraGps> posicaoAtual({required Duration limite}) async {
    final posicao = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: limite,
      ),
    ).timeout(limite + const Duration(seconds: 2));
    return AmostraGps.dePosition(posicao);
  }

  @override
  Future<AmostraGps?> ultimaPosicaoConhecida() async {
    final posicao = await Geolocator.getLastKnownPosition();
    return posicao == null ? null : AmostraGps.dePosition(posicao);
  }
}
