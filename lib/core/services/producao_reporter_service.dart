import 'package:flutter/foundation.dart';

import '../../features/producao/data/especie_repository.dart';
import '../../features/producao/data/producao_repository.dart';
import '../../features/producao/domain/classificacao_peso.dart';
import '../../features/producao/domain/models/producao_envio.dart';
import '../../features/producao/domain/models/producao_registro.dart';
import '../auth/auth_service.dart';
import '../database/database_helper.dart';

/// Sincroniza com a API todos os registros de produção locais ainda não
/// enviados (`sincronizado = 0`) — mesmo padrão de
/// [LocalizacaoReporterService], adaptado pra `producao_registro`.
///
/// O backend não modela tipo/classificação de peixe (ver
/// [ProducaoScreen]) — só `especieId` (catálogo genérico) e peso/
/// quantidade totais — nem aceita captura sem viagem (`viagemId` é
/// obrigatório em `POST base/resultado/capturas`). Por isso cada registro
/// pendente precisa, antes de enviar:
/// 1. ter [ProducaoRegistro.viagemId] preenchido, e a viagem local
///    correspondente já ter um `remoto_id` salvo (ver
///    `ViagemRepository.criar`/`NovaViagemScreen`) — sem viagem em
///    andamento no momento do registro, ou enquanto o registro remoto da
///    viagem ainda não terminou, a captura fica pendente, não falha;
/// 2. ter [ProducaoRegistro.tipoPeixe] preenchido, pra resolver o
///    `especieId` correspondente no catálogo (ver [_nomeEspecieRemota]).
class ProducaoReporterService {
  static const bool sincronizacaoHabilitada = true;

  /// Nome da espécie no catálogo remoto (cadastrado na plataforma) pra
  /// cada [TipoPeixe] local — o catálogo genérico não distingue Kihada de
  /// Bati, só tem uma entrada de atum pra ambos.
  static const Map<TipoPeixe, String> _nomeEspecieRemota = {
    TipoPeixe.kihada: 'Atum',
    TipoPeixe.bati: 'Atum',
  };

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

    // Cache de especieId por tipo — resolvido no máximo uma vez por
    // chamada, mesmo com vários registros pendentes do mesmo tipo.
    final especieIdPorTipo = <TipoPeixe, String>{};

    var enviados = 0;
    for (final mapa in pendentes) {
      final registro = ProducaoRegistro.fromMap(mapa);

      // Registros salvos antes da v11 (sem tipo/classificação) não têm
      // como virar o payload novo — ficam pendentes até alguém editá-los
      // (funcionalidade ainda não existe) em vez de travar a fila inteira.
      if (registro.tipoPeixe == null || registro.quantidadeUnidades == null) {
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

      final especieId = await _resolverEspecieId(
          registro.tipoPeixe!, especieIdPorTipo);
      if (especieId == null) {
        debugPrint(
            '⚠️ Espécie "${_nomeEspecieRemota[registro.tipoPeixe]}" não encontrada no catálogo — captura ${registro.id} pulada.');
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

  /// Resolve o ID da espécie no catálogo remoto pro [tipo] dado, usando
  /// [cache] pra não bater na rede de novo dentro da mesma sincronização.
  /// Melhor-esforço: erro de rede ou espécie não encontrada retornam nulo
  /// em vez de lançar, pra não travar a fila inteira por um registro.
  static Future<String?> _resolverEspecieId(
    TipoPeixe tipo,
    Map<TipoPeixe, String> cache,
  ) async {
    final cacheado = cache[tipo];
    if (cacheado != null) return cacheado;

    final nome = _nomeEspecieRemota[tipo];
    if (nome == null) return null;

    try {
      final resultados = await EspecieRepository().listar(nome: nome);
      for (final especie in resultados) {
        if (especie.nome.trim().toLowerCase() == nome.toLowerCase()) {
          cache[tipo] = especie.id;
          return especie.id;
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar espécie remota "$nome": $e');
    }
    return null;
  }
}
