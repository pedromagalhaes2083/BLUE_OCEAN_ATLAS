import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Pasta onde ficam os áudios do diário de bordo — um arquivo por nota,
/// nomeado pelo horário de gravação, dentro de uma subpasta por viagem
/// (mesmo padrão de pasta-por-registro de `FotoEmbarcacaoService`, só com
/// mais um nível pra não misturar áudio de viagens diferentes na mesma
/// pasta). Nunca sincronizado com o backend — ver doc de
/// `DiarioBordoEntrada`.
class DiarioBordoAudioService {
  static Future<Directory> _pastaViagem(int viagemId) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final pasta = Directory(
        p.join(documentsDir.path, 'diario_bordo_audio', 'viagem_$viagemId'));
    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }
    return pasta;
  }

  /// Caminho completo pra uma gravação nova dessa viagem — quem grava usa
  /// esse caminho como destino direto do `record` (ver `DiarioBordoScreen`),
  /// não copia um arquivo já existente (diferente de
  /// `FotoEmbarcacaoService.salvar`, que recebe uma foto já tirada).
  static Future<String> proximoCaminho(int viagemId) async {
    final pasta = await _pastaViagem(viagemId);
    final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    return p.join(pasta.path, nomeArquivo);
  }

  /// Apaga o arquivo de áudio de uma nota removida — nunca lança se o
  /// arquivo já não existir (ex: removido manualmente, ou nota que nunca
  /// chegou a gravar nada).
  static Future<void> apagar(String caminhoAudio) async {
    final arquivo = File(caminhoAudio);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
