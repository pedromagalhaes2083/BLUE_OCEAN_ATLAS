import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/localizacao_reporter_service.dart';
import '../../core/utils/coordenadas_format.dart';
import 'position_card.dart';

/// Widget autocontido de posição GPS atual: cuida de permissões, loading,
/// erro, timeout e formatação DMS internamente. Basta incluir em qualquer
/// tela — não exige FAB nem estado externo.
///
/// Para disparar uma atualização de fora (ex: outro botão da tela), use um
/// `GlobalKey<PosicaoAtualWidgetState>` e chame `obterPosicaoAtual()`.
class PosicaoAtualWidget extends StatefulWidget {
  /// Chamado sempre que uma nova posição é obtida com sucesso — útil para
  /// telas que precisam da coordenada para outra lógica (ex: filtrar por
  /// distância).
  final void Function(Position posicao)? onPosicaoObtida;

  const PosicaoAtualWidget({super.key, this.onPosicaoObtida});

  @override
  State<PosicaoAtualWidget> createState() => PosicaoAtualWidgetState();
}

class PosicaoAtualWidgetState extends State<PosicaoAtualWidget> {
  Position? _posicaoAtual;
  bool _carregando = false;
  String? _erro;

  Position? get posicaoAtual => _posicaoAtual;

  @override
  void initState() {
    super.initState();
    obterPosicaoAtual();
  }

  /// Dispara uma nova tentativa de obter a posição.
  Future<void> obterPosicaoAtual() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final servicoAtivado = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivado) {
        if (!mounted) return;
        setState(
            () => _erro = '❌ Localização está desativada no dispositivo');
        return;
      }

      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _erro =
            '❌ Permissão negada permanentemente.\nVá em Configurações > Apps');
        return;
      }

      if (permissao == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => _erro = '❌ Permissão de localização negada');
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _posicaoAtual = posicao;
        _erro = null;
      });
      widget.onPosicaoObtida?.call(posicao);

      // Dispara gravação + sincronização em segundo plano (não trava a UI
      // nem o carregamento do card) — cobre a abertura do app com o mesmo
      // fluxo de fila offline usado no rastreamento periódico.
      unawaited(
        LocalizacaoReporterService.registrarESincronizar(
          posicaoConhecida: posicao,
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _erro =
          '❌ Tempo esgotado ao obter a posição.\nTente novamente em área aberta.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = '❌ Erro: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PositionCard(
      isLoadingPosition: _carregando,
      positionError: _erro,
      currentPosition: _posicaoAtual,
      formatCoordinates: formatarCoordenadasDMS,
      onRefresh: obterPosicaoAtual,
    );
  }
}
