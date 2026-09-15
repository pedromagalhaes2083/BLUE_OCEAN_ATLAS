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

  @override
  String get producaoTitulo => 'Registro de Produção';

  @override
  String get producaoVerHistorico => 'Ver histórico e totais';

  @override
  String producaoDataLabel(String data) {
    return 'Data: $data';
  }

  @override
  String get producaoSemViagemAviso =>
      'Sem viagem em andamento — registro não será associado a uma viagem.';

  @override
  String get producaoClassificacaoLabel => 'Classificação *';

  @override
  String get producaoSelecioneClassificacao => 'Selecione a classificação';

  @override
  String get producaoQuantidadeLabel => 'Quantidade (unidades) *';

  @override
  String get producaoInformeQuantidade => 'Informe a quantidade';

  @override
  String get producaoQuantidadeInvalida =>
      'Informe um número inteiro maior que zero';

  @override
  String get producaoObservacaoLabel => 'Observação (opcional)';

  @override
  String get producaoCapturandoLocalizacao => 'Capturando localização...';

  @override
  String get producaoSalvando => 'Salvando...';

  @override
  String get producaoSalvarBotao => 'SALVAR PRODUÇÃO';

  @override
  String get producaoTipoPeixeLabel => 'Tipo do peixe *';

  @override
  String get producaoSelecioneTipoPeixe => 'Selecione o tipo do peixe';

  @override
  String get producaoPesoEstimadoLabel => 'Peso estimado';

  @override
  String get producaoSemEmbarcacaoVinculada =>
      'Nenhuma embarcação vinculada — configure em Configurações → Embarcação antes de registrar produção.';

  @override
  String producaoErroGps(String erro) {
    return 'Não foi possível obter o GPS agora ($erro). Registro será salvo sem coordenada.';
  }

  @override
  String get producaoSalvaSucesso => '✅ Produção salva com sucesso!';

  @override
  String producaoErroSalvar(String erro) {
    return 'Erro ao salvar: $erro';
  }

  @override
  String producaoKgPorUnidade(String min, String max) {
    return '$min–$max kg/un.';
  }

  @override
  String get producaoEmbarcacaoNaoDefinida => 'Não definida';

  @override
  String get fechar => 'Fechar';

  @override
  String get remover => 'Remover';

  @override
  String get mapaCartaRecomendacaoIndisponivel =>
      'Carta da recomendação não disponível (o link pode ter expirado)';

  @override
  String get mapaErroCarregarCartaRecomendacao =>
      'Não foi possível carregar a carta da recomendação';

  @override
  String mapaErroSalvarRota(String erro) {
    return 'Erro ao salvar rota: $erro';
  }

  @override
  String get mapaLabelData => 'Data';

  @override
  String get mapaLabelClassificacaoCurto => 'Classificação';

  @override
  String get mapaLabelPeso => 'Peso';

  @override
  String mapaProducaoTotal(String kg) {
    return '$kg kg no total';
  }

  @override
  String get mapaEspecieNaoInformada => 'Não informado';

  @override
  String get mapaClorofilaTitulo => 'Clorofila-a';

  @override
  String get mapaClorofilaSemDado =>
      'Sem dado válido pra esse ponto (nuvem, terra próxima ou falha do sensor no dia mais recente disponível)';

  @override
  String mapaClorofilaData(String data) {
    return 'Data: $data';
  }

  @override
  String mapaClorofilaFonte(String fonte) {
    return 'Fonte: $fonte';
  }

  @override
  String get mapaClorofilaDisclaimer =>
      'Indicador de produtividade biológica/oceanográfica — não representa diretamente quantidade de peixe.';

  @override
  String get mapaAdicionarPontoClorofila => 'Marcar outro ponto de clorofila-a';

  @override
  String get mapaIndiceProdutividadeTitulo =>
      'Índice de Produtividade Blue Ocean';

  @override
  String get mapaAdicionarPontoIndice =>
      'Marcar outro ponto de índice de produtividade';

  @override
  String mapaIndiceDadosClorofilaData(String data) {
    return 'Dados de clorofila-a de $data';
  }

  @override
  String get mapaIndiceFontes =>
      'Fontes: NOAA CoastWatch (ERDDAP) · Open-Meteo Marine';

  @override
  String get mapaIndiceDisclaimer =>
      'Estimativa combinando clorofila-a e temperatura da superfície do mar — não representa diretamente quantidade de peixe, só um indicador indireto de produtividade.';

  @override
  String get mapaTemperaturaTitulo => 'Temperatura da superfície do mar';

  @override
  String mapaConsultarPontoInstrucao(String titulo) {
    return 'Consultar $titulo — aponte o centro do mapa para o local desejado';
  }

  @override
  String get mapaConsultarBotao => 'Consultar';

  @override
  String mapaTemperaturaResultado(String valor) {
    return 'Temperatura no ponto: $valor °C';
  }

  @override
  String get mapaTemperaturaSemDado =>
      'Sem dado de temperatura pra esse ponto agora';

  @override
  String get mapaErroBuscarTemperatura => 'Erro ao buscar temperatura';

  @override
  String get mapaErroBuscarClorofila => 'Erro ao buscar clorofila-a';

  @override
  String get mapaErroCalcularIndice =>
      'Erro ao calcular índice de produtividade';

  @override
  String get mapaMenuTitulo => 'MENU DO MAPA';

  @override
  String get mapaCancelarMarcacao => 'Cancelar marcação';

  @override
  String get mapaMarcarPonto => 'Marcar um ponto';

  @override
  String get mapaCamadasTitulo => 'CAMADAS';

  @override
  String get mapaCamadaRuasTitulo => 'Mapa de Ruas (OpenStreetMap)';

  @override
  String get mapaCamadaRuasSubtitulo =>
      'Desligado: mostra a carta náutica carregada';

  @override
  String get mapaCamadaNauticaTitulo => 'Informações náuticas (OpenSeaMap)';

  @override
  String get mapaCamadaNauticaSubtitulo =>
      'Boias, marcas, faróis e portos — só sobre o Mapa de Ruas';

  @override
  String get mapaCamadaProfundidadeTitulo => 'Profundidade';

  @override
  String get mapaCamadaProfundidadeSubtitulo =>
      'Sombreamento batimétrico (GEBCO) · OpenSeaMap';

  @override
  String get mapaCamadaCurvasTitulo => 'Curvas de profundidade';

  @override
  String get mapaCamadaCurvasSubtitulo => 'Isóbatas · OpenSeaMap';

  @override
  String get mapaClorofilaSubtitulo =>
      'Indicador de produtividade · NOAA CoastWatch';

  @override
  String get mapaCamadaProducaoTitulo => 'Pontos de pesca (calor de produção)';

  @override
  String get mapaCamadaOverlayTitulo => 'Sobreposição de imagem';

  @override
  String get mapaCamadaOverlaySubtitulo =>
      'PNG georreferenciado — toque em \"Escolher imagem\" pra trocar';

  @override
  String get mapaEscolherImagem => 'Escolher imagem';

  @override
  String get mapaIndiceProdutividadeSubtitulo =>
      'Combina clorofila-a e temperatura — estimativa, não garantia de cardume';

  @override
  String get mapaBaixarRegiao => 'Baixar região para uso offline';

  @override
  String get mapaAtribuicao =>
      '© OpenStreetMap contributors · © OpenSeaMap contributors · Profundidade: GEBCO / OpenSeaMap depth project';

  @override
  String get mapaOverlayDialogTitulo => 'Sobreposição PNG';

  @override
  String get mapaOverlayDialogTexto =>
      'Escolha, na galeria de fotos do dispositivo, um PNG georreferenciado (com o metadado \"geo_bounds\" embutido) para exibir sobre a carta.';

  @override
  String get mapaSelecionarImagem => 'Selecionar imagem';

  @override
  String mapaOverlayFallback(String erro) {
    return '$erro Usando área padrão do app.';
  }

  @override
  String mapaErroSelecionarImagem(String erro) {
    return 'Erro ao selecionar imagem: $erro';
  }

  @override
  String mapaPontoMarcadoConfirmacao(String valor) {
    return 'Ponto marcado: $valor';
  }

  @override
  String get mapaPontoMarcadoTitulo => 'Ponto marcado';

  @override
  String get mapaLabelCoordenadas => 'Coordenadas';

  @override
  String get mapaLabelMarcadoEm => 'Marcado em';

  @override
  String get mapaLabelDistancia => 'Distância';

  @override
  String get mapaLabelRumo => 'Rumo';

  @override
  String get mapaConsultarAqui => 'Consultar aqui';

  @override
  String get mapaPontoRecomendacaoTitulo => 'Ponto da recomendação';

  @override
  String get mapaLabelRecebidoEm => 'Recebido em';

  @override
  String get mapaEditarRota => 'Editar Rota';

  @override
  String get mapaNovaRotaPlanejada => 'Nova Rota Planejada';

  @override
  String get mapaRecomendacaoFallback => 'Recomendação';

  @override
  String get mapaRotaHistorico => 'Rota do histórico';

  @override
  String get mapaMenuDoMapaTooltip => 'Menu do mapa';

  @override
  String get mapaMeusPontosTooltip => 'Meus Pontos';

  @override
  String get mapaCarregandoCarta => 'Carregando carta náutica...';

  @override
  String mapaErroCarregarCarta(String erro) {
    return 'Erro ao carregar carta: $erro';
  }

  @override
  String get mapaApontarCentro =>
      'Aponte o centro do mapa para o local desejado';

  @override
  String get mapaNomeLocalLabel => 'Nome do local (opcional)';

  @override
  String get mapaNomeLocalHint => 'Ex: Poço do Camurupim';

  @override
  String get mapaMarcarPontoBotao => 'Marcar ponto';

  @override
  String get mapaRotaTocarPrimeiroPonto =>
      'Toque no mapa ou num ponto marcado para adicionar o primeiro ponto';

  @override
  String mapaRotaPontosAdicionados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pontos adicionados',
      one: '1 ponto adicionado',
    );
    return '$_temp0 — toque para continuar';
  }

  @override
  String get mapaNomeRotaLabel => 'Nome da rota';

  @override
  String get mapaNomeRotaHint => 'Ex: Pesqueiro do Camurupim';

  @override
  String get mapaDesfazerUltimo => 'Desfazer último';

  @override
  String get mapaSalvarAlteracoes => 'Salvar alterações';

  @override
  String get mapaSalvarRota => 'Salvar rota';

  @override
  String get shellHome => 'Home';

  @override
  String get shellCartasTab => 'Cartas';

  @override
  String cartasSemConexao(String horario) {
    return 'Sem conexão — mostrando a última lista sincronizada em $horario';
  }

  @override
  String get cartasDataDesconhecida => 'data desconhecida';

  @override
  String get minhasSolicitacoesTooltip => 'Minhas solicitações';

  @override
  String get minhasSolicitacoesTitulo => 'Minhas Solicitações';

  @override
  String minhasSolicitacoesErro(String erro) {
    return 'Erro ao carregar solicitações: $erro';
  }

  @override
  String get minhasSolicitacoesVazio => 'Nenhuma solicitação de carta ainda';

  @override
  String minhasSolicitacoesPedidoEm(String data) {
    return 'Pedido em $data';
  }

  @override
  String get minhasSolicitacoesPendente => 'Pendente';

  @override
  String get solicitarCartaTitulo => 'Solicitar Carta Náutica';

  @override
  String get solicitarCartaCoordenadaGeografica => 'Coordenada Geográfica';

  @override
  String get solicitarCartaInstrucao =>
      'Gire os seletores como no relógio para ajustar graus e minutos';

  @override
  String get solicitarCartaBotao => 'SOLICITAR CARTA NÁUTICA';

  @override
  String get solicitarCartaSucesso =>
      'Solicitação registrada! Veja em \"Minhas Solicitações\".';

  @override
  String solicitarCartaErro(String erro) {
    return 'Erro ao solicitar carta: $erro';
  }

  @override
  String get embarcacaoTitulo => 'Minha Embarcação';

  @override
  String embarcacaoErroCarregar(String erro) {
    return 'Erro ao carregar embarcação: $erro';
  }

  @override
  String get embarcacaoSincronizadaSucesso =>
      'Embarcação sincronizada com a viagem ativa.';

  @override
  String get embarcacaoSemProprietario => 'Sem proprietário cadastrado';

  @override
  String get embarcacaoAtiva => 'Ativa';

  @override
  String get embarcacaoInativa => 'Inativa';

  @override
  String get embarcacaoCapacidadesTitulo => 'CAPACIDADES E TRIPULAÇÃO';

  @override
  String get embarcacaoUrnas => 'Urnas';

  @override
  String get embarcacaoGelo => 'Gelo';

  @override
  String get embarcacaoDiesel => 'Diesel';

  @override
  String get embarcacaoTripulantes => 'Tripulantes';

  @override
  String get embarcacaoDetalhesTitulo => 'DETALHES';

  @override
  String get embarcacaoMotorUsado => 'Motor Usado';

  @override
  String get embarcacaoIdMestre => 'ID Mestre / Capitão';

  @override
  String get embarcacaoIdRastreio => 'ID DE RASTREIO';

  @override
  String get embarcacaoVinculacaoAutomatica =>
      'A embarcação é vinculada automaticamente a partir da sua viagem ativa na plataforma.';

  @override
  String get embarcacaoRastrear => 'Rastrear';

  @override
  String get embarcacaoConfigTooltipSincronizar =>
      'Sincronizar com a viagem ativa';

  @override
  String get embarcacaoConfigTesteDisparado =>
      'Teste disparado — veja o resultado no console/log';

  @override
  String get embarcacaoConfigSemEmbarcacaoTexto =>
      'A embarcação é vinculada automaticamente a partir da sua viagem ativa na plataforma. Toque em sincronizar para buscar de novo.';

  @override
  String get embarcacaoConfigVinculadaTexto =>
      'Vinculada pela viagem ativa na plataforma.';

  @override
  String get embarcacaoConfigIdLabel => 'ID Embarcação';

  @override
  String get embarcacaoConfigCapacidadeGelo => 'Capacidade de gelo';

  @override
  String get embarcacaoConfigCapacidadeDiesel => 'Capacidade de diesel';

  @override
  String get embarcacaoConfigMotorUsado => 'Motor usado';

  @override
  String get embarcacaoConfigNumeroTripulantes => 'Número de tripulantes';

  @override
  String get embarcacaoConfigTestarEnvio => 'Testar envio de localização';

  @override
  String viagemErroCarregarHistorico(String erro) {
    return 'Erro ao carregar histórico: $erro';
  }

  @override
  String get viagemResumoDaViagemFallback => 'Resumo da viagem';

  @override
  String viagemCompartilharInicio(String data) {
    return 'Início: $data';
  }

  @override
  String viagemCompartilharDistancia(String mn) {
    return 'Distância: $mn mn';
  }

  @override
  String viagemCompartilharDuracao(String valor) {
    return 'Duração: $valor';
  }

  @override
  String viagemCompartilharVelMedia(String valor) {
    return 'Vel. média: $valor km/h';
  }

  @override
  String viagemCompartilharVelMaxima(String valor) {
    return 'Vel. máxima: $valor km/h';
  }

  @override
  String get viagemCompartilharProducaoTitulo => '🐟 Produção:';

  @override
  String get viagemFinalizarTitulo => 'Finalizar viagem';

  @override
  String get viagemFinalizarTexto =>
      'Tem certeza que deseja encerrar esta viagem? O rastreamento de posição em segundo plano para junto — o app só volta a enviar a posição quando outra viagem for iniciada.';

  @override
  String get viagemFinalizarBotao => 'Finalizar';

  @override
  String viagemErroFinalizar(String erro) {
    return 'Erro ao finalizar viagem: $erro';
  }

  @override
  String get viagemVerRotaTooltip => 'Ver rota na carta';

  @override
  String get viagemCompartilharTooltip => 'Compartilhar resumo da viagem';

  @override
  String get viagemAtualizarTooltip => 'Atualizar';

  @override
  String get viagemNenhumRegistro => 'Nenhum registro encontrado';

  @override
  String get viagemCriadasNaPlataforma =>
      'As viagens agora são criadas na plataforma. Toque em sincronizar para buscar a viagem ativa.';

  @override
  String get viagemEmAndamentoFallback => 'Viagem em andamento';

  @override
  String viagemIniciadaEm(String data) {
    return 'Iniciada em $data';
  }

  @override
  String get viagemDuracaoLabel => 'Duração';

  @override
  String get viagemVelMediaLabel => 'Vel. média';

  @override
  String get viagemVelMaximaLabel => 'Vel. máxima';

  @override
  String viagemPrecLabel(String m) {
    return 'Prec: ${m}m';
  }

  @override
  String get apagar => 'Apagar';

  @override
  String rotasErroCarregar(String erro) {
    return 'Erro ao carregar rotas: $erro';
  }

  @override
  String get rotasApagarTitulo => 'Apagar rota?';

  @override
  String rotasApagarTexto(String nome) {
    return '\"$nome\" será removida permanentemente.';
  }

  @override
  String get rotasNovaRota => 'Nova rota';

  @override
  String get rotasNenhumaAinda => 'Nenhuma rota planejada ainda';

  @override
  String get rotasTocarNovaRota =>
      'Toque em \"Nova rota\" para marcar pontos no mapa';

  @override
  String rotasPontosEData(int n, String data) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pontos',
      one: '1 ponto',
    );
    return '$_temp0 · $data';
  }

  @override
  String get rotasAnalisarTooltip => 'Analisar condições da rota';

  @override
  String get rotasEditarTooltip => 'Editar rota';

  @override
  String get rotasApagarTooltip => 'Apagar rota';

  @override
  String rotasAnaliseTitulo(String nome) {
    return 'Análise: $nome';
  }

  @override
  String get rotasBuscandoCondicoes => 'Buscando condições ao longo da rota...';

  @override
  String rotasPontosComCondicaoSevera(int severos, int total) {
    return '$severos de $total pontos com condição severa';
  }

  @override
  String get rotasNenhumPontoSevero => 'Nenhum ponto com condição severa';

  @override
  String rotasPontosDistanciaTotal(int n, String distancia) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pontos',
      one: '1 ponto',
    );
    return '$_temp0 · $distancia mn no total';
  }

  @override
  String rotasTrechoDesdePonto(String trecho, int indice) {
    return '+$trecho mn desde o ponto $indice';
  }

  @override
  String get metricaVento => 'Vento';

  @override
  String get metricaOnda => 'Onda';

  @override
  String get metricaCorrente => 'Corrente';

  @override
  String get metricaAgua => 'Água';

  @override
  String get metricaMare => 'Maré';

  @override
  String get condicoesMarTitulo => 'Condições do Mar';

  @override
  String get condicoesMarAguardandoPosicao =>
      'Aguardando posição atual da embarcação...';

  @override
  String get erroBuscarPrevisaoPrefixo => 'Erro ao buscar previsão';

  @override
  String get condicoesPontoTituloFallback => 'Condições do Ponto';

  @override
  String get posicaoAtualTitulo => '📍 Posição Atual';

  @override
  String get posicaoAtualizarTooltip => 'Atualizar posição';

  @override
  String get posicaoTocarIcone => 'Toque no ícone para atualizar';

  @override
  String get posicaoTocarBotao => 'Toque no botão para atualizar';

  @override
  String get posicaoErroLocalizacaoDesativada =>
      '❌ Localização está desativada no dispositivo';

  @override
  String get posicaoErroPermissaoNegadaPermanente =>
      '❌ Permissão negada permanentemente.\nVá em Configurações > Apps';

  @override
  String get posicaoErroPermissaoNegada => '❌ Permissão de localização negada';

  @override
  String get posicaoErroTimeout =>
      '❌ Tempo esgotado ao obter a posição.\nTente novamente em área aberta.';

  @override
  String posicaoErroGenerico(String erro) {
    return '❌ Erro: $erro';
  }

  @override
  String get profundidadeCarregando => 'Carregando profundidade...';

  @override
  String get pontoEmTerra => 'Ponto em terra';

  @override
  String get sstCarregando => 'Carregando temperatura da água...';

  @override
  String get sstSuperficieDoMar => 'Superfície do mar';

  @override
  String mareNivelAgora(String nivel) {
    return '$nivel m agora';
  }

  @override
  String get marePreamar => 'Preamar';

  @override
  String get mareBaixaMar => 'Baixa-mar';

  @override
  String get luaLabel => 'Lua';

  @override
  String luaIluminadaCiclo(int pct, int dia) {
    return '$pct% iluminada · dia $dia do ciclo';
  }

  @override
  String get luaNascer => 'Nascer';

  @override
  String get luaPor => 'Pôr';

  @override
  String get luaProximasFases => 'PRÓXIMAS FASES';

  @override
  String get luaHoje => 'hoje';

  @override
  String luaEmDias(int d) {
    return 'em ${d}d';
  }

  @override
  String get solunarTitulo => 'Tabela Solunar';

  @override
  String get solunarSubtitulo =>
      'Períodos de maior atividade de alimentação, segundo a posição da lua';

  @override
  String get ventoCarregando => 'Carregando previsão do tempo...';

  @override
  String get ventoClimaAtual => 'Clima Atual';

  @override
  String get ventoVelocidadeTitulo => 'VELOCIDADE DO VENTO';

  @override
  String ventoDirecao(int graus) {
    return 'Direção: $graus°';
  }

  @override
  String get labelTemperatura => 'Temperatura';

  @override
  String get labelPressao => 'Pressão';

  @override
  String get ventoPrevisaoHoraria => 'Previsão horária';

  @override
  String get ventoIntensidadeCalmo => 'Calmo';

  @override
  String get ventoIntensidadeLeve => 'Leve';

  @override
  String get ventoIntensidadeModerado => 'Moderado';

  @override
  String get ventoIntensidadeForte => 'Forte';

  @override
  String get ventoIntensidadeMuitoForte => 'Muito forte';

  @override
  String get ondaCondicoesAtuais => 'Condições Atuais';

  @override
  String get ondaAlturaTitulo => 'ALTURA DE ONDA';

  @override
  String ondaPeriodo(String n) {
    return 'Período $n s';
  }

  @override
  String get ondaCorrenteTitulo => 'CORRENTE';

  @override
  String get ondaSemDados => 'Sem dados';

  @override
  String get ondaSwellPrefixo => 'Swell';

  @override
  String ondaDirecaoOnda(int graus) {
    return 'Dir. onda $graus°';
  }

  @override
  String get ondaAlturaCalmo => 'Calmo';

  @override
  String get ondaAlturaLeve => 'Leve';

  @override
  String get ondaAlturaModerado => 'Moderado';

  @override
  String get ondaAlturaAgitado => 'Agitado';

  @override
  String get ondaAlturaMuitoAgitado => 'Muito agitado';

  @override
  String get ondaAlturaTempestuoso => 'Tempestuoso';

  @override
  String get meteoSheetPosicaoFallback => 'Posição';

  @override
  String get meteoSheetSemDados => 'Sem dados meteorológicos';

  @override
  String get meteoSheetVentoTitulo => 'Vento';

  @override
  String get meteoSheetMovimentoTitulo => 'Movimento';

  @override
  String get meteoSheetAtmosferaTitulo => 'Atmosfera';

  @override
  String get meteoSheetOndasTitulo => 'Ondas';

  @override
  String get meteoSheetVelocidadeRealTws => 'Velocidade real (TWS)';

  @override
  String get meteoSheetDirecaoRealTwd => 'Direção real (TWD)';

  @override
  String get meteoSheetAnguloRealTwa => 'Ângulo real (TWA)';

  @override
  String get meteoSheetVelocidadeAparenteAws => 'Velocidade aparente (AWS)';

  @override
  String get meteoSheetAnguloAparenteAwa => 'Ângulo aparente (AWA)';

  @override
  String get meteoSheetRajadas => 'Rajadas';

  @override
  String get meteoSheetVelocidadeRealSog => 'Velocidade Real (SOG)';

  @override
  String get meteoSheetDirecaoRealCog => 'Direção Real (COG)';

  @override
  String get meteoSheetVelocidadeAparenteStw => 'Velocidade Aparente (STW)';

  @override
  String get meteoSheetAnguloAparenteCtw => 'Ângulo Aparente (CTW)';

  @override
  String get meteoSheetNuvens => 'Nuvens';

  @override
  String get meteoSheetChuva => 'Chuva';

  @override
  String get meteoSheetAlturaCombinada => 'Altura combinada';

  @override
  String get meteoSheetVentoAltura => 'Vento — altura';

  @override
  String get meteoSheetVentoDirecao => 'Vento — direção';

  @override
  String get meteoSheetVentoPeriodo => 'Vento — período';

  @override
  String get meteoSheetSwellAltura => 'Swell — altura';

  @override
  String get meteoSheetSwellDirecao => 'Swell — direção';

  @override
  String get meteoSheetSwellPeriodo => 'Swell — período';

  @override
  String get alertaConfigTitulo => 'Configurar Alertas';

  @override
  String get alertaConfigDescricao =>
      'Escolha a partir de que ponto cada condição no caminho da embarcação dispara uma notificação (com vibração). Vale tanto pra checagem manual em \"Alerta de Rota\" quanto pro rastreamento em segundo plano durante uma viagem.';

  @override
  String get alertaConfigVentoTitulo => 'Vento';

  @override
  String get alertaConfigVentoSubtitulo =>
      'Alerta quando o vento à frente passar de';

  @override
  String get alertaConfigOndaTitulo => 'Altura de onda e swell';

  @override
  String get alertaConfigOndaSubtitulo =>
      'Alerta quando onda ou swell passarem de';

  @override
  String get alertaConfigCorrenteTitulo => 'Corrente de maré';

  @override
  String get alertaConfigCorrenteSubtitulo =>
      'Alerta quando a corrente passar de';

  @override
  String get alertaConfigTemperaturaTitulo => 'Temperatura da água';

  @override
  String get alertaConfigTemperaturaSubtitulo =>
      'Alerta quando a temperatura passar de';

  @override
  String get alertaRotaTitulo => 'Alerta de Rota';

  @override
  String get alertaRotaTooltipConfigurar => 'Configurar alertas';

  @override
  String get alertaRotaTooltipSimular => 'Simular com ponto marcado';

  @override
  String alertaRotaErroPosicaoPrefixo(String erro) {
    return 'Erro ao obter posição: $erro';
  }

  @override
  String get alertaRotaNenhumPontoMarcado => 'Nenhum ponto marcado ainda';

  @override
  String get alertaRotaSimularDialogTitulo => 'Simular a partir de qual ponto?';

  @override
  String get alertaRotaRumoSimuladoTitulo => 'Rumo simulado';

  @override
  String get alertaRotaBotaoSimular => 'Simular';

  @override
  String get alertaRotaVentoTitulo => 'Vento à frente';

  @override
  String get alertaRotaCorrenteTitulo => 'Corrente à frente';

  @override
  String get alertaRotaOndaTitulo => 'Onda à frente';

  @override
  String get alertaRotaSwellTitulo => 'Swell à frente';

  @override
  String get alertaRotaBussolaTitulo => 'Bússola';

  @override
  String get alertaRotaSemSinal => 'Sem sinal';

  @override
  String get alertaRotaAlcanceTitulo => 'Alcance do alerta';

  @override
  String get alertaRotaAlcanceDescricao =>
      'Distância à frente da embarcação, no rumo atual, onde as condições são checadas.';

  @override
  String alertaRotaRumoEAlcance(String rumo, String alcance) {
    return 'Rumo $rumo° · $alcance mn à frente';
  }

  @override
  String get alertaRotaSemRumoDescricao =>
      'Rumo indisponível — a embarcação precisa estar em movimento para o GPS calcular um rumo válido.';

  @override
  String alertaRotaSimulacaoAtiva(String nome, String rumo) {
    return 'Simulação ativa — usando \"$nome\" com rumo $rumo° (não é o GPS real)';
  }

  @override
  String get alertaRotaCorrenteFraca => 'Fraca';

  @override
  String get alertaRotaCorrenteModerada => 'Moderada';

  @override
  String get alertaRotaCorrenteForte => 'Forte';

  @override
  String get alertaRotaCorrenteMuitoForte => 'Muito forte';

  @override
  String get alertaRotaCorrenteExtrema => 'Extrema';

  @override
  String get diaSemanaSegunda => 'Segunda-feira';

  @override
  String get diaSemanaTerca => 'Terça-feira';

  @override
  String get diaSemanaQuarta => 'Quarta-feira';

  @override
  String get diaSemanaQuinta => 'Quinta-feira';

  @override
  String get diaSemanaSexta => 'Sexta-feira';

  @override
  String get diaSemanaSabado => 'Sábado';

  @override
  String get diaSemanaDomingo => 'Domingo';

  @override
  String get faseLuaScreenTitulo => 'Fase da Lua';

  @override
  String get faseLuaErroBuscarPrefixo => 'Erro ao buscar nascer/pôr da lua';

  @override
  String get faseLuaAguardandoPosicao =>
      'Aguardando posição atual da embarcação para os horários de nascer/pôr da lua — a fase acima não depende disso.';

  @override
  String get faseLuaNascerEPorTitulo => 'NASCER E PÔR DA LUA';

  @override
  String faseLuaHojeData(String data) {
    return 'Hoje, $data';
  }

  @override
  String get erroSincronizarPrefixo => 'Erro ao sincronizar';

  @override
  String get tabuaMareTooltipRemoverPorto => 'Remover porto';

  @override
  String get tabuaMareRemoverPortoTitulo => 'Remover porto?';

  @override
  String tabuaMareRemoverPortoConteudo(String nome) {
    return '\"$nome\" será removido da lista.';
  }

  @override
  String get tabuaMareSincronizando => 'Sincronizando...';

  @override
  String get tabuaMareSincronizarDeNovo => 'Sincronizar de novo';

  @override
  String tabuaMareSincronizadoEm(String data) {
    return 'Sincronizado em $data · disponível offline';
  }

  @override
  String get tabuaMareAindaNaoSincronizado =>
      'Ainda não sincronizado — precisa de internet na 1ª vez';

  @override
  String get tabuaMareSincronizePrimeiraVez =>
      'Sincronize pelo menos uma vez, com internet, pra calcular a tábua de maré offline deste porto.';

  @override
  String get tabuaMareNivelAgoraTitulo => 'Nível agora';

  @override
  String get tabuaMareTitulo => 'Tábua de Maré';

  @override
  String get tabuaMareBotaoPorto => 'Porto';

  @override
  String tabuaMareErroCarregarPrefixo(String erro) {
    return 'Erro ao carregar portos: $erro';
  }

  @override
  String tabuaMareErroSincronizarNome(String nome) {
    return 'Erro ao sincronizar \"$nome\"';
  }

  @override
  String get tabuaMareNovoPortoTitulo => 'Novo porto';

  @override
  String get tabuaMareNomeLabel => 'Nome';

  @override
  String get tabuaMareNomeHint => 'Ex: Porto de Itarema';

  @override
  String get tabuaMarePreencherNome => 'Preencha o nome do porto';

  @override
  String get tabuaMareNenhumPortoTitulo => 'Nenhum porto salvo ainda';

  @override
  String get tabuaMareNenhumPortoDescricao =>
      'Salve a coordenada de um porto (ex: Itarema, Acaraú, Camocim) pra consultar a maré prevista, mesmo offline depois de sincronizado.';

  @override
  String get tabuaMarePoucosDados =>
      'Poucos dados de maré retornados pra esse ponto';

  @override
  String get mareEPescaTitulo => 'Maré e Pesca';

  @override
  String get mareEPescaErroBuscarPrefixo => 'Erro ao buscar previsão de maré';

  @override
  String get mareEPescaAguardandoPosicao =>
      'Aguardando posição atual da embarcação...';

  @override
  String get mareEPescaCabecalhoTitulo => 'Influência da Maré na Pesca de Atum';

  @override
  String get mareEPescaCabecalhoDescricao =>
      'Entenda como a amplitude das marés pode alterar correntes, mistura da água e condições de alimentação dos atuns.';

  @override
  String mareEPescaCondicaoAtual(String tipo) {
    return 'Condição atual da maré: $tipo';
  }

  @override
  String get mareEPescaGrafico24hTitulo => 'Maré nas próximas 24h';

  @override
  String get mareEPescaEntendaSizigia => 'Entenda a sizígia';

  @override
  String get mareEPescaEntendaQuadratura => 'Entenda a quadratura';

  @override
  String get mareEPescaImportante => 'Importante';

  @override
  String get mareEPescaAvisoPrincipal =>
      'A fase da maré não deve ser utilizada isoladamente para determinar uma área de pesca. A resposta do ambiente varia conforme localização, profundidade, topografia, regime de correntes, temperatura, disponibilidade de alimento, vento e outros fatores oceanográficos.';

  @override
  String get mareEPescaAvisoSecundario =>
      'Utilize a maré como um dos indicadores dentro de uma análise integrada.';

  @override
  String get producaoHistoricoTitulo => 'Histórico de Produção';

  @override
  String get producaoHistoricoTooltipPorPonto => 'Produção por ponto';

  @override
  String get producaoHistoricoTooltipVerMapa => 'Ver no mapa';

  @override
  String get producaoHistoricoTooltipExportarCsv => 'Exportar como CSV';

  @override
  String producaoHistoricoErroCarregarPrefixo(String erro) {
    return 'Erro ao carregar produção: $erro';
  }

  @override
  String producaoHistoricoErroExportarPrefixo(String erro) {
    return 'Erro ao exportar: $erro';
  }

  @override
  String get producaoHistoricoCsvCabecalho =>
      'Data/Hora,Espécie,Classificação,Quantidade (un.),Quantidade (kg),Latitude,Longitude,Observação';

  @override
  String producaoHistoricoCompartilharTexto(String kg) {
    return 'Histórico de produção — $kg kg';
  }

  @override
  String get producaoHistoricoNenhumRegistro =>
      'Nenhum registro de produção ainda';

  @override
  String producaoHistoricoTotalResumo(String kg, int n) {
    return 'Total: $kg kg em $n registro(s)';
  }

  @override
  String producaoHistoricoClassificacaoEUnidades(
      String classificacao, int unidades) {
    return 'Classificação $classificacao kg · $unidades un.';
  }

  @override
  String get producaoPorPontoTitulo => 'Produção por Ponto';

  @override
  String producaoPorPontoErroCarregarPrefixo(String erro) {
    return 'Erro ao carregar: $erro';
  }

  @override
  String get producaoPorPontoVazioTitulo =>
      'Nenhuma produção associada a um ponto marcado ainda';

  @override
  String get producaoPorPontoVazioDescricao =>
      'Registre capturas com coordenada e marque pontos no mapa para ver aqui os pontos mais produtivos';

  @override
  String producaoPorPontoTotalRegistros(int n) {
    return '$n registro(s)';
  }

  @override
  String producaoPorPontoEspecieDestaque(String especie) {
    return ' · $especie em destaque';
  }

  @override
  String get meusPontosTitulo => 'Meus Pontos';

  @override
  String get meusPontosNenhumTituloERecomendacao =>
      'Nenhum ponto marcado nem recomendação ainda';

  @override
  String get meusPontosSecaoPontosMarcados => 'PONTOS MARCADOS';

  @override
  String get meusPontosSecaoRecomendacoes => 'RECOMENDAÇÕES';

  @override
  String get meusPontosDataDesconhecida => 'data desconhecida';

  @override
  String meusPontosBannerOffline(String horario) {
    return 'Sem conexão — mostrando as últimas recomendações sincronizadas em $horario';
  }

  @override
  String get meusPontosMarcadoEm => 'Marcado em';

  @override
  String get meusPontosProducaoAqui => 'Produção aqui';

  @override
  String meusPontosProducaoAquiValor(String kg, int n) {
    return '$kg kg ($n registro(s))';
  }

  @override
  String get meusPontosConsultarAqui => 'Consultar aqui';

  @override
  String get meusPontosMareEPescaAqui => 'Maré e Pesca aqui';

  @override
  String get mapaScreenTituloFallback => 'Mapa';

  @override
  String get mapaRotaProducao => 'Rota de Produção';

  @override
  String get mapaSstLabel => 'SST';

  @override
  String get recomendacaoSemTitulo => '(sem título)';

  @override
  String get recomendacaoNenhumaDisponivel => 'Nenhuma recomendação disponível';

  @override
  String get recomendacaoExpirada => 'Expirada';

  @override
  String recomendacaoValidaAte(String data) {
    return 'Válida até $data';
  }

  @override
  String recomendacaoVarPrefixo(String variavel, String valor) {
    return 'Var. $variavel: $valor';
  }

  @override
  String recomendacaoPontosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get recomendacaoVerNaCarta => 'Ver na Carta';

  @override
  String recomendacaoKgEstimados(String kg) {
    return '$kg kg estimados';
  }

  @override
  String recomendacaoPontosAmostrados(int n) {
    return '$n pontos amostrados';
  }

  @override
  String get faseLuaTipoNovaLua => 'Lua Nova';

  @override
  String get faseLuaTipoCrescente => 'Lua Crescente';

  @override
  String get faseLuaTipoQuartoCrescente => 'Quarto Crescente';

  @override
  String get faseLuaTipoGibosaCrescente => 'Gibosa Crescente';

  @override
  String get faseLuaTipoCheia => 'Lua Cheia';

  @override
  String get faseLuaTipoGibosaMinguante => 'Gibosa Minguante';

  @override
  String get faseLuaTipoQuartoMinguante => 'Quarto Minguante';

  @override
  String get faseLuaTipoMinguante => 'Lua Minguante';

  @override
  String get tipoMareSizigiaLabel => 'Sizígia';

  @override
  String get tipoMareSizigiaNota =>
      'Correntes mais fortes, maior amplitude de maré.';

  @override
  String get tipoMareQuadraturaLabel => 'Quadratura';

  @override
  String get tipoMareQuadraturaNota =>
      'Correntes mais fracas, menor amplitude de maré.';

  @override
  String get tipoMareTransicaoLabel => 'Transição';

  @override
  String get tipoMareTransicaoNota =>
      'Nem sizígia nem quadratura — período de meio de caminho.';

  @override
  String get tendenciaPressaoCaindo => 'Caindo';

  @override
  String get tendenciaPressaoEstavel => 'Estável';

  @override
  String get tendenciaPressaoSubindo => 'Subindo';

  @override
  String get tipoPeriodoSolunarMaior => 'Período Maior';

  @override
  String get tipoPeriodoSolunarMenor => 'Período Menor';

  @override
  String get variavelAmbientalVento => 'Vento';

  @override
  String get variavelAmbientalCorrente => 'Corrente';

  @override
  String get variavelAmbientalClorofila => 'Clorofila';

  @override
  String get variavelAmbientalOnda => 'Onda';

  @override
  String get variavelAmbientalTemperatura => 'Temperatura';

  @override
  String get nivelOperacionalFavoravelTitulo =>
      'Condição potencialmente favorável';

  @override
  String get nivelOperacionalFavoravelTexto =>
      'Quando vários indicadores oceanográficos convergem, a influência da maré pode reforçar uma condição já favorável.';

  @override
  String get nivelOperacionalAtencaoTitulo => 'Condição de atenção';

  @override
  String get nivelOperacionalAtencaoTexto =>
      'A maré isoladamente não é suficiente para indicar uma boa área de pesca.';

  @override
  String get nivelOperacionalBaixaEvidenciaTitulo => 'Baixa evidência';

  @override
  String get nivelOperacionalBaixaEvidenciaTexto =>
      'Não utilizar a fase da maré como único motivo para deslocar a embarcação.';

  @override
  String get nivelOperacionalCardTitulo => 'Classificação Atual';

  @override
  String get nivelOperacionalCardDescricao =>
      'Classificação a partir dos indicadores que o app tem hoje (maré astronômica + corrente medida) — não é previsão de captura.';

  @override
  String get nivelOperacionalAgora => 'AGORA';

  @override
  String get estadoMareTitulo => 'ESTADO ATUAL';

  @override
  String estadoMareTituloMare(String tipo) {
    return 'MARÉ DE $tipo';
  }

  @override
  String get estadoMareFaseDaLua => 'FASE DA LUA';

  @override
  String estadoMareDiaDoCiclo(int n) {
    return 'dia $n do ciclo';
  }

  @override
  String get estadoMareAmplitudePrevista => 'AMPLITUDE PREVISTA (24H)';

  @override
  String get estadoMareProximaPreamar => 'PRÓXIMA PREAMAR';

  @override
  String get estadoMareProximaBaixaMar => 'PRÓXIMA BAIXA-MAR';

  @override
  String get estadoMareDadoIndisponivel => 'Dado indisponível';

  @override
  String get estadoMareQuadratura => 'QUADRATURA';

  @override
  String get estadoMareSizigia => 'SIZÍGIA';

  @override
  String get classificacaoIndiceBaixa => 'Baixo';

  @override
  String get classificacaoIndiceModerada => 'Moderado';

  @override
  String get classificacaoIndiceAlta => 'Alto';

  @override
  String get indiceFatorFaseLunarNome => 'Fase lunar (proximidade da sizígia)';

  @override
  String get indiceFatorAmplitudeNome => 'Amplitude de maré prevista';

  @override
  String get indiceFatorCorrenteNome => 'Velocidade da corrente';

  @override
  String indiceFatorFaseLunarDetalhe(String fase, int dia) {
    return '$fase · dia $dia do ciclo';
  }

  @override
  String indiceFatorAmplitudeDetalhe(String m) {
    return '$m m nas próximas 24h';
  }

  @override
  String indiceFatorCorrenteDetalhe(String ms) {
    return '$ms m/s agora';
  }

  @override
  String get indiceInformativoDirecaoCorrente => 'Direção da corrente';

  @override
  String get indiceInformativoDiferencaTemperatura =>
      'Diferença de temperatura';

  @override
  String get indiceInformativoProximidadeFrentes =>
      'Proximidade de frentes térmicas';

  @override
  String get indiceCardTitulo => 'Potencial de Influência';

  @override
  String get indiceCardDescricao =>
      'Quanto as condições de maré podem estar contribuindo para a dinâmica oceanográfica da região — não é chance de pegar atum.';

  @override
  String indiceCardPotencialPrefixo(String classificacao) {
    return 'Potencial $classificacao';
  }

  @override
  String get indiceCardFatoresConsiderados => 'FATORES CONSIDERADOS';

  @override
  String get indiceCardInformativos => 'INFORMATIVOS (NÃO ENTRAM NA PONTUAÇÃO)';

  @override
  String get comparacaoSizigiaTitulo => 'Maré de Sizígia';

  @override
  String get comparacaoSizigiaResumo => 'Maior amplitude de maré';

  @override
  String get comparacaoSizigiaEfeito1 => 'Maior variação do nível do mar';

  @override
  String get comparacaoSizigiaEfeito2 =>
      'Correntes de maré potencialmente mais intensas em determinadas regiões';

  @override
  String get comparacaoSizigiaEfeito3 => 'Maior transporte horizontal de água';

  @override
  String get comparacaoSizigiaEfeito4 =>
      'Maior mistura em ambientes onde a maré exerce forte influência';

  @override
  String get comparacaoSizigiaEfeito5 =>
      'Alteração na distribuição/concentração de organismos que servem de alimento aos peixes';

  @override
  String get comparacaoSizigiaRelacaoPesca =>
      'Em áreas onde as correntes de maré possuem influência significativa, períodos de maior amplitude podem aumentar a movimentação e a mistura da água, podendo alterar a distribuição de presas e criar condições favoráveis à atividade dos atuns.';

  @override
  String get comparacaoSizigiaPotencial => 'ALTO';

  @override
  String get comparacaoQuadraturaTitulo => 'Maré de Quadratura';

  @override
  String get comparacaoQuadraturaResumo => 'Menor amplitude de maré';

  @override
  String get comparacaoQuadraturaEfeito1 =>
      'Correntes de maré potencialmente menos intensas';

  @override
  String get comparacaoQuadraturaEfeito2 => 'Menor variação do nível da água';

  @override
  String get comparacaoQuadraturaEfeito3 =>
      'Menor influência da maré sobre a mistura em determinadas regiões';

  @override
  String get comparacaoQuadraturaEfeito4 =>
      'Distribuição diferente de organismos e presas';

  @override
  String get comparacaoQuadraturaRelacaoPesca =>
      'Durante a quadratura, a menor amplitude da maré pode resultar em menor influência das correntes de maré em determinadas áreas. Entretanto, isso não significa necessariamente menor atividade de atum, pois temperatura, frentes oceânicas, alimento, profundidade e outros fatores podem ser mais importantes.';

  @override
  String get comparacaoQuadraturaPotencial => 'MODERADO';

  @override
  String get comparacaoRelacaoPescaTitulo => 'RELAÇÃO COM A PESCA DE ATUM';

  @override
  String comparacaoPotencialInfluencia(String potencial) {
    return 'Potencial de influência: $potencial';
  }

  @override
  String get comparacaoRodape =>
      'Representa a força potencial da influência da maré, não uma previsão direta de captura.';

  @override
  String get graficoMareSemDado => 'Dado indisponível para o gráfico de 24h';

  @override
  String get graficoMareCorrenteLabel => 'Corrente';

  @override
  String get graficoMareAgoraLabel => 'Agora';

  @override
  String get janelaOperacionalTitulo => 'Janela operacional';

  @override
  String get janelaOperacionalDescricao =>
      'Próximas horas — maré, corrente e temperatura reais de cada horário.';

  @override
  String get janelaObsSemDado =>
      'Sem dado de maré suficiente para esse horário.';

  @override
  String get janelaObsEstofa =>
      'Período de estofa (maré parada). Corrente de maré tende a ficar fraca nesse horário.';

  @override
  String get janelaObsEnchente =>
      'Período de enchente. Observar regiões de convergência e concentração de presas.';

  @override
  String get janelaObsVazante =>
      'Período de vazante. Observar bordas de banco e canais onde a correnteza pode concentrar alimento.';

  @override
  String get explicacaoSizigiaTexto =>
      'Na Lua Nova e na Lua Cheia, as forças gravitacionais do Sol e da Lua se combinam, aumentando a amplitude das marés.';

  @override
  String get explicacaoQuadraturaTexto =>
      'Nos quartos crescente e minguante, Sol e Lua exercem suas forças gravitacionais em direções aproximadamente perpendiculares, resultando em menor amplitude das marés.';

  @override
  String get explicacaoEntendiBotao => 'Entendi';

  @override
  String get explicacaoSol => 'Sol';

  @override
  String get explicacaoTerra => 'Terra';

  @override
  String get explicacaoLua => 'Lua';

  @override
  String get fluxoInfluenciaTitulo => 'Fluxo de Influência';

  @override
  String get fluxoInfluenciaSubtitulo => 'Por que isso importa para o atum?';

  @override
  String get fluxoEtapa1Titulo => 'Maré';

  @override
  String get fluxoEtapa1Sub => 'Sizígia ou quadratura';

  @override
  String get fluxoEtapa2Titulo => 'Correntes';

  @override
  String get fluxoEtapa2Sub => 'Mais ou menos intensas';

  @override
  String get fluxoEtapa3Titulo => 'Mistura / transporte de água';

  @override
  String get fluxoEtapa3Sub => 'Movimentação da coluna d\'água';

  @override
  String get fluxoEtapa4Titulo => 'Distribuição de nutrientes e presas';

  @override
  String get fluxoEtapa4Sub => 'Onde o alimento se concentra';

  @override
  String get fluxoEtapa5Titulo => 'Concentração de alimento';

  @override
  String get fluxoEtapa5Sub => 'Disponibilidade pro atum';

  @override
  String get fluxoEtapa6Titulo => 'Comportamento dos atuns';

  @override
  String get fluxoEtapa6Sub => 'Deslocamento e agregação';

  @override
  String get fluxoEtapa7Titulo => 'Potencial de atividade de pesca';

  @override
  String get fluxoEtapa7Sub => 'Um indicador entre vários';

  @override
  String get fluxoRodape =>
      'Essa é uma cadeia de influência possível, não uma relação determinística: cada etapa depende de fatores locais (batimetria, topografia, regime de correntes da região) que a maré sozinha não explica.';

  @override
  String mareCardTipoLabel(String tipo) {
    return 'Maré de $tipo';
  }
}
