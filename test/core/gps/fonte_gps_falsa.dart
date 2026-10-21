import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'package:atlas/core/gps/amostra_gps.dart';
import 'package:atlas/core/gps/fonte_gps.dart';

/// GPS simulado pros testes — sem aparelho, sem coordenada real.
class FonteGpsFalsa implements FonteGps {
  LocationPermission permissao;
  LocationPermission permissaoAposPedir;
  bool servico;

  /// Próximas posições devolvidas por [posicaoAtual], em ordem. Vazia →
  /// simula falta de sinal (lança [TimeoutException]).
  final List<AmostraGps> posicoes;
  AmostraGps? ultimaConhecida;

  var pedidosDePermissao = 0;

  FonteGpsFalsa({
    this.permissao = LocationPermission.whileInUse,
    LocationPermission? permissaoAposPedir,
    this.servico = true,
    List<AmostraGps>? posicoes,
    this.ultimaConhecida,
  })  : permissaoAposPedir = permissaoAposPedir ?? permissao,
        posicoes = posicoes ?? [];

  @override
  Future<bool> servicoHabilitado() async => servico;

  @override
  Future<LocationPermission> verificarPermissao() async => permissao;

  @override
  Future<LocationPermission> solicitarPermissao() async {
    pedidosDePermissao++;
    permissao = permissaoAposPedir;
    return permissao;
  }

  @override
  Future<AmostraGps> posicaoAtual({required Duration limite}) async {
    if (posicoes.isEmpty) throw TimeoutException('sem sinal (simulado)', limite);
    return posicoes.removeAt(0);
  }

  @override
  Future<AmostraGps?> ultimaPosicaoConhecida() async => ultimaConhecida;
}
