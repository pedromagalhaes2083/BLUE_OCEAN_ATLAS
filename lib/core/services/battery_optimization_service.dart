import 'dart:io';

import 'package:permission_handler/permission_handler.dart' as ph;

/// Checa se o app está isento da otimização de bateria do Android — sem
/// isso, vários fabricantes (Samsung, Xiaomi, Huawei etc.) matam tarefas em
/// segundo plano de forma agressiva, e o rastreamento de GPS a cada 15 min
/// simplesmente para de rodar sem nenhum aviso ao usuário. Complementa
/// `LocationService.solicitarIgnorarOtimizacaoBateria` (que já pede a
/// isenção uma vez, ao iniciar uma viagem) com uma checagem que pode ser
/// repetida a qualquer momento — pro caso do usuário ter negado o pedido
/// inicial, ou o aparelho ter revogado a isenção depois (acontece em
/// alguns fabricantes após atualização do sistema).
///
/// Só existe no Android — no iOS o sistema não expõe esse controle, então
/// [estaIgnorandoOtimizacao] sempre devolve `true` lá (nada a avisar).
class BatteryOptimizationService {
  static Future<bool> estaIgnorandoOtimizacao() async {
    if (!Platform.isAndroid) return true;
    final status = await ph.Permission.ignoreBatteryOptimizations.status;
    return status.isGranted;
  }

  /// Mesmo pedido usado em `NovaViagemScreen` — reaproveitado aqui pra
  /// telas fora do fluxo de iniciar viagem (ex: Configurações).
  static Future<bool> solicitarIsencao() async {
    if (!Platform.isAndroid) return true;
    final resultado =
        await ph.Permission.ignoreBatteryOptimizations.request();
    return resultado.isGranted;
  }
}
