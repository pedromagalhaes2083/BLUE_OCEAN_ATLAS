import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Obtém a posição atual do usuário
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool requestPermission = true,
  }) async {
    try {
      // Verifica permissão
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (!requestPermission) return null;
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada');
      }

      // Verifica se o serviço de localização está ativo
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desativado');
      }

      // Obtém a posição
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      ).timeout(const Duration(seconds: 15));
    } catch (e) {
      rethrow; // Deixa a tela tratar o erro
    }
  }

  /// Pede a permissão de localização "sempre" (`ACCESS_BACKGROUND_LOCATION`),
  /// necessária pra a tarefa periódica em segundo plano
  /// ([LocationTrackingService]) conseguir capturar a posição com o app
  /// fechado — sem ela, o Android bloqueia silenciosamente o GPS fora do
  /// app em primeiro plano, mesmo com a tarefa do WorkManager rodando.
  ///
  /// No Android, só dá pra pedir "sempre" depois de já ter "enquanto uso o
  /// app" concedido — por isso primeiro garante isso, e só então tenta a
  /// segunda etapa. Chamar de novo com "enquanto uso" já concedido é o
  /// gatilho que faz o Android mostrar (ou abrir, a partir do Android 11)
  /// a opção "Permitir o tempo todo".
  Future<LocationPermission> solicitarPermissaoSempre() async {
    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.whileInUse) {
      permissao = await Geolocator.requestPermission();
    }

    return permissao;
  }

  /// Pede pro Android ignorar a otimização de bateria pra este app —
  /// distinto da permissão de localização "sempre". Muitos fabricantes
  /// (Xiaomi, Samsung, Huawei etc.) matam tarefas em segundo plano
  /// agressivamente mesmo com a permissão de GPS correta, a menos que o
  /// app esteja na lista de exceções de bateria. Mostra o diálogo nativo
  /// do Android ("Permitir" / "Não permitir"); retorna se ficou concedida.
  ///
  /// Sem efeito em iOS (a plataforma não tem esse conceito) — retorna true
  /// direto.
  Future<bool> solicitarIgnorarOtimizacaoBateria() async {
    final status = await ph.Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return true;

    final resultado =
        await ph.Permission.ignoreBatteryOptimizations.request();
    return resultado.isGranted;
  }

  /// Converte Decimal para DMS (formato amigável)
  String decimalToDMS(double decimal, bool isLatitude) {
    String direction =
        isLatitude ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');

    decimal = decimal.abs();
    int degrees = decimal.floor();
    double minutesDecimal = (decimal - degrees) * 60;
    int minutes = minutesDecimal.floor();
    double seconds = (minutesDecimal - minutes) * 60;

    return '$degrees° $minutes\' ${seconds.toStringAsFixed(1)}" $direction';
  }
}
