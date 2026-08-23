import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_map/flutter_map.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart';

/// Chave do metadado de texto (chunk `tEXt`) gravado dentro do PNG,
/// contendo os limites geográficos do retângulo que a imagem cobre.
const _chaveGeoBounds = 'geo_bounds';

/// Lê os limites geográficos (bounds) de um PNG georreferenciado, embutidos
/// como metadado de texto dentro do próprio arquivo — evita hardcodar
/// coordenadas de sobreposição no código do app.
///
/// O metadado é gravado por uma ferramenta externa ao app (script de
/// preparação dos PNGs); aqui só há leitura.
///
/// Formato esperado do valor na chave `geo_bounds`:
/// `sw_lat=X;sw_lng=Y;ne_lat=X;ne_lng=Y`
class GeoPngHelper {
  GeoPngHelper._();

  /// Lê os bounds geográficos embutidos em [pngFile].
  ///
  /// Faz um parse leve do PNG (só a estrutura de chunks, sem decodificar os
  /// pixels) — suficiente para ler o metadado de texto.
  ///
  /// Lança [Exception] com mensagem clara se o arquivo não for um PNG
  /// válido, não tiver o metadado `geo_bounds` ou se o valor estiver
  /// malformado.
  static Future<LatLngBounds> readBounds(File pngFile) async {
    return readBoundsFromBytes(await pngFile.readAsBytes());
  }

  /// Igual a [readBounds], mas a partir dos bytes já em memória — usado
  /// quando o PNG vem de uma resposta de rede (ex: `cartaNauticaUrl` de uma
  /// recomendação) em vez de um arquivo local, evitando gravar um arquivo
  /// temporário só para ler o metadado.
  static Future<LatLngBounds> readBoundsFromBytes(Uint8List bytes) async {
    final decoder = img.PngDecoder();
    if (decoder.startDecode(bytes) == null) {
      throw Exception('Arquivo não é um PNG válido.');
    }

    final valor = decoder.info.textData[_chaveGeoBounds];
    if (valor == null || valor.trim().isEmpty) {
      throw Exception(
        'Este PNG não possui dados de georreferenciamento '
        '(metadado "$_chaveGeoBounds" ausente).',
      );
    }

    return _parseBounds(valor);
  }

  static LatLngBounds _parseBounds(String valor) {
    final campos = <String, double>{};
    for (final par in valor.split(';')) {
      final i = par.indexOf('=');
      if (i == -1) continue;
      final numero = double.tryParse(par.substring(i + 1).trim());
      if (numero != null) campos[par.substring(0, i).trim()] = numero;
    }

    final swLat = campos['sw_lat'];
    final swLng = campos['sw_lng'];
    final neLat = campos['ne_lat'];
    final neLng = campos['ne_lng'];

    if (swLat == null || swLng == null || neLat == null || neLng == null) {
      throw Exception(
        'Metadado "$_chaveGeoBounds" malformado: esperado '
        '"sw_lat=X;sw_lng=Y;ne_lat=X;ne_lng=Y", recebido "$valor".',
      );
    }

    return LatLngBounds(LatLng(swLat, swLng), LatLng(neLat, neLng));
  }
}
