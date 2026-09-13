// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitulo => 'Atlas Blue Ocean';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get sair => 'Sair';

  @override
  String get salvar => 'Salvar';

  @override
  String get sincronizar => 'Sincronizar';

  @override
  String get idiomaSistema => 'Idioma do sistema';

  @override
  String get idiomaPortugues => 'Português';

  @override
  String get idiomaIngles => 'English';

  @override
  String get idiomaEspanhol => 'Español';

  @override
  String get idiomaItaliano => 'Italiano';

  @override
  String get idiomaFrances => 'Français';

  @override
  String get loginSubtitulo => 'Login do Mestre';

  @override
  String get loginUsuarioLabel => 'Usuário';

  @override
  String get loginUsuarioObrigatorio => 'Informe o usuário';

  @override
  String get loginSenhaLabel => 'Senha';

  @override
  String get loginSenhaObrigatoria => 'Informe a senha';

  @override
  String get loginLembrarCredenciais => 'Lembrar minhas credenciais';

  @override
  String get loginLembrarCredenciaisSubtitulo =>
      'Entra automaticamente da próxima vez, até você sair da conta.';

  @override
  String get loginBotaoEntrar => 'ENTRAR';

  @override
  String get loginErroCredenciaisInvalidas => 'Usuário ou senha incorretos.';

  @override
  String get loginErroConexao => 'Erro ao conectar. Tente novamente.';

  @override
  String get loginEscolherOrganizacaoTitulo => 'Escolha a organização';

  @override
  String get configuracoesTitulo => 'Configurações';

  @override
  String get configIdentificacaoAparelho => 'Identificação do Aparelho';

  @override
  String get configIdDispositivo => 'ID do Dispositivo';

  @override
  String get configCopiar => 'Copiar';

  @override
  String get configIdCopiado => 'ID copiado para a área de transferência';

  @override
  String get configEmbarcacao => 'Embarcação';

  @override
  String get configConfigurarEmbarcacao => 'Configurar Embarcação';

  @override
  String get configConfigurarEmbarcacaoSubtitulo =>
      'Capacidades, tripulação, mestre e ID de envio de localização.';

  @override
  String get configRastreamentoLocalizacao => 'Rastreamento de Localização';

  @override
  String get configIntervaloCapturaEnvio => 'Intervalo de captura e envio';

  @override
  String get configIntervaloExplicacao =>
      'A cada intervalo, o app captura a posição, grava localmente e envia pra API. Sem internet, fica guardado e é enviado assim que a conexão voltar.';

  @override
  String configMinutos(int min) {
    return '$min minutos';
  }

  @override
  String configIntervaloSalvo(int min) {
    return 'Intervalo de rastreamento: $min min';
  }

  @override
  String get configOtimizacaoBateriaTitulo =>
      'Otimização de bateria pode interromper o rastreamento';

  @override
  String get configOtimizacaoBateriaTexto =>
      'O aparelho pode parar de registrar a posição a cada 15 minutos durante uma viagem, sem nenhum aviso, se o Atlas não estiver isento da otimização de bateria do sistema.';

  @override
  String get configIsentarApp => 'Isentar o app';

  @override
  String get configAparencia => 'Aparência';

  @override
  String get configTemaEscuro => 'Tema Escuro';

  @override
  String get configTemaClaro => 'Claro';

  @override
  String get configTemaSistema => 'Sistema';

  @override
  String get configTemaEscuroSegmento => 'Escuro';

  @override
  String get configModoNoturno => 'Modo Noturno';

  @override
  String get configModoNoturnoSubtitulo =>
      'Tela em vermelho para preservar a visão no escuro.';

  @override
  String get configRecomendacoes => 'Recomendações';

  @override
  String get configOcultarRecomendacoesExpiradas =>
      'Ocultar recomendações expiradas';

  @override
  String get configOcultarRecomendacoesExpiradasSubtitulo =>
      'Some da lista em \"Cartas Náuticas\" quem já passou da validade — continuam salvas, só não aparecem.';

  @override
  String get configEmergencia => 'Emergência';

  @override
  String get configContatoEmergencia => 'Contato de emergência (WhatsApp)';

  @override
  String get configContatoEmergenciaSubtitulo =>
      'Se preenchido, o botão de EMERGÊNCIA no painel abre direto uma conversa com esse número. Vazio, ele deixa você escolher o app na hora.';

  @override
  String get configNumeroLabel => 'Número com DDD e país';

  @override
  String get configNumeroHint => 'Ex: 5588999998888';

  @override
  String get configContatoSalvo => 'Contato de emergência salvo';

  @override
  String get configDadosBackup => 'Dados e Backup';

  @override
  String get configBackupManual => 'Backup manual';

  @override
  String get configBackupExplicacao =>
      'Rotas planejadas, pontos marcados, pedidos de carta e produção só existem neste aparelho — nada disso é enviado a um servidor. Gere um backup de vez em quando e guarde num lugar seguro (e-mail, nuvem, outro aparelho).';

  @override
  String get configGerarBackup => 'Gerar e compartilhar backup';

  @override
  String configBackupCompartilhado(String carimbo) {
    return 'Backup do Atlas Blue Ocean — $carimbo';
  }

  @override
  String configErroBackup(String erro) {
    return 'Erro ao gerar backup: $erro';
  }

  @override
  String get configDetalhesAparelho => 'Detalhes do Aparelho';

  @override
  String get configModelo => 'Modelo';

  @override
  String get configFabricante => 'Fabricante';

  @override
  String get configSistemaOperacional => 'Sistema Operacional';

  @override
  String get configTesteDispositivo => 'Teste — Dispositivo & Recomendações';

  @override
  String get configIdioma => 'Idioma';

  @override
  String get configIdiomaSubtitulo => 'Idioma usado em todo o aplicativo';

  @override
  String get dashboardAtivarModoNoturno => 'Ativar modo noturno';

  @override
  String get dashboardDesativarModoNoturno => 'Desativar modo noturno';

  @override
  String get dashboardBoasVindas => 'Bem-vindo, Mestre!';

  @override
  String dashboardEmbarcacaoLabel(String nome) {
    return 'Embarcação: $nome';
  }

  @override
  String get dashboardEmbarcacaoNaoDefinida => 'Não definida';

  @override
  String get dashboardEmergenciaBotao => 'EMERGÊNCIA — Enviar Posição';

  @override
  String get dashboardRastreamentoAtivo => 'Rastreamento Ativo';

  @override
  String dashboardRastreamentoSubtitulo(int min) {
    return 'Registrando posição a cada $min minutos';
  }

  @override
  String dashboardPosicoesPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posições aguardando sincronização',
      one: '1 posição aguardando sincronização',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPosicoesPendentesSubtitulo =>
      'Serão enviadas automaticamente assim que houver conexão.';

  @override
  String get dashboardSincronizarAgora => 'Sincronizar agora';

  @override
  String dashboardBateriaBaixa(int percent) {
    return 'Bateria do celular em $percent%';
  }

  @override
  String get dashboardBateriaBaixaSubtitulo =>
      'O rastreamento pode parar se a bateria acabar.';

  @override
  String get dashboardSemPosicaoRecente => 'Sem posição recente registrada';

  @override
  String dashboardSemPosicaoRecenteSubtitulo(String tempo) {
    return 'Última posição há $tempo. Verifique o sinal de GPS.';
  }

  @override
  String dashboardTempoMinutos(int min) {
    return '$min min';
  }

  @override
  String dashboardTempoHoras(int h) {
    return '$h h';
  }

  @override
  String dashboardTempoDias(int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get dashboardBat => 'BAT';

  @override
  String get dashboardMetros => 'metros';

  @override
  String get dashboardSst => 'SST';

  @override
  String get dashboardMapa => 'Mapa';

  @override
  String get dashboardRodape =>
      'Todos os dados são salvos localmente.\nA sincronização com o servidor será feita quando houver conexão.';

  @override
  String get dashboardErroCarregar =>
      'Não foi possível carregar os dados do painel.';

  @override
  String get dashboardTentarNovamente => 'Tentar novamente';

  @override
  String dashboardPosicoesEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posições enviadas',
      one: '1 posição enviada',
    );
    return '$_temp0';
  }

  @override
  String dashboardAindaPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ainda pendentes',
      one: '1 ainda pendente',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSincronizacaoFalhou =>
      'Não foi possível sincronizar agora. Verifique a conexão.';

  @override
  String dashboardErroSincronizar(String erro) {
    return 'Erro ao sincronizar: $erro';
  }

  @override
  String get dashboardSosTitulo => 'Enviar sinal de emergência?';

  @override
  String get dashboardSosTexto =>
      'Isso vai abrir um app de mensagem com sua posição atual e um pedido de ajuda, pra você enviar a quem puder socorrer.';

  @override
  String get dashboardSosConfirmar => 'EMERGÊNCIA';

  @override
  String dashboardSosErroPosicao(String erro) {
    return 'Não foi possível obter a posição: $erro';
  }

  @override
  String dashboardSosMensagem(
      String embarcacao, String posicao, String horario, String url) {
    return '🆘 EMERGÊNCIA — preciso de ajuda!\nEmbarcação: $embarcacao\nPosição: $posicao\nHorário: $horario\n$url';
  }

  @override
  String get dashboardEmbarcacaoNaoInformada => 'não informada';

  @override
  String get drawerViagemAtual => 'Viagem Atual';

  @override
  String get drawerProducao => 'Produção';

  @override
  String get drawerSolicitarCarta => 'Solicitar Carta';

  @override
  String get drawerCartasNauticas => 'Cartas Náuticas';

  @override
  String get drawerMinhasRotas => 'Minhas Rotas';

  @override
  String get drawerEmbarcacao => 'Embarcação';

  @override
  String get drawerCondicoesMar => 'Condições do Mar';

  @override
  String get drawerAlertaRota => 'Alerta de Rota';

  @override
  String get drawerTabuaMare => 'Tábua de Maré';

  @override
  String get drawerMareEPesca => 'Maré e Pesca';

  @override
  String get drawerFaseLua => 'Fase da Lua';

  @override
  String get drawerAvisosNavegantes => 'Avisos aos Navegantes';

  @override
  String get drawerConfiguracoes => 'Configurações';

  @override
  String get drawerSair => 'Sair';

  @override
  String get dashboardCartaSolicitadaSucesso => 'Carta solicitada com sucesso!';

  @override
  String get dashboardNenhumaEmbarcacaoTitulo => 'Nenhuma embarcação vinculada';

  @override
  String dashboardNenhumaEmbarcacaoTexto(String motivo) {
    return 'A embarcação é vinculada automaticamente pela sua viagem ativa na plataforma. Sincronize antes de $motivo.';
  }

  @override
  String get dashboardNenhumaViagemTitulo => 'Nenhuma viagem em andamento';

  @override
  String dashboardNenhumaViagemTexto(String motivo) {
    return 'As viagens agora são criadas na plataforma. Sincronize antes de $motivo, ou peça pra iniciar a viagem por lá.';
  }

  @override
  String get dashboardMotivoRegistrarProducao => 'registrar produção';

  @override
  String get dashboardViagemSincronizada => 'Viagem ativa sincronizada.';

  @override
  String get dashboardNenhumaViagemEncontrada =>
      'Nenhuma viagem ativa encontrada na plataforma agora.';

  @override
  String get dashboardSairTitulo => 'Sair do Sistema';

  @override
  String get dashboardSairTexto => 'Deseja realmente sair?';
}
