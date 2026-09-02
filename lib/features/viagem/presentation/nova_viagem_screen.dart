import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/constantes.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/device_id_service.dart';
import 'package:atlas/core/services/location_service.dart';
import 'package:atlas/core/services/location_tracking_service.dart';
import 'package:atlas/core/utils/erro_amigavel.dart';
import 'package:atlas/features/dispositivo/data/dispositivo_repository.dart';
import 'package:atlas/features/viagem/data/porto_repository.dart';
import 'package:atlas/features/viagem/data/viagem_repository.dart';
import 'package:atlas/features/viagem/domain/models/porto.dart';
import 'package:atlas/features/viagem/domain/models/viagem.dart';
import 'package:atlas/features/widgets/seletor_coordenada_widget.dart';

class NovaViagemScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const NovaViagemScreen({
    super.key,
    required this.dbHelper,
  });

  @override
  State<NovaViagemScreen> createState() => _NovaViagemScreenState();
}

class _NovaViagemScreenState extends State<NovaViagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  DateTime _dataInicio = DateTime.now();
  DateTime? _dataTermino;

  Porto? _portoOrigem;
  Porto? _portoDestino;
  bool _salvando = false;

  Future<void> _salvarViagem() async {
    if (!_formKey.currentState!.validate()) return;

    // Desabilita o botão (ver onPressed) já a partir daqui, antes de
    // qualquer `await` — fecha a maior parte da janela em que um duplo
    // toque conseguiria passar pela checagem de "já em andamento" duas
    // vezes antes de qualquer uma delas terminar de inserir. O índice
    // único em `viagem` (ver DatabaseHelper) cobre o resto, que essa trava
    // sozinha não alcança.
    setState(() => _salvando = true);

    // A viagem no backend exige uma embarcação com id real — sem isso, o
    // POST falharia (best-effort, então não travaria o app), mas o
    // registro remoto nunca existiria e o mestre não teria como saber por
    // quê. Melhor travar aqui, com uma mensagem clara, do que deixar
    // passar batido.
    final embarcacaoId = await Config.obtem(Constantes.embarcacaoId);
    if (embarcacaoId.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Configure a embarcação (Configurações → Configurar Embarcação) '
            'antes de iniciar uma viagem.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    if (_portoOrigem == null) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o porto de origem.')),
      );
      return;
    }

    // Nunca mais de uma viagem em andamento ao mesmo tempo — sem essa
    // trava, GPS e produção registrados nesse meio-tempo não têm como
    // saber a qual das duas viagens pertencem (ver LocalizacaoReporterService/
    // ProducaoScreen, que assumem no máximo uma).
    final jaEmAndamento = await widget.dbHelper.queryWhere(
      'viagem',
      where: 'status = ?',
      whereArgs: ['em_andamento'],
    );
    if (jaEmAndamento.isNotEmpty) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Já existe uma viagem em andamento. Finalize-a antes de iniciar outra.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    await _confirmarPermissaoSegundoPlano();
    if (!mounted) return;

    final viagem = Viagem(
      id: 0,
      nome: _nomeController.text.trim().isEmpty
          ? null
          : _nomeController.text.trim(),
      dataInicio: _dataInicio,
      dataTermino: _dataTermino,
      // ID real (UUID do catálogo remoto), nunca o nome de exibição — mesmo
      // valor já validado/usado logo acima e no registro remoto.
      embarcacaoId: embarcacaoId.trim(),
      status: 'em_andamento',
    );

    final int viagemLocalId;
    try {
      viagemLocalId = await widget.dbHelper.insert('viagem', viagem.toMap());
    } catch (e) {
      // Violação do índice único (ver DatabaseHelper) — outra viagem foi
      // criada bem nesse intervalo (ex: duplo toque). Não é um erro real
      // pro usuário resolver, é a trava de concorrência funcionando.
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Já existe uma viagem em andamento. Finalize-a antes de iniciar outra.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
      return;
    }

    // O rastreamento em segundo plano só roda enquanto houver viagem em
    // andamento — começa aqui e para em `_finalizarViagem`
    // (HistoricoLocalizacoesScreen), em vez de acompanhar login/logout.
    try {
      final intervalo = int.tryParse(await Config.obtem(
            Constantes.intervaloRastreamentoMinutos,
            '$intervaloMinimoMinutos',
          )) ??
          intervaloMinimoMinutos;
      await LocationTrackingService()
          .iniciarRastreamento(intervaloMinutos: intervalo);
    } catch (e) {
      debugPrint('Erro ao iniciar rastreamento de localização: $e');
    }

    // Registro remoto — best-effort, igual à sincronização de localização/
    // dispositivo: a viagem local já existe e já funciona sem rede, então
    // uma falha aqui (sem conexão no cais, backend fora) não deve travar
    // o início da viagem.
    try {
      final remotoId = await _criarViagemNoBackend(embarcacaoId.trim());
      // Sem isso, capturas dessa viagem nunca conseguem sincronizar depois
      // (`viagemId` é obrigatório em `POST base/resultado/capturas` — ver
      // ProducaoReporterService).
      await widget.dbHelper.update(
        'viagem',
        {'remoto_id': remotoId},
        id: viagemLocalId,
      );
    } catch (e) {
      debugPrint('Erro ao registrar viagem no backend: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viagem iniciada com sucesso!')),
    );

    Navigator.pop(context, true); // Retorna sucesso
  }

  Future<String> _criarViagemNoBackend(String embarcacaoId) async {
    String? dispositivoId;
    try {
      final deviceId = await DeviceIdService.obtemId();
      final dispositivo =
          await DispositivoRepository().buscarPorIdentificador(deviceId);
      dispositivoId = dispositivo.id;
    } catch (e) {
      debugPrint('Dispositivo não resolvido pro registro de viagem: $e');
    }

    double? latitude;
    double? longitude;
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));
      latitude = posicao.latitude;
      longitude = posicao.longitude;
    } catch (e) {
      debugPrint('Posição inicial não resolvida pro registro de viagem: $e');
    }

    return ViagemRepository().criar(
      embarcacaoId: embarcacaoId,
      portoOrigemId: _portoOrigem!.id,
      portoDestinoId: _portoDestino?.id,
      inicioPrevisto: _dataInicio,
      fimPrevisto: _dataTermino,
      latitudeInicial: latitude,
      longitudeInicial: longitude,
      dispositivoId: dispositivoId,
    );
  }

  /// Explica por que o app precisa da localização "o tempo todo" antes de
  /// pedir — obrigatório pela política do Android/Play a partir da API 30 —
  /// e então tenta elevar a permissão. Nunca bloqueia o início da viagem:
  /// sem "sempre", o rastreamento simplesmente só funciona com o app
  /// aberto, então só avisa em vez de impedir.
  Future<void> _confirmarPermissaoSegundoPlano() async {
    final permissaoAtual = await Geolocator.checkPermission();
    if (permissaoAtual == LocationPermission.always) return;
    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(child: Text('Localização em segundo plano')),
          ],
        ),
        content: const Text(
          'Enquanto a viagem estiver em andamento, o Atlas envia sua '
          'posição periodicamente para o servidor — inclusive com o app '
          'fechado, pra manter o rastreamento de segurança da embarcação. '
          'Isso exige a permissão "Permitir o tempo todo" e a exceção de '
          'otimização de bateria nas próximas telas. Fora de uma viagem, '
          'a posição não é enviada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    final resultado = await LocationService().solicitarPermissaoSempre();
    if (!mounted) return;
    if (resultado != LocationPermission.always) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sem "Permitir o tempo todo", o envio de posição só funciona '
            'com o app aberto. Pode ativar depois nas configurações do '
            'aparelho.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }

    // Pedido separado — Android trata otimização de bateria e permissão de
    // localização como coisas distintas, cada uma com seu próprio diálogo.
    final ignoraOtimizacao =
        await LocationService().solicitarIgnorarOtimizacaoBateria();
    if (!mounted) return;
    if (!ignoraOtimizacao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sem a exceção de otimização de bateria, o aparelho pode '
            'interromper o envio de posição em segundo plano. Pode ativar '
            'depois nas configurações de bateria do app.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // ── Seleção de porto ─────────────────────────────────────────────────────

  Future<void> _selecionarPortoOrigem() async {
    final porto = await _abrirBuscaPorto(titulo: 'Porto de origem');
    if (porto != null) setState(() => _portoOrigem = porto);
  }

  Future<void> _selecionarPortoDestino() async {
    final porto = await _abrirBuscaPorto(titulo: 'Porto de destino');
    if (porto != null) setState(() => _portoDestino = porto);
  }

  Future<Porto?> _abrirBuscaPorto({required String titulo}) async {
    if (!mounted) return null;
    return showDialog<Porto>(
      context: context,
      builder: (dialogContext) => _BuscaPortoDialog(titulo: titulo),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Viagem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Viagem (opcional)',
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Data de Início'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataInicio)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  // showDatePicker só devolve ano/mês/dia (meia-noite) — sem
                  // recompor com o horário que já estava em _dataInicio, o
                  // horário real de início da viagem se perdia toda vez que
                  // a data era tocada, mesmo sem intenção de mudar a hora.
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataInicio,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date == null) return;
                  setState(() => _dataInicio = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        _dataInicio.hour,
                        _dataInicio.minute,
                        _dataInicio.second,
                      ));
                },
              ),
              ListTile(
                title: const Text('Data de Término (opcional)'),
                subtitle: Text(_dataTermino != null
                    ? DateFormat('dd/MM/yyyy').format(_dataTermino!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final horaBase = _dataTermino ?? _dataInicio;
                  final date = await showDatePicker(
                    context: context,
                    initialDate: horaBase,
                    firstDate: _dataInicio,
                    lastDate: DateTime(2030),
                  );
                  if (date == null) return;
                  setState(() => _dataTermino = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        horaBase.hour,
                        horaBase.minute,
                        horaBase.second,
                      ));
                },
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.anchor, color: Colors.blue),
                      title: const Text('Porto de origem *'),
                      subtitle: Text(_portoOrigem?.nome ?? 'Toque para escolher'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _salvando ? null : _selecionarPortoOrigem,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.flag_outlined, color: Colors.blue),
                      title: const Text('Porto de destino (opcional)'),
                      subtitle: Text(_portoDestino?.nome ?? 'Toque para escolher'),
                      trailing: _portoDestino != null
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              tooltip: 'Remover destino',
                              onPressed: _salvando
                                  ? null
                                  : () => setState(() => _portoDestino = null),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: _salvando ? null : _selecionarPortoDestino,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvando ? null : _salvarViagem,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('INICIAR VIAGEM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo de busca/cadastro de porto — separado em widget próprio pra ter
/// seu próprio estado de busca sem poluir `_NovaViagemScreenState`.
class _BuscaPortoDialog extends StatefulWidget {
  final String titulo;

  const _BuscaPortoDialog({required this.titulo});

  @override
  State<_BuscaPortoDialog> createState() => _BuscaPortoDialogState();
}

class _BuscaPortoDialogState extends State<_BuscaPortoDialog> {
  final _buscaController = TextEditingController();
  List<Porto>? _resultados;
  bool _buscando = false;
  String? _erro;

  Future<void> _buscar() async {
    final termo = _buscaController.text.trim();
    if (termo.isEmpty) return;

    setState(() {
      _buscando = true;
      _erro = null;
      _resultados = null;
    });
    try {
      final resultados = await PortoRepository().listar(nome: termo);
      if (!mounted) return;
      setState(() => _resultados = resultados);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = mensagemErroAmigavel(e, prefixo: 'Erro ao buscar portos'));
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _cadastrarNovo() async {
    final termo = _buscaController.text.trim();
    if (termo.isEmpty || !mounted) return;

    final novo = await showDialog<Porto>(
      context: context,
      builder: (_) => _NovoPortoDialog(nomeInicial: termo),
    );
    if (novo != null && mounted) Navigator.pop(context, novo);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do porto',
                      hintText: 'Ex: Santos',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscando ? null : _buscar,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_buscando)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 12))
            else if (_resultados != null) ...[
              if (_resultados!.isEmpty)
                const Text('Nenhum porto encontrado.',
                    style: TextStyle(color: Colors.grey))
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _resultados!.length,
                    itemBuilder: (context, i) {
                      final porto = _resultados![i];
                      return ListTile(
                        title: Text(porto.nome),
                        subtitle: porto.codigo != null
                            ? Text(porto.codigo!)
                            : null,
                        onTap: () => Navigator.pop(context, porto),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _cadastrarNovo,
                icon: const Icon(Icons.add),
                label: Text('Cadastrar "${_buscaController.text.trim()}" como novo porto'),
              ),
            ],
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
}

/// Formulário mínimo pra cadastrar um porto novo — nome (já vem da busca),
/// código/sigla/país opcionais e a coordenada, que a API exige.
class _NovoPortoDialog extends StatefulWidget {
  final String nomeInicial;

  const _NovoPortoDialog({required this.nomeInicial});

  @override
  State<_NovoPortoDialog> createState() => _NovoPortoDialogState();
}

class _NovoPortoDialogState extends State<_NovoPortoDialog> {
  late final TextEditingController _nomeController =
      TextEditingController(text: widget.nomeInicial);
  final _codigoController = TextEditingController();
  double _latitude = 0;
  double _longitude = 0;
  bool _salvando = false;
  String? _erro;

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final porto = await PortoRepository().criarOuReaproveitar(
        nome: nome,
        codigo: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );
      if (!mounted) return;
      Navigator.pop(context, porto);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = mensagemErroAmigavel(e, prefixo: 'Erro ao cadastrar porto');
        _salvando = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo porto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código (opcional)',
                hintText: 'Ex: BRSSZ',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            SeletorCoordenadaWidget(
              onAlterado: (lat, lon) {
                _latitude = lat;
                _longitude = lon;
              },
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando || _nomeController.text.trim().isEmpty
              ? null
              : _salvar,
          child: _salvando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
