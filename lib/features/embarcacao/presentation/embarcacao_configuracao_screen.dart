import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/localizacao_reporter_service.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../data/embarcacao_repository.dart';
import '../domain/models/embarcacao.dart';
import '../domain/models/embarcacao_remota.dart';
import 'cadastrar_embarcacao_screen.dart';
import 'widgets/foto_embarcacao_picker.dart';

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

  /// Nome da embarcação do catálogo remoto que corresponde ao
  /// `_embarcacaoIdController.text` atual — carregado sob demanda pra
  /// mostrar junto do ID (que continua sendo a fonte da verdade). Nulo
  /// enquanto não resolvido ou se o ID não bateu com nenhuma da lista.
  String? _nomeEmbarcacaoRemota;
  bool _buscandoNomeRemoto = false;

  /// true quando já existia um `Constantes.embarcacaoId` salvo de verdade
  /// (não o fallback [_embarcacaoIdPadrao]) no momento em que a tela
  /// carregou — trava a escolha depois da primeira vez: uma vez vinculado,
  /// o mestre não pode trocar sozinho pelo app (só a plataforma). Ver
  /// [_carregar].
  bool _embarcacaoJaVinculada = false;

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
      // Sem fallback pra uma embarcação real aqui: o campo começa vazio de
      // verdade até o mestre escolher pelo catálogo (ver
      // `_escolherEmbarcacaoRemota`) — um valor pré-preenchido arriscaria
      // vincular à embarcação errada se salvo sem querer.
      final embarcacaoIdSalvo = await Config.obtem(Constantes.embarcacaoId, '');
      final jaVinculada = embarcacaoIdSalvo.trim().isNotEmpty;
      final embarcacaoId = embarcacaoIdSalvo;

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
        _embarcacaoJaVinculada = jaVinculada;
        _fotoPath = embarcacao?.foto;
      });
      _resolverNomeRemoto(embarcacaoId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar configuração: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Busca no catálogo remoto o nome correspondente ao ID já configurado —
  /// só pra exibição (o ID continua sendo o que realmente é salvo/usado).
  /// Melhor-esforço: sem rede ou ID não encontrado, o campo de nome
  /// remoto simplesmente fica vazio, sem travar a tela.
  Future<void> _resolverNomeRemoto(String embarcacaoId) async {
    if (embarcacaoId.trim().isEmpty) return;
    setState(() => _buscandoNomeRemoto = true);
    try {
      final lista = await EmbarcacaoRepository().listar();
      String? nomeEncontrado;
      for (final e in lista) {
        if (e.id == embarcacaoId) {
          nomeEncontrado = e.nome;
          break;
        }
      }
      if (!mounted) return;
      setState(() => _nomeEmbarcacaoRemota = nomeEncontrado);
    } catch (e) {
      debugPrint('Erro ao buscar nome remoto da embarcação: $e');
    } finally {
      if (mounted) setState(() => _buscandoNomeRemoto = false);
    }
  }

  /// Abre o diálogo de escolha da embarcação — lista o catálogo real da
  /// plataforma (quem cadastra é lá, não o app) em vez de deixar o mestre
  /// digitar o ID à mão, que é sujeito a erro de digitação. Só chamado
  /// enquanto [_embarcacaoJaVinculada] for falso — depois da primeira
  /// vinculação, a escolha fica travada (ver doc do campo).
  Future<void> _escolherEmbarcacaoRemota() async {
    if (_embarcacaoJaVinculada) return;
    final escolhida = await showDialog<EmbarcacaoRemota>(
      context: context,
      builder: (_) => const _EscolhaEmbarcacaoDialog(),
    );
    if (escolhida == null) return;
    setState(() {
      _embarcacaoIdController.text = escolhida.id;
      _nomeEmbarcacaoRemota = escolhida.nome;
    });
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
      appBar: AppBar(
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
            Icon(Icons.sailing,
                size: 80,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma embarcação cadastrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre a embarcação antes de configurar capacidades e tripulação.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                        color: Theme.of(context).colorScheme.primary,
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
                    InkWell(
                      onTap: _embarcacaoJaVinculada
                          ? null
                          : _escolherEmbarcacaoRemota,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Embarcação vinculada (plataforma)',
                          prefixIcon: Icon(
                              _embarcacaoJaVinculada
                                  ? Icons.lock_outline
                                  : Icons.directions_boat_filled,
                              color: _embarcacaoJaVinculada
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.primary,
                              size: 20),
                          suffixIcon: _embarcacaoJaVinculada
                              ? null
                              : const Icon(Icons.arrow_drop_down),
                          enabledBorder: _embarcacaoJaVinculada
                              ? null
                              : OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 1.5),
                                ),
                        ),
                        child: _buscandoNomeRemoto
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                _nomeEmbarcacaoRemota ??
                                    (_embarcacaoIdController.text.trim().isEmpty
                                        ? 'Toque para escolher'
                                        : '(ID não encontrado no catálogo)'),
                                style: _nomeEmbarcacaoRemota == null
                                    ? TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)
                                    : null,
                              ),
                      ),
                    ),
                    if (_embarcacaoJaVinculada) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Vinculada — só pode ser alterada pela plataforma.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _campoTexto(
                      label: 'ID Embarcação',
                      controller: _embarcacaoIdController,
                      icon: Icons.tag,
                      readOnly: _embarcacaoJaVinculada,
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
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary),
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
    bool readOnly = false,
    TextStyle? style,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: style,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        suffixIcon: suffixIcon,
        // Só sobrescreve a borda "de repouso" do tema quando destacado —
        // o resto (preenchimento, cantos, borda em foco) já vem daí.
        enabledBorder: destacado
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1.5),
              )
            : null,
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
              prefixIcon: Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 20),
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
              // Mesmo preenchimento dos campos de formulário ao lado (ver
              // `_buildTheme` em main.dart) — evita destoar entre claro/escuro.
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: unidade,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary),
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

/// Diálogo de busca/escolha no catálogo de embarcações da plataforma —
/// mesmo padrão do `_BuscaPortoDialog` em NovaViagemScreen, mas sem a
/// opção de cadastrar: quem cadastra embarcação é a plataforma online,
/// não o app (só lista pra escolha).
class _EscolhaEmbarcacaoDialog extends StatefulWidget {
  const _EscolhaEmbarcacaoDialog();

  @override
  State<_EscolhaEmbarcacaoDialog> createState() =>
      _EscolhaEmbarcacaoDialogState();
}

class _EscolhaEmbarcacaoDialogState extends State<_EscolhaEmbarcacaoDialog> {
  final _buscaController = TextEditingController();
  List<EmbarcacaoRemota> _resultados = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await EmbarcacaoRepository()
          .listar(nome: _buscaController.text.trim());
      if (!mounted) return;
      setState(() => _resultados = resultados);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = mensagemErroAmigavel(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escolher embarcação'),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _buscaController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _buscar,
                ),
              ),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildConteudo()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Text(_erro!, textAlign: TextAlign.center),
      );
    }
    if (_resultados.isEmpty) {
      return const Center(child: Text('Nenhuma embarcação encontrada'));
    }
    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final e = _resultados[index];
        return ListTile(
          leading: const Icon(Icons.directions_boat),
          title: Text(e.nome),
          subtitle: e.codigo == null ? null : Text(e.codigo!),
          onTap: () => Navigator.pop(context, e),
        );
      },
    );
  }
}
