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
}
