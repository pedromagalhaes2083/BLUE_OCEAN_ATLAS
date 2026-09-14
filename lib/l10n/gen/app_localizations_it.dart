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
}
