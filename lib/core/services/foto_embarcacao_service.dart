import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FotoEmbarcacaoService {
  static Future<String> salvar(String origemPath) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final fotosDir = Directory(p.join(documentsDir.path, 'embarcacao_fotos'));
    if (!await fotosDir.exists()) {
      await fotosDir.create(recursive: true);
    }

    final extensao = p.extension(origemPath);
    final nomeArquivo =
        'embarcacao_${DateTime.now().millisecondsSinceEpoch}$extensao';
    final destino = p.join(fotosDir.path, nomeArquivo);

    await File(origemPath).copy(destino);
    return destino;
  }
}
