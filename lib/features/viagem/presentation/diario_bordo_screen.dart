import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/services/diario_bordo_audio_service.dart';
import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../widgets/diario_bordo/forma_de_onda.dart';
import '../domain/models/diario_bordo_entrada.dart';

/// Duração máxima de uma gravação — acima disso, para sozinha (ver
/// doc de [_iniciarGravacao]).
const _duracaoMaximaGravacao = Duration(minutes: 2);

/// Intervalo de amostragem da amplitude durante a gravação — granularidade
/// bruta de captura, não o número de barras desenhadas (ver
/// [_numBarrasOnda]/[_reamostrarAmplitudes]).
const _intervaloAmostraAmplitude = Duration(milliseconds: 120);

/// Número fixo de barras da forma de onda (ver [FormaDeOnda]) — toda
/// gravação, curta ou longa, reamostra pra essa mesma quantidade antes de
/// salvar, pra manter o desenho com densidade consistente e o dado
/// compacto no banco.
const _numBarrasOnda = 40;

/// Diário de bordo de uma viagem — bloco de notas (texto e áudio) atrelado
/// a [viagemId], nunca sincronizado com o backend (ver doc de
/// `DiarioBordoEntrada`). Acessível tanto pra viagem em andamento quanto
/// pra uma já encerrada — a tela só precisa do id, não do status.
class DiarioBordoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int viagemId;
  final String? viagemNome;

  const DiarioBordoScreen({
    super.key,
    required this.dbHelper,
    required this.viagemId,
    this.viagemNome,
  });

  @override
  State<DiarioBordoScreen> createState() => _DiarioBordoScreenState();
}

class _DiarioBordoScreenState extends State<DiarioBordoScreen> {
  final _textoController = TextEditingController();
  final _scrollController = ScrollController();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  List<DiarioBordoEntrada> _entradas = [];
  bool _carregando = true;

  bool _gravando = false;
  Duration _duracaoGravando = Duration.zero;
  Timer? _timerGravacao;
  final List<double> _amplitudesGravando = [];
  StreamSubscription<Amplitude>? _amplitudeSub;

  int? _reproduzindoId;
  Duration _posicaoReproduzindo = Duration.zero;
  Duration _duracaoReproduzindo = Duration.zero;

  StreamSubscription? _onPlayerCompleteSub;
  StreamSubscription? _onPositionChangedSub;
  StreamSubscription? _onDurationChangedSub;

  @override
  void initState() {
    super.initState();
    _carregar();
    _onPlayerCompleteSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _reproduzindoId = null;
        _posicaoReproduzindo = Duration.zero;
      });
    });
    _onPositionChangedSub = _player.onPositionChanged.listen((posicao) {
      if (!mounted) return;
      setState(() => _posicaoReproduzindo = posicao);
    });
    _onDurationChangedSub = _player.onDurationChanged.listen((duracao) {
      if (!mounted) return;
      setState(() => _duracaoReproduzindo = duracao);
    });
  }

  @override
  void dispose() {
    _timerGravacao?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    _onPlayerCompleteSub?.cancel();
    _onPositionChangedSub?.cancel();
    _onDurationChangedSub?.cancel();
    _textoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final linhas = await widget.dbHelper.queryWhere(
      'diario_bordo',
      where: 'viagem_id = ?',
      whereArgs: [widget.viagemId],
      orderBy: 'criado_em ASC',
    );
    if (!mounted) return;
    setState(() {
      _entradas = linhas.map(DiarioBordoEntrada.fromMap).toList();
      _carregando = false;
    });
    _rolarPraFinal();
  }

  void _rolarPraFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // ── Notas de texto ───────────────────────────────────────────────────────

  Future<void> _enviarTexto() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) return;
    _textoController.clear();

    final entrada = DiarioBordoEntrada(
      viagemId: widget.viagemId,
      tipo: TipoDiarioBordo.texto,
      conteudo: texto,
      criadoEm: DateTime.now(),
    );
    await widget.dbHelper.insert('diario_bordo', entrada.toMap());
    await _carregar();
  }

  Future<void> _editarTexto(DiarioBordoEntrada entrada) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: entrada.conteudo);
    final novoTexto = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.diarioBordoEditarNota),
        content: TextField(
          controller: controller,
          maxLines: null,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.salvar),
          ),
        ],
      ),
    );
    if (novoTexto == null || novoTexto.isEmpty || entrada.id == null) return;

    await widget.dbHelper.update(
      'diario_bordo',
      entrada.copyWith(conteudo: novoTexto).toMap(),
      id: entrada.id!,
    );
    await _carregar();
  }

  Future<void> _remover(DiarioBordoEntrada entrada) async {
    final l10n = AppLocalizations.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.diarioBordoRemoverNotaTitulo),
        content: Text(l10n.diarioBordoRemoverNotaMensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.remover, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true || entrada.id == null) return;

    if (entrada.tipo == TipoDiarioBordo.audio && entrada.caminhoAudio != null) {
      if (_reproduzindoId == entrada.id) {
        await _player.stop();
        _reproduzindoId = null;
      }
      await DiarioBordoAudioService.apagar(entrada.caminhoAudio!);
    }
    await widget.dbHelper.delete('diario_bordo', id: entrada.id!);
    await _carregar();
  }

  // ── Gravação de áudio ────────────────────────────────────────────────────

  /// Pára sozinha ao bater [_duracaoMaximaGravacao] — evita um arquivo
  /// gigante por esquecimento (o usuário ainda pode parar antes, a
  /// qualquer momento, tocando o botão de novo).
  Future<void> _iniciarGravacao() async {
    final l10n = AppLocalizations.of(context);
    final temPermissao = await _recorder.hasPermission();
    if (!temPermissao) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diarioBordoSemPermissaoMicrofone)),
      );
      return;
    }

    final caminho = await DiarioBordoAudioService.proximoCaminho(widget.viagemId);
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: caminho,
    );
    if (!mounted) return;
    _amplitudesGravando.clear();
    setState(() {
      _gravando = true;
      _duracaoGravando = Duration.zero;
    });
    // Amplitude real em dBFS (tipicamente -45 a 0 em ambiente com algum som;
    // abaixo disso é silêncio) — normaliza pra 0.0-1.0 só pra desenhar a
    // forma de onda (ver [FormaDeOnda]), não é um valor calibrado de
    // verdade, só o suficiente pra refletir onde o áudio ficou mais alto
    // ou mais baixo.
    _amplitudeSub = _recorder
        .onAmplitudeChanged(_intervaloAmostraAmplitude)
        .listen((amplitude) {
      final normalizado = ((amplitude.current + 45) / 45).clamp(0.0, 1.0);
      _amplitudesGravando.add(normalizado);
    });
    _timerGravacao = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _duracaoGravando += const Duration(seconds: 1));
      if (_duracaoGravando >= _duracaoMaximaGravacao) {
        _pararGravacao();
      }
    });
  }

  Future<void> _pararGravacao() async {
    _timerGravacao?.cancel();
    _timerGravacao = null;
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final caminho = await _recorder.stop();
    final duracaoS = _duracaoGravando.inSeconds;
    final amplitudes = List<double>.from(_amplitudesGravando);
    if (!mounted) return;
    setState(() => _gravando = false);

    // Gravação cancelada antes de qualquer áudio de verdade ser capturado
    // (ex: toque acidental) — não vale a pena salvar uma nota de 0s.
    if (caminho == null || duracaoS < 1) return;

    final entrada = DiarioBordoEntrada(
      viagemId: widget.viagemId,
      tipo: TipoDiarioBordo.audio,
      caminhoAudio: caminho,
      duracaoAudioS: duracaoS,
      amplitudes: amplitudes.isEmpty
          ? null
          : _reamostrarAmplitudes(amplitudes, _numBarrasOnda),
      criadoEm: DateTime.now(),
    );
    await widget.dbHelper.insert('diario_bordo', entrada.toMap());
    await _carregar();
  }

  /// Reamostra [valores] (uma amostra a cada [_intervaloAmostraAmplitude]
  /// durante a gravação — centenas delas numa nota de 2 minutos) pro
  /// número fixo [quantidade] de barras, pela média de cada bloco — mantém
  /// o formato geral da forma de onda real sem guardar centenas de pontos
  /// por nota.
  List<double> _reamostrarAmplitudes(List<double> valores, int quantidade) {
    if (valores.length <= quantidade) return valores;
    final tamanhoBloco = valores.length / quantidade;
    return List.generate(quantidade, (i) {
      final inicio = (i * tamanhoBloco).floor();
      final fim = (((i + 1) * tamanhoBloco).ceil()).clamp(inicio + 1, valores.length);
      final bloco = valores.sublist(inicio, fim);
      return bloco.reduce((a, b) => a + b) / bloco.length;
    });
  }

  // ── Reprodução de áudio ──────────────────────────────────────────────────

  Future<void> _alternarReproducao(DiarioBordoEntrada entrada) async {
    if (entrada.caminhoAudio == null || entrada.id == null) return;

    if (_reproduzindoId == entrada.id) {
      await _player.pause();
      setState(() => _reproduzindoId = null);
      return;
    }

    setState(() {
      _reproduzindoId = entrada.id;
      _posicaoReproduzindo = Duration.zero;
      _duracaoReproduzindo = Duration(seconds: entrada.duracaoAudioS ?? 0);
    });
    await _player.play(DeviceFileSource(entrada.caminhoAudio!));
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viagemNome?.isNotEmpty == true
            ? '${l10n.diarioBordoTelaTitulo} · ${widget.viagemNome}'
            : l10n.diarioBordoTelaTitulo),
      ),
      body: Column(
        children: [
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _entradas.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.diarioBordoVazio,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: corRotulo(context)),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: _entradas.length,
                        itemBuilder: (context, index) => _linhaEntrada(
                          _entradas[index],
                          mostrarCirculo: _mostrarCirculo(index),
                        ),
                      ),
          ),
          SafeArea(
            top: false,
            child: _gravando ? _barraGravando(l10n) : _barraEntrada(l10n),
          ),
        ],
      ),
    );
  }

  /// `true` quando é a primeira entrada da lista ou o dia do calendário
  /// mudou desde a entrada anterior — só nesse caso [_linhaEntrada] mostra
  /// o círculo com o dia do mês; entradas seguintes no mesmo dia ficam só
  /// com o conteúdo, sem repetir o círculo (ver pedido original: evitar um
  /// círculo por entrada quando várias caem na mesma data).
  bool _mostrarCirculo(int index) {
    if (index == 0) return true;
    final atual = _entradas[index].criadoEm;
    final anterior = _entradas[index - 1].criadoEm;
    return atual.year != anterior.year ||
        atual.month != anterior.month ||
        atual.day != anterior.day;
  }

  Widget _linhaEntrada(DiarioBordoEntrada entrada, {required bool mostrarCirculo}) {
    final hora = _formatarHora(entrada.criadoEm);
    return GestureDetector(
      onLongPress: () => _mostrarAcoes(entrada),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: mostrarCirculo
                  ? CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        entrada.criadoEm.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: entrada.tipo == TipoDiarioBordo.texto
                  ? _linhaTexto(entrada)
                  : _linhaAudio(entrada),
            ),
            const SizedBox(width: 8),
            Text(hora, style: TextStyle(fontSize: 11, color: corRotulo(context))),
          ],
        ),
      ),
    );
  }

  /// Mesmo balão (cor, raio, padding) da nota de áudio (ver [_linhaAudio])
  /// — nota de texto e nota de áudio são a mesma "mensagem" no diário, só
  /// com conteúdos diferentes por dentro, então levam o mesmo separador
  /// visual em vez de uma ficar com fundo e a outra texto solto na tela.
  Widget _linhaTexto(DiarioBordoEntrada entrada) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(entrada.conteudo ?? ''),
    );
  }

  /// Forma de onda genérica (barras uniformes) pra notas de áudio gravadas
  /// antes da captura de amplitude existir, ou quando ela falhou — nunca
  /// finge ser a forma real daquele áudio especificamente (ver doc de
  /// `DiarioBordoEntrada.amplitudes`), só mantém o mesmo visual do player.
  static final List<double> _amplitudesGenericas =
      List.generate(_numBarrasOnda, (i) => 0.35 + 0.3 * (i.isEven ? 1 : 0.4));

  Widget _linhaAudio(DiarioBordoEntrada entrada) {
    final tocandoEssa = _reproduzindoId == entrada.id;
    final duracaoTotal = tocandoEssa && _duracaoReproduzindo > Duration.zero
        ? _duracaoReproduzindo
        : Duration(seconds: entrada.duracaoAudioS ?? 0);
    final posicao = tocandoEssa ? _posicaoReproduzindo : Duration.zero;
    final progresso = duracaoTotal.inMilliseconds == 0
        ? 0.0
        : posicao.inMilliseconds / duracaoTotal.inMilliseconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(tocandoEssa ? Icons.pause_circle : Icons.play_circle),
            iconSize: 34,
            padding: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => _alternarReproducao(entrada),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormaDeOnda(
                  amplitudes: entrada.amplitudes ?? _amplitudesGenericas,
                  progresso: progresso,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatarDuracao(posicao),
                        style: TextStyle(fontSize: 11, color: corRotulo(context))),
                    Text(_formatarDuracao(duracaoTotal),
                        style: TextStyle(fontSize: 11, color: corRotulo(context))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAcoes(DiarioBordoEntrada entrada) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (entrada.tipo == TipoDiarioBordo.texto)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.editar),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _editarTexto(entrada);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  Text(l10n.remover, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                _remover(entrada);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraEntrada(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textoController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: l10n.diarioBordoCampoDica,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textoController,
            builder: (context, value, _) {
              final temTexto = value.text.trim().isNotEmpty;
              return IconButton(
                icon: Icon(temTexto ? Icons.send : Icons.mic),
                color: Theme.of(context).colorScheme.primary,
                onPressed: temTexto ? _enviarTexto : _iniciarGravacao,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _barraGravando(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.diarioBordoGravando(_formatarDuracao(_duracaoGravando)),
            ),
          ),
          TextButton(
            onPressed: _pararGravacao,
            child: Text(l10n.diarioBordoPararGravacao),
          ),
        ],
      ),
    );
  }

  /// Só hora:minuto — a data em si já aparece no círculo do dia (ver
  /// [_linhaEntrada]/[_mostrarCirculo]), não precisa repetir por linha.
  String _formatarHora(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatarDuracao(Duration d) {
    final minutos = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }
}
