// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitulo => 'Atlas Blue Ocean';

  @override
  String get cancelar => 'Cancel';

  @override
  String get sair => 'Log out';

  @override
  String get salvar => 'Save';

  @override
  String get sincronizar => 'Sync';

  @override
  String get idiomaSistema => 'System language';

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
  String get loginSubtitulo => 'Master\'s Login';

  @override
  String get loginUsuarioLabel => 'Username';

  @override
  String get loginUsuarioObrigatorio => 'Enter your username';

  @override
  String get loginSenhaLabel => 'Password';

  @override
  String get loginSenhaObrigatoria => 'Enter your password';

  @override
  String get loginLembrarCredenciais => 'Remember my credentials';

  @override
  String get loginLembrarCredenciaisSubtitulo =>
      'Signs you in automatically next time, until you log out.';

  @override
  String get loginBotaoEntrar => 'LOG IN';

  @override
  String get loginErroCredenciaisInvalidas => 'Incorrect username or password.';

  @override
  String get loginErroConexao => 'Connection error. Please try again.';

  @override
  String get loginEscolherOrganizacaoTitulo => 'Choose the organization';

  @override
  String get configuracoesTitulo => 'Settings';

  @override
  String get configIdentificacaoAparelho => 'Device Identification';

  @override
  String get configIdDispositivo => 'Device ID';

  @override
  String get configCopiar => 'Copy';

  @override
  String get configIdCopiado => 'ID copied to clipboard';

  @override
  String get configEmbarcacao => 'Vessel';

  @override
  String get configConfigurarEmbarcacao => 'Configure Vessel';

  @override
  String get configConfigurarEmbarcacaoSubtitulo =>
      'Capacities, crew, master and location-reporting ID.';

  @override
  String get configRastreamentoLocalizacao => 'Location Tracking';

  @override
  String get configIntervaloCapturaEnvio => 'Capture and send interval';

  @override
  String get configIntervaloExplicacao =>
      'At each interval, the app captures the position, saves it locally and sends it to the API. Without internet, it\'s kept and sent as soon as the connection is back.';

  @override
  String configMinutos(int min) {
    return '$min minutes';
  }

  @override
  String configIntervaloSalvo(int min) {
    return 'Tracking interval: $min min';
  }

  @override
  String get configOtimizacaoBateriaTitulo =>
      'Battery optimization may interrupt tracking';

  @override
  String get configOtimizacaoBateriaTexto =>
      'The device may stop recording the position every 15 minutes during a trip, without any warning, if Atlas isn\'t exempt from the system\'s battery optimization.';

  @override
  String get configIsentarApp => 'Exempt the app';

  @override
  String get configAparencia => 'Appearance';

  @override
  String get configTemaEscuro => 'Dark Theme';

  @override
  String get configTemaClaro => 'Light';

  @override
  String get configTemaSistema => 'System';

  @override
  String get configTemaEscuroSegmento => 'Dark';

  @override
  String get configModoNoturno => 'Night Mode';

  @override
  String get configModoNoturnoSubtitulo =>
      'Red-tinted screen to preserve your night vision.';

  @override
  String get configRecomendacoes => 'Recommendations';

  @override
  String get configOcultarRecomendacoesExpiradas =>
      'Hide expired recommendations';

  @override
  String get configOcultarRecomendacoesExpiradasSubtitulo =>
      'Removes expired ones from the \"Nautical Charts\" list — they stay saved, they just don\'t show up.';

  @override
  String get configEmergencia => 'Emergency';

  @override
  String get configContatoEmergencia => 'Emergency contact (WhatsApp)';

  @override
  String get configContatoEmergenciaSubtitulo =>
      'If filled in, the EMERGENCY button on the dashboard opens a conversation with this number directly. If empty, it lets you choose the app on the spot.';

  @override
  String get configNumeroLabel => 'Number with area and country code';

  @override
  String get configNumeroHint => 'e.g.: 5588999998888';

  @override
  String get configContatoSalvo => 'Emergency contact saved';

  @override
  String get configDadosBackup => 'Data and Backup';

  @override
  String get configBackupManual => 'Manual backup';

  @override
  String get configBackupExplicacao =>
      'Planned routes, marked points, chart requests and production only exist on this device — none of it is sent to a server. Generate a backup every so often and keep it somewhere safe (email, cloud, another device).';

  @override
  String get configGerarBackup => 'Generate and share backup';

  @override
  String configBackupCompartilhado(String carimbo) {
    return 'Atlas Blue Ocean backup — $carimbo';
  }

  @override
  String configErroBackup(String erro) {
    return 'Error generating backup: $erro';
  }

  @override
  String get configDetalhesAparelho => 'Device Details';

  @override
  String get configModelo => 'Model';

  @override
  String get configFabricante => 'Manufacturer';

  @override
  String get configSistemaOperacional => 'Operating System';

  @override
  String get configTesteDispositivo => 'Test — Device & Recommendations';

  @override
  String get configIdioma => 'Language';

  @override
  String get configIdiomaSubtitulo => 'Language used throughout the app';

  @override
  String get dashboardAtivarModoNoturno => 'Turn on night mode';

  @override
  String get dashboardDesativarModoNoturno => 'Turn off night mode';

  @override
  String get dashboardBoasVindas => 'Welcome, Master!';

  @override
  String dashboardEmbarcacaoLabel(String nome) {
    return 'Vessel: $nome';
  }

  @override
  String get dashboardEmbarcacaoNaoDefinida => 'Not set';

  @override
  String get dashboardEmergenciaBotao => 'EMERGENCY — Send Position';

  @override
  String get dashboardRastreamentoAtivo => 'Tracking Active';

  @override
  String dashboardRastreamentoSubtitulo(int min) {
    return 'Recording position every $min minutes';
  }

  @override
  String dashboardPosicoesPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions waiting to sync',
      one: '1 position waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPosicoesPendentesSubtitulo =>
      'Will be sent automatically as soon as there\'s a connection.';

  @override
  String get dashboardSincronizarAgora => 'Sync now';

  @override
  String dashboardBateriaBaixa(int percent) {
    return 'Phone battery at $percent%';
  }

  @override
  String get dashboardBateriaBaixaSubtitulo =>
      'Tracking may stop if the battery runs out.';

  @override
  String get dashboardSemPosicaoRecente => 'No recent position recorded';

  @override
  String dashboardSemPosicaoRecenteSubtitulo(String tempo) {
    return 'Last position $tempo ago. Check the GPS signal.';
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
      other: '$d days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dashboardBat => 'DEPTH';

  @override
  String get dashboardMetros => 'meters';

  @override
  String get dashboardSst => 'SST';

  @override
  String get dashboardMapa => 'Map';

  @override
  String get dashboardRodape =>
      'All data is saved locally.\nSyncing with the server happens as soon as there\'s a connection.';

  @override
  String get dashboardErroCarregar => 'Couldn\'t load the dashboard data.';

  @override
  String get dashboardTentarNovamente => 'Try again';

  @override
  String dashboardPosicoesEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions sent',
      one: '1 position sent',
    );
    return '$_temp0';
  }

  @override
  String dashboardAindaPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count still pending',
      one: '1 still pending',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSincronizacaoFalhou =>
      'Couldn\'t sync right now. Check your connection.';

  @override
  String dashboardErroSincronizar(String erro) {
    return 'Error syncing: $erro';
  }

  @override
  String get dashboardSosTitulo => 'Send emergency signal?';

  @override
  String get dashboardSosTexto =>
      'This will open a messaging app with your current position and a request for help, for you to send to whoever can assist you.';

  @override
  String get dashboardSosConfirmar => 'EMERGENCY';

  @override
  String dashboardSosErroPosicao(String erro) {
    return 'Couldn\'t get the position: $erro';
  }

  @override
  String dashboardSosMensagem(
      String embarcacao, String posicao, String horario, String url) {
    return '🆘 EMERGENCY — I need help!\nVessel: $embarcacao\nPosition: $posicao\nTime: $horario\n$url';
  }

  @override
  String get dashboardEmbarcacaoNaoInformada => 'not provided';

  @override
  String get drawerViagemAtual => 'Current Trip';

  @override
  String get drawerProducao => 'Production';

  @override
  String get drawerSolicitarCarta => 'Request Chart';

  @override
  String get drawerCartasNauticas => 'Nautical Charts';

  @override
  String get drawerMinhasRotas => 'My Routes';

  @override
  String get drawerEmbarcacao => 'Vessel';

  @override
  String get drawerCondicoesMar => 'Sea Conditions';

  @override
  String get drawerAlertaRota => 'Route Alert';

  @override
  String get drawerTabuaMare => 'Tide Table';

  @override
  String get drawerMareEPesca => 'Tide & Fishing';

  @override
  String get drawerFaseLua => 'Moon Phase';

  @override
  String get drawerAvisosNavegantes => 'Notices to Mariners';

  @override
  String get drawerConfiguracoes => 'Settings';

  @override
  String get drawerSair => 'Log out';

  @override
  String get dashboardCartaSolicitadaSucesso =>
      'Chart request sent successfully!';

  @override
  String get dashboardNenhumaEmbarcacaoTitulo => 'No vessel linked';

  @override
  String dashboardNenhumaEmbarcacaoTexto(String motivo) {
    return 'The vessel is linked automatically from your active trip on the platform. Sync before $motivo.';
  }

  @override
  String get dashboardNenhumaViagemTitulo => 'No trip in progress';

  @override
  String dashboardNenhumaViagemTexto(String motivo) {
    return 'Trips are now created on the platform. Sync before $motivo, or ask for the trip to be started there.';
  }

  @override
  String get dashboardMotivoRegistrarProducao => 'recording production';

  @override
  String get dashboardViagemSincronizada => 'Active trip synced.';

  @override
  String get dashboardNenhumaViagemEncontrada =>
      'No active trip found on the platform right now.';

  @override
  String get dashboardSairTitulo => 'Log Out';

  @override
  String get dashboardSairTexto => 'Are you sure you want to log out?';

  @override
  String get producaoTitulo => 'Production Log';

  @override
  String get producaoVerHistorico => 'View history and totals';

  @override
  String producaoDataLabel(String data) {
    return 'Date: $data';
  }

  @override
  String get producaoSemViagemAviso =>
      'No trip in progress — this entry won\'t be linked to a trip.';

  @override
  String get producaoClassificacaoLabel => 'Weight class *';

  @override
  String get producaoSelecioneClassificacao => 'Select the weight class';

  @override
  String get producaoQuantidadeLabel => 'Quantity (units) *';

  @override
  String get producaoInformeQuantidade => 'Enter the quantity';

  @override
  String get producaoQuantidadeInvalida =>
      'Enter a whole number greater than zero';

  @override
  String get producaoObservacaoLabel => 'Notes (optional)';

  @override
  String get producaoCapturandoLocalizacao => 'Getting location...';

  @override
  String get producaoSalvando => 'Saving...';

  @override
  String get producaoSalvarBotao => 'SAVE PRODUCTION';

  @override
  String get producaoTipoPeixeLabel => 'Fish type *';

  @override
  String get producaoSelecioneTipoPeixe => 'Select the fish type';

  @override
  String get producaoPesoEstimadoLabel => 'Estimated weight';

  @override
  String get producaoSemEmbarcacaoVinculada =>
      'No vessel linked — set it up in Settings → Vessel before recording production.';

  @override
  String producaoErroGps(String erro) {
    return 'Couldn\'t get the GPS position now ($erro). The entry will be saved without a location.';
  }

  @override
  String get producaoSalvaSucesso => '✅ Production saved successfully!';

  @override
  String producaoErroSalvar(String erro) {
    return 'Error saving: $erro';
  }

  @override
  String producaoKgPorUnidade(String min, String max) {
    return '$min–$max kg/unit';
  }

  @override
  String get producaoEmbarcacaoNaoDefinida => 'Not set';

  @override
  String get fechar => 'Close';

  @override
  String get remover => 'Remove';

  @override
  String get mapaCartaRecomendacaoIndisponivel =>
      'Recommendation chart not available (the link may have expired)';

  @override
  String get mapaErroCarregarCartaRecomendacao =>
      'Couldn\'t load the recommendation\'s chart';

  @override
  String mapaErroSalvarRota(String erro) {
    return 'Error saving route: $erro';
  }

  @override
  String get mapaLabelData => 'Date';

  @override
  String get mapaLabelClassificacaoCurto => 'Weight class';

  @override
  String get mapaLabelPeso => 'Weight';

  @override
  String mapaProducaoTotal(String kg) {
    return '$kg kg total';
  }

  @override
  String get mapaEspecieNaoInformada => 'Not specified';

  @override
  String get mapaClorofilaTitulo => 'Chlorophyll-a';

  @override
  String get mapaClorofilaSemDado =>
      'No valid data for this point (cloud cover, land nearby, or a sensor gap on the latest available day)';

  @override
  String mapaClorofilaData(String data) {
    return 'Date: $data';
  }

  @override
  String mapaClorofilaFonte(String fonte) {
    return 'Source: $fonte';
  }

  @override
  String get mapaClorofilaDisclaimer =>
      'Biological/environmental productivity indicator — it doesn\'t directly represent the amount of fish.';

  @override
  String get mapaAdicionarPontoClorofila => 'Mark another chlorophyll-a point';

  @override
  String get mapaIndiceProdutividadeTitulo => 'Blue Ocean Productivity Index';

  @override
  String get mapaAdicionarPontoIndice =>
      'Mark another productivity index point';

  @override
  String mapaIndiceDadosClorofilaData(String data) {
    return 'Chlorophyll-a data from $data';
  }

  @override
  String get mapaIndiceFontes =>
      'Sources: NOAA CoastWatch (ERDDAP) · Open-Meteo Marine';

  @override
  String get mapaIndiceDisclaimer =>
      'An estimate combining chlorophyll-a and sea surface temperature — it doesn\'t directly represent the amount of fish, just an indirect productivity indicator.';

  @override
  String get mapaTemperaturaTitulo => 'Sea surface temperature';

  @override
  String mapaConsultarPontoInstrucao(String titulo) {
    return 'Look up $titulo — point the center of the map at the desired spot';
  }

  @override
  String get mapaConsultarBotao => 'Look up';

  @override
  String mapaTemperaturaResultado(String valor) {
    return 'Temperature at this point: $valor °C';
  }

  @override
  String get mapaTemperaturaSemDado =>
      'No temperature data for this point right now';

  @override
  String get mapaErroBuscarTemperatura => 'Error fetching temperature';

  @override
  String get mapaErroBuscarClorofila => 'Error fetching chlorophyll-a';

  @override
  String get mapaErroCalcularIndice =>
      'Error calculating the productivity index';

  @override
  String get mapaMenuTitulo => 'MAP MENU';

  @override
  String get mapaCancelarMarcacao => 'Cancel marking';

  @override
  String get mapaMarcarPonto => 'Mark a point';

  @override
  String get mapaCamadasTitulo => 'LAYERS';

  @override
  String get mapaCamadaRuasTitulo => 'Street Map (OpenStreetMap)';

  @override
  String get mapaCamadaRuasSubtitulo => 'Off: shows the loaded nautical chart';

  @override
  String get mapaCamadaNauticaTitulo => 'Nautical information (OpenSeaMap)';

  @override
  String get mapaCamadaNauticaSubtitulo =>
      'Buoys, marks, lighthouses and ports — only over the Street Map';

  @override
  String get mapaCamadaProfundidadeTitulo => 'Depth';

  @override
  String get mapaCamadaProfundidadeSubtitulo =>
      'Bathymetric shading (GEBCO) · OpenSeaMap';

  @override
  String get mapaCamadaCurvasTitulo => 'Depth contours';

  @override
  String get mapaCamadaCurvasSubtitulo => 'Isobaths · OpenSeaMap';

  @override
  String get mapaClorofilaSubtitulo =>
      'Productivity indicator · NOAA CoastWatch';

  @override
  String get mapaCamadaProducaoTitulo => 'Fishing spots (production heatmap)';

  @override
  String get mapaCamadaOverlayTitulo => 'Image overlay';

  @override
  String get mapaCamadaOverlaySubtitulo =>
      'Georeferenced PNG — tap \"Choose image\" to change it';

  @override
  String get mapaEscolherImagem => 'Choose image';

  @override
  String get mapaIndiceProdutividadeSubtitulo =>
      'Combines chlorophyll-a and temperature — an estimate, not a guarantee of fish';

  @override
  String get mapaBaixarRegiao => 'Download region for offline use';

  @override
  String get mapaAtribuicao =>
      '© OpenStreetMap contributors · © OpenSeaMap contributors · Depth: GEBCO / OpenSeaMap depth project';

  @override
  String get mapaOverlayDialogTitulo => 'PNG Overlay';

  @override
  String get mapaOverlayDialogTexto =>
      'Choose, from the device\'s photo gallery, a georeferenced PNG (with the \"geo_bounds\" metadata embedded) to display over the chart.';

  @override
  String get mapaSelecionarImagem => 'Select image';

  @override
  String mapaOverlayFallback(String erro) {
    return '$erro Using the app\'s default area.';
  }

  @override
  String mapaErroSelecionarImagem(String erro) {
    return 'Error selecting image: $erro';
  }

  @override
  String mapaPontoMarcadoConfirmacao(String valor) {
    return 'Point marked: $valor';
  }

  @override
  String get mapaPontoMarcadoTitulo => 'Marked point';

  @override
  String get mapaLabelCoordenadas => 'Coordinates';

  @override
  String get mapaLabelMarcadoEm => 'Marked on';

  @override
  String get mapaLabelDistancia => 'Distance';

  @override
  String get mapaLabelRumo => 'Bearing';

  @override
  String get mapaConsultarAqui => 'Look up here';

  @override
  String get mapaPontoRecomendacaoTitulo => 'Recommendation point';

  @override
  String get mapaLabelRecebidoEm => 'Received on';

  @override
  String get mapaEditarRota => 'Edit Route';

  @override
  String get mapaNovaRotaPlanejada => 'New Planned Route';

  @override
  String get mapaRecomendacaoFallback => 'Recommendation';

  @override
  String get mapaRotaHistorico => 'History route';

  @override
  String get mapaMenuDoMapaTooltip => 'Map menu';

  @override
  String get mapaMeusPontosTooltip => 'My Points';

  @override
  String get mapaCarregandoCarta => 'Loading nautical chart...';

  @override
  String mapaErroCarregarCarta(String erro) {
    return 'Error loading chart: $erro';
  }

  @override
  String get mapaApontarCentro =>
      'Point the center of the map at the desired spot';

  @override
  String get mapaNomeLocalLabel => 'Place name (optional)';

  @override
  String get mapaNomeLocalHint => 'e.g.: Camurupim Pit';

  @override
  String get mapaMarcarPontoBotao => 'Mark point';

  @override
  String get mapaRotaTocarPrimeiroPonto =>
      'Tap the map or a marked point to add the first point';

  @override
  String mapaRotaPontosAdicionados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n points added',
      one: '1 point added',
    );
    return '$_temp0 — tap to continue';
  }

  @override
  String get mapaNomeRotaLabel => 'Route name';

  @override
  String get mapaNomeRotaHint => 'e.g.: Camurupim Fishing Spot';

  @override
  String get mapaDesfazerUltimo => 'Undo last';

  @override
  String get mapaSalvarAlteracoes => 'Save changes';

  @override
  String get mapaSalvarRota => 'Save route';

  @override
  String get shellHome => 'Home';

  @override
  String get shellCartasTab => 'Charts';

  @override
  String cartasSemConexao(String horario) {
    return 'No connection — showing the last list synced at $horario';
  }

  @override
  String get cartasDataDesconhecida => 'unknown date';

  @override
  String get minhasSolicitacoesTooltip => 'My requests';

  @override
  String get minhasSolicitacoesTitulo => 'My Requests';

  @override
  String minhasSolicitacoesErro(String erro) {
    return 'Error loading requests: $erro';
  }

  @override
  String get minhasSolicitacoesVazio => 'No chart requests yet';

  @override
  String minhasSolicitacoesPedidoEm(String data) {
    return 'Requested on $data';
  }

  @override
  String get minhasSolicitacoesPendente => 'Pending';

  @override
  String get solicitarCartaTitulo => 'Request Nautical Chart';

  @override
  String get solicitarCartaCoordenadaGeografica => 'Geographic Coordinate';

  @override
  String get solicitarCartaInstrucao =>
      'Turn the dials like a clock to adjust degrees and minutes';

  @override
  String get solicitarCartaBotao => 'REQUEST NAUTICAL CHART';

  @override
  String get solicitarCartaSucesso =>
      'Request submitted! Check \"My Requests\".';

  @override
  String solicitarCartaErro(String erro) {
    return 'Error requesting chart: $erro';
  }

  @override
  String get embarcacaoTitulo => 'My Vessel';

  @override
  String embarcacaoErroCarregar(String erro) {
    return 'Error loading vessel: $erro';
  }

  @override
  String get embarcacaoSincronizadaSucesso =>
      'Vessel synced with the active trip.';

  @override
  String get embarcacaoSemProprietario => 'No owner on record';

  @override
  String get embarcacaoAtiva => 'Active';

  @override
  String get embarcacaoInativa => 'Inactive';

  @override
  String get embarcacaoCapacidadesTitulo => 'CAPACITIES AND CREW';

  @override
  String get embarcacaoUrnas => 'Holds';

  @override
  String get embarcacaoGelo => 'Ice';

  @override
  String get embarcacaoDiesel => 'Diesel';

  @override
  String get embarcacaoTripulantes => 'Crew';

  @override
  String get embarcacaoDetalhesTitulo => 'DETAILS';

  @override
  String get embarcacaoMotorUsado => 'Engine Used';

  @override
  String get embarcacaoIdMestre => 'Master/Captain ID';

  @override
  String get embarcacaoIdRastreio => 'TRACKING ID';

  @override
  String get embarcacaoVinculacaoAutomatica =>
      'The vessel is linked automatically from your active trip on the platform.';

  @override
  String get embarcacaoRastrear => 'Track';

  @override
  String get embarcacaoConfigTooltipSincronizar => 'Sync with the active trip';

  @override
  String get embarcacaoConfigTesteDisparado =>
      'Test triggered — check the result in the console/log';

  @override
  String get embarcacaoConfigSemEmbarcacaoTexto =>
      'The vessel is linked automatically from your active trip on the platform. Tap sync to fetch it again.';

  @override
  String get embarcacaoConfigVinculadaTexto =>
      'Linked from the active trip on the platform.';

  @override
  String get embarcacaoConfigIdLabel => 'Vessel ID';

  @override
  String get embarcacaoConfigCapacidadeGelo => 'Ice capacity';

  @override
  String get embarcacaoConfigCapacidadeDiesel => 'Diesel capacity';

  @override
  String get embarcacaoConfigMotorUsado => 'Engine used';

  @override
  String get embarcacaoConfigNumeroTripulantes => 'Number of crew';

  @override
  String get embarcacaoConfigTestarEnvio => 'Test location reporting';

  @override
  String viagemErroCarregarHistorico(String erro) {
    return 'Error loading history: $erro';
  }

  @override
  String get viagemResumoDaViagemFallback => 'Trip summary';

  @override
  String viagemCompartilharInicio(String data) {
    return 'Start: $data';
  }

  @override
  String viagemCompartilharDistancia(String mn) {
    return 'Distance: $mn nm';
  }

  @override
  String viagemCompartilharDuracao(String valor) {
    return 'Duration: $valor';
  }

  @override
  String viagemCompartilharVelMedia(String valor) {
    return 'Avg. speed: $valor km/h';
  }

  @override
  String viagemCompartilharVelMaxima(String valor) {
    return 'Max. speed: $valor km/h';
  }

  @override
  String get viagemCompartilharProducaoTitulo => '🐟 Production:';

  @override
  String get viagemFinalizarTitulo => 'End trip';

  @override
  String get viagemFinalizarTexto =>
      'Are you sure you want to end this trip? Background position tracking stops along with it — the app only starts sending the position again when another trip is started.';

  @override
  String get viagemFinalizarBotao => 'End';

  @override
  String viagemErroFinalizar(String erro) {
    return 'Error ending trip: $erro';
  }

  @override
  String get viagemVerRotaTooltip => 'View route on the chart';

  @override
  String get viagemCompartilharTooltip => 'Share trip summary';

  @override
  String get viagemAtualizarTooltip => 'Refresh';

  @override
  String get viagemNenhumRegistro => 'No records found';

  @override
  String get viagemCriadasNaPlataforma =>
      'Trips are now created on the platform. Tap sync to fetch the active trip.';

  @override
  String get viagemEmAndamentoFallback => 'Trip in progress';

  @override
  String viagemIniciadaEm(String data) {
    return 'Started on $data';
  }

  @override
  String get viagemDuracaoLabel => 'Duration';

  @override
  String get viagemVelMediaLabel => 'Avg. speed';

  @override
  String get viagemVelMaximaLabel => 'Max. speed';

  @override
  String viagemPrecLabel(String m) {
    return 'Acc: ${m}m';
  }

  @override
  String get apagar => 'Delete';

  @override
  String rotasErroCarregar(String erro) {
    return 'Error loading routes: $erro';
  }

  @override
  String get rotasApagarTitulo => 'Delete route?';

  @override
  String rotasApagarTexto(String nome) {
    return '\"$nome\" will be permanently removed.';
  }

  @override
  String get rotasNovaRota => 'New route';

  @override
  String get rotasNenhumaAinda => 'No routes planned yet';

  @override
  String get rotasTocarNovaRota =>
      'Tap \"New route\" to mark points on the map';

  @override
  String rotasPontosEData(int n, String data) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n points',
      one: '1 point',
    );
    return '$_temp0 · $data';
  }

  @override
  String get rotasAnalisarTooltip => 'Analyze route conditions';

  @override
  String get rotasEditarTooltip => 'Edit route';

  @override
  String get rotasApagarTooltip => 'Delete route';

  @override
  String rotasAnaliseTitulo(String nome) {
    return 'Analysis: $nome';
  }

  @override
  String get rotasBuscandoCondicoes => 'Fetching conditions along the route...';

  @override
  String rotasPontosComCondicaoSevera(int severos, int total) {
    return '$severos of $total points with a severe condition';
  }

  @override
  String get rotasNenhumPontoSevero => 'No points with a severe condition';

  @override
  String rotasPontosDistanciaTotal(int n, String distancia) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n points',
      one: '1 point',
    );
    return '$_temp0 · $distancia nm total';
  }

  @override
  String rotasTrechoDesdePonto(String trecho, int indice) {
    return '+$trecho nm from point $indice';
  }

  @override
  String get metricaVento => 'Wind';

  @override
  String get metricaOnda => 'Wave';

  @override
  String get metricaCorrente => 'Current';

  @override
  String get metricaAgua => 'Water';

  @override
  String get metricaMare => 'Tide';

  @override
  String get condicoesMarTitulo => 'Sea Conditions';

  @override
  String get condicoesMarAguardandoPosicao =>
      'Waiting for the vessel\'s current position...';

  @override
  String get erroBuscarPrevisaoPrefixo => 'Error fetching forecast';

  @override
  String get condicoesPontoTituloFallback => 'Point Conditions';

  @override
  String get posicaoAtualTitulo => '📍 Current Position';

  @override
  String get posicaoAtualizarTooltip => 'Refresh position';

  @override
  String get posicaoTocarIcone => 'Tap the icon to refresh';

  @override
  String get posicaoTocarBotao => 'Tap the button to refresh';

  @override
  String get posicaoErroLocalizacaoDesativada =>
      '❌ Location is turned off on this device';

  @override
  String get posicaoErroPermissaoNegadaPermanente =>
      '❌ Permission permanently denied.\nGo to Settings > Apps';

  @override
  String get posicaoErroPermissaoNegada => '❌ Location permission denied';

  @override
  String get posicaoErroTimeout =>
      '❌ Timed out getting the position.\nTry again in an open area.';

  @override
  String posicaoErroGenerico(String erro) {
    return '❌ Error: $erro';
  }

  @override
  String get profundidadeCarregando => 'Loading depth...';

  @override
  String get pontoEmTerra => 'Point on land';

  @override
  String get sstCarregando => 'Loading water temperature...';

  @override
  String get sstSuperficieDoMar => 'Sea surface';

  @override
  String mareNivelAgora(String nivel) {
    return '$nivel m now';
  }

  @override
  String get marePreamar => 'High tide';

  @override
  String get mareBaixaMar => 'Low tide';

  @override
  String get luaLabel => 'Moon';

  @override
  String luaIluminadaCiclo(int pct, int dia) {
    return '$pct% illuminated · day $dia of the cycle';
  }

  @override
  String get luaNascer => 'Rise';

  @override
  String get luaPor => 'Set';

  @override
  String get luaProximasFases => 'UPCOMING PHASES';

  @override
  String get luaHoje => 'today';

  @override
  String luaEmDias(int d) {
    return 'in ${d}d';
  }

  @override
  String get solunarTitulo => 'Solunar Table';

  @override
  String get solunarSubtitulo =>
      'Periods of highest feeding activity, based on the moon\'s position';

  @override
  String get ventoCarregando => 'Loading weather forecast...';

  @override
  String get ventoClimaAtual => 'Current Weather';

  @override
  String get ventoVelocidadeTitulo => 'WIND SPEED';

  @override
  String ventoDirecao(int graus) {
    return 'Direction: $graus°';
  }

  @override
  String get labelTemperatura => 'Temperature';

  @override
  String get labelPressao => 'Pressure';

  @override
  String get ventoPrevisaoHoraria => 'Hourly forecast';

  @override
  String get ventoIntensidadeCalmo => 'Calm';

  @override
  String get ventoIntensidadeLeve => 'Light';

  @override
  String get ventoIntensidadeModerado => 'Moderate';

  @override
  String get ventoIntensidadeForte => 'Strong';

  @override
  String get ventoIntensidadeMuitoForte => 'Very strong';

  @override
  String get ondaCondicoesAtuais => 'Current Conditions';

  @override
  String get ondaAlturaTitulo => 'WAVE HEIGHT';

  @override
  String ondaPeriodo(String n) {
    return 'Period $n s';
  }

  @override
  String get ondaCorrenteTitulo => 'CURRENT';

  @override
  String get ondaSemDados => 'No data';

  @override
  String get ondaSwellPrefixo => 'Swell';

  @override
  String ondaDirecaoOnda(int graus) {
    return 'Wave dir. $graus°';
  }

  @override
  String get ondaAlturaCalmo => 'Calm';

  @override
  String get ondaAlturaLeve => 'Light';

  @override
  String get ondaAlturaModerado => 'Moderate';

  @override
  String get ondaAlturaAgitado => 'Rough';

  @override
  String get ondaAlturaMuitoAgitado => 'Very rough';

  @override
  String get ondaAlturaTempestuoso => 'Stormy';

  @override
  String get meteoSheetPosicaoFallback => 'Position';

  @override
  String get meteoSheetSemDados => 'No weather data';

  @override
  String get meteoSheetVentoTitulo => 'Wind';

  @override
  String get meteoSheetMovimentoTitulo => 'Movement';

  @override
  String get meteoSheetAtmosferaTitulo => 'Atmosphere';

  @override
  String get meteoSheetOndasTitulo => 'Waves';

  @override
  String get meteoSheetVelocidadeRealTws => 'True wind speed (TWS)';

  @override
  String get meteoSheetDirecaoRealTwd => 'True wind direction (TWD)';

  @override
  String get meteoSheetAnguloRealTwa => 'True wind angle (TWA)';

  @override
  String get meteoSheetVelocidadeAparenteAws => 'Apparent wind speed (AWS)';

  @override
  String get meteoSheetAnguloAparenteAwa => 'Apparent wind angle (AWA)';

  @override
  String get meteoSheetRajadas => 'Gusts';

  @override
  String get meteoSheetVelocidadeRealSog => 'Speed over ground (SOG)';

  @override
  String get meteoSheetDirecaoRealCog => 'Course over ground (COG)';

  @override
  String get meteoSheetVelocidadeAparenteStw => 'Speed through water (STW)';

  @override
  String get meteoSheetAnguloAparenteCtw => 'Course through water (CTW)';

  @override
  String get meteoSheetNuvens => 'Clouds';

  @override
  String get meteoSheetChuva => 'Rain';

  @override
  String get meteoSheetAlturaCombinada => 'Combined height';

  @override
  String get meteoSheetVentoAltura => 'Wind — height';

  @override
  String get meteoSheetVentoDirecao => 'Wind — direction';

  @override
  String get meteoSheetVentoPeriodo => 'Wind — period';

  @override
  String get meteoSheetSwellAltura => 'Swell — height';

  @override
  String get meteoSheetSwellDirecao => 'Swell — direction';

  @override
  String get meteoSheetSwellPeriodo => 'Swell — period';

  @override
  String get alertaConfigTitulo => 'Configure Alerts';

  @override
  String get alertaConfigDescricao =>
      'Choose the point at which each condition along the vessel\'s path triggers a notification (with vibration). Applies both to manual checks in \"Route Alert\" and to background tracking during a trip.';

  @override
  String get alertaConfigVentoTitulo => 'Wind';

  @override
  String get alertaConfigVentoSubtitulo => 'Alert when the wind ahead exceeds';

  @override
  String get alertaConfigOndaTitulo => 'Wave and swell height';

  @override
  String get alertaConfigOndaSubtitulo => 'Alert when wave or swell exceed';

  @override
  String get alertaConfigCorrenteTitulo => 'Tidal current';

  @override
  String get alertaConfigCorrenteSubtitulo => 'Alert when the current exceeds';

  @override
  String get alertaConfigTemperaturaTitulo => 'Water temperature';

  @override
  String get alertaConfigTemperaturaSubtitulo =>
      'Alert when the temperature exceeds';

  @override
  String get alertaRotaTitulo => 'Route Alert';

  @override
  String get alertaRotaTooltipConfigurar => 'Configure alerts';

  @override
  String get alertaRotaTooltipSimular => 'Simulate with a marked point';

  @override
  String alertaRotaErroPosicaoPrefixo(String erro) {
    return 'Error getting position: $erro';
  }

  @override
  String get alertaRotaNenhumPontoMarcado => 'No marked points yet';

  @override
  String get alertaRotaSimularDialogTitulo => 'Simulate from which point?';

  @override
  String get alertaRotaRumoSimuladoTitulo => 'Simulated heading';

  @override
  String get alertaRotaBotaoSimular => 'Simulate';

  @override
  String get alertaRotaVentoTitulo => 'Wind ahead';

  @override
  String get alertaRotaCorrenteTitulo => 'Current ahead';

  @override
  String get alertaRotaOndaTitulo => 'Wave ahead';

  @override
  String get alertaRotaSwellTitulo => 'Swell ahead';

  @override
  String get alertaRotaBussolaTitulo => 'Compass';

  @override
  String get alertaRotaSemSinal => 'No signal';

  @override
  String get alertaRotaAlcanceTitulo => 'Alert range';

  @override
  String get alertaRotaAlcanceDescricao =>
      'Distance ahead of the vessel, on the current heading, where conditions are checked.';

  @override
  String alertaRotaRumoEAlcance(String rumo, String alcance) {
    return 'Heading $rumo° · $alcance nm ahead';
  }

  @override
  String get alertaRotaSemRumoDescricao =>
      'Heading unavailable — the vessel must be moving for the GPS to compute a valid heading.';

  @override
  String alertaRotaSimulacaoAtiva(String nome, String rumo) {
    return 'Simulation active — using \"$nome\" with heading $rumo° (not the real GPS)';
  }

  @override
  String get alertaRotaCorrenteFraca => 'Weak';

  @override
  String get alertaRotaCorrenteModerada => 'Moderate';

  @override
  String get alertaRotaCorrenteForte => 'Strong';

  @override
  String get alertaRotaCorrenteMuitoForte => 'Very strong';

  @override
  String get alertaRotaCorrenteExtrema => 'Extreme';

  @override
  String get diaSemanaSegunda => 'Monday';

  @override
  String get diaSemanaTerca => 'Tuesday';

  @override
  String get diaSemanaQuarta => 'Wednesday';

  @override
  String get diaSemanaQuinta => 'Thursday';

  @override
  String get diaSemanaSexta => 'Friday';

  @override
  String get diaSemanaSabado => 'Saturday';

  @override
  String get diaSemanaDomingo => 'Sunday';

  @override
  String get faseLuaScreenTitulo => 'Moon Phase';

  @override
  String get faseLuaErroBuscarPrefixo => 'Error fetching moonrise/moonset';

  @override
  String get faseLuaAguardandoPosicao =>
      'Waiting for the vessel\'s current position for moonrise/moonset times — the phase above doesn\'t depend on it.';

  @override
  String get faseLuaNascerEPorTitulo => 'MOONRISE AND MOONSET';

  @override
  String faseLuaHojeData(String data) {
    return 'Today, $data';
  }

  @override
  String get erroSincronizarPrefixo => 'Error syncing';

  @override
  String get tabuaMareTooltipRemoverPorto => 'Remove port';

  @override
  String get tabuaMareRemoverPortoTitulo => 'Remove port?';

  @override
  String tabuaMareRemoverPortoConteudo(String nome) {
    return '\"$nome\" will be removed from the list.';
  }

  @override
  String get tabuaMareSincronizando => 'Syncing...';

  @override
  String get tabuaMareSincronizarDeNovo => 'Sync again';

  @override
  String tabuaMareSincronizadoEm(String data) {
    return 'Synced on $data · available offline';
  }

  @override
  String get tabuaMareAindaNaoSincronizado =>
      'Not synced yet — needs internet the first time';

  @override
  String get tabuaMareSincronizePrimeiraVez =>
      'Sync at least once, with internet, to calculate this port\'s offline tide table.';

  @override
  String get tabuaMareNivelAgoraTitulo => 'Level now';

  @override
  String get tabuaMareTitulo => 'Tide Table';

  @override
  String get tabuaMareBotaoPorto => 'Port';

  @override
  String tabuaMareErroCarregarPrefixo(String erro) {
    return 'Error loading ports: $erro';
  }

  @override
  String tabuaMareErroSincronizarNome(String nome) {
    return 'Error syncing \"$nome\"';
  }

  @override
  String get tabuaMareNovoPortoTitulo => 'New port';

  @override
  String get tabuaMareNomeLabel => 'Name';

  @override
  String get tabuaMareNomeHint => 'e.g. Port of Itarema';

  @override
  String get tabuaMarePreencherNome => 'Enter the port\'s name';

  @override
  String get tabuaMareNenhumPortoTitulo => 'No ports saved yet';

  @override
  String get tabuaMareNenhumPortoDescricao =>
      'Save a port\'s coordinates (e.g. Itarema, Acaraú, Camocim) to check the forecast tide, even offline once synced.';

  @override
  String get tabuaMarePoucosDados =>
      'Too little tide data was returned for this point';

  @override
  String get mareEPescaTitulo => 'Tide and Fishing';

  @override
  String get mareEPescaErroBuscarPrefixo => 'Error fetching tide forecast';

  @override
  String get mareEPescaAguardandoPosicao =>
      'Waiting for the vessel\'s current position...';

  @override
  String get mareEPescaCabecalhoTitulo => 'Tide Influence on Tuna Fishing';

  @override
  String get mareEPescaCabecalhoDescricao =>
      'Understand how tidal amplitude can affect currents, water mixing and tuna feeding conditions.';

  @override
  String mareEPescaCondicaoAtual(String tipo) {
    return 'Current tide condition: $tipo';
  }

  @override
  String get mareEPescaGrafico24hTitulo => 'Tide over the next 24h';

  @override
  String get mareEPescaEntendaSizigia => 'Understand spring tides';

  @override
  String get mareEPescaEntendaQuadratura => 'Understand neap tides';

  @override
  String get mareEPescaImportante => 'Important';

  @override
  String get mareEPescaAvisoPrincipal =>
      'The tide phase should not be used in isolation to determine a fishing area. The environment\'s response varies with location, depth, topography, current patterns, temperature, food availability, wind and other oceanographic factors.';

  @override
  String get mareEPescaAvisoSecundario =>
      'Use the tide as one of the indicators within an integrated analysis.';

  @override
  String get producaoHistoricoTitulo => 'Production History';

  @override
  String get producaoHistoricoTooltipPorPonto => 'Production by point';

  @override
  String get producaoHistoricoTooltipVerMapa => 'View on map';

  @override
  String get producaoHistoricoTooltipExportarCsv => 'Export as CSV';

  @override
  String producaoHistoricoErroCarregarPrefixo(String erro) {
    return 'Error loading production: $erro';
  }

  @override
  String producaoHistoricoErroExportarPrefixo(String erro) {
    return 'Error exporting: $erro';
  }

  @override
  String get producaoHistoricoCsvCabecalho =>
      'Date/Time,Species,Classification,Quantity (units),Quantity (kg),Latitude,Longitude,Note';

  @override
  String producaoHistoricoCompartilharTexto(String kg) {
    return 'Production history — $kg kg';
  }

  @override
  String get producaoHistoricoNenhumRegistro => 'No production records yet';

  @override
  String producaoHistoricoTotalResumo(String kg, int n) {
    return 'Total: $kg kg in $n record(s)';
  }

  @override
  String producaoHistoricoClassificacaoEUnidades(
      String classificacao, int unidades) {
    return 'Classification $classificacao kg · $unidades un.';
  }

  @override
  String get producaoPorPontoTitulo => 'Production by Point';

  @override
  String producaoPorPontoErroCarregarPrefixo(String erro) {
    return 'Error loading: $erro';
  }

  @override
  String get producaoPorPontoVazioTitulo =>
      'No production linked to a marked point yet';

  @override
  String get producaoPorPontoVazioDescricao =>
      'Record catches with coordinates and mark points on the map to see the most productive points here';

  @override
  String producaoPorPontoTotalRegistros(int n) {
    return '$n record(s)';
  }

  @override
  String producaoPorPontoEspecieDestaque(String especie) {
    return ' · $especie in the lead';
  }

  @override
  String get meusPontosTitulo => 'My Points';

  @override
  String get meusPontosNenhumTituloERecomendacao =>
      'No marked points or recommendations yet';

  @override
  String get meusPontosSecaoPontosMarcados => 'MARKED POINTS';

  @override
  String get meusPontosSecaoRecomendacoes => 'RECOMMENDATIONS';

  @override
  String get meusPontosDataDesconhecida => 'unknown date';

  @override
  String meusPontosBannerOffline(String horario) {
    return 'No connection — showing the last recommendations synced at $horario';
  }

  @override
  String get meusPontosMarcadoEm => 'Marked on';

  @override
  String get meusPontosProducaoAqui => 'Production here';

  @override
  String meusPontosProducaoAquiValor(String kg, int n) {
    return '$kg kg ($n record(s))';
  }

  @override
  String get meusPontosConsultarAqui => 'Check conditions here';

  @override
  String get meusPontosMareEPescaAqui => 'Tide and Fishing here';

  @override
  String get mapaScreenTituloFallback => 'Map';

  @override
  String get mapaRotaProducao => 'Production Route';

  @override
  String get mapaSstLabel => 'SST';
}
