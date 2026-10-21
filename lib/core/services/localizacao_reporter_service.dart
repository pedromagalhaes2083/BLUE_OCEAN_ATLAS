import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../features/dispositivo/data/dispositivo_repository.dart';
import '../../features/localizacao/data/localizacao_repository.dart';
import '../../features/localizacao/domain/models/localizacao_envio.dart';
import '../auth/auth_service.dart';
import '../config/config.dart';
import '../config/constantes.dart';
import '../database/database_helper.dart';
import '../gps/amostra_gps.dart';
import '../gps/fonte_gps.dart';
import '../gps/gps_log.dart';
import '../gps/validador_posicao.dart';
import 'device_id_service.dart';
import 'location_tracking_service.dart';

/// Captura a posição atual, faz a triagem (ver [ValidadorPosicao]), grava
/// no histórico local (`localizacao_historico`, associada à viagem em
/// andamento se houver) e sincroniza com a API os registros válidos ainda
/// não enviados — inclusive os pendentes de execuções anteriores sem
/// internet (`sincronizado = 0`).
///
/// Chamado periodicamente pelo serviço iniciado em
/// [LocationTrackingService.iniciarRastreamento] e também na abertura do app
/// (ver [PosicaoAtualWidget]).
///
/// Gravar vem sempre antes de enviar, e nenhuma falha de envio (rede,
/// sessão, servidor) interrompe a captura: o histórico local é a fonte de
/// verdade, a API recebe quando der.
class LocalizacaoReporterService {
  static const _limiteCaptura = Duration(seconds: 20);

  /// Uma reserva de envio mais velha que isso é de um envio que morreu no
  /// meio (app/serviço morto pelo sistema) — o registro volta a ficar
  /// disponível pra envio.
  static const reservaExpiraApos = Duration(minutes: 10);

  static Future<void>? _sincronizacaoEmAndamento;

  /// [posicaoConhecida] evita um novo fix de GPS quando quem chamou (ex:
  /// [PosicaoAtualWidget] na abertura do app) já obteve a posição atual
  /// segundos antes.
  static Future<void> registrarESincronizar({
    Position? posicaoConhecida,
  }) async {
    await registrarPosicao(
      amostraConhecida: posicaoConhecida == null
          ? null
          : AmostraGps.dePosition(posicaoConhecida),
    );
    await sincronizarPendentes();
  }

  /// Captura (ou usa [amostraConhecida]), valida e grava uma posição.
  /// Devolve o resultado da triagem, ou null se não havia posição nenhuma
  /// pra gravar (sem sinal e sem última posição do sistema) ou se a
  /// gravação falhou. Nunca lança — roda dentro do serviço em segundo
  /// plano, onde uma exceção não teria quem tratar.
  static Future<ResultadoValidacaoGps?> registrarPosicao({
    AmostraGps? amostraConhecida,
    FonteGps fonte = const FonteGpsGeolocator(),
    DateTime? agora,
  }) async {
    final amostra = amostraConhecida ?? await _capturar(fonte);
    if (amostra == null) return null;

    try {
      final referencias = await _referenciasDeValidacao();
      final resultado = ValidadorPosicao.validar(
        amostra,
        agora: (agora ?? DateTime.now()).toUtc(),
        anteriorValida: referencias.valida,
        ultimaSuspeitaPorSalto: referencias.suspeitaPorSalto,
        config: await _configValidacao(),
      );

      final motivos = resultado.motivos.map((m) => m.name).join(',');
      if (resultado.invalida) {
        GpsLog.evento('posição descartada (inválida)', motivos);
        return resultado;
      }
      if (!resultado.valida) {
        GpsLog.evento('posição suspeita — guardada só pra auditoria',
            '$motivos (${GpsLog.coordenada(amostra.latitude, amostra.longitude)})');
      }

      int? bateriaNivel;
      try {
        bateriaNivel = await Battery().batteryLevel;
      } catch (_) {
        // Nível de bateria é informativo — segue sem ele se indisponível.
      }

      final viagens = await DatabaseHelper.instance.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      final viagemId = viagens.isNotEmpty ? viagens.first['id'] as int? : null;

      final gravou = await _inserirSeNova({
        // Instante do fix do GPS, não do momento da gravação — com a última
        // posição conhecida ou um GPS que demorou a responder, os dois
        // podem estar minutos distantes.
        'data_hora': amostra.instante.toUtc().toIso8601String(),
        'latitude': amostra.latitude,
        'longitude': amostra.longitude,
        'velocidade': amostra.velocidadeMs,
        'precisao': amostra.precisaoMetros,
        'altitude': amostra.altitude,
        'direcao': amostra.rumoGraus?.round(),
        'bateria_nivel': bateriaNivel,
        'viagem_id': viagemId,
        'sincronizado': 0,
        'validacao': resultado.status.name,
        'motivos_validacao': motivos.isEmpty ? null : motivos,
      });
      if (!gravou) {
        GpsLog.evento('posição repetida ignorada',
            'o mesmo fix do GPS já estava gravado');
        return resultado;
      }

      if (resultado.valida) {
        GpsLog.evento('posição registrada',
            GpsLog.coordenada(amostra.latitude, amostra.longitude));
      }
      return resultado;
    } catch (e) {
      GpsLog.evento('falha ao gravar posição no banco local', '$e');
      return null;
    }
  }

  /// Grava a posição só se ainda não houver uma com o mesmo instante de GPS
  /// e as mesmas coordenadas. Na abertura do app, o serviço de rastreamento
  /// e a tela inicial capturam quase juntos e podem receber o mesmo fix —
  /// gravado duas vezes, o servidor recusava a segunda ("Posicionamento
  /// duplicado ou inválido", visto num aparelho real em 2026-10-21) e ela
  /// ficava pendente pra sempre. Uma instrução só (INSERT … WHERE NOT
  /// EXISTS) é atômica no SQLite, inclusive entre o app e o serviço
  /// (isolates diferentes). Devolve se gravou.
  static Future<bool> _inserirSeNova(Map<String, Object?> valores) async {
    final db = await DatabaseHelper.instance.database;
    final colunas = valores.keys.toList();
    // rawInsert devolve o id da linha nova, ou 0 quando o NOT EXISTS barrou
    // a inserção.
    final id = await db.rawInsert(
      'INSERT INTO localizacao_historico (${colunas.join(', ')}) '
      'SELECT ${List.filled(colunas.length, '?').join(', ')} '
      'WHERE NOT EXISTS (SELECT 1 FROM localizacao_historico '
      'WHERE data_hora = ? AND latitude = ? AND longitude = ?)',
      [
        ...valores.values,
        valores['data_hora'],
        valores['latitude'],
        valores['longitude'],
      ],
    );
    return id > 0;
  }

  /// Uma posição nova; sem sinal dentro do limite, cai pra última posição
  /// que o sistema já tinha (a triagem marca como antiga se for o caso, em
  /// vez de perder a rodada inteira).
  static Future<AmostraGps?> _capturar(FonteGps fonte) async {
    try {
      return await fonte.posicaoAtual(limite: _limiteCaptura);
    } catch (e) {
      GpsLog.evento('sem posição nova do GPS', '$e');
    }
    try {
      final ultima = await fonte.ultimaPosicaoConhecida();
      if (ultima != null) {
        GpsLog.evento('usando a última posição conhecida do sistema');
        return ultima;
      }
    } catch (e) {
      GpsLog.evento('sem última posição conhecida', '$e');
    }
    GpsLog.evento('nenhuma posição disponível — nada gravado nesta rodada');
    return null;
  }

  /// A última posição válida e, se a gravação mais recente depois dela foi
  /// suspeita só por salto, essa suspeita (ver
  /// [MotivoValidacaoGps.reancorada]).
  static Future<({AmostraGps? valida, AmostraGps? suspeitaPorSalto})>
      _referenciasDeValidacao() async {
    final db = await DatabaseHelper.instance.database;
    final valida = await db.query(
      'localizacao_historico',
      where: 'validacao = ?',
      whereArgs: ['valida'],
      orderBy: 'data_hora DESC',
      limit: 1,
    );
    final ultima = await db.query(
      'localizacao_historico',
      orderBy: 'data_hora DESC',
      limit: 1,
    );

    AmostraGps paraAmostra(Map<String, Object?> linha) => AmostraGps(
          latitude: (linha['latitude'] as num).toDouble(),
          longitude: (linha['longitude'] as num).toDouble(),
          instante: DateTime.parse(linha['data_hora'] as String).toUtc(),
          precisaoMetros: (linha['precisao'] as num?)?.toDouble(),
        );

    final suspeita = ultima.isNotEmpty &&
            ultima.first['validacao'] == 'suspeita' &&
            ultima.first['motivos_validacao'] ==
                MotivoValidacaoGps.saltoImplausivel.name
        ? paraAmostra(ultima.first)
        : null;
    return (
      valida: valida.isEmpty ? null : paraAmostra(valida.first),
      suspeitaPorSalto: suspeita,
    );
  }

  static Future<ConfigValidacaoGps> _configValidacao() async {
    final bruto = await Config.obtem(Constantes.gpsVelocidadeMaximaNos, '');
    final nos = double.tryParse(bruto.replaceAll(',', '.'));
    return nos != null && nos > 0
        ? ConfigValidacaoGps(velocidadeMaximaNos: nos)
        : const ConfigValidacaoGps();
  }

  /// Envia pra API os registros válidos ainda não sincronizados — tanto o
  /// que acabou de ser gravado quanto qualquer backlog de quando o aparelho
  /// estava sem internet.
  ///
  /// Chamadas simultâneas nesta isolate compartilham o mesmo envio. Entre
  /// isolates (app aberto + serviço de rastreamento), cada registro é
  /// reservado no banco antes de ir pra API (`sync_reservado_em`), então os
  /// dois nunca enviam o mesmo registro ao mesmo tempo.
  ///
  /// Os parâmetros existem só pros testes substituírem a rede e a sessão.
  static Future<void> sincronizarPendentes({
    @visibleForTesting Future<bool> Function()? garantirSessao,
    @visibleForTesting Future<String> Function()? resolverDispositivoId,
    @visibleForTesting Future<void> Function(LocalizacaoEnvio)? enviar,
  }) {
    return _sincronizacaoEmAndamento ??= _sincronizar(
      garantirSessao: garantirSessao ?? _garantirSessao,
      resolverDispositivoId: resolverDispositivoId ?? _resolverDispositivoId,
      enviar: enviar ?? LocalizacaoRepository().enviar,
    ).whenComplete(() {
      _sincronizacaoEmAndamento = null;
    });
  }

  static Future<void> _sincronizar({
    required Future<bool> Function() garantirSessao,
    required Future<String> Function() resolverDispositivoId,
    required Future<void> Function(LocalizacaoEnvio) enviar,
  }) async {
    try {
      // Sem sessão o envio só fica pra depois — o rastreamento continua
      // gravando localmente. (Antes, uma falha aqui parava o serviço de
      // rastreamento: sem internet em alto-mar, o token vence em ~30 min,
      // o login automático falha por falta de rede, e nenhuma posição era
      // mais gravada até o app ser reaberto com sinal.)
      if (!await garantirSessao()) return;

      // Sem fallback pra uma embarcação real: se nada foi configurado
      // ainda, os registros ficam pendentes localmente em vez de serem
      // enviados associados a uma embarcação que pode não ser a do usuário.
      final embarcacaoId = await Config.obtem(Constantes.embarcacaoId, '');
      if (embarcacaoId.isEmpty) {
        GpsLog.evento('envio adiado: embarcação não configurada');
        return;
      }

      final db = await DatabaseHelper.instance.database;
      final pendentes = await db.query(
        'localizacao_historico',
        where: 'sincronizado = 0 AND validacao = ? AND '
            '(sync_reservado_em IS NULL OR sync_reservado_em < ?)',
        whereArgs: ['valida', _limiteReserva()],
        orderBy: 'data_hora ASC',
      );
      if (pendentes.isEmpty) return;

      // O backend exige um UUID nesse campo (confirmado via erro de
      // validação "dispositivoId must be a UUID") — não aceita o
      // identificador bruto do aparelho, só o UUID do registro.
      final String dispositivoId;
      try {
        dispositivoId = await resolverDispositivoId();
      } catch (e) {
        GpsLog.evento('envio adiado: não foi possível identificar o dispositivo',
            _descreverErro(e));
        return;
      }

      var enviados = 0;
      for (final registro in pendentes) {
        final id = registro['id'] as int;
        if (await _gemeaJaEnviada(db, registro)) {
          // Duplicata de uma posição que o servidor já tem (gravada antes do
          // `_inserirSeNova` existir) — reenviar só levaria outro "400
          // duplicado". Marca como sincronizada sem chamar a API.
          await db.update('localizacao_historico',
              {'sincronizado': 1, 'sync_reservado_em': null},
              where: 'id = ?', whereArgs: [id]);
          GpsLog.evento('posição $id já enviada (duplicata) — marcada sem reenviar');
          continue;
        }
        if (!await _reservar(db, id)) continue; // outra isolate está enviando

        try {
          final velocidadeMs = (registro['velocidade'] as num?)?.toDouble();
          await enviar(LocalizacaoEnvio(
            embarcacaoId: embarcacaoId,
            dispositivoId: dispositivoId,
            instante: DateTime.parse(registro['data_hora'] as String).toUtc(),
            latitude: (registro['latitude'] as num).toDouble(),
            longitude: (registro['longitude'] as num).toDouble(),
            precisaoMetros: (registro['precisao'] as num?)?.toDouble(),
            altitude: (registro['altitude'] as num?)?.toDouble(),
            velocidadeNos: velocidadeMs != null ? velocidadeMs * 1.94384 : null,
            direcao: (registro['direcao'] as num?)?.toInt(),
            bateriaNivel: (registro['bateria_nivel'] as num?)?.toInt(),
          ));
        } catch (e) {
          await _liberar(db, id);
          GpsLog.evento('falha ao enviar posição $id', _descreverErro(e));
          // Sem rede, os próximos falhariam igual — para e tenta na próxima
          // rodada. Erro do servidor com um registro específico não deve
          // travar a fila: segue com os outros.
          if (_ehErroDeRede(e)) break;
          continue;
        }

        // Só marca sincronizado depois da confirmação da API.
        await db.update(
          'localizacao_historico',
          {'sincronizado': 1, 'sync_reservado_em': null},
          where: 'id = ?',
          whereArgs: [id],
        );
        enviados++;
      }
      GpsLog.evento(
          'sincronização', '$enviados/${pendentes.length} posições enviadas');
    } catch (e) {
      GpsLog.evento('falha na sincronização de posições', _descreverErro(e));
    }
  }

  /// Reserva o registro pra esta isolate. A condição no UPDATE torna isso
  /// atômico no SQLite: se outra isolate reservou (ou já sincronizou) entre
  /// a consulta e aqui, nenhuma linha muda e o registro é pulado.
  static Future<bool> _reservar(dynamic db, int id) async {
    final linhas = await db.rawUpdate(
      'UPDATE localizacao_historico SET sync_reservado_em = ? '
      'WHERE id = ? AND sincronizado = 0 AND '
      '(sync_reservado_em IS NULL OR sync_reservado_em < ?)',
      [DateTime.now().toUtc().toIso8601String(), id, _limiteReserva()],
    );
    return linhas == 1;
  }

  /// Já existe outra linha com o mesmo fix (instante + coordenadas) marcada
  /// como sincronizada?
  static Future<bool> _gemeaJaEnviada(
      dynamic db, Map<String, Object?> registro) async {
    final gemeas = await db.query(
      'localizacao_historico',
      columns: ['id'],
      where: 'id != ? AND sincronizado = 1 AND data_hora = ? AND '
          'latitude = ? AND longitude = ?',
      whereArgs: [
        registro['id'],
        registro['data_hora'],
        registro['latitude'],
        registro['longitude'],
      ],
      limit: 1,
    );
    return gemeas.isNotEmpty;
  }

  static Future<void> _liberar(dynamic db, int id) async {
    await db.update(
      'localizacao_historico',
      {'sync_reservado_em': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static String _limiteReserva() =>
      DateTime.now().toUtc().subtract(reservaExpiraApos).toIso8601String();

  static Future<bool> _garantirSessao() async {
    if (await AuthService.isLoggedIn()) return true;
    // Token vencido não é sessão morta — tenta renovar com a credencial
    // lembrada (mesmo mecanismo do boot do app).
    final resultado = await AuthService.renovarSessao();
    switch (resultado) {
      case ResultadoRenovacaoSessao.ok:
        GpsLog.evento('sessão renovada automaticamente');
        return true;
      case ResultadoRenovacaoSessao.semConexao:
        GpsLog.evento('envio adiado: sem conexão pra renovar a sessão');
        return false;
      case ResultadoRenovacaoSessao.credencialRecusada:
        GpsLog.evento('envio adiado: credencial recusada pelo servidor — '
            'o mestre precisa entrar de novo no app');
        return false;
      case ResultadoRenovacaoSessao.semCredencial:
        GpsLog.evento('envio adiado: sessão expirada e sem credencial lembrada');
        return false;
    }
  }

  static Future<String> _resolverDispositivoId() async {
    final identificador = await DeviceIdService.obtemId();
    final dispositivo =
        await DispositivoRepository().buscarPorIdentificador(identificador);
    return dispositivo.id;
  }

  static bool _ehErroDeRede(Object e) =>
      e is SocketException ||
      e is TimeoutException ||
      e is http.ClientException ||
      e is HandshakeException;

  /// Mensagens de erro da API podem trazer o corpo inteiro da resposta —
  /// corta pra não encher o log.
  static String _descreverErro(Object e) {
    final texto = '$e'.replaceAll('\n', ' ');
    return texto.length > 200 ? '${texto.substring(0, 200)}…' : texto;
  }
}
