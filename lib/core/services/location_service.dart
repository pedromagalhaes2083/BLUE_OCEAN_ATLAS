import 'package:geolocator/geolocator.dart';

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
