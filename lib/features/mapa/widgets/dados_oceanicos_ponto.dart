import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/models/wave_forecast.dart';
import '../../../core/utils/proximidade.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../metereologia/domain/models/leitura_profundidade.dart';
import '../../metereologia/domain/models/porto_mare.dart';

/// Profundidade, temperatura (SST) e corrente de um ponto qualquer — busca
/// ao vivo (não depende do GPS atual), usada no diálogo de detalhe tanto de
/// um ponto marcado quanto de um ponto de recomendação, no mapa e na tela
/// "Meus Pontos".
class DadosOceanicosPonto extends StatefulWidget {
  final double latitude;
  final double longitude;

  const DadosOceanicosPonto({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DadosOceanicosPonto> createState() => _DadosOceanicosPontoState();
}

class _DadosOceanicosPontoState extends State<DadosOceanicosPonto> {
  bool _carregandoProfundidade = true;
  bool _carregandoTemperatura = true;
  LeituraProfundidade? _profundidade;
  double? _temperatura;

  /// Nós — convertido do km/h que a Open-Meteo retorna, mesma conversão
  /// usada em `CondicoesAtuaisCard` (`* 0.539957`).
  double? _correnteVelocidadeNos;
  int? _correnteDirecaoGraus;
  double? _nivelMarM;
  MareEvento? _proximoEventoMare;

  /// Preenchidos quando a Open-Meteo falha (sem rede) e existe um
  /// [PortoMare] salvo com modelo offline perto o bastante do ponto — a
  /// maré passa a vir do modelo harmônico local em vez da API ao vivo.
  bool _mareOffline = false;
  String? _portoOfflineNome;
  DateTime? _proximoEventoOfflineHorario;
  bool? _proximoEventoOfflineAlta;

  /// Raio de busca pra considerar um porto salvo "perto o bastante" do
  /// ponto — maré varia por local, então um porto muito distante daria uma
  /// previsão enganosa.
  static const _raioPortoOfflineNm = 60.0;

  /// `true` quando profundidade e/ou onda/corrente/maré vieram do cache
  /// local (ver `DadosPontoCacheService`) em vez da API ao vivo — não
  /// aparece se a maré caiu pro modelo harmônico offline (esse já deixa
  /// isso claro no próprio rótulo, `"Maré (offline: <porto>)"`).
  bool _dadosOffline = false;
  DateTime? _dadosOfflineEm;

  @override
  void initState() {
    super.initState();
    _carregarProfundidade();
    _carregarTemperatura();
  }

  Future<void> _carregarProfundidade() async {
    final repo = ProfundidadeRepository();
    try {
      final resultado = await repo.buscarPonto(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (!mounted) return;
      setState(() {
        _profundidade = resultado;
        _carregandoProfundidade = false;
        if (repo.ultimoResultadoOffline) {
          _dadosOffline = true;
          _dadosOfflineEm = _maisAntiga(_dadosOfflineEm, repo.ultimaAtualizacaoCache);
        }
      });
    } catch (_) {
      // Nem rede nem cache tinham profundidade desse ponto — sem
      // alternativa aqui (diferente de maré, não há um modelo offline de
      // profundidade), a linha continua mostrando "—".
      if (!mounted) return;
      setState(() => _carregandoProfundidade = false);
    }
  }

  Future<void> _carregarTemperatura() async {
    final repo = WaveForecastRepository();
    try {
      final forecast = await repo.buscar(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (!mounted) return;
      setState(() {
        _temperatura = forecast.current?.seaSurfaceTemperature;
        final velocidadeKmh = forecast.current?.oceanCurrentVelocity;
        _correnteVelocidadeNos =
            velocidadeKmh != null ? velocidadeKmh * 0.539957 : null;
        _correnteDirecaoGraus = forecast.current?.oceanCurrentDirection;
        _nivelMarM = forecast.current?.seaLevelHeightMsl;
        final eventos = forecast.eventosMare;
        _proximoEventoMare = eventos.isNotEmpty ? eventos.first : null;
        _carregandoTemperatura = false;
        if (repo.ultimoResultadoOffline) {
          _dadosOffline = true;
          _dadosOfflineEm =
              _maisAntiga(_dadosOfflineEm, repo.ultimaAtualizacaoCache);
        }
      });
    } catch (_) {
      // buscar() já tentou o cache local sozinho — só chega aqui se nem
      // rede nem cache tiverem nada desse ponto. Ainda vale tentar o
      // modelo de maré harmônico (mais confiável pra "agora" que um
      // cache muito antigo seria, se existisse).
      final portoOffline = await _buscarPortoOfflineProximo();
      if (!mounted) return;
      if (portoOffline != null) {
        final modelo = portoOffline.modelo!;
        final agora = DateTime.now();
        final eventos = modelo.proximosEventos(agora);
        setState(() {
          _nivelMarM = modelo.altura(agora);
          _mareOffline = true;
          _portoOfflineNome = portoOffline.nome;
          _proximoEventoOfflineHorario =
              eventos.isNotEmpty ? eventos.first.horario : null;
          _proximoEventoOfflineAlta =
              eventos.isNotEmpty ? eventos.first.alta : null;
          _carregandoTemperatura = false;
        });
      } else {
        setState(() => _carregandoTemperatura = false);
      }
    }
  }

  /// A mais antiga entre duas datas de cache, ignorando nulos — usada pra
  /// que [_dadosOfflineEm] sempre mostre o dado mais desatualizado entre
  /// profundidade e onda/corrente/maré, quando os dois vierem do cache.
  DateTime? _maisAntiga(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isBefore(b) ? a : b;
  }

  /// Busca, entre os portos salvos em "Tábua de Maré" com modelo offline já
  /// sincronizado, o mais próximo do ponto — usado como reserva quando a
  /// Open-Meteo falha (sem rede, no mar). Retorna `null` se não houver
  /// nenhum porto com modelo dentro de [_raioPortoOfflineNm].
  Future<PortoMare?> _buscarPortoOfflineProximo() async {
    try {
      final maps = await DatabaseHelper.instance.query('porto_mare');
      final portos = maps
          .map(PortoMare.fromMap)
          .where((p) => p.temModeloOffline)
          .toList();
      if (portos.isEmpty) return null;

      PortoMare? maisProximo;
      var menorDistancia = double.infinity;
      for (final porto in portos) {
        final distancia = calcularDistanciaNauticas(
          widget.latitude,
          widget.longitude,
          porto.latitude,
          porto.longitude,
        );
        if (distancia < menorDistancia) {
          menorDistancia = distancia;
          maisProximo = porto;
        }
      }
      if (maisProximo == null || menorDistancia > _raioPortoOfflineNm) {
        return null;
      }
      return maisProximo;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinhaInfoPonto(
          icon: Icons.waves_outlined,
          label: 'Profundidade',
          valor: _valorProfundidade(),
          carregando: _carregandoProfundidade,
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.thermostat_outlined,
          label: 'Temperatura (SST)',
          valor: _temperatura != null
              ? '${_temperatura!.toStringAsFixed(1)}°C'
              : '—',
          carregando: _carregandoTemperatura,
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.water_outlined,
          label: 'Corrente',
          valor: _valorCorrente(),
          // Mesma chamada da temperatura (WaveForecastRepository.buscar) —
          // não tem loading próprio, os dois chegam juntos.
          carregando: _carregandoTemperatura,
        ),
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: _mareOffline ? Icons.cloud_off_outlined : Icons.waves_outlined,
          label: _mareOffline ? 'Maré (offline: $_portoOfflineNome)' : 'Maré',
          valor: _valorMare(),
          carregando: _carregandoTemperatura,
        ),
        if (_dadosOffline) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 14, color: Colors.amber.shade800),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _dadosOfflineEm != null
                      ? 'Sem conexão — dado de '
                          '${_dadosOfflineEm!.day.toString().padLeft(2, '0')}/'
                          '${_dadosOfflineEm!.month.toString().padLeft(2, '0')} '
                          '${_dadosOfflineEm!.hour.toString().padLeft(2, '0')}:'
                          '${_dadosOfflineEm!.minute.toString().padLeft(2, '0')}'
                      : 'Sem conexão — mostrando o último dado sincronizado',
                  style: TextStyle(
                      fontSize: 11, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _valorCorrente() {
    final velocidade = _correnteVelocidadeNos;
    if (velocidade == null) return '—';
    final direcao = _correnteDirecaoGraus;
    return direcao != null
        ? '${velocidade.toStringAsFixed(1)} nós, $direcao°'
        : '${velocidade.toStringAsFixed(1)} nós';
  }

  String _valorMare() {
    final nivel = _nivelMarM;
    if (nivel == null) return '—';

    if (_mareOffline) {
      final horario = _proximoEventoOfflineHorario;
      final alta = _proximoEventoOfflineAlta;
      if (horario == null || alta == null) return '${nivel.toStringAsFixed(2)} m';
      final tipo = alta ? 'preamar' : 'baixa-mar';
      final h = horario.hour.toString().padLeft(2, '0');
      final m = horario.minute.toString().padLeft(2, '0');
      return '${nivel.toStringAsFixed(2)} m ($tipo às $h:$m)';
    }

    final evento = _proximoEventoMare;
    if (evento == null) return '${nivel.toStringAsFixed(2)} m';
    final tipo = evento.tipo == TipoMare.alta ? 'preamar' : 'baixa-mar';
    final h = evento.time.hour.toString().padLeft(2, '0');
    final m = evento.time.minute.toString().padLeft(2, '0');
    return '${nivel.toStringAsFixed(2)} m ($tipo às $h:$m)';
  }

  String _valorProfundidade() {
    final p = _profundidade;
    if (p == null) return '—';
    if (!p.emAgua) return 'Em terra';
    return '${p.profundidadeMetros.toStringAsFixed(0)} m';
  }
}

/// Linha "ícone + rótulo + valor" usada nos diálogos de detalhe de ponto
/// (coordenadas, data, distância, rumo, profundidade, temperatura, corrente).
class LinhaInfoPonto extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final bool carregando;

  const LinhaInfoPonto({
    super.key,
    required this.icon,
    required this.label,
    required this.valor,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label,
              style: TextStyle(color: onSurfaceVariant, fontSize: 13)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: carregando
              ? const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Text(
                  valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
        ),
      ],
    );
  }
}
