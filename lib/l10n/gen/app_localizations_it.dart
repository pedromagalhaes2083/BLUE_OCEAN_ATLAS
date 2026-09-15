// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitulo => 'Atlas Blue Ocean';

  @override
  String get cancelar => 'Annulla';

  @override
  String get sair => 'Esci';

  @override
  String get salvar => 'Salva';

  @override
  String get sincronizar => 'Sincronizza';

  @override
  String get idiomaSistema => 'Lingua di sistema';

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
  String get loginSubtitulo => 'Accesso del comandante';

  @override
  String get loginUsuarioLabel => 'Utente';

  @override
  String get loginUsuarioObrigatorio => 'Inserisci l\'utente';

  @override
  String get loginSenhaLabel => 'Password';

  @override
  String get loginSenhaObrigatoria => 'Inserisci la password';

  @override
  String get loginLembrarCredenciais => 'Ricorda le mie credenziali';

  @override
  String get loginLembrarCredenciaisSubtitulo =>
      'Accede automaticamente la prossima volta, finché non esci dall\'account.';

  @override
  String get loginBotaoEntrar => 'ACCEDI';

  @override
  String get loginErroCredenciaisInvalidas => 'Utente o password errati.';

  @override
  String get loginErroConexao => 'Errore di connessione. Riprova.';

  @override
  String get loginEscolherOrganizacaoTitulo => 'Scegli l\'organizzazione';

  @override
  String get configuracoesTitulo => 'Impostazioni';

  @override
  String get configIdentificacaoAparelho => 'Identificazione del Dispositivo';

  @override
  String get configIdDispositivo => 'ID del Dispositivo';

  @override
  String get configCopiar => 'Copia';

  @override
  String get configIdCopiado => 'ID copiato negli appunti';

  @override
  String get configEmbarcacao => 'Imbarcazione';

  @override
  String get configConfigurarEmbarcacao => 'Configura Imbarcazione';

  @override
  String get configConfigurarEmbarcacaoSubtitulo =>
      'Capacità, equipaggio, comandante e ID di invio posizione.';

  @override
  String get configRastreamentoLocalizacao => 'Tracciamento della Posizione';

  @override
  String get configIntervaloCapturaEnvio => 'Intervallo di rilevamento e invio';

  @override
  String get configIntervaloExplicacao =>
      'A ogni intervallo, l\'app rileva la posizione, la salva localmente e la invia all\'API. Senza internet, resta salvata e viene inviata non appena torna la connessione.';

  @override
  String configMinutos(int min) {
    return '$min minuti';
  }

  @override
  String configIntervaloSalvo(int min) {
    return 'Intervallo di tracciamento: $min min';
  }

  @override
  String get configOtimizacaoBateriaTitulo =>
      'L\'ottimizzazione della batteria può interrompere il tracciamento';

  @override
  String get configOtimizacaoBateriaTexto =>
      'Il dispositivo può smettere di registrare la posizione ogni 15 minuti durante un viaggio, senza alcun avviso, se Atlas non è esente dall\'ottimizzazione della batteria del sistema.';

  @override
  String get configIsentarApp => 'Esenta l\'app';

  @override
  String get configAparencia => 'Aspetto';

  @override
  String get configTemaEscuro => 'Tema Scuro';

  @override
  String get configTemaClaro => 'Chiaro';

  @override
  String get configTemaSistema => 'Sistema';

  @override
  String get configTemaEscuroSegmento => 'Scuro';

  @override
  String get configModoNoturno => 'Modalità Notturna';

  @override
  String get configModoNoturnoSubtitulo =>
      'Schermo rosso per preservare la visione notturna.';

  @override
  String get configRecomendacoes => 'Raccomandazioni';

  @override
  String get configOcultarRecomendacoesExpiradas =>
      'Nascondi raccomandazioni scadute';

  @override
  String get configOcultarRecomendacoesExpiradasSubtitulo =>
      'Rimuove dalla lista di \"Carte Nautiche\" quelle già scadute — restano salvate, semplicemente non compaiono.';

  @override
  String get configEmergencia => 'Emergenza';

  @override
  String get configContatoEmergencia => 'Contatto di emergenza (WhatsApp)';

  @override
  String get configContatoEmergenciaSubtitulo =>
      'Se compilato, il pulsante EMERGENZA nel pannello apre direttamente una conversazione con questo numero. Se vuoto, ti lascia scegliere l\'app al momento.';

  @override
  String get configNumeroLabel => 'Numero con prefisso e paese';

  @override
  String get configNumeroHint => 'Es: 5588999998888';

  @override
  String get configContatoSalvo => 'Contatto di emergenza salvato';

  @override
  String get configDadosBackup => 'Dati e Backup';

  @override
  String get configBackupManual => 'Backup manuale';

  @override
  String get configBackupExplicacao =>
      'Rotte pianificate, punti segnati, richieste di carte e produzione esistono solo su questo dispositivo — nulla di tutto ciò viene inviato a un server. Genera un backup di tanto in tanto e conservalo in un posto sicuro (email, cloud, altro dispositivo).';

  @override
  String get configGerarBackup => 'Genera e condividi backup';

  @override
  String configBackupCompartilhado(String carimbo) {
    return 'Backup di Atlas Blue Ocean — $carimbo';
  }

  @override
  String configErroBackup(String erro) {
    return 'Errore nella generazione del backup: $erro';
  }

  @override
  String get configDetalhesAparelho => 'Dettagli del Dispositivo';

  @override
  String get configModelo => 'Modello';

  @override
  String get configFabricante => 'Produttore';

  @override
  String get configSistemaOperacional => 'Sistema Operativo';

  @override
  String get configTesteDispositivo => 'Test — Dispositivo e Raccomandazioni';

  @override
  String get configIdioma => 'Lingua';

  @override
  String get configIdiomaSubtitulo => 'Lingua usata in tutta l\'app';

  @override
  String get dashboardAtivarModoNoturno => 'Attiva modalità notturna';

  @override
  String get dashboardDesativarModoNoturno => 'Disattiva modalità notturna';

  @override
  String get dashboardBoasVindas => 'Benvenuto, Comandante!';

  @override
  String dashboardEmbarcacaoLabel(String nome) {
    return 'Imbarcazione: $nome';
  }

  @override
  String get dashboardEmbarcacaoNaoDefinida => 'Non impostata';

  @override
  String get dashboardEmergenciaBotao => 'EMERGENZA — Invia Posizione';

  @override
  String get dashboardRastreamentoAtivo => 'Tracciamento Attivo';

  @override
  String dashboardRastreamentoSubtitulo(int min) {
    return 'Registrazione posizione ogni $min minuti';
  }

  @override
  String dashboardPosicoesPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posizioni in attesa di sincronizzazione',
      one: '1 posizione in attesa di sincronizzazione',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPosicoesPendentesSubtitulo =>
      'Verranno inviate automaticamente non appena ci sarà connessione.';

  @override
  String get dashboardSincronizarAgora => 'Sincronizza ora';

  @override
  String dashboardBateriaBaixa(int percent) {
    return 'Batteria del telefono al $percent%';
  }

  @override
  String get dashboardBateriaBaixaSubtitulo =>
      'Il tracciamento potrebbe interrompersi se la batteria si esaurisce.';

  @override
  String get dashboardSemPosicaoRecente =>
      'Nessuna posizione recente registrata';

  @override
  String dashboardSemPosicaoRecenteSubtitulo(String tempo) {
    return 'Ultima posizione $tempo fa. Controlla il segnale GPS.';
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
      other: '$d giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get dashboardBat => 'PROF';

  @override
  String get dashboardMetros => 'metri';

  @override
  String get dashboardSst => 'SST';

  @override
  String get dashboardMapa => 'Mappa';

  @override
  String get dashboardRodape =>
      'Tutti i dati sono salvati localmente.\nLa sincronizzazione con il server avverrà non appena ci sarà connessione.';

  @override
  String get dashboardErroCarregar =>
      'Impossibile caricare i dati del pannello.';

  @override
  String get dashboardTentarNovamente => 'Riprova';

  @override
  String dashboardPosicoesEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posizioni inviate',
      one: '1 posizione inviata',
    );
    return '$_temp0';
  }

  @override
  String dashboardAindaPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ancora in sospeso',
      one: '1 ancora in sospeso',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSincronizacaoFalhou =>
      'Impossibile sincronizzare ora. Controlla la connessione.';

  @override
  String dashboardErroSincronizar(String erro) {
    return 'Errore durante la sincronizzazione: $erro';
  }

  @override
  String get dashboardSosTitulo => 'Inviare il segnale di emergenza?';

  @override
  String get dashboardSosTexto =>
      'Verrà aperta un\'app di messaggistica con la tua posizione attuale e una richiesta di aiuto, da inviare a chi può soccorrerti.';

  @override
  String get dashboardSosConfirmar => 'EMERGENZA';

  @override
  String dashboardSosErroPosicao(String erro) {
    return 'Impossibile ottenere la posizione: $erro';
  }

  @override
  String dashboardSosMensagem(
      String embarcacao, String posicao, String horario, String url) {
    return '🆘 EMERGENZA — ho bisogno di aiuto!\nImbarcazione: $embarcacao\nPosizione: $posicao\nOrario: $horario\n$url';
  }

  @override
  String get dashboardEmbarcacaoNaoInformada => 'non indicata';

  @override
  String get drawerViagemAtual => 'Viaggio Attuale';

  @override
  String get drawerProducao => 'Produzione';

  @override
  String get drawerSolicitarCarta => 'Richiedi Carta';

  @override
  String get drawerCartasNauticas => 'Carte Nautiche';

  @override
  String get drawerMinhasRotas => 'Le Mie Rotte';

  @override
  String get drawerEmbarcacao => 'Imbarcazione';

  @override
  String get drawerCondicoesMar => 'Condizioni del Mare';

  @override
  String get drawerAlertaRota => 'Allerta di Rotta';

  @override
  String get drawerTabuaMare => 'Tabella delle Maree';

  @override
  String get drawerMareEPesca => 'Marea e Pesca';

  @override
  String get drawerFaseLua => 'Fase Lunare';

  @override
  String get drawerAvisosNavegantes => 'Avvisi ai Naviganti';

  @override
  String get drawerConfiguracoes => 'Impostazioni';

  @override
  String get drawerSair => 'Esci';

  @override
  String get dashboardCartaSolicitadaSucesso => 'Carta richiesta con successo!';

  @override
  String get dashboardNenhumaEmbarcacaoTitulo =>
      'Nessuna imbarcazione collegata';

  @override
  String dashboardNenhumaEmbarcacaoTexto(String motivo) {
    return 'L\'imbarcazione viene collegata automaticamente dal tuo viaggio attivo sulla piattaforma. Sincronizza prima di $motivo.';
  }

  @override
  String get dashboardNenhumaViagemTitulo => 'Nessun viaggio in corso';

  @override
  String dashboardNenhumaViagemTexto(String motivo) {
    return 'I viaggi ora vengono creati sulla piattaforma. Sincronizza prima di $motivo, oppure chiedi che il viaggio venga avviato lì.';
  }

  @override
  String get dashboardMotivoRegistrarProducao => 'registrare la produzione';

  @override
  String get dashboardViagemSincronizada => 'Viaggio attivo sincronizzato.';

  @override
  String get dashboardNenhumaViagemEncontrada =>
      'Nessun viaggio attivo trovato sulla piattaforma al momento.';

  @override
  String get dashboardSairTitulo => 'Esci dal Sistema';

  @override
  String get dashboardSairTexto => 'Vuoi davvero uscire?';

  @override
  String get producaoTitulo => 'Registro di Produzione';

  @override
  String get producaoVerHistorico => 'Vedi cronologia e totali';

  @override
  String producaoDataLabel(String data) {
    return 'Data: $data';
  }

  @override
  String get producaoSemViagemAviso =>
      'Nessun viaggio in corso — il record non sarà associato a un viaggio.';

  @override
  String get producaoClassificacaoLabel => 'Classificazione *';

  @override
  String get producaoSelecioneClassificacao => 'Seleziona la classificazione';

  @override
  String get producaoQuantidadeLabel => 'Quantità (unità) *';

  @override
  String get producaoInformeQuantidade => 'Inserisci la quantità';

  @override
  String get producaoQuantidadeInvalida =>
      'Inserisci un numero intero maggiore di zero';

  @override
  String get producaoObservacaoLabel => 'Osservazione (facoltativa)';

  @override
  String get producaoCapturandoLocalizacao => 'Rilevamento posizione...';

  @override
  String get producaoSalvando => 'Salvataggio...';

  @override
  String get producaoSalvarBotao => 'SALVA PRODUZIONE';

  @override
  String get producaoTipoPeixeLabel => 'Tipo di pesce *';

  @override
  String get producaoSelecioneTipoPeixe => 'Seleziona il tipo di pesce';

  @override
  String get producaoPesoEstimadoLabel => 'Peso stimato';

  @override
  String get producaoSemEmbarcacaoVinculada =>
      'Nessuna imbarcazione collegata — configurala in Impostazioni → Imbarcazione prima di registrare la produzione.';

  @override
  String producaoErroGps(String erro) {
    return 'Impossibile ottenere il GPS ora ($erro). Il record verrà salvato senza coordinate.';
  }

  @override
  String get producaoSalvaSucesso => '✅ Produzione salvata con successo!';

  @override
  String producaoErroSalvar(String erro) {
    return 'Errore nel salvataggio: $erro';
  }

  @override
  String producaoKgPorUnidade(String min, String max) {
    return '$min–$max kg/unità';
  }

  @override
  String get producaoEmbarcacaoNaoDefinida => 'Non impostata';

  @override
  String get fechar => 'Chiudi';

  @override
  String get remover => 'Rimuovi';

  @override
  String get mapaCartaRecomendacaoIndisponivel =>
      'Carta della raccomandazione non disponibile (il link potrebbe essere scaduto)';

  @override
  String get mapaErroCarregarCartaRecomendacao =>
      'Impossibile caricare la carta della raccomandazione';

  @override
  String mapaErroSalvarRota(String erro) {
    return 'Errore nel salvare la rotta: $erro';
  }

  @override
  String get mapaLabelData => 'Data';

  @override
  String get mapaLabelClassificacaoCurto => 'Classificazione';

  @override
  String get mapaLabelPeso => 'Peso';

  @override
  String mapaProducaoTotal(String kg) {
    return '$kg kg in totale';
  }

  @override
  String get mapaEspecieNaoInformada => 'Non specificato';

  @override
  String get mapaClorofilaTitulo => 'Clorofilla-a';

  @override
  String get mapaClorofilaSemDado =>
      'Nessun dato valido per questo punto (nuvole, terra vicina o guasto del sensore nel giorno più recente disponibile)';

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
      'Indicatore di produttività biologica/ambientale — non rappresenta direttamente la quantità di pesce.';

  @override
  String get mapaAdicionarPontoClorofila =>
      'Segna un altro punto di clorofilla-a';

  @override
  String get mapaIndiceProdutividadeTitulo =>
      'Indice di Produttività Blue Ocean';

  @override
  String get mapaAdicionarPontoIndice =>
      'Segna un altro punto di indice di produttività';

  @override
  String mapaIndiceDadosClorofilaData(String data) {
    return 'Dati di clorofilla-a del $data';
  }

  @override
  String get mapaIndiceFontes =>
      'Fonti: NOAA CoastWatch (ERDDAP) · Open-Meteo Marine';

  @override
  String get mapaIndiceDisclaimer =>
      'Stima che combina clorofilla-a e temperatura della superficie del mare — non rappresenta direttamente la quantità di pesce, solo un indicatore indiretto di produttività.';

  @override
  String get mapaTemperaturaTitulo => 'Temperatura della superficie del mare';

  @override
  String mapaConsultarPontoInstrucao(String titulo) {
    return 'Consulta $titulo — punta il centro della mappa verso il luogo desiderato';
  }

  @override
  String get mapaConsultarBotao => 'Consulta';

  @override
  String mapaTemperaturaResultado(String valor) {
    return 'Temperatura nel punto: $valor °C';
  }

  @override
  String get mapaTemperaturaSemDado =>
      'Nessun dato di temperatura per questo punto ora';

  @override
  String get mapaErroBuscarTemperatura =>
      'Errore nel recuperare la temperatura';

  @override
  String get mapaErroBuscarClorofila => 'Errore nel recuperare la clorofilla-a';

  @override
  String get mapaErroCalcularIndice =>
      'Errore nel calcolare l\'indice di produttività';

  @override
  String get mapaMenuTitulo => 'MENU DELLA MAPPA';

  @override
  String get mapaCancelarMarcacao => 'Annulla la marcatura';

  @override
  String get mapaMarcarPonto => 'Segna un punto';

  @override
  String get mapaCamadasTitulo => 'STRATI';

  @override
  String get mapaCamadaRuasTitulo => 'Mappa Stradale (OpenStreetMap)';

  @override
  String get mapaCamadaRuasSubtitulo =>
      'Spento: mostra la carta nautica caricata';

  @override
  String get mapaCamadaNauticaTitulo => 'Informazioni nautiche (OpenSeaMap)';

  @override
  String get mapaCamadaNauticaSubtitulo =>
      'Boe, segnali, fari e porti — solo sulla Mappa Stradale';

  @override
  String get mapaCamadaProfundidadeTitulo => 'Profondità';

  @override
  String get mapaCamadaProfundidadeSubtitulo =>
      'Ombreggiatura batimetrica (GEBCO) · OpenSeaMap';

  @override
  String get mapaCamadaCurvasTitulo => 'Curve di profondità';

  @override
  String get mapaCamadaCurvasSubtitulo => 'Isobate · OpenSeaMap';

  @override
  String get mapaClorofilaSubtitulo =>
      'Indicatore di produttività · NOAA CoastWatch';

  @override
  String get mapaCamadaProducaoTitulo =>
      'Punti di pesca (mappa di calore della produzione)';

  @override
  String get mapaCamadaOverlayTitulo => 'Sovrapposizione immagine';

  @override
  String get mapaCamadaOverlaySubtitulo =>
      'PNG georeferenziato — tocca \"Scegli immagine\" per cambiarlo';

  @override
  String get mapaEscolherImagem => 'Scegli immagine';

  @override
  String get mapaIndiceProdutividadeSubtitulo =>
      'Combina clorofilla-a e temperatura — una stima, non una garanzia di pesce';

  @override
  String get mapaBaixarRegiao => 'Scarica la regione per l\'uso offline';

  @override
  String get mapaAtribuicao =>
      '© OpenStreetMap contributors · © OpenSeaMap contributors · Profondità: GEBCO / OpenSeaMap depth project';

  @override
  String get mapaOverlayDialogTitulo => 'Sovrapposizione PNG';

  @override
  String get mapaOverlayDialogTexto =>
      'Scegli, dalla galleria fotografica del dispositivo, un PNG georeferenziato (con il metadato \"geo_bounds\" incorporato) da mostrare sopra la carta.';

  @override
  String get mapaSelecionarImagem => 'Seleziona immagine';

  @override
  String mapaOverlayFallback(String erro) {
    return '$erro Uso dell\'area predefinita dell\'app.';
  }

  @override
  String mapaErroSelecionarImagem(String erro) {
    return 'Errore nella selezione dell\'immagine: $erro';
  }

  @override
  String mapaPontoMarcadoConfirmacao(String valor) {
    return 'Punto segnato: $valor';
  }

  @override
  String get mapaPontoMarcadoTitulo => 'Punto segnato';

  @override
  String get mapaLabelCoordenadas => 'Coordinate';

  @override
  String get mapaLabelMarcadoEm => 'Segnato il';

  @override
  String get mapaLabelDistancia => 'Distanza';

  @override
  String get mapaLabelRumo => 'Rotta';

  @override
  String get mapaConsultarAqui => 'Consulta qui';

  @override
  String get mapaPontoRecomendacaoTitulo => 'Punto della raccomandazione';

  @override
  String get mapaLabelRecebidoEm => 'Ricevuto il';

  @override
  String get mapaEditarRota => 'Modifica Rotta';

  @override
  String get mapaNovaRotaPlanejada => 'Nuova Rotta Pianificata';

  @override
  String get mapaRecomendacaoFallback => 'Raccomandazione';

  @override
  String get mapaRotaHistorico => 'Rotta della cronologia';

  @override
  String get mapaMenuDoMapaTooltip => 'Menu della mappa';

  @override
  String get mapaMeusPontosTooltip => 'I Miei Punti';

  @override
  String get mapaCarregandoCarta => 'Caricamento carta nautica...';

  @override
  String mapaErroCarregarCarta(String erro) {
    return 'Errore nel caricare la carta: $erro';
  }

  @override
  String get mapaApontarCentro =>
      'Punta il centro della mappa verso il luogo desiderato';

  @override
  String get mapaNomeLocalLabel => 'Nome del luogo (facoltativo)';

  @override
  String get mapaNomeLocalHint => 'Es: Pozzo di Camurupim';

  @override
  String get mapaMarcarPontoBotao => 'Segna punto';

  @override
  String get mapaRotaTocarPrimeiroPonto =>
      'Tocca la mappa o un punto segnato per aggiungere il primo punto';

  @override
  String mapaRotaPontosAdicionados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n punti aggiunti',
      one: '1 punto aggiunto',
    );
    return '$_temp0 — tocca per continuare';
  }

  @override
  String get mapaNomeRotaLabel => 'Nome della rotta';

  @override
  String get mapaNomeRotaHint => 'Es: Zona di pesca di Camurupim';

  @override
  String get mapaDesfazerUltimo => 'Annulla l\'ultimo';

  @override
  String get mapaSalvarAlteracoes => 'Salva modifiche';

  @override
  String get mapaSalvarRota => 'Salva rotta';

  @override
  String get shellHome => 'Home';

  @override
  String get shellCartasTab => 'Carte';

  @override
  String cartasSemConexao(String horario) {
    return 'Nessuna connessione — mostra l\'ultimo elenco sincronizzato alle $horario';
  }

  @override
  String get cartasDataDesconhecida => 'data sconosciuta';

  @override
  String get minhasSolicitacoesTooltip => 'Le mie richieste';

  @override
  String get minhasSolicitacoesTitulo => 'Le Mie Richieste';

  @override
  String minhasSolicitacoesErro(String erro) {
    return 'Errore nel caricare le richieste: $erro';
  }

  @override
  String get minhasSolicitacoesVazio => 'Ancora nessuna richiesta di carta';

  @override
  String minhasSolicitacoesPedidoEm(String data) {
    return 'Richiesta il $data';
  }

  @override
  String get minhasSolicitacoesPendente => 'In attesa';

  @override
  String get solicitarCartaTitulo => 'Richiedi Carta Nautica';

  @override
  String get solicitarCartaCoordenadaGeografica => 'Coordinata Geografica';

  @override
  String get solicitarCartaInstrucao =>
      'Ruota i selettori come un orologio per regolare gradi e minuti';

  @override
  String get solicitarCartaBotao => 'RICHIEDI CARTA NAUTICA';

  @override
  String get solicitarCartaSucesso =>
      'Richiesta registrata! Guardala in \"Le Mie Richieste\".';

  @override
  String solicitarCartaErro(String erro) {
    return 'Errore nella richiesta della carta: $erro';
  }

  @override
  String get embarcacaoTitulo => 'La Mia Imbarcazione';

  @override
  String embarcacaoErroCarregar(String erro) {
    return 'Errore nel caricare l\'imbarcazione: $erro';
  }

  @override
  String get embarcacaoSincronizadaSucesso =>
      'Imbarcazione sincronizzata con il viaggio attivo.';

  @override
  String get embarcacaoSemProprietario => 'Nessun proprietario registrato';

  @override
  String get embarcacaoAtiva => 'Attiva';

  @override
  String get embarcacaoInativa => 'Inattiva';

  @override
  String get embarcacaoCapacidadesTitulo => 'CAPACITÀ ED EQUIPAGGIO';

  @override
  String get embarcacaoUrnas => 'Stive';

  @override
  String get embarcacaoGelo => 'Ghiaccio';

  @override
  String get embarcacaoDiesel => 'Gasolio';

  @override
  String get embarcacaoTripulantes => 'Equipaggio';

  @override
  String get embarcacaoDetalhesTitulo => 'DETTAGLI';

  @override
  String get embarcacaoMotorUsado => 'Motore Usato';

  @override
  String get embarcacaoIdMestre => 'ID Comandante/Capitano';

  @override
  String get embarcacaoIdRastreio => 'ID DI TRACCIAMENTO';

  @override
  String get embarcacaoVinculacaoAutomatica =>
      'L\'imbarcazione viene collegata automaticamente dal tuo viaggio attivo sulla piattaforma.';

  @override
  String get embarcacaoRastrear => 'Traccia';

  @override
  String get embarcacaoConfigTooltipSincronizar =>
      'Sincronizza con il viaggio attivo';

  @override
  String get embarcacaoConfigTesteDisparado =>
      'Test avviato — controlla il risultato nella console/log';

  @override
  String get embarcacaoConfigSemEmbarcacaoTexto =>
      'L\'imbarcazione viene collegata automaticamente dal tuo viaggio attivo sulla piattaforma. Tocca sincronizza per recuperarla di nuovo.';

  @override
  String get embarcacaoConfigVinculadaTexto =>
      'Collegata dal viaggio attivo sulla piattaforma.';

  @override
  String get embarcacaoConfigIdLabel => 'ID Imbarcazione';

  @override
  String get embarcacaoConfigCapacidadeGelo => 'Capacità di ghiaccio';

  @override
  String get embarcacaoConfigCapacidadeDiesel => 'Capacità di gasolio';

  @override
  String get embarcacaoConfigMotorUsado => 'Motore usato';

  @override
  String get embarcacaoConfigNumeroTripulantes =>
      'Numero di membri dell\'equipaggio';

  @override
  String get embarcacaoConfigTestarEnvio => 'Testa l\'invio della posizione';

  @override
  String viagemErroCarregarHistorico(String erro) {
    return 'Errore nel caricare la cronologia: $erro';
  }

  @override
  String get viagemResumoDaViagemFallback => 'Riepilogo del viaggio';

  @override
  String viagemCompartilharInicio(String data) {
    return 'Inizio: $data';
  }

  @override
  String viagemCompartilharDistancia(String mn) {
    return 'Distanza: $mn mn';
  }

  @override
  String viagemCompartilharDuracao(String valor) {
    return 'Durata: $valor';
  }

  @override
  String viagemCompartilharVelMedia(String valor) {
    return 'Vel. media: $valor km/h';
  }

  @override
  String viagemCompartilharVelMaxima(String valor) {
    return 'Vel. massima: $valor km/h';
  }

  @override
  String get viagemCompartilharProducaoTitulo => '🐟 Produzione:';

  @override
  String get viagemFinalizarTitulo => 'Termina viaggio';

  @override
  String get viagemFinalizarTexto =>
      'Sei sicuro di voler terminare questo viaggio? Il tracciamento della posizione in background si ferma insieme ad esso — l\'app tornerà a inviare la posizione solo quando verrà avviato un altro viaggio.';

  @override
  String get viagemFinalizarBotao => 'Termina';

  @override
  String viagemErroFinalizar(String erro) {
    return 'Errore nel terminare il viaggio: $erro';
  }

  @override
  String get viagemVerRotaTooltip => 'Vedi rotta sulla carta';

  @override
  String get viagemCompartilharTooltip => 'Condividi riepilogo del viaggio';

  @override
  String get viagemAtualizarTooltip => 'Aggiorna';

  @override
  String get viagemNenhumRegistro => 'Nessun record trovato';

  @override
  String get viagemCriadasNaPlataforma =>
      'I viaggi ora vengono creati sulla piattaforma. Tocca sincronizza per recuperare il viaggio attivo.';

  @override
  String get viagemEmAndamentoFallback => 'Viaggio in corso';

  @override
  String viagemIniciadaEm(String data) {
    return 'Iniziato il $data';
  }

  @override
  String get viagemDuracaoLabel => 'Durata';

  @override
  String get viagemVelMediaLabel => 'Vel. media';

  @override
  String get viagemVelMaximaLabel => 'Vel. massima';

  @override
  String viagemPrecLabel(String m) {
    return 'Prec: ${m}m';
  }

  @override
  String get apagar => 'Elimina';

  @override
  String rotasErroCarregar(String erro) {
    return 'Errore nel caricare le rotte: $erro';
  }

  @override
  String get rotasApagarTitulo => 'Eliminare la rotta?';

  @override
  String rotasApagarTexto(String nome) {
    return '\"$nome\" verrà rimossa permanentemente.';
  }

  @override
  String get rotasNovaRota => 'Nuova rotta';

  @override
  String get rotasNenhumaAinda => 'Ancora nessuna rotta pianificata';

  @override
  String get rotasTocarNovaRota =>
      'Tocca \"Nuova rotta\" per segnare i punti sulla mappa';

  @override
  String rotasPontosEData(int n, String data) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n punti',
      one: '1 punto',
    );
    return '$_temp0 · $data';
  }

  @override
  String get rotasAnalisarTooltip => 'Analizza le condizioni della rotta';

  @override
  String get rotasEditarTooltip => 'Modifica rotta';

  @override
  String get rotasApagarTooltip => 'Elimina rotta';

  @override
  String rotasAnaliseTitulo(String nome) {
    return 'Analisi: $nome';
  }

  @override
  String get rotasBuscandoCondicoes => 'Recupero condizioni lungo la rotta...';

  @override
  String rotasPontosComCondicaoSevera(int severos, int total) {
    return '$severos di $total punti con condizione severa';
  }

  @override
  String get rotasNenhumPontoSevero => 'Nessun punto con condizione severa';

  @override
  String rotasPontosDistanciaTotal(int n, String distancia) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n punti',
      one: '1 punto',
    );
    return '$_temp0 · $distancia mn totali';
  }

  @override
  String rotasTrechoDesdePonto(String trecho, int indice) {
    return '+$trecho mn dal punto $indice';
  }

  @override
  String get metricaVento => 'Vento';

  @override
  String get metricaOnda => 'Onda';

  @override
  String get metricaCorrente => 'Corrente';

  @override
  String get metricaAgua => 'Acqua';

  @override
  String get metricaMare => 'Marea';

  @override
  String get condicoesMarTitulo => 'Condizioni del Mare';

  @override
  String get condicoesMarAguardandoPosicao =>
      'In attesa della posizione attuale dell\'imbarcazione...';

  @override
  String get erroBuscarPrevisaoPrefixo => 'Errore nel recuperare le previsioni';

  @override
  String get condicoesPontoTituloFallback => 'Condizioni del Punto';

  @override
  String get posicaoAtualTitulo => '📍 Posizione Attuale';

  @override
  String get posicaoAtualizarTooltip => 'Aggiorna posizione';

  @override
  String get posicaoTocarIcone => 'Tocca l\'icona per aggiornare';

  @override
  String get posicaoTocarBotao => 'Tocca il pulsante per aggiornare';

  @override
  String get posicaoErroLocalizacaoDesativada =>
      '❌ La localizzazione è disattivata sul dispositivo';

  @override
  String get posicaoErroPermissaoNegadaPermanente =>
      '❌ Permesso negato permanentemente.\nVai su Impostazioni > App';

  @override
  String get posicaoErroPermissaoNegada =>
      '❌ Permesso di localizzazione negato';

  @override
  String get posicaoErroTimeout =>
      '❌ Tempo scaduto nell\'ottenere la posizione.\nRiprova in un\'area aperta.';

  @override
  String posicaoErroGenerico(String erro) {
    return '❌ Errore: $erro';
  }

  @override
  String get profundidadeCarregando => 'Caricamento profondità...';

  @override
  String get pontoEmTerra => 'Punto sulla terraferma';

  @override
  String get sstCarregando => 'Caricamento temperatura dell\'acqua...';

  @override
  String get sstSuperficieDoMar => 'Superficie del mare';

  @override
  String mareNivelAgora(String nivel) {
    return '$nivel m ora';
  }

  @override
  String get marePreamar => 'Alta marea';

  @override
  String get mareBaixaMar => 'Bassa marea';

  @override
  String get luaLabel => 'Luna';

  @override
  String luaIluminadaCiclo(int pct, int dia) {
    return '$pct% illuminata · giorno $dia del ciclo';
  }

  @override
  String get luaNascer => 'Sorge';

  @override
  String get luaPor => 'Tramonta';

  @override
  String get luaProximasFases => 'PROSSIME FASI';

  @override
  String get luaHoje => 'oggi';

  @override
  String luaEmDias(int d) {
    return 'tra ${d}g';
  }

  @override
  String get solunarTitulo => 'Tabella Solunare';

  @override
  String get solunarSubtitulo =>
      'Periodi di maggiore attività alimentare, in base alla posizione della luna';

  @override
  String get ventoCarregando => 'Caricamento previsioni meteo...';

  @override
  String get ventoClimaAtual => 'Meteo Attuale';

  @override
  String get ventoVelocidadeTitulo => 'VELOCITÀ DEL VENTO';

  @override
  String ventoDirecao(int graus) {
    return 'Direzione: $graus°';
  }

  @override
  String get labelTemperatura => 'Temperatura';

  @override
  String get labelPressao => 'Pressione';

  @override
  String get ventoPrevisaoHoraria => 'Previsioni orarie';

  @override
  String get ventoIntensidadeCalmo => 'Calmo';

  @override
  String get ventoIntensidadeLeve => 'Leggero';

  @override
  String get ventoIntensidadeModerado => 'Moderato';

  @override
  String get ventoIntensidadeForte => 'Forte';

  @override
  String get ventoIntensidadeMuitoForte => 'Molto forte';

  @override
  String get ondaCondicoesAtuais => 'Condizioni Attuali';

  @override
  String get ondaAlturaTitulo => 'ALTEZZA DELL\'ONDA';

  @override
  String ondaPeriodo(String n) {
    return 'Periodo $n s';
  }

  @override
  String get ondaCorrenteTitulo => 'CORRENTE';

  @override
  String get ondaSemDados => 'Nessun dato';

  @override
  String get ondaSwellPrefixo => 'Mareggiata';

  @override
  String ondaDirecaoOnda(int graus) {
    return 'Dir. onda $graus°';
  }

  @override
  String get ondaAlturaCalmo => 'Calmo';

  @override
  String get ondaAlturaLeve => 'Leggero';

  @override
  String get ondaAlturaModerado => 'Moderato';

  @override
  String get ondaAlturaAgitado => 'Mosso';

  @override
  String get ondaAlturaMuitoAgitado => 'Molto mosso';

  @override
  String get ondaAlturaTempestuoso => 'Tempestoso';

  @override
  String get meteoSheetPosicaoFallback => 'Posizione';

  @override
  String get meteoSheetSemDados => 'Nessun dato meteorologico';

  @override
  String get meteoSheetVentoTitulo => 'Vento';

  @override
  String get meteoSheetMovimentoTitulo => 'Movimento';

  @override
  String get meteoSheetAtmosferaTitulo => 'Atmosfera';

  @override
  String get meteoSheetOndasTitulo => 'Onde';

  @override
  String get meteoSheetVelocidadeRealTws => 'Velocità reale del vento (TWS)';

  @override
  String get meteoSheetDirecaoRealTwd => 'Direzione reale del vento (TWD)';

  @override
  String get meteoSheetAnguloRealTwa => 'Angolo reale del vento (TWA)';

  @override
  String get meteoSheetVelocidadeAparenteAws =>
      'Velocità apparente del vento (AWS)';

  @override
  String get meteoSheetAnguloAparenteAwa => 'Angolo apparente del vento (AWA)';

  @override
  String get meteoSheetRajadas => 'Raffiche';

  @override
  String get meteoSheetVelocidadeRealSog => 'Velocità sul fondo (SOG)';

  @override
  String get meteoSheetDirecaoRealCog => 'Rotta sul fondo (COG)';

  @override
  String get meteoSheetVelocidadeAparenteStw =>
      'Velocità attraverso l\'acqua (STW)';

  @override
  String get meteoSheetAnguloAparenteCtw => 'Rotta attraverso l\'acqua (CTW)';

  @override
  String get meteoSheetNuvens => 'Nuvole';

  @override
  String get meteoSheetChuva => 'Pioggia';

  @override
  String get meteoSheetAlturaCombinada => 'Altezza combinata';

  @override
  String get meteoSheetVentoAltura => 'Vento — altezza';

  @override
  String get meteoSheetVentoDirecao => 'Vento — direzione';

  @override
  String get meteoSheetVentoPeriodo => 'Vento — periodo';

  @override
  String get meteoSheetSwellAltura => 'Swell — altezza';

  @override
  String get meteoSheetSwellDirecao => 'Swell — direzione';

  @override
  String get meteoSheetSwellPeriodo => 'Swell — periodo';

  @override
  String get alertaConfigTitulo => 'Configura Avvisi';

  @override
  String get alertaConfigDescricao =>
      'Scegli da che punto ogni condizione lungo il percorso dell\'imbarcazione attiva una notifica (con vibrazione). Vale sia per il controllo manuale in \"Avviso di Rotta\" che per il monitoraggio in background durante un viaggio.';

  @override
  String get alertaConfigVentoTitulo => 'Vento';

  @override
  String get alertaConfigVentoSubtitulo =>
      'Avviso quando il vento in rotta supera';

  @override
  String get alertaConfigOndaTitulo => 'Altezza onda e swell';

  @override
  String get alertaConfigOndaSubtitulo => 'Avviso quando onda o swell superano';

  @override
  String get alertaConfigCorrenteTitulo => 'Corrente di marea';

  @override
  String get alertaConfigCorrenteSubtitulo =>
      'Avviso quando la corrente supera';

  @override
  String get alertaConfigTemperaturaTitulo => 'Temperatura dell\'acqua';

  @override
  String get alertaConfigTemperaturaSubtitulo =>
      'Avviso quando la temperatura supera';

  @override
  String get alertaRotaTitulo => 'Avviso di Rotta';

  @override
  String get alertaRotaTooltipConfigurar => 'Configura avvisi';

  @override
  String get alertaRotaTooltipSimular => 'Simula con punto salvato';

  @override
  String alertaRotaErroPosicaoPrefixo(String erro) {
    return 'Errore nel recupero della posizione: $erro';
  }

  @override
  String get alertaRotaNenhumPontoMarcado => 'Nessun punto salvato ancora';

  @override
  String get alertaRotaSimularDialogTitulo => 'Simulare da quale punto?';

  @override
  String get alertaRotaRumoSimuladoTitulo => 'Rotta simulata';

  @override
  String get alertaRotaBotaoSimular => 'Simula';

  @override
  String get alertaRotaVentoTitulo => 'Vento in rotta';

  @override
  String get alertaRotaCorrenteTitulo => 'Corrente in rotta';

  @override
  String get alertaRotaOndaTitulo => 'Onda in rotta';

  @override
  String get alertaRotaSwellTitulo => 'Swell in rotta';

  @override
  String get alertaRotaBussolaTitulo => 'Bussola';

  @override
  String get alertaRotaSemSinal => 'Nessun segnale';

  @override
  String get alertaRotaAlcanceTitulo => 'Raggio dell\'avviso';

  @override
  String get alertaRotaAlcanceDescricao =>
      'Distanza davanti all\'imbarcazione, sulla rotta attuale, dove vengono controllate le condizioni.';

  @override
  String alertaRotaRumoEAlcance(String rumo, String alcance) {
    return 'Rotta $rumo° · $alcance mn avanti';
  }

  @override
  String get alertaRotaSemRumoDescricao =>
      'Rotta non disponibile — l\'imbarcazione deve essere in movimento perché il GPS calcoli una rotta valida.';

  @override
  String alertaRotaSimulacaoAtiva(String nome, String rumo) {
    return 'Simulazione attiva — usando \"$nome\" con rotta $rumo° (non è il GPS reale)';
  }

  @override
  String get alertaRotaCorrenteFraca => 'Debole';

  @override
  String get alertaRotaCorrenteModerada => 'Moderata';

  @override
  String get alertaRotaCorrenteForte => 'Forte';

  @override
  String get alertaRotaCorrenteMuitoForte => 'Molto forte';

  @override
  String get alertaRotaCorrenteExtrema => 'Estrema';

  @override
  String get diaSemanaSegunda => 'Lunedì';

  @override
  String get diaSemanaTerca => 'Martedì';

  @override
  String get diaSemanaQuarta => 'Mercoledì';

  @override
  String get diaSemanaQuinta => 'Giovedì';

  @override
  String get diaSemanaSexta => 'Venerdì';

  @override
  String get diaSemanaSabado => 'Sabato';

  @override
  String get diaSemanaDomingo => 'Domenica';

  @override
  String get faseLuaScreenTitulo => 'Fase Lunare';

  @override
  String get faseLuaErroBuscarPrefixo =>
      'Errore nel recupero di alba/tramonto lunare';

  @override
  String get faseLuaAguardandoPosicao =>
      'In attesa della posizione attuale dell\'imbarcazione per gli orari di alba/tramonto lunare — la fase sopra non dipende da questo.';

  @override
  String get faseLuaNascerEPorTitulo => 'ALBA E TRAMONTO LUNARE';

  @override
  String faseLuaHojeData(String data) {
    return 'Oggi, $data';
  }

  @override
  String get erroSincronizarPrefixo => 'Errore durante la sincronizzazione';

  @override
  String get tabuaMareTooltipRemoverPorto => 'Rimuovi porto';

  @override
  String get tabuaMareRemoverPortoTitulo => 'Rimuovere il porto?';

  @override
  String tabuaMareRemoverPortoConteudo(String nome) {
    return '\"$nome\" verrà rimosso dalla lista.';
  }

  @override
  String get tabuaMareSincronizando => 'Sincronizzazione...';

  @override
  String get tabuaMareSincronizarDeNovo => 'Sincronizza di nuovo';

  @override
  String tabuaMareSincronizadoEm(String data) {
    return 'Sincronizzato il $data · disponibile offline';
  }

  @override
  String get tabuaMareAindaNaoSincronizado =>
      'Non ancora sincronizzato — serve internet la prima volta';

  @override
  String get tabuaMareSincronizePrimeiraVez =>
      'Sincronizza almeno una volta, con internet, per calcolare la tabella di marea offline di questo porto.';

  @override
  String get tabuaMareNivelAgoraTitulo => 'Livello adesso';

  @override
  String get tabuaMareTitulo => 'Tabella di Marea';

  @override
  String get tabuaMareBotaoPorto => 'Porto';

  @override
  String tabuaMareErroCarregarPrefixo(String erro) {
    return 'Errore nel caricamento dei porti: $erro';
  }

  @override
  String tabuaMareErroSincronizarNome(String nome) {
    return 'Errore nella sincronizzazione di \"$nome\"';
  }

  @override
  String get tabuaMareNovoPortoTitulo => 'Nuovo porto';

  @override
  String get tabuaMareNomeLabel => 'Nome';

  @override
  String get tabuaMareNomeHint => 'Es: Porto di Itarema';

  @override
  String get tabuaMarePreencherNome => 'Inserisci il nome del porto';

  @override
  String get tabuaMareNenhumPortoTitulo => 'Nessun porto salvato ancora';

  @override
  String get tabuaMareNenhumPortoDescricao =>
      'Salva le coordinate di un porto (es: Itarema, Acaraú, Camocim) per consultare la marea prevista, anche offline dopo la sincronizzazione.';

  @override
  String get tabuaMarePoucosDados =>
      'Sono stati restituiti troppo pochi dati di marea per questo punto';

  @override
  String get mareEPescaTitulo => 'Marea e Pesca';

  @override
  String get mareEPescaErroBuscarPrefixo =>
      'Errore nel recupero della previsione di marea';

  @override
  String get mareEPescaAguardandoPosicao =>
      'In attesa della posizione attuale dell\'imbarcazione...';

  @override
  String get mareEPescaCabecalhoTitulo =>
      'Influenza della Marea sulla Pesca del Tonno';

  @override
  String get mareEPescaCabecalhoDescricao =>
      'Scopri come l\'ampiezza delle maree può alterare le correnti, il mescolamento dell\'acqua e le condizioni di alimentazione dei tonni.';

  @override
  String mareEPescaCondicaoAtual(String tipo) {
    return 'Condizione attuale della marea: $tipo';
  }

  @override
  String get mareEPescaGrafico24hTitulo => 'Marea nelle prossime 24h';

  @override
  String get mareEPescaEntendaSizigia => 'Scopri le maree sizigiali';

  @override
  String get mareEPescaEntendaQuadratura => 'Scopri le maree di quadratura';

  @override
  String get mareEPescaImportante => 'Importante';

  @override
  String get mareEPescaAvisoPrincipal =>
      'La fase di marea non deve essere utilizzata da sola per determinare un\'area di pesca. La risposta dell\'ambiente varia in base a posizione, profondità, topografia, regime delle correnti, temperatura, disponibilità di cibo, vento e altri fattori oceanografici.';

  @override
  String get mareEPescaAvisoSecundario =>
      'Usa la marea come uno degli indicatori all\'interno di un\'analisi integrata.';

  @override
  String get producaoHistoricoTitulo => 'Storico Produzione';

  @override
  String get producaoHistoricoTooltipPorPonto => 'Produzione per punto';

  @override
  String get producaoHistoricoTooltipVerMapa => 'Visualizza sulla mappa';

  @override
  String get producaoHistoricoTooltipExportarCsv => 'Esporta come CSV';

  @override
  String producaoHistoricoErroCarregarPrefixo(String erro) {
    return 'Errore nel caricamento della produzione: $erro';
  }

  @override
  String producaoHistoricoErroExportarPrefixo(String erro) {
    return 'Errore nell\'esportazione: $erro';
  }

  @override
  String get producaoHistoricoCsvCabecalho =>
      'Data/Ora,Specie,Classificazione,Quantità (un.),Quantità (kg),Latitudine,Longitudine,Nota';

  @override
  String producaoHistoricoCompartilharTexto(String kg) {
    return 'Storico produzione — $kg kg';
  }

  @override
  String get producaoHistoricoNenhumRegistro =>
      'Nessun registro di produzione ancora';

  @override
  String producaoHistoricoTotalResumo(String kg, int n) {
    return 'Totale: $kg kg in $n registrazione(i)';
  }

  @override
  String producaoHistoricoClassificacaoEUnidades(
      String classificacao, int unidades) {
    return 'Classificazione $classificacao kg · $unidades un.';
  }

  @override
  String get producaoPorPontoTitulo => 'Produzione per Punto';

  @override
  String producaoPorPontoErroCarregarPrefixo(String erro) {
    return 'Errore nel caricamento: $erro';
  }

  @override
  String get producaoPorPontoVazioTitulo =>
      'Nessuna produzione associata a un punto salvato ancora';

  @override
  String get producaoPorPontoVazioDescricao =>
      'Registra le catture con coordinate e salva punti sulla mappa per vedere qui i punti più produttivi';

  @override
  String producaoPorPontoTotalRegistros(int n) {
    return '$n registrazione(i)';
  }

  @override
  String producaoPorPontoEspecieDestaque(String especie) {
    return ' · $especie in evidenza';
  }
}
