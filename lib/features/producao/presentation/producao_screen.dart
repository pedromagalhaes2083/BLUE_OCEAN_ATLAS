import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/producao_registro.dart';
import 'producao_historico_screen.dart';

class ProducaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const ProducaoScreen({super.key, required this.dbHelper});

  @override
  State<ProducaoScreen> createState() => _ProducaoScreenState();
}

class _ProducaoScreenState extends State<ProducaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _especieController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacaoController = TextEditingController();

  String _embarcacaoNome = 'Não definida';
  int? _viagemAtivaId;
  Position? _posicaoAtual;
  bool _isSalvando = false;

  @override
  void initState() {
    super.initState();
    _carregarContexto();
    _obterLocalizacao();
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

  Future<void> _obterLocalizacao() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _posicaoAtual = position);
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }

  Future<void> _salvarProducao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSalvando = true);

    try {
      final registro = ProducaoRegistro(
        id: 0,
        embarcacaoId: _embarcacaoNome,
        dataHora: DateTime.now(),
        especie: _especieController.text.trim(),
        quantidadeKg: double.parse(_quantidadeController.text),
        latitude: _posicaoAtual?.latitude,
        longitude: _posicaoAtual?.longitude,
        cartaCodigo: null,
        observacao: _observacaoController.text.trim().isEmpty
            ? null
            : _observacaoController.text.trim(),
        viagemId: _viagemAtivaId,
        sincronizado: false,
      );

      await widget.dbHelper.insert('producao_registro', registro.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Produção salva com sucesso!'),
            backgroundColor: Colors.green),
      );

      _especieController.clear();
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
              TextFormField(
                controller: _especieController,
                decoration: const InputDecoration(
                    labelText: 'Espécie *', border: OutlineInputBorder()),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Informe a espécie' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantidadeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Quantidade (kg) *',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Informe a quantidade' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSalvando ? null : _salvarProducao,
                  child: _isSalvando
                      ? const CircularProgressIndicator(color: Colors.white)
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

  @override
  void dispose() {
    _especieController.dispose();
    _quantidadeController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }
}
