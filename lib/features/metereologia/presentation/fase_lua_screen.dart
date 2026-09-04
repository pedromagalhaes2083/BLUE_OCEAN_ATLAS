import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/fase_lua.dart';
import '../../../core/utils/tabela_solunar.dart';
import '../../widgets/posicao_atual_widget.dart';
import '../../widgets/wave_forecast/fase_lua_card.dart';
import '../../widgets/wave_forecast/tabela_solunar_card.dart';
import '../data/fase_lua_repository.dart';
import '../domain/models/dia_lunar.dart';

/// Tela dedicada de fase da lua: fase atual, próximas fases principais
/// (Nova/Quarto Crescente/Cheia/Quarto Minguante) e nascer/pôr da lua dia
/// a dia na posição atual da embarcação.
///
/// A fase em si não depende de posição nem de rede (ver
/// `core/utils/fase_lua.dart`) — só o nascer/pôr por dia depende de
/// coordenada, buscado na Open-Meteo assim que o GPS responde.
class FaseLuaScreen extends StatefulWidget {
  const FaseLuaScreen({super.key});

  @override
  State<FaseLuaScreen> createState() => _FaseLuaScreenState();
}

class _FaseLuaScreenState extends State<FaseLuaScreen> {
  double? _lat;
  double? _lon;

  List<DiaLunar>? _dias;
  bool _carregando = false;
  String? _erro;

  late final FaseLua _faseAtual = calcularFaseLua();
  late final List<ProximaFaseLua> _proximasFases = proximasFasesPrincipais();

  Future<void> _buscarDias() async {
    if (_lat == null || _lon == null) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final dias = await FaseLuaRepository()
          .buscar(latitude: _lat!, longitude: _lon!);
      if (!mounted) return;
      setState(() => _dias = dias);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro =
          mensagemErroAmigavel(e, prefixo: 'Erro ao buscar nascer/pôr da lua'));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _atualizarPosicao(double lat, double lon) {
    setState(() {
      _lat = lat;
      _lon = lon;
    });
    _buscarDias();
  }

  DiaLunar? get _diaHoje {
    final dias = _dias;
    if (dias == null || dias.isEmpty) return null;
    final hoje = DateTime.now();
    for (final dia in dias) {
      if (dia.data.year == hoje.year &&
          dia.data.month == hoje.month &&
          dia.data.day == hoje.day) {
        return dia;
      }
    }
    return dias.first;
  }

  /// Períodos solunares de hoje — precisa de pelo menos os dias vizinhos
  /// pra interpolar corretamente perto da virada do dia (ver
  /// `calcularPeriodosSolunares`), por isso usa a lista inteira que já
  /// veio da Open-Meteo, não só o [_diaHoje].
  List<PeriodoSolunar> get _periodosSolunaresHoje {
    final dias = _dias;
    if (dias == null) return [];
    final agora = DateTime.now();
    final inicioDoDia = DateTime(agora.year, agora.month, agora.day);
    return calcularPeriodosSolunares(
      dias,
      desde: inicioDoDia,
      janela: const Duration(days: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fase da Lua')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card de posição sempre primeiro — é o único cuja resposta (GPS)
          // condiciona o resto da tela (nascer/pôr por dia), então o
          // mestre vê logo se falta ele antes de rolar por cards que ainda
          // vão aparecer em branco.
          PosicaoAtualWidget(
            onPosicaoObtida: (posicao) =>
                _atualizarPosicao(posicao.latitude, posicao.longitude),
          ),
          const SizedBox(height: 16),
          FaseLuaCard(
            faseAtual: _faseAtual,
            diaHoje: _diaHoje,
            proximasFases: _proximasFases,
          ),
          if (_periodosSolunaresHoje.isNotEmpty) ...[
            const SizedBox(height: 16),
            TabelaSolunarCard(periodos: _periodosSolunaresHoje),
          ],
          const SizedBox(height: 24),
          if (_lat == null || _lon == null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aguardando posição atual da embarcação para os horários '
                'de nascer/pôr da lua — a fase acima não depende disso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: corRotulo(context)),
              ),
            )
          else if (_carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erro != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                        _erro == mensagemSemConexao
                            ? Icons.wifi_off_outlined
                            : Icons.error_outline,
                        color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_erro!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
          else if (_dias != null) ...[
            Text('NASCER E PÔR DA LUA',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: corRotulo(context))),
            const SizedBox(height: 8),
            Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: _dias!
                    .map((dia) => _LinhaDiaLunar(dia: dia))
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinhaDiaLunar extends StatelessWidget {
  final DiaLunar dia;

  const _LinhaDiaLunar({required this.dia});

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final eHoje = dia.data.year == hoje.year &&
        dia.data.month == hoje.month &&
        dia.data.day == hoje.day;

    final fase = calcularFaseLua(dia.data);
    const diasSemana = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
      'Sexta-feira', 'Sábado', 'Domingo',
    ];
    final d = dia.data.day.toString().padLeft(2, '0');
    final mes = dia.data.month.toString().padLeft(2, '0');

    String horaOuTraco(DateTime? h) => h == null
        ? '—'
        : '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: eHoje
            ? Colors.deepPurple.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Text(fase.tipo.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              eHoje ? 'Hoje, $d/$mes' : '${diasSemana[dia.data.weekday - 1]}, $d/$mes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: eHoje ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.arrow_upward, size: 14, color: Colors.deepPurple.shade300),
                const SizedBox(width: 4),
                Text(horaOuTraco(dia.nascer), style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.arrow_downward, size: 14, color: Colors.deepPurple.shade300),
                const SizedBox(width: 4),
                Text(horaOuTraco(dia.poesta), style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
