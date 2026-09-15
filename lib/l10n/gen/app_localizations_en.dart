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
}
