import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/producao_reporter_service.dart';
import '../domain/classificacao_peso.dart';
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

  String _embarcacaoNome = 'Não definida';
  int? _viagemAtivaId;
  bool _isSalvando = false;
  bool _capturandoLocalizacao = false;

  TipoPeixe? _tipoPeixe;
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
  }

  // Identifica a embarcação registrada e a viagem em andamento (se houver)
  // pra preencher o registro corretamente, em vez de valores fixos.
  Future<void> _carregarContexto() async {
    final embarcacoes = await widget.dbHelper.query('embarcacao');
    final viagens = await widget.dbHelper.queryWhere(
      'viagem',
      where: 'status = ?',
      whereArgs: ['em_andamento'],
      orderBy: 'id DESC',
    );

    if (!mounted) return;
    setState(() {
      if (embarcacoes.isNotEmpty) {
        final embarcacao = embarcacoes.first;
        _embarcacaoNome =
            (embarcacao['registro'] as String?)?.isNotEmpty == true
                ? embarcacao['registro'] as String
                : (embarcacao['nome'] as String? ?? 'Não definida');
      }
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

    final faixa =
        faixaPesoUnitario(_tipoPeixe ?? TipoPeixe.kihada, classificacao);
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
    if (_tipoPeixe == null || _classificacao == null) {
      setState(() {}); // força a Form a mostrar os erros dos dropdowns
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
            content: Text(
              'Não foi possível obter o GPS agora ($e). '
              'Registro será salvo sem coordenada.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _capturandoLocalizacao = false);
    }

    try {
      final tipo = _tipoPeixe!;
      final classificacao = _classificacao!;
      final unidades = int.parse(_quantidadeController.text.trim());
      final faixa = faixaPesoUnitario(tipo, classificacao);
      // O total salvo usa o ponto médio da faixa — o intervalo completo é
      // só uma estimativa mostrada durante o lançamento, mas o histórico e
      // o mapa de calor de produção precisam de um único número por
      // registro.
      final pesoMedio = faixa.media;

      final registro = ProducaoRegistro(
        id: 0,
        embarcacaoId: _embarcacaoNome,
        dataHora: DateTime.now(),
        especie: tipo.label,
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
        tipoPeixe: tipo,
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
        const SnackBar(
            content: Text('✅ Produção salva com sucesso!'),
            backgroundColor: Colors.green),
      );

      setState(() {
        _tipoPeixe = null;
        _classificacao = null;
        _pesoEstimadoMin = null;
        _pesoEstimadoMax = null;
      });
      _quantidadeController.clear();
      _observacaoController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Produção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver histórico e totais',
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
                      Text('Embarcação: $_embarcacaoNome'),
                      Text(
                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
                      if (_viagemAtivaId == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Sem viagem em andamento — registro não será associado a uma viagem.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.orange[800]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSeletorTipoPeixe(),
              const SizedBox(height: 16),
              DropdownButtonFormField<Classificacao>(
                initialValue: _classificacao,
                isExpanded: true,
                decoration: _decoracaoCampo(
                  label: 'Classificação *',
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
                validator: (v) => v == null ? 'Selecione a classificação' : null,
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
                  label: 'Quantidade (unidades) *',
                  icone: Icons.tag_outlined,
                ),
                validator: (v) {
                  final texto = v?.trim() ?? '';
                  if (texto.isEmpty) return 'Informe a quantidade';
                  final unidades = int.tryParse(texto);
                  if (unidades == null || unidades <= 0) {
                    return 'Informe um número inteiro maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildPesoEstimadoCard(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacaoController,
                maxLines: 3,
                decoration: _decoracaoCampo(
                  label: 'Observação (opcional)',
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
                                ? 'Capturando localização...'
                                : 'Salvando...'),
                          ],
                        )
                      : const Text('SALVAR PRODUÇÃO',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seletor de chave (toggle de 2 botões) para o tipo do peixe — só duas
  /// opções mutuamente exclusivas, então um combo é overhead: o usuário vê
  /// as duas de uma vez e escolhe com um toque, sem abrir menu.
  Widget _buildSeletorTipoPeixe() {
    return FormField<TipoPeixe>(
      initialValue: _tipoPeixe,
      validator: (v) => v == null ? 'Selecione o tipo do peixe' : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo do peixe *',
              style: TextStyle(
                fontSize: 12,
                color: state.hasError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TipoPeixe>(
                segments: TipoPeixe.values
                    .map((tipo) => ButtonSegment(
                          value: tipo,
                          label: Text(tipo.label),
                          icon: const Icon(Icons.set_meal_outlined),
                        ))
                    .toList(),
                selected: _tipoPeixe == null ? const {} : {_tipoPeixe!},
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                onSelectionChanged: (selecao) {
                  final novoTipo = selecao.isEmpty ? null : selecao.first;
                  setState(() => _tipoPeixe = novoTipo);
                  state.didChange(novoTipo);
                  _atualizarPesoEstimado();
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Card com o resultado do cálculo automático — quantidade × intervalo de
  /// peso da classificação escolhida (ver [_atualizarPesoEstimado]).
  Widget _buildPesoEstimadoCard() {
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
                  Text('Peso estimado',
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
          '${faixa.min.toStringAsFixed(0)}–${faixa.max.toStringAsFixed(0)} kg/un.',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
