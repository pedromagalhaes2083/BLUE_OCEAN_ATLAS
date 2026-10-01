import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/producao_reporter_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../embarcacao/data/embarcacao_local_lookup.dart';
import '../data/especie_repository.dart';
import '../domain/classificacao_peso.dart';
import '../domain/models/especie_remota.dart';
import '../domain/models/producao_registro.dart';
import 'producao_historico_screen.dart';

/// Borda, raio e preenchimento vêm do `inputDecorationTheme` global (ver
/// `_buildTheme` em `main.dart`) — aqui só label/ícone, que mudam por campo.
InputDecoration _decoracaoCampo({
  required String label,
  required IconData icone,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icone),
  );
}

class ProducaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const ProducaoScreen({super.key, required this.dbHelper});

  @override
  State<ProducaoScreen> createState() => _ProducaoScreenState();
}

class _ProducaoScreenState extends State<ProducaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _observacaoController = TextEditingController();

  String? _embarcacaoNome;

  /// ID real da embarcação (UUID do catálogo remoto, configurado em
  /// Configurações → Embarcação) — nunca o nome/registro exibido em
  /// [_embarcacaoNome]. É o valor de verdade gravado no registro; o nome é
  /// só pra exibição na tela.
  String? _embarcacaoId;
  int? _viagemAtivaId;
  bool _isSalvando = false;
  bool _capturandoLocalizacao = false;

  final _especieController = TextEditingController();

  /// ID no catálogo remoto (ver `EspecieRepository`) da sugestão que o
  /// usuário escolheu — nulo quando ele digitou um nome livre (sem
  /// selecionar nenhuma sugestão) ou ainda não buscou nada. Nesse caso a
  /// sincronização resolve o ID depois, pelo nome (ver
  /// `ProducaoReporterService`).
  String? _especieId;
  List<EspecieRemota> _sugestoesEspecie = [];
  bool _buscandoEspecie = false;
  Timer? _debounceEspecie;

  Classificacao? _classificacao;

  /// Intervalo de peso estimado (kg) recalculado a cada mudança de
  /// classificação ou quantidade — ver [_atualizarPesoEstimado].
  double? _pesoEstimadoMin;
  double? _pesoEstimadoMax;

  @override
  void initState() {
    super.initState();
    _carregarContexto();
    _quantidadeController.addListener(_atualizarPesoEstimado);
    _especieController.addListener(_aoDigitarEspecie);
  }

  /// Dispara a cada tecla digitada no campo de espécie — qualquer edição
  /// manual invalida a sugestão escolhida antes (ver [_selecionarEspecie],
  /// que desliga este listener antes de preencher o texto programaticamente,
  /// então só chega aqui por digitação de verdade do usuário) e agenda uma
  /// nova busca no catálogo remoto, com debounce pra não bater na rede a
  /// cada tecla.
  void _aoDigitarEspecie() {
    if (_especieId != null) setState(() => _especieId = null);
    _debounceEspecie?.cancel();
    final texto = _especieController.text.trim();
    if (texto.length < 2) {
      if (_sugestoesEspecie.isNotEmpty) setState(() => _sugestoesEspecie = []);
      return;
    }
    _debounceEspecie = Timer(const Duration(milliseconds: 400), () {
      _buscarEspecies(texto);
    });
  }

  /// Busca sugestões no catálogo remoto (ver `EspecieRepository`) —
  /// melhor-esforço: sem rede ou erro, simplesmente não mostra sugestão
  /// nenhuma, sem travar o campo (o usuário continua podendo digitar
  /// livremente e salvar; a espécie é resolvida por nome depois, na
  /// sincronização).
  Future<void> _buscarEspecies(String texto) async {
    setState(() => _buscandoEspecie = true);
    try {
      final resultados = await EspecieRepository().listar(nome: texto);
      if (!mounted || _especieController.text.trim() != texto) return;
      setState(() => _sugestoesEspecie = resultados);
    } catch (_) {
      if (mounted) setState(() => _sugestoesEspecie = []);
    } finally {
      if (mounted) setState(() => _buscandoEspecie = false);
    }
  }

  void _selecionarEspecie(EspecieRemota especie) {
    _especieController.removeListener(_aoDigitarEspecie);
    _especieController.text = especie.nome;
    _especieController.addListener(_aoDigitarEspecie);
    setState(() {
      _especieId = especie.id;
      _sugestoesEspecie = [];
    });
  }

  // Identifica a embarcação registrada e a viagem em andamento (se houver)
  // pra preencher o registro corretamente, em vez de valores fixos.
  Future<void> _carregarContexto() async {
    final registroEmbarcacao = await buscarEmbarcacaoLocalAtual(widget.dbHelper);
    final viagens = await widget.dbHelper.queryWhere(
      'viagem',
      where: 'status = ?',
      whereArgs: ['em_andamento'],
      orderBy: 'id DESC',
    );
    final embarcacaoId = await Config.obtem(Constantes.embarcacaoId, '');

    if (!mounted) return;
    setState(() {
      if (registroEmbarcacao != null) {
        final embarcacao = registroEmbarcacao;
        _embarcacaoNome =
            (embarcacao['registro'] as String?)?.isNotEmpty == true
                ? embarcacao['registro'] as String
                : embarcacao['nome'] as String?;
      }
      _embarcacaoId = embarcacaoId.trim().isEmpty ? null : embarcacaoId.trim();
      if (viagens.isNotEmpty) {
        _viagemAtivaId = viagens.first['id'] as int;
      }
    });
  }

  void _atualizarPesoEstimado() {
    final classificacao = _classificacao;
    final unidades = int.tryParse(_quantidadeController.text.trim());
    if (classificacao == null || unidades == null || unidades <= 0) {
      if (_pesoEstimadoMin != null) {
        setState(() {
          _pesoEstimadoMin = null;
          _pesoEstimadoMax = null;
        });
      }
      return;
    }

    final faixa = faixaPesoUnitario(classificacao);
    final novoMin = unidades * faixa.min;
    final novoMax = unidades * faixa.max;
    if (novoMin != _pesoEstimadoMin || novoMax != _pesoEstimadoMax) {
      setState(() {
        _pesoEstimadoMin = novoMin;
        _pesoEstimadoMax = novoMax;
      });
    }
  }

  Future<void> _salvarProducao() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classificacao == null) {
      setState(() {}); // força a Form a mostrar os erros dos dropdowns
      return;
    }
    final embarcacaoId = _embarcacaoId;
    if (embarcacaoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).producaoSemEmbarcacaoVinculada),
        ),
      );
      return;
    }

    setState(() {
      _isSalvando = true;
      _capturandoLocalizacao = true;
    });

    Position? posicao;
    try {
      posicao = await LocationService().getCurrentPosition();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).producaoErroGps('$e')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _capturandoLocalizacao = false);
    }

    try {
      final especie = _especieController.text.trim();
      final classificacao = _classificacao!;
      final unidades = int.parse(_quantidadeController.text.trim());
      final faixa = faixaPesoUnitario(classificacao);
      // O total salvo usa o ponto médio da faixa — o intervalo completo é
      // só uma estimativa mostrada durante o lançamento, mas o histórico e
      // o mapa de calor de produção precisam de um único número por
      // registro.
      final pesoMedio = faixa.media;

      final registro = ProducaoRegistro(
        id: 0,
        embarcacaoId: embarcacaoId,
        dataHora: DateTime.now(),
        especie: especie,
        quantidadeKg: unidades * pesoMedio,
        latitude: posicao?.latitude,
        longitude: posicao?.longitude,
        precisaoMetros: posicao?.accuracy,
        cartaCodigo: null,
        observacao: _observacaoController.text.trim().isEmpty
            ? null
            : _observacaoController.text.trim(),
        viagemId: _viagemAtivaId,
        sincronizado: false,
        especieId: _especieId,
        classificacao: classificacao,
        quantidadeUnidades: unidades,
        pesoMedioUnitario: pesoMedio,
      );

      await widget.dbHelper.insert('producao_registro', registro.toMap());

      // Fire-and-forget — não bloqueia a UI nem falha o salvamento local se
      // a rede estiver indisponível ou a sincronização estiver desligada.
      unawaited(ProducaoReporterService.sincronizarPendentes());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).producaoSalvaSucesso),
            backgroundColor: Colors.green),
      );

      setState(() {
        _especieId = null;
        _sugestoesEspecie = [];
        _classificacao = null;
        _pesoEstimadoMin = null;
        _pesoEstimadoMax = null;
      });
      _especieController.clear();
      _quantidadeController.clear();
      _observacaoController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).producaoErroSalvar('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isSalvando = false);
    }
  }

  void _abrirHistorico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProducaoHistoricoScreen(dbHelper: widget.dbHelper),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.producaoTitulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.producaoVerHistorico,
            onPressed: _abrirHistorico,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.dashboardEmbarcacaoLabel(
                          _embarcacaoNome ?? l10n.producaoEmbarcacaoNaoDefinida)),
                      Text(l10n.producaoDataLabel(
                          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))),
                      if (_viagemAtivaId == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            l10n.producaoSemViagemAviso,
                            style:
                                TextStyle(fontSize: 12, color: Colors.orange[800]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCampoEspecie(l10n),
              const SizedBox(height: 16),
              DropdownButtonFormField<Classificacao>(
                initialValue: _classificacao,
                isExpanded: true,
                decoration: _decoracaoCampo(
                  label: l10n.producaoClassificacaoLabel,
                  icone: Icons.straighten_outlined,
                ),
                items: Classificacao.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: _ItemClassificacao(classificacao: c),
                        ))
                    .toList(),
                selectedItemBuilder: (context) => Classificacao.values
                    .map((c) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text('${c.label} kg'),
                        ))
                    .toList(),
                validator: (v) =>
                    v == null ? l10n.producaoSelecioneClassificacao : null,
                onChanged: (v) {
                  setState(() => _classificacao = v);
                  _atualizarPesoEstimado();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                keyboardType: TextInputType.number,
                decoration: _decoracaoCampo(
                  label: l10n.producaoQuantidadeLabel,
                  icone: Icons.tag_outlined,
                ),
                validator: (v) {
                  final texto = v?.trim() ?? '';
                  if (texto.isEmpty) return l10n.producaoInformeQuantidade;
                  final unidades = int.tryParse(texto);
                  if (unidades == null || unidades <= 0) {
                    return l10n.producaoQuantidadeInvalida;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildPesoEstimadoCard(l10n),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacaoController,
                maxLines: 3,
                decoration: _decoracaoCampo(
                  label: l10n.producaoObservacaoLabel,
                  icone: Icons.notes_outlined,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSalvando ? null : _salvarProducao,
                  child: _isSalvando
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(_capturandoLocalizacao
                                ? l10n.producaoCapturandoLocalizacao
                                : l10n.producaoSalvando),
                          ],
                        )
                      : Text(l10n.producaoSalvarBotao,
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Campo de espécie livre, com sugestões buscadas no catálogo remoto
  /// (ver `EspecieRepository`) enquanto o usuário digita — mesmo espírito
  /// de qualquer campo "busca com sugestão" do app, sem exigir escolher
  /// exatamente uma das opções: quem não achar a espécie no catálogo (ex:
  /// ainda não cadastrada na plataforma) continua podendo digitar
  /// livremente e salvar — a sincronização resolve o ID depois pelo nome
  /// (ver `ProducaoReporterService`).
  Widget _buildCampoEspecie(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _especieController,
          decoration: _decoracaoCampo(
            label: l10n.producaoEspecieLabel,
            icone: Icons.set_meal_outlined,
          ).copyWith(
            helperText: l10n.producaoEspecieDica,
            suffixIcon: _buscandoEspecie
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          validator: (v) =>
              (v?.trim().isEmpty ?? true) ? l10n.producaoInformeEspecie : null,
        ),
        if (_sugestoesEspecie.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final especie in _sugestoesEspecie)
                  ListTile(
                    dense: true,
                    title: Text(especie.nome),
                    subtitle: especie.nomeCientifico != null
                        ? Text(especie.nomeCientifico!,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic, fontSize: 12))
                        : null,
                    onTap: () => _selecionarEspecie(especie),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// Card com o resultado do cálculo automático — quantidade × intervalo de
  /// peso da classificação escolhida (ver [_atualizarPesoEstimado]).
  Widget _buildPesoEstimadoCard(AppLocalizations l10n) {
    final min = _pesoEstimadoMin;
    final max = _pesoEstimadoMax;
    final temEstimativa = min != null && max != null;
    final colorScheme = Theme.of(context).colorScheme;
    // `primaryContainer`/`onPrimaryContainer` em vez de um azul pastel fixo
    // — o par já é calculado pelo tema pra dar contraste tanto no claro
    // quanto no escuro (ver ColorScheme.fromSeed em main.dart).
    final corFundo =
        temEstimativa ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
    final corDestaque =
        temEstimativa ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;
    return Card(
      color: corFundo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.scale_outlined, color: corDestaque),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.producaoPesoEstimadoLabel,
                      style: TextStyle(
                          fontSize: 13, color: colorScheme.onSurfaceVariant)),
                  Text(
                    temEstimativa
                        ? '${min.toStringAsFixed(1)} – ${max.toStringAsFixed(1)} kg'
                        : '—',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: corDestaque,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceEspecie?.cancel();
    _especieController.removeListener(_aoDigitarEspecie);
    _especieController.dispose();
    _quantidadeController.removeListener(_atualizarPesoEstimado);
    _quantidadeController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }
}

/// Linha de item do combo de Classificação: faixa em destaque à esquerda e
/// o intervalo de peso por unidade à direita, discreto — mesma altura e
/// alinhamento do combo de Tipo do peixe ao lado, em vez de um texto único
/// e longo espremido no espaço do item.
class _ItemClassificacao extends StatelessWidget {
  final Classificacao classificacao;

  const _ItemClassificacao({required this.classificacao});

  @override
  Widget build(BuildContext context) {
    final faixa = faixaPesoPorClassificacao[classificacao]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${classificacao.label} kg'),
        Text(
          AppLocalizations.of(context).producaoKgPorUnidade(
              faixa.min.toStringAsFixed(0), faixa.max.toStringAsFixed(0)),
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
