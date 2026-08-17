import 'package:flutter/foundation.dart';

import '../../features/dispositivo/data/dispositivo_repository.dart';
import '../../features/producao/data/producao_repository.dart';
import '../../features/producao/domain/models/producao_envio.dart';
import '../../features/producao/domain/models/producao_registro.dart';
import '../auth/auth_service.dart';
import '../database/database_helper.dart';
import 'device_id_service.dart';

/// Sincroniza com a API todos os registros de produção locais ainda não
/// enviados (`sincronizado = 0`) — mesmo padrão de
/// [LocalizacaoReporterService], adaptado pra `producao_registro`.
///
/// **Interruptor:** [sincronizacaoHabilitada] fica `false` até o backend
/// ter um endpoint de produção de verdade (`Endpoints.producaoRegistro`
/// hoje é placeholder). Com a flag desligada, [sincronizarPendentes] não
/// faz nenhuma chamada de rede — só confere se há pendências e retorna. O
/// resto do pipeline (fila local, resolução de dispositivo, marcação de
/// sincronizado) já está pronto e coberto por teste; quando o endpoint
/// real for confirmado, basta atualizar `Endpoints.producaoRegistro` e
/// virar esta flag pra `true`.
class ProducaoReporterService {
  static const bool sincronizacaoHabilitada = false;

  /// Chame depois de salvar um registro em `producao_registro` — mesmo
  /// papel que [LocalizacaoReporterService.sincronizarPendentes] tem lá,
  /// só que sem capturar nada novo aqui (quem grava o registro já fez
  /// isso); só varre a fila de pendências.
  static Future<void> sincronizarPendentes() async {
    if (!sincronizacaoHabilitada) {
      debugPrint(
          'ℹ️ Sincronização de produção desligada (endpoint ainda não confirmado no backend).');
      return;
    }

    if (!await AuthService.isLoggedIn()) {
      debugPrint(
          '⚠️ Sessão expirada — sincronização de produção adiada até novo login.');
      return;
    }

    final pendentes = await DatabaseHelper.instance.queryWhere(
      'producao_registro',
      where: 'sincronizado = ?',
      whereArgs: [0],
      orderBy: 'data_hora ASC',
    );
    if (pendentes.isEmpty) return;

    String dispositivoId;
    try {
      final deviceIdentificador = await DeviceIdService.obtemId();
      final dispositivo = await DispositivoRepository()
          .buscarPorIdentificador(deviceIdentificador);
      dispositivoId = dispositivo.id;
    } catch (e) {
      debugPrint(
          '❌ Sem internet ou erro ao buscar dispositivo — sincronização de produção adiada: $e');
      return;
    }

    var enviados = 0;
    for (final mapa in pendentes) {
      final registro = ProducaoRegistro.fromMap(mapa);

      // Registros salvos antes da v11 (sem tipo/classificação) não têm
      // como virar o payload novo — ficam pendentes até alguém editá-los
      // (funcionalidade ainda não existe) em vez de travar a fila inteira.
      if (registro.tipoPeixe == null ||
          registro.classificacao == null ||
          registro.pesoMedioUnitario == null ||
          registro.quantidadeUnidades == null) {
        debugPrint(
            '⚠️ Registro de produção ${registro.id} sem classificação — pulado.');
        continue;
      }

      try {
        await ProducaoRepository().enviar(ProducaoEnvio(
          embarcacaoId: registro.embarcacaoId,
          dispositivoId: dispositivoId,
          instante: registro.dataHora,
          tipoPeixe: registro.tipoPeixe!,
          classificacao: registro.classificacao!,
          quantidadeUnidades: registro.quantidadeUnidades!,
          pesoMedioUnitario: registro.pesoMedioUnitario!,
          quantidadeKg: registro.quantidadeKg,
          latitude: registro.latitude,
          longitude: registro.longitude,
          precisaoMetros: registro.precisaoMetros,
          viagemId: registro.viagemId,
          observacao: registro.observacao,
        ));
        await DatabaseHelper.instance.update(
          'producao_registro',
          {'sincronizado': 1},
          id: registro.id,
        );
        enviados++;
      } catch (e) {
        debugPrint('❌ Erro ao sincronizar produção ${registro.id}: $e');
        // Um registro com erro não deve travar a fila inteira — segue
        // tentando os outros pendentes.
      }
    }
    debugPrint(
        '🌐 Sincronização de produção: $enviados/${pendentes.length} registros enviados');
  }
}
