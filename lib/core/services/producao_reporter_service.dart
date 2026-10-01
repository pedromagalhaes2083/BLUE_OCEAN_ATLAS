import 'package:flutter/foundation.dart';

import '../../features/producao/data/especie_repository.dart';
import '../../features/producao/data/producao_repository.dart';
import '../../features/producao/domain/models/producao_envio.dart';
import '../../features/producao/domain/models/producao_registro.dart';
import '../auth/auth_service.dart';
import '../database/database_helper.dart';

/// Sincroniza com a API todos os registros de produção locais ainda não
/// enviados (`sincronizado = 0`) — mesmo padrão de
/// [LocalizacaoReporterService], adaptado pra `producao_registro`.
///
/// O backend não modela classificação por peso (ver [ProducaoScreen]) — só
/// `especieId` (catálogo genérico cadastrado na plataforma, ver
/// `EspecieRepository`) e peso/quantidade totais — nem aceita captura sem
/// viagem (`viagemId` é obrigatório em `POST base/resultado/capturas`). Por
/// isso cada registro pendente precisa, antes de enviar:
/// 1. ter [ProducaoRegistro.viagemId] preenchido, e a viagem local
///    correspondente já ter um `remoto_id` salvo (ver
///    `ViagemRepository.criar`/`NovaViagemScreen`) — sem viagem em
///    andamento no momento do registro, ou enquanto o registro remoto da
///    viagem ainda não terminou, a captura fica pendente, não falha;
/// 2. ter um `especieId` resolvido — ou já veio pronto de
///    [ProducaoRegistro.especieId] (usuário escolheu uma sugestão do
///    catálogo na hora do registro, ver `ProducaoScreen`), ou é resolvido
///    aqui por nome (ver [_resolverEspecieId]) — cobre tanto texto livre
///    quanto registros salvos antes desta coluna existir.
class ProducaoReporterService {
  static const bool sincronizacaoHabilitada = true;

  /// Chame depois de salvar um registro em `producao_registro` — mesmo
  /// papel que [LocalizacaoReporterService.sincronizarPendentes] tem lá,
  /// só que sem capturar nada novo aqui (quem grava o registro já fez
  /// isso); só varre a fila de pendências.
  static Future<void> sincronizarPendentes() async {
    if (!sincronizacaoHabilitada) return;

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

    // Cache de especieId por nome — resolvido no máximo uma vez por
    // chamada, mesmo com vários registros pendentes da mesma espécie.
    final especieIdPorNome = <String, String>{};

    var enviados = 0;
    for (final mapa in pendentes) {
      final registro = ProducaoRegistro.fromMap(mapa);

      if (registro.especie.trim().isEmpty ||
          registro.quantidadeUnidades == null) {
        debugPrint(
            '⚠️ Registro de produção ${registro.id} sem classificação — pulado.');
        continue;
      }

      if (registro.viagemId == null) {
        debugPrint(
            '⚠️ Registro de produção ${registro.id} sem viagem vinculada — pulado (viagemId é obrigatório no backend).');
        continue;
      }

      final viagemRemotoId = await _resolverViagemRemota(registro.viagemId!);
      if (viagemRemotoId == null) {
        debugPrint(
            '⏳ Viagem ${registro.viagemId} ainda sem registro remoto — captura ${registro.id} adiada.');
        continue;
      }

      final especieId = registro.especieId ??
          await _resolverEspecieId(registro.especie, especieIdPorNome);
      if (especieId == null) {
        debugPrint(
            '⚠️ Espécie "${registro.especie}" não encontrada no catálogo — captura ${registro.id} pulada.');
        continue;
      }

      try {
        await ProducaoRepository().enviar(ProducaoEnvio(
          viagemId: viagemRemotoId,
          especieId: especieId,
          pesoKg: registro.quantidadeKg,
          quantidade: registro.quantidadeUnidades!,
          instante: registro.dataHora,
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

  /// Busca o `remoto_id` (UUID) salvo pra viagem local — nulo se a viagem
  /// não existe mais, ou se o registro remoto dela ainda não terminou (ver
  /// `NovaViagemScreen`).
  static Future<String?> _resolverViagemRemota(int viagemLocalId) async {
    final linhas = await DatabaseHelper.instance.queryWhere(
      'viagem',
      where: 'id = ?',
      whereArgs: [viagemLocalId],
    );
    if (linhas.isEmpty) return null;
    return linhas.first['remoto_id'] as String?;
  }

  /// Resolve o ID da espécie no catálogo remoto pelo nome digitado/exibido
  /// no registro, usando [cache] pra não bater na rede de novo dentro da
  /// mesma sincronização. Melhor-esforço: erro de rede ou espécie não
  /// encontrada retornam nulo em vez de lançar, pra não travar a fila
  /// inteira por um registro.
  static Future<String?> _resolverEspecieId(
    String nomeEspecie,
    Map<String, String> cache,
  ) async {
    final nome = nomeEspecie.trim();
    final cacheado = cache[nome.toLowerCase()];
    if (cacheado != null) return cacheado;

    try {
      final resultados = await EspecieRepository().listar(nome: nome);
      for (final especie in resultados) {
        if (especie.nome.trim().toLowerCase() == nome.toLowerCase()) {
          cache[nome.toLowerCase()] = especie.id;
          return especie.id;
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar espécie remota "$nome": $e');
    }
    return null;
  }
}
