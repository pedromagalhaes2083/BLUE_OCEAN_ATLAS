import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/localizacao_reporter_service.dart';
import '../domain/models/embarcacao.dart';
import 'cadastrar_embarcaao_screen.dart';
import 'widgets/foto_embarcacao_picker.dart';

const _embarcacaoIdPadrao = 'c8f1da10-e015-41c9-920f-ce2c512c3a95';
const _kgPorTonelada = 1000.0;
const _litrosPorGalao = 3.78541;

class EmbarcacaoConfiguracaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const EmbarcacaoConfiguracaoScreen({super.key, required this.dbHelper});

  @override
  State<EmbarcacaoConfiguracaoScreen> createState() =>
      _EmbarcacaoConfiguracaoScreenState();
}

class _EmbarcacaoConfiguracaoScreenState
    extends State<EmbarcacaoConfiguracaoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _embarcacaoIdController = TextEditingController();
  final _capacidadeGeloController = TextEditingController();
  final _capacidadeDieselController = TextEditingController();
  final _motorUsadoController = TextEditingController();
  final _numeroTripulantesController = TextEditingController();
  final _mestreIdController = TextEditingController();

  String _unidadeGelo = 'toneladas';
  String _unidadeDiesel = 'litros';
  String? _fotoPath;

  Embarcacao? _embarcacao;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _testandoEnvio = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _embarcacaoIdController.dispose();
    _capacidadeGeloController.dispose();
    _capacidadeDieselController.dispose();
    _motorUsadoController.dispose();
    _numeroTripulantesController.dispose();
    _mestreIdController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final registros = await widget.dbHelper.query('embarcacao');
      final embarcacaoId =
          await Config.obtem(Constantes.embarcacaoId, _embarcacaoIdPadrao);

      Embarcacao? embarcacao;
      if (registros.isNotEmpty) {
        embarcacao = Embarcacao.fromMap(registros.first);
      }

      if (!mounted) return;
      setState(() {
        _embarcacao = embarcacao;
        _nomeController.text = embarcacao?.nome ?? '';
        _capacidadeGeloController.text = embarcacao?.capacidadeGeloKg == null
            ? ''
            : _formatarNumero(embarcacao!.capacidadeGeloKg! / _kgPorTonelada);
        _capacidadeDieselController.text =
            embarcacao?.capacidadeDieselLitros == null
                ? ''
                : _formatarNumero(embarcacao!.capacidadeDieselLitros!);
        _motorUsadoController.text = embarcacao?.motorUsado ?? '';
        _numeroTripulantesController.text =
            embarcacao?.numeroTripulantes?.toString() ?? '';
        _mestreIdController.text = embarcacao?.mestreId ?? '';
        _embarcacaoIdController.text = embarcacaoId;
        _fotoPath = embarcacao?.foto;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar configuração: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatarNumero(double valor) {
    return valor == valor.roundToDouble()
        ? valor.toStringAsFixed(0)
        : valor.toStringAsFixed(2);
  }

  void _alternarUnidadeGelo(String? novaUnidade) {
    if (novaUnidade == null || novaUnidade == _unidadeGelo) return;
    final atual = double.tryParse(_capacidadeGeloController.text.trim());
    setState(() {
      if (atual != null) {
        final emKg = _unidadeGelo == 'toneladas' ? atual * _kgPorTonelada : atual;
        final convertido = novaUnidade == 'toneladas' ? emKg / _kgPorTonelada : emKg;
        _capacidadeGeloController.text = _formatarNumero(convertido);
      }
      _unidadeGelo = novaUnidade;
    });
  }

  void _alternarUnidadeDiesel(String? novaUnidade) {
    if (novaUnidade == null || novaUnidade == _unidadeDiesel) return;
    final atual = double.tryParse(_capacidadeDieselController.text.trim());
    setState(() {
      if (atual != null) {
        final emLitros =
            _unidadeDiesel == 'galões' ? atual * _litrosPorGalao : atual;
        final convertido =
            novaUnidade == 'galões' ? emLitros / _litrosPorGalao : emLitros;
        _capacidadeDieselController.text = _formatarNumero(convertido);
      }
      _unidadeDiesel = novaUnidade;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_embarcacao?.id == null) return;

    setState(() => _isSaving = true);
    try {
      final gelo = double.tryParse(_capacidadeGeloController.text.trim());
      final diesel = double.tryParse(_capacidadeDieselController.text.trim());

      await widget.dbHelper.update(
        'embarcacao',
        {
          'nome': _nomeController.text.trim(),
          'capacidade_gelo_kg':
              gelo == null ? null : (_unidadeGelo == 'toneladas' ? gelo * _kgPorTonelada : gelo),
          'capacidade_diesel_litros': diesel == null
              ? null
              : (_unidadeDiesel == 'galões' ? diesel * _litrosPorGalao : diesel),
          'motor_usado': _motorUsadoController.text.trim().isEmpty
              ? null
              : _motorUsadoController.text.trim(),
          'numero_tripulantes':
              int.tryParse(_numeroTripulantesController.text.trim()),
          'mestre_id': _mestreIdController.text.trim().isEmpty
              ? null
              : _mestreIdController.text.trim(),
          'foto': _fotoPath,
        },
        id: _embarcacao!.id!,
      );
      await Config.grava(
          Constantes.embarcacaoId, _embarcacaoIdController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuração da embarcação salva')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _testarEnvioLocalizacao() async {
    setState(() => _testandoEnvio = true);
    await LocalizacaoReporterService.registrarESincronizar();
    if (!mounted) return;
    setState(() => _testandoEnvio = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Teste disparado — veja o resultado no console/log')),
    );
  }

  Future<void> _excluirEmbarcacao() async {
    if (_embarcacao?.id == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir embarcação'),
        content: Text(
          'Todos os dados de "${_embarcacao!.nome}" serão apagados permanentemente. '
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _isSaving = true);
    try {
      final foto = _embarcacao!.foto;
      await widget.dbHelper.delete('embarcacao', id: _embarcacao!.id!);
      if (foto != null) {
        final arquivo = File(foto);
        if (await arquivo.exists()) await arquivo.delete();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Embarcação excluída')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _cadastrarEmbarcacao() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastrarEmbarcacaoScreen(dbHelper: widget.dbHelper),
      ),
    );
    if (resultado == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue.shade900,
        elevation: 0,
        actions: _embarcacao == null
            ? null
            : [
                IconButton(
                  onPressed: _isSaving ? null : _excluirEmbarcacao,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir embarcação',
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _embarcacao == null
              ? _buildSemEmbarcacao()
              : _buildForm(),
    );
  }

  Widget _buildSemEmbarcacao() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sailing, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma embarcação cadastrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre a embarcação antes de configurar capacidades e tripulação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cadastrarEmbarcacao,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Embarcação'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 8,
            shadowColor: Colors.blue.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FotoEmbarcacaoPicker(
                      fotoPath: _fotoPath,
                      onChanged: (path) => setState(() => _fotoPath = path),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Configurar Embarcação',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _campoTexto(
                      label: 'Nome',
                      controller: _nomeController,
                      icon: Icons.directions_boat,
                      validator: (value) => value?.trim().isEmpty ?? true
                          ? 'Nome da embarcação é obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _campoTexto(
                      label: 'ID Embarcação',
                      controller: _embarcacaoIdController,
                      icon: Icons.tag,
                      destacado: true,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      suffixIcon: IconButton(
                        icon: _testandoEnvio
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send, size: 18),
                        tooltip: 'Testar envio agora',
                        onPressed: _testandoEnvio ? null : _testarEnvioLocalizacao,
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Informe um ID'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    _campoComUnidade(
                      label: 'Capacidade de Gelo',
                      controller: _capacidadeGeloController,
                      icon: Icons.ac_unit,
                      unidade: _unidadeGelo,
                      opcoes: const ['kg', 'toneladas'],
                      onUnidadeChanged: _alternarUnidadeGelo,
                    ),
                    const SizedBox(height: 18),
                    _campoComUnidade(
                      label: 'Capacidade de Diesel',
                      controller: _capacidadeDieselController,
                      icon: Icons.local_gas_station,
                      unidade: _unidadeDiesel,
                      opcoes: const ['litros', 'galões'],
                      onUnidadeChanged: _alternarUnidadeDiesel,
                    ),
                    const SizedBox(height: 18),
                    _campoTexto(
                      label: 'Motor Usado',
                      controller: _motorUsadoController,
                      icon: Icons.settings,
                    ),
                    const SizedBox(height: 18),
                    _campoTexto(
                      label: 'Número de Tripulantes',
                      controller: _numeroTripulantesController,
                      icon: Icons.groups,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validarNumeroOpcional(value, isInt: true),
                    ),
                    const SizedBox(height: 18),
                    _campoTexto(
                      label: 'ID Mestre / Capitão',
                      controller: _mestreIdController,
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isSaving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue.shade900,
                              side: BorderSide(color: Colors.blue.shade900),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _salvar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Salvar Configuração',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool destacado = false,
    TextStyle? style,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: style,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: destacado
              ? BorderSide(color: Colors.blue.shade400, width: 1.5)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
      ),
    );
  }

  Widget _campoComUnidade({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String unidade,
    required List<String> opcoes,
    required ValueChanged<String?> onUnidadeChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) => _validarNumeroOpcional(value, isInt: false),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.blue.shade900, size: 20),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unidade,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade900),
                items: opcoes
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: onUnidadeChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _validarNumeroOpcional(String? value, {required bool isInt}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed =
        isInt ? int.tryParse(value.trim()) : double.tryParse(value.trim());
    return parsed == null ? 'Informe um número válido' : null;
  }
}
