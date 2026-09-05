import 'package:flutter/material.dart';

import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/fase_lua.dart';
import '../../../core/utils/tabela_solunar.dart';
import '../../widgets/posicao_atual_widget.dart';
import '../../widgets/previsao_tempo/previsao_tempo_widgets.dart';
import '../../widgets/profundidade_card.dart';
import '../../widgets/wave_forecast/fase_lua_card.dart';
import '../../widgets/wave_forecast/tabela_solunar_card.dart';
import '../../widgets/wave_forecast/wave_forecast_widgets.dart';
import 'mare_pesca_atum_screen.dart';
import '../data/fase_lua_repository.dart';
import '../data/previsao_tempo_repository.dart';
import '../data/profundidade_repository.dart';
import '../data/wave_forecast_repository.dart';
import '../domain/models/dia_lunar.dart';
import '../domain/models/leitura_profundidade.dart';
import 'fase_lua_screen.dart';

/// Tela com as condições do mar (temperatura da água, corrente, ondas/swell
/// e clima) na posição atual da embarcação — ou em qualquer outra posição
/// informada manualmente.
///
/// Pra consultar um ponto fixo (ex: um ponto marcado no mapa), sem GPS nem
/// campo de posição manual, ver [CondicoesPontoScreen].
class CondicoesMarScreen extends StatefulWidget {
  const CondicoesMarScreen({super.key});

  @override
  State<CondicoesMarScreen> createState() => _CondicoesMarScreenState();
}

class _CondicoesMarScreenState extends State<CondicoesMarScreen> {
  // ── Posição em uso pra todas as buscas (GPS por padrão, ou manual) ──────
  double? _lat;
  double? _lon;

  // ── Dados via API (Open-Meteo) ───────────────────────────────────────────
  WaveForecast? _waveForecast;
  PrevisaoTempo? _previsaoTempo;
  LeituraProfundidade? _profundidade;
  bool _carregandoOceano = false;
  String? _erroOceano;

  // Dias lunares (nascer/pôr) usados só pra montar a tabela solunar de hoje
  // (ver [_periodosSolunaresHoje]) — busca à parte, best-effort: uma falha
  // aqui não deve derrubar o resto da tela (ver [_buscarDiasLunares]).
  List<DiaLunar>? _diasLunares;

  Future<void> _buscarDadosOceano() async {
    if (_lat == null || _lon == null) return;

    setState(() {
      _carregandoOceano = true;
      _erroOceano = null;
    });
    try {
      final wave = await WaveForecastRepository()
          .buscar(latitude: _lat!, longitude: _lon!);
      final tempo = await PrevisaoTempoRepository()
          .buscar(latitude: _lat!, longitude: _lon!);
      final profundidade = await ProfundidadeRepository()
          .buscarPonto(latitude: _lat!, longitude: _lon!);

      if (!mounted) return;
      setState(() {
        _waveForecast = wave;
        _previsaoTempo = tempo;
        _profundidade = profundidade;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroOceano =
          mensagemErroAmigavel(e, prefixo: 'Erro ao buscar previsão'));
    } finally {
      if (mounted) setState(() => _carregandoOceano = false);
    }

    _buscarDiasLunares();
  }

  /// Busca à parte da principal (ver comentário do campo) — não usa o
  /// mesmo try/catch de cima pra um erro aqui nunca aparecer como "erro ao
  /// buscar previsão" e esconder onda/vento/maré que já carregaram certo.
  Future<void> _buscarDiasLunares() async {
    if (_lat == null || _lon == null) return;
    try {
      final dias =
          await FaseLuaRepository().buscar(latitude: _lat!, longitude: _lon!);
      if (!mounted) return;
      setState(() => _diasLunares = dias);
    } catch (e) {
      debugPrint('Erro ao buscar dias lunares pra tabela solunar: $e');
    }
  }

  /// Períodos solunares de hoje — precisa dos dias vizinhos pra interpolar
  /// perto da virada do dia (ver `calcularPeriodosSolunares`), por isso usa
  /// a lista inteira, não só o dia de hoje.
  List<PeriodoSolunar> get _periodosSolunaresHoje {
    final dias = _diasLunares;
    if (dias == null) return [];
    final agora = DateTime.now();
    final inicioDoDia = DateTime(agora.year, agora.month, agora.day);
    return calcularPeriodosSolunares(
      dias,
      desde: inicioDoDia,
      janela: const Duration(days: 1),
    );
  }

  // ── Posição ──────────────────────────────────────────────────────────────

  void _atualizarPosicao(double lat, double lon) {
    setState(() {
      _lat = lat;
      _lon = lon;
    });
    _buscarDadosOceano();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Condições do Mar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PosicaoAtualWidget(
            onPosicaoObtida: (posicao) =>
                _atualizarPosicao(posicao.latitude, posicao.longitude),
          ),
          const SizedBox(height: 16),
          // A fase da lua não depende de GPS nem de rede (ver
          // `calcularFaseLua`) — mostra já, sem esperar a posição nem a
          // previsão de onda/vento carregarem. Só o nascer/pôr por dia
          // depende de coordenada, e fica na tela dedicada (ver [onTap]).
          FaseLuaCard(
            faseAtual: calcularFaseLua(),
            proximasFases: proximasFasesPrincipais(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaseLuaScreen()),
            ),
          ),
          if (_periodosSolunaresHoje.isNotEmpty) ...[
            const SizedBox(height: 16),
            TabelaSolunarCard(periodos: _periodosSolunaresHoje),
          ],
          const SizedBox(height: 24),
          if (_lat == null || _lon == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aguardando posição atual da embarcação...',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_carregandoOceano)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erroOceano != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                        _erroOceano == mensagemSemConexao
                            ? Icons.wifi_off_outlined
                            : Icons.error_outline,
                        color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_erroOceano!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (_profundidade != null || _waveForecast != null) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_profundidade != null)
                      Expanded(child: ProfundidadeCard(leitura: _profundidade!)),
                    if (_profundidade != null && _waveForecast != null)
                      const SizedBox(width: 12),
                    if (_waveForecast != null)
                      Expanded(
                          child:
                              SeaSurfaceTemperatureCard(forecast: _waveForecast!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_previsaoTempo != null) ...[
              CondicoesVentoCard(previsao: _previsaoTempo!),
              const SizedBox(height: 16),
            ],
            if (_waveForecast != null) ...[
              CondicoesAtuaisCard(forecast: _waveForecast!),
              const SizedBox(height: 16),
              MareCard(
                forecast: _waveForecast!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MareEPescaAtumScreen()),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
