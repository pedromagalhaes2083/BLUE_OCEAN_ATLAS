import 'dart:io' show Platform;
import 'dart:math';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/config.dart';
import '../config/constantes.dart';

/// Informações descritivas do aparelho, apenas para exibição (não são
/// usadas como identificador — veja [DeviceIdService.obtemId] para isso).
class DeviceInfoResumo {
  final String modelo;
  final String fabricante;
  final String sistemaOperacional;
  final String versaoSO;

  const DeviceInfoResumo({
    required this.modelo,
    required this.fabricante,
    required this.sistemaOperacional,
    required this.versaoSO,
  });
}

/// Gera e obtém um identificador único para o aparelho onde o app está
/// instalado, estável mesmo após reinstalação.
///
/// - Android: usa o `Settings.Secure.ANDROID_ID` do sistema (via pacote
///   `android_id`). Esse valor não depende do armazenamento do app — ele só
///   muda em reset de fábrica ou se a chave de assinatura do app mudar.
/// - iOS: não há um equivalente 100% garantido (o `identifierForVendor` pode
///   mudar se todos os apps do desenvolvedor forem removidos e reinstalados).
///   Por isso o ID é gerado uma vez e salvo no Keychain (via
///   `flutter_secure_storage`), que sobrevive à desinstalação do app.
class DeviceIdService {
  static const _chaveSegura = 'device_id';
  static const _secureStorage = FlutterSecureStorage();
  static String? _cache;

  static Future<String> obtemId() async {
    if (_cache != null) return _cache!;

    final String id;
    if (Platform.isAndroid) {
      id = await const AndroidId().getId() ?? await _idPersistenteGenerico();
    } else if (Platform.isIOS) {
      id = await _obtemIdIOS();
    } else {
      id = await _idPersistenteGenerico();
    }

    _cache = id;
    return id;
  }

  static Future<String> _obtemIdIOS() async {
    final salvo = await _secureStorage.read(key: _chaveSegura);
    if (salvo != null && salvo.isNotEmpty) return salvo;

    final info = await DeviceInfoPlugin().iosInfo;
    final gerado = info.identifierForVendor ?? _idAleatorio();
    await _secureStorage.write(key: _chaveSegura, value: gerado);
    return gerado;
  }

  /// Fallback para plataformas sem um ID de sistema estável disponível
  /// (ex: desktop/web). Não sobrevive à reinstalação.
  static Future<String> _idPersistenteGenerico() async {
    final salvo = await Config.obtem(Constantes.deviceId);
    if (salvo.isNotEmpty) return salvo;

    final gerado = _idAleatorio();
    await Config.grava(Constantes.deviceId, gerado);
    return gerado;
  }

  static String _idAleatorio() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(16).toRadixString(16))
        .join();
  }

  static Future<DeviceInfoResumo> obtemInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return DeviceInfoResumo(
        modelo: info.model,
        fabricante: info.manufacturer,
        sistemaOperacional: 'Android',
        versaoSO: info.version.release,
      );
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return DeviceInfoResumo(
        modelo: info.utsname.machine,
        fabricante: 'Apple',
        sistemaOperacional: info.systemName,
        versaoSO: info.systemVersion,
      );
    }

    return const DeviceInfoResumo(
      modelo: 'Desconhecido',
      fabricante: 'Desconhecido',
      sistemaOperacional: 'Desconhecido',
      versaoSO: '',
    );
  }
}
