import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/leitura_clorofila.dart';

/// Único lugar que conhece a rota/formato de `base/oceano/clorofila` — o
/// app NUNCA fala direto com a Copernicus Marine (as credenciais ficam só
/// no backend, ver doc do endpoint em [Endpoints.oceanoClorofila]); aqui só
/// pede o recorte (bbox + data) e devolve o que o backend responder.
///
/// Mesma ideia de "recurso = 1 repository" já usada pros outros recursos
/// da API Blue Ocean (ver `ViagemRepository`, `EmbarcacaoRepository` etc.)
class ClorofilaRepository {
  static final _formatoData = DateFormat('yyyy-MM-dd');

  /// [bounds] é o viewport visível do mapa (não o mundo inteiro — ver
  /// spec: "a aplicação não deve baixar o oceano inteiro"). [data] é
  /// opcional; sem ela, o backend decide (normalmente o dado diário mais
  /// recente disponível).
  Future<ClorofilaResposta> buscar({
    required LatLngBounds bounds,
    DateTime? data,
  }) async {
    final query = {
      'north': bounds.north.toStringAsFixed(4),
      'south': bounds.south.toStringAsFixed(4),
      'east': bounds.east.toStringAsFixed(4),
      'west': bounds.west.toStringAsFixed(4),
      if (data != null) 'date': _formatoData.format(data),
    };
    final rota =
        '${Endpoints.oceanoClorofila}?${Uri(queryParameters: query).query}';
    final json = await ApiService.get(rota) as Map<String, dynamic>;
    return ClorofilaResposta.fromJson(json);
  }
}
