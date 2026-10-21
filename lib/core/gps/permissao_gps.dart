import 'package:geolocator/geolocator.dart';

import 'fonte_gps.dart';
import 'gps_log.dart';

/// Situação do GPS pra iniciar o rastreamento — cada caso pede uma ação
/// diferente do usuário, por isso não é só um booleano.
enum EstadoPermissaoGps {
  /// "Permitir o tempo todo": rastreia com o app fechado e retoma sozinho
  /// depois de reiniciar o aparelho.
  concedidaSempre,

  /// "Só durante o uso": o serviço em primeiro plano funciona enquanto
  /// estiver rodando, mas o Android não deixa retomá-lo sozinho depois de
  /// reiniciar o aparelho.
  concedidaDuranteUso,

  /// Negada, mas o sistema ainda deixa perguntar de novo.
  negada,

  /// Negada de vez — só o usuário, nas configurações do app, pode liberar.
  negadaPermanentemente,
}

extension EstadoPermissaoGpsX on EstadoPermissaoGps {
  bool get permiteRastrear =>
      this == EstadoPermissaoGps.concedidaSempre ||
      this == EstadoPermissaoGps.concedidaDuranteUso;
}

/// Diagnóstico de permissão + serviço de localização.
class DiagnosticoGps {
  final EstadoPermissaoGps permissao;

  /// GPS do aparelho desligado — dá pra rastrear assim que for ligado, mas
  /// até lá nenhuma posição é capturada.
  final bool servicoHabilitado;

  const DiagnosticoGps(this.permissao, {required this.servicoHabilitado});
}

class PermissaoGps {
  /// Verifica a permissão e o serviço de localização. Só pede a permissão
  /// ao usuário quando [solicitar] é true **e** ela está apenas negada (não
  /// negada de vez) — quem chama em segundo plano (sem tela pra mostrar o
  /// diálogo) passa false; quem chama a partir de uma ação do usuário pode
  /// passar true. Negada de vez nunca é perguntada de novo: o sistema não
  /// mostraria o diálogo, e insistir só incomodaria.
  static Future<DiagnosticoGps> diagnosticar({
    FonteGps fonte = const FonteGpsGeolocator(),
    bool solicitar = false,
  }) async {
    var permissao = await fonte.verificarPermissao();
    if (permissao == LocationPermission.denied && solicitar) {
      GpsLog.evento('permissão de localização negada — pedindo ao usuário');
      permissao = await fonte.solicitarPermissao();
    }
    final estado = _mapear(permissao);
    final servico = await fonte.servicoHabilitado();
    GpsLog.evento('diagnóstico',
        'permissão: ${estado.name}, serviço de localização: ${servico ? 'ligado' : 'desligado'}');
    return DiagnosticoGps(estado, servicoHabilitado: servico);
  }

  static EstadoPermissaoGps _mapear(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
        return EstadoPermissaoGps.concedidaSempre;
      case LocationPermission.whileInUse:
        return EstadoPermissaoGps.concedidaDuranteUso;
      case LocationPermission.deniedForever:
        return EstadoPermissaoGps.negadaPermanentemente;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return EstadoPermissaoGps.negada;
    }
  }
}
