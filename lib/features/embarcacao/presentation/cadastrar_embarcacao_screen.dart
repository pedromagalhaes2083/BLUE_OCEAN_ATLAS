import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import 'widgets/foto_embarcacao_picker.dart';

class CadastrarEmbarcacaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const CadastrarEmbarcacaoScreen({super.key, required this.dbHelper});

  @override
  State<CadastrarEmbarcacaoScreen> createState() =>
      _CadastrarEmbarcacaoScreenState();
}

class _CadastrarEmbarcacaoScreenState extends State<CadastrarEmbarcacaoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _donoController = TextEditingController();
  final _registroController = TextEditingController();
  final _quantidadeUrnasController = TextEditingController(text: '1');
  final _capacidadeGeloController = TextEditingController();
  final _capacidadeDieselController = TextEditingController();
  final _motorUsadoController = TextEditingController();
  final _numeroTripulantesController = TextEditingController();
  final _mestreIdController = TextEditingController();

  String? _fotoPath;
  bool _isLoading = false;

  Future<void> _salvarEmbarcacao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        'nome': _nomeController.text.trim(),
        'dono': _donoController.text.trim().isEmpty
            ? null
            : _donoController.text.trim(),
        'quantidade_urnas': int.parse(_quantidadeUrnasController.text),
        'registro': _registroController.text.trim().isEmpty
            ? null
            : _registroController.text.trim().toUpperCase(),
        'data_cadastro': DateTime.now().toIso8601String(),
        'ativo': 1,
        'capacidade_gelo_kg':
            double.tryParse(_capacidadeGeloController.text.trim()),
        'capacidade_diesel_litros':
            double.tryParse(_capacidadeDieselController.text.trim()),
        'motor_usado': _motorUsadoController.text.trim().isEmpty
            ? null
            : _motorUsadoController.text.trim(),
        'numero_tripulantes':
            int.tryParse(_numeroTripulantesController.text.trim()),
        'mestre_id': _mestreIdController.text.trim().isEmpty
            ? null
            : _mestreIdController.text.trim(),
        'foto': _fotoPath,
      };

      final id = await widget.dbHelper.insert('embarcacao', data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Embarcação "$id" cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retorna sucesso
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _donoController.dispose();
    _registroController.dispose();
    _quantidadeUrnasController.dispose();
    _capacidadeGeloController.dispose();
    _capacidadeDieselController.dispose();
    _motorUsadoController.dispose();
    _numeroTripulantesController.dispose();
    _mestreIdController.dispose();
    super.dispose();
  }

  String? _validarNumeroOpcional(String? value, {required bool isInt}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed =
        isInt ? int.tryParse(value.trim()) : double.tryParse(value.trim());
    return parsed == null ? 'Informe um número válido' : null;
  }

  Widget _buildSecao({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, color: Colors.blue.shade900),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      appBar: AppBar(
        title: const Text('Cadastrar Embarcação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FotoEmbarcacaoPicker(
                fotoPath: _fotoPath,
                onChanged: (path) => setState(() => _fotoPath = path),
              ),
              const SizedBox(height: 24),
              _buildSecao(
                titulo: 'Dados da Embarcação',
                icone: Icons.directions_boat,
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Embarcação *',
                      prefixIcon: Icon(Icons.directions_boat),
                    ),
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? 'Nome da embarcação é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _donoController,
                    decoration: const InputDecoration(
                      labelText: 'Dono / Proprietário',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _registroController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Registro',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSecao(
                titulo: 'Capacidades',
                icone: Icons.inventory_2,
                children: [
                  TextFormField(
                    controller: _quantidadeUrnasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de Urnas *',
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Informe a quantidade';
                      }
                      if (int.tryParse(value!) == null) {
                        return 'Informe um número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _capacidadeGeloController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Capacidade de Gelo',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.ac_unit),
                    ),
                    validator: (value) =>
                        _validarNumeroOpcional(value, isInt: false),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _capacidadeDieselController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Capacidade de Diesel',
                      suffixText: 'L',
                      prefixIcon: Icon(Icons.local_gas_station),
                    ),
                    validator: (value) =>
                        _validarNumeroOpcional(value, isInt: false),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _motorUsadoController,
                    decoration: const InputDecoration(
                      labelText: 'Motor Usado',
                      prefixIcon: Icon(Icons.settings),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSecao(
                titulo: 'Tripulação',
                icone: Icons.groups,
                children: [
                  TextFormField(
                    controller: _numeroTripulantesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de Tripulantes',
                      prefixIcon: Icon(Icons.groups),
                    ),
                    validator: (value) =>
                        _validarNumeroOpcional(value, isInt: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mestreIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID do Mestre da Embarcação',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarEmbarcacao,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'CADASTRAR EMBARCAÇÃO',
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
