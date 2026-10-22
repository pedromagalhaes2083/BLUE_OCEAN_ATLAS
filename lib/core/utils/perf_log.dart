import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Medição de desempenho de quadros, pra comparar antes/depois de uma
/// otimização num aparelho real (build release, onde o DevTools não está à
/// mão). Só existe quando o app é compilado com
/// `--dart-define=PERF_LOG=true` — no build normal, [ativo] é uma constante
/// falsa e tudo aqui some na compilação.
///
/// A cada [_janela], escreve no log (`[Perf]`) quantos quadros foram
/// desenhados, os tempos de build (UI thread) e raster (GPU thread) —
/// mediana, p90 e máximo — a fração de quadros acima do orçamento de 60 Hz
/// e quantas vezes cada contador de [contar] foi incrementado (ex.: quantas
/// vezes o `build()` do mapa rodou).
class PerfLog {
  static const ativo = bool.fromEnvironment('PERF_LOG');

  static const _janela = Duration(seconds: 5);
  static const _orcamentoQuadroUs = 16667; // 60 Hz

  static final _build = <int>[];
  static final _raster = <int>[];
  static final _contadores = <String, int>{};
  static DateTime _inicioJanela = DateTime.now();

  static void iniciar() {
    if (!ativo) return;
    SchedulerBinding.instance.addTimingsCallback(_aoReceberTempos);
    debugPrint('[Perf] medição de quadros ativa (janela de ${_janela.inSeconds} s)');
  }

  /// Incrementa um contador da janela atual (ex.: `mapa.build`).
  static void contar(String nome) {
    if (!ativo) return;
    _contadores[nome] = (_contadores[nome] ?? 0) + 1;
  }

  static void _aoReceberTempos(List<FrameTiming> tempos) {
    for (final t in tempos) {
      _build.add(t.buildDuration.inMicroseconds);
      _raster.add(t.rasterDuration.inMicroseconds);
    }
    if (DateTime.now().difference(_inicioJanela) >= _janela) _emitir();
  }

  static void _emitir() {
    if (_build.isNotEmpty) {
      final acimaOrcamento = List.generate(_build.length, (i) => i)
          .where((i) => _build[i] > _orcamentoQuadroUs || _raster[i] > _orcamentoQuadroUs)
          .length;
      debugPrint('[Perf] quadros=${_build.length} '
          'build(ms) p50=${_ms(_pct(_build, 50))} p90=${_ms(_pct(_build, 90))} '
          'max=${_ms(_pct(_build, 100))} | '
          'raster(ms) p50=${_ms(_pct(_raster, 50))} p90=${_ms(_pct(_raster, 90))} '
          'max=${_ms(_pct(_raster, 100))} | '
          'acima de 16,7 ms: $acimaOrcamento '
          '(${(100 * acimaOrcamento / _build.length).toStringAsFixed(0)}%) | '
          '${_contadores.entries.map((e) => '${e.key}=${e.value}').join(' ')}');
    }
    _build.clear();
    _raster.clear();
    _contadores.clear();
    _inicioJanela = DateTime.now();
  }

  static int _pct(List<int> valores, int percentil) {
    final ordenados = [...valores]..sort();
    final i = ((percentil / 100) * (ordenados.length - 1)).round();
    return ordenados[i];
  }

  static String _ms(int us) => (us / 1000).toStringAsFixed(1);
}
