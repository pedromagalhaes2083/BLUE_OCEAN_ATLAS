// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitulo => 'Atlas Blue Ocean';

  @override
  String get cancelar => 'Annuler';

  @override
  String get sair => 'Se déconnecter';

  @override
  String get salvar => 'Enregistrer';

  @override
  String get sincronizar => 'Synchroniser';

  @override
  String get idiomaSistema => 'Langue du système';

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
  String get loginSubtitulo => 'Connexion du patron';

  @override
  String get loginUsuarioLabel => 'Utilisateur';

  @override
  String get loginUsuarioObrigatorio => 'Indiquez l\'utilisateur';

  @override
  String get loginSenhaLabel => 'Mot de passe';

  @override
  String get loginSenhaObrigatoria => 'Indiquez le mot de passe';

  @override
  String get loginLembrarCredenciais => 'Se souvenir de mes identifiants';

  @override
  String get loginLembrarCredenciaisSubtitulo =>
      'Connexion automatique la prochaine fois, jusqu\'à ce que vous vous déconnectiez.';

  @override
  String get loginBotaoEntrar => 'SE CONNECTER';

  @override
  String get loginErroCredenciaisInvalidas =>
      'Utilisateur ou mot de passe incorrect.';

  @override
  String get loginErroConexao => 'Erreur de connexion. Réessayez.';

  @override
  String get loginEscolherOrganizacaoTitulo => 'Choisissez l\'organisation';

  @override
  String get configuracoesTitulo => 'Paramètres';

  @override
  String get configIdentificacaoAparelho => 'Identification de l\'Appareil';

  @override
  String get configIdDispositivo => 'ID de l\'Appareil';

  @override
  String get configCopiar => 'Copier';

  @override
  String get configIdCopiado => 'ID copié dans le presse-papiers';

  @override
  String get configEmbarcacao => 'Embarcation';

  @override
  String get configConfigurarEmbarcacao => 'Configurer l\'Embarcation';

  @override
  String get configConfigurarEmbarcacaoSubtitulo =>
      'Capacités, équipage, patron et ID d\'envoi de position.';

  @override
  String get configRastreamentoLocalizacao => 'Suivi de Localisation';

  @override
  String get configIntervaloCapturaEnvio => 'Intervalle de capture et d\'envoi';

  @override
  String get configIntervaloExplicacao =>
      'À chaque intervalle, l\'app capture la position, l\'enregistre localement et l\'envoie à l\'API. Sans internet, elle est conservée et envoyée dès le retour de la connexion.';

  @override
  String configMinutos(int min) {
    return '$min minutes';
  }

  @override
  String configIntervaloSalvo(int min) {
    return 'Intervalle de suivi : $min min';
  }

  @override
  String get configOtimizacaoBateriaTitulo =>
      'L\'optimisation de la batterie peut interrompre le suivi';

  @override
  String get configOtimizacaoBateriaTexto =>
      'L\'appareil peut cesser d\'enregistrer la position toutes les 15 minutes pendant un voyage, sans aucun avertissement, si Atlas n\'est pas exempté de l\'optimisation de la batterie du système.';

  @override
  String get configIsentarApp => 'Exempter l\'app';

  @override
  String get configAparencia => 'Apparence';

  @override
  String get configTemaEscuro => 'Thème Sombre';

  @override
  String get configTemaClaro => 'Clair';

  @override
  String get configTemaSistema => 'Système';

  @override
  String get configTemaEscuroSegmento => 'Sombre';

  @override
  String get configModoNoturno => 'Mode Nuit';

  @override
  String get configModoNoturnoSubtitulo =>
      'Écran teinté de rouge pour préserver la vision nocturne.';

  @override
  String get configRecomendacoes => 'Recommandations';

  @override
  String get configOcultarRecomendacoesExpiradas =>
      'Masquer les recommandations expirées';

  @override
  String get configOcultarRecomendacoesExpiradasSubtitulo =>
      'Retire de la liste « Cartes Nautiques » celles déjà expirées — elles restent enregistrées, elles n\'apparaissent simplement plus.';

  @override
  String get configEmergencia => 'Urgence';

  @override
  String get configContatoEmergencia => 'Contact d\'urgence (WhatsApp)';

  @override
  String get configContatoEmergenciaSubtitulo =>
      'S\'il est renseigné, le bouton URGENCE du tableau de bord ouvre directement une conversation avec ce numéro. Vide, il vous laisse choisir l\'app sur le moment.';

  @override
  String get configNumeroLabel => 'Numéro avec indicatif et pays';

  @override
  String get configNumeroHint => 'Ex : 5588999998888';

  @override
  String get configContatoSalvo => 'Contact d\'urgence enregistré';

  @override
  String get configDadosBackup => 'Données et Sauvegarde';

  @override
  String get configBackupManual => 'Sauvegarde manuelle';

  @override
  String get configBackupExplicacao =>
      'Les itinéraires planifiés, points marqués, demandes de cartes et la production n\'existent que sur cet appareil — rien de tout cela n\'est envoyé à un serveur. Générez une sauvegarde de temps en temps et conservez-la en lieu sûr (e-mail, cloud, autre appareil).';

  @override
  String get configGerarBackup => 'Générer et partager la sauvegarde';

  @override
  String configBackupCompartilhado(String carimbo) {
    return 'Sauvegarde Atlas Blue Ocean — $carimbo';
  }

  @override
  String configErroBackup(String erro) {
    return 'Erreur lors de la génération de la sauvegarde : $erro';
  }

  @override
  String get configDetalhesAparelho => 'Détails de l\'Appareil';

  @override
  String get configModelo => 'Modèle';

  @override
  String get configFabricante => 'Fabricant';

  @override
  String get configSistemaOperacional => 'Système d\'Exploitation';

  @override
  String get configTesteDispositivo => 'Test — Appareil et Recommandations';

  @override
  String get configIdioma => 'Langue';

  @override
  String get configIdiomaSubtitulo =>
      'Langue utilisée dans toute l\'application';

  @override
  String get dashboardAtivarModoNoturno => 'Activer le mode nuit';

  @override
  String get dashboardDesativarModoNoturno => 'Désactiver le mode nuit';

  @override
  String get dashboardBoasVindas => 'Bienvenue, Patron !';

  @override
  String dashboardEmbarcacaoLabel(String nome) {
    return 'Embarcation : $nome';
  }

  @override
  String get dashboardEmbarcacaoNaoDefinida => 'Non définie';

  @override
  String get dashboardEmergenciaBotao => 'URGENCE — Envoyer la Position';

  @override
  String get dashboardRastreamentoAtivo => 'Suivi Actif';

  @override
  String dashboardRastreamentoSubtitulo(int min) {
    return 'Enregistrement de la position toutes les $min minutes';
  }

  @override
  String dashboardPosicoesPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions en attente de synchronisation',
      one: '1 position en attente de synchronisation',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPosicoesPendentesSubtitulo =>
      'Seront envoyées automatiquement dès qu\'il y aura une connexion.';

  @override
  String get dashboardSincronizarAgora => 'Synchroniser maintenant';

  @override
  String dashboardBateriaBaixa(int percent) {
    return 'Batterie du téléphone à $percent %';
  }

  @override
  String get dashboardBateriaBaixaSubtitulo =>
      'Le suivi peut s\'arrêter si la batterie s\'épuise.';

  @override
  String get dashboardSemPosicaoRecente =>
      'Aucune position récente enregistrée';

  @override
  String dashboardSemPosicaoRecenteSubtitulo(String tempo) {
    return 'Dernière position il y a $tempo. Vérifiez le signal GPS.';
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
      other: '$d jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get dashboardBat => 'PROF';

  @override
  String get dashboardMetros => 'mètres';

  @override
  String get dashboardSst => 'TSM';

  @override
  String get dashboardMapa => 'Carte';

  @override
  String get dashboardRodape =>
      'Toutes les données sont enregistrées localement.\nLa synchronisation avec le serveur se fera dès qu\'il y aura une connexion.';

  @override
  String get dashboardErroCarregar =>
      'Impossible de charger les données du tableau de bord.';

  @override
  String get dashboardTentarNovamente => 'Réessayer';

  @override
  String dashboardPosicoesEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions envoyées',
      one: '1 position envoyée',
    );
    return '$_temp0';
  }

  @override
  String dashboardAindaPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encore en attente',
      one: '1 encore en attente',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSincronizacaoFalhou =>
      'Impossible de synchroniser maintenant. Vérifiez la connexion.';

  @override
  String dashboardErroSincronizar(String erro) {
    return 'Erreur de synchronisation : $erro';
  }

  @override
  String get dashboardSosTitulo => 'Envoyer le signal d\'urgence ?';

  @override
  String get dashboardSosTexto =>
      'Cela ouvrira une app de messagerie avec votre position actuelle et une demande d\'aide, à envoyer à qui peut vous secourir.';

  @override
  String get dashboardSosConfirmar => 'URGENCE';

  @override
  String dashboardSosErroPosicao(String erro) {
    return 'Impossible d\'obtenir la position : $erro';
  }

  @override
  String dashboardSosMensagem(
      String embarcacao, String posicao, String horario, String url) {
    return '🆘 URGENCE — j\'ai besoin d\'aide !\nEmbarcation : $embarcacao\nPosition : $posicao\nHeure : $horario\n$url';
  }

  @override
  String get dashboardEmbarcacaoNaoInformada => 'non renseignée';

  @override
  String get drawerViagemAtual => 'Voyage en Cours';

  @override
  String get drawerProducao => 'Production';

  @override
  String get drawerSolicitarCarta => 'Demander une Carte';

  @override
  String get drawerCartasNauticas => 'Cartes Nautiques';

  @override
  String get drawerMinhasRotas => 'Mes Itinéraires';

  @override
  String get drawerEmbarcacao => 'Embarcation';

  @override
  String get drawerCondicoesMar => 'Conditions de Mer';

  @override
  String get drawerAlertaRota => 'Alerte d\'Itinéraire';

  @override
  String get drawerTabuaMare => 'Table des Marées';

  @override
  String get drawerMareEPesca => 'Marée et Pêche';

  @override
  String get drawerFaseLua => 'Phase Lunaire';

  @override
  String get drawerAvisosNavegantes => 'Avis aux Navigateurs';

  @override
  String get drawerConfiguracoes => 'Paramètres';

  @override
  String get drawerSair => 'Se déconnecter';

  @override
  String get dashboardCartaSolicitadaSucesso => 'Carte demandée avec succès !';

  @override
  String get dashboardNenhumaEmbarcacaoTitulo => 'Aucune embarcation liée';

  @override
  String dashboardNenhumaEmbarcacaoTexto(String motivo) {
    return 'L\'embarcation est liée automatiquement à partir de votre voyage actif sur la plateforme. Synchronisez avant de $motivo.';
  }

  @override
  String get dashboardNenhumaViagemTitulo => 'Aucun voyage en cours';

  @override
  String dashboardNenhumaViagemTexto(String motivo) {
    return 'Les voyages sont désormais créés sur la plateforme. Synchronisez avant de $motivo, ou demandez que le voyage soit démarré là-bas.';
  }

  @override
  String get dashboardMotivoRegistrarProducao => 'enregistrer la production';

  @override
  String get dashboardViagemSincronizada => 'Voyage actif synchronisé.';

  @override
  String get dashboardNenhumaViagemEncontrada =>
      'Aucun voyage actif trouvé sur la plateforme pour le moment.';

  @override
  String get dashboardSairTitulo => 'Se Déconnecter';

  @override
  String get dashboardSairTexto => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get producaoTitulo => 'Registre de Production';

  @override
  String get producaoVerHistorico => 'Voir l\'historique et les totaux';

  @override
  String producaoDataLabel(String data) {
    return 'Date : $data';
  }

  @override
  String get producaoSemViagemAviso =>
      'Aucun voyage en cours — cette entrée ne sera pas associée à un voyage.';

  @override
  String get producaoClassificacaoLabel => 'Classification *';

  @override
  String get producaoSelecioneClassificacao => 'Sélectionnez la classification';

  @override
  String get producaoQuantidadeLabel => 'Quantité (unités) *';

  @override
  String get producaoInformeQuantidade => 'Indiquez la quantité';

  @override
  String get producaoQuantidadeInvalida =>
      'Indiquez un nombre entier supérieur à zéro';

  @override
  String get producaoObservacaoLabel => 'Remarque (facultatif)';

  @override
  String get producaoCapturandoLocalizacao => 'Récupération de la position...';

  @override
  String get producaoSalvando => 'Enregistrement...';

  @override
  String get producaoSalvarBotao => 'ENREGISTRER LA PRODUCTION';

  @override
  String get producaoTipoPeixeLabel => 'Type de poisson *';

  @override
  String get producaoSelecioneTipoPeixe => 'Sélectionnez le type de poisson';

  @override
  String get producaoPesoEstimadoLabel => 'Poids estimé';

  @override
  String get producaoSemEmbarcacaoVinculada =>
      'Aucune embarcation liée — configurez-la dans Paramètres → Embarcation avant d\'enregistrer la production.';

  @override
  String producaoErroGps(String erro) {
    return 'Impossible d\'obtenir le GPS pour le moment ($erro). L\'entrée sera enregistrée sans position.';
  }

  @override
  String get producaoSalvaSucesso => '✅ Production enregistrée avec succès !';

  @override
  String producaoErroSalvar(String erro) {
    return 'Erreur lors de l\'enregistrement : $erro';
  }

  @override
  String producaoKgPorUnidade(String min, String max) {
    return '$min–$max kg/unité';
  }

  @override
  String get producaoEmbarcacaoNaoDefinida => 'Non définie';

  @override
  String get fechar => 'Fermer';

  @override
  String get remover => 'Supprimer';

  @override
  String get mapaCartaRecomendacaoIndisponivel =>
      'Carte de la recommandation indisponible (le lien a peut-être expiré)';

  @override
  String get mapaErroCarregarCartaRecomendacao =>
      'Impossible de charger la carte de la recommandation';

  @override
  String mapaErroSalvarRota(String erro) {
    return 'Erreur lors de l\'enregistrement de l\'itinéraire : $erro';
  }

  @override
  String get mapaLabelData => 'Date';

  @override
  String get mapaLabelClassificacaoCurto => 'Classification';

  @override
  String get mapaLabelPeso => 'Poids';

  @override
  String mapaProducaoTotal(String kg) {
    return '$kg kg au total';
  }

  @override
  String get mapaEspecieNaoInformada => 'Non renseigné';

  @override
  String get mapaClorofilaTitulo => 'Chlorophylle-a';

  @override
  String get mapaClorofilaSemDado =>
      'Aucune donnée valide pour ce point (nuages, terre proche ou panne du capteur le jour le plus récent disponible)';

  @override
  String mapaClorofilaData(String data) {
    return 'Date : $data';
  }

  @override
  String mapaClorofilaFonte(String fonte) {
    return 'Source : $fonte';
  }

  @override
  String get mapaClorofilaDisclaimer =>
      'Indicateur de productivité biologique/environnementale — ne représente pas directement la quantité de poissons.';

  @override
  String get mapaAdicionarPontoClorofila =>
      'Marquer un autre point de chlorophylle-a';

  @override
  String get mapaIndiceProdutividadeTitulo =>
      'Indice de Productivité Blue Ocean';

  @override
  String get mapaAdicionarPontoIndice =>
      'Marquer un autre point d\'indice de productivité';

  @override
  String mapaIndiceDadosClorofilaData(String data) {
    return 'Données de chlorophylle-a du $data';
  }

  @override
  String get mapaIndiceFontes =>
      'Sources : NOAA CoastWatch (ERDDAP) · Open-Meteo Marine';

  @override
  String get mapaIndiceDisclaimer =>
      'Estimation combinant la chlorophylle-a et la température de surface de la mer — ne représente pas directement la quantité de poissons, seulement un indicateur indirect de productivité.';

  @override
  String get mapaTemperaturaTitulo => 'Température de surface de la mer';

  @override
  String mapaConsultarPontoInstrucao(String titulo) {
    return 'Consulter $titulo — pointez le centre de la carte vers l\'endroit souhaité';
  }

  @override
  String get mapaConsultarBotao => 'Consulter';

  @override
  String mapaTemperaturaResultado(String valor) {
    return 'Température au point : $valor °C';
  }

  @override
  String get mapaTemperaturaSemDado =>
      'Aucune donnée de température pour ce point actuellement';

  @override
  String get mapaErroBuscarTemperatura =>
      'Erreur lors de la récupération de la température';

  @override
  String get mapaErroBuscarClorofila =>
      'Erreur lors de la récupération de la chlorophylle-a';

  @override
  String get mapaErroCalcularIndice =>
      'Erreur lors du calcul de l\'indice de productivité';

  @override
  String get mapaMenuTitulo => 'MENU DE LA CARTE';

  @override
  String get mapaCancelarMarcacao => 'Annuler le marquage';

  @override
  String get mapaMarcarPonto => 'Marquer un point';

  @override
  String get mapaCamadasTitulo => 'COUCHES';

  @override
  String get mapaCamadaRuasTitulo => 'Plan des Rues (OpenStreetMap)';

  @override
  String get mapaCamadaRuasSubtitulo =>
      'Désactivé : affiche la carte nautique chargée';

  @override
  String get mapaCamadaNauticaTitulo => 'Informations nautiques (OpenSeaMap)';

  @override
  String get mapaCamadaNauticaSubtitulo =>
      'Bouées, marques, phares et ports — uniquement sur le Plan des Rues';

  @override
  String get mapaCamadaProfundidadeTitulo => 'Profondeur';

  @override
  String get mapaCamadaProfundidadeSubtitulo =>
      'Ombrage bathymétrique (GEBCO) · OpenSeaMap';

  @override
  String get mapaCamadaCurvasTitulo => 'Courbes de profondeur';

  @override
  String get mapaCamadaCurvasSubtitulo => 'Isobathes · OpenSeaMap';

  @override
  String get mapaClorofilaSubtitulo =>
      'Indicateur de productivité · NOAA CoastWatch';

  @override
  String get mapaCamadaProducaoTitulo =>
      'Zones de pêche (carte de chaleur de production)';

  @override
  String get mapaCamadaOverlayTitulo => 'Superposition d\'image';

  @override
  String get mapaCamadaOverlaySubtitulo =>
      'PNG géoréférencé — appuyez sur « Choisir une image » pour le changer';

  @override
  String get mapaEscolherImagem => 'Choisir une image';

  @override
  String get mapaIndiceProdutividadeSubtitulo =>
      'Combine la chlorophylle-a et la température — une estimation, pas une garantie de poisson';

  @override
  String get mapaBaixarRegiao =>
      'Télécharger la région pour une utilisation hors ligne';

  @override
  String get mapaAtribuicao =>
      '© OpenStreetMap contributors · © OpenSeaMap contributors · Profondeur : GEBCO / OpenSeaMap depth project';

  @override
  String get mapaOverlayDialogTitulo => 'Superposition PNG';

  @override
  String get mapaOverlayDialogTexto =>
      'Choisissez, dans la galerie photo de l\'appareil, un PNG géoréférencé (avec la métadonnée « geo_bounds » intégrée) à afficher sur la carte.';

  @override
  String get mapaSelecionarImagem => 'Sélectionner une image';

  @override
  String mapaOverlayFallback(String erro) {
    return '$erro Utilisation de la zone par défaut de l\'app.';
  }

  @override
  String mapaErroSelecionarImagem(String erro) {
    return 'Erreur lors de la sélection de l\'image : $erro';
  }

  @override
  String mapaPontoMarcadoConfirmacao(String valor) {
    return 'Point marqué : $valor';
  }

  @override
  String get mapaPontoMarcadoTitulo => 'Point marqué';

  @override
  String get mapaLabelCoordenadas => 'Coordonnées';

  @override
  String get mapaLabelMarcadoEm => 'Marqué le';

  @override
  String get mapaLabelDistancia => 'Distance';

  @override
  String get mapaLabelRumo => 'Cap';

  @override
  String get mapaConsultarAqui => 'Consulter ici';

  @override
  String get mapaPontoRecomendacaoTitulo => 'Point de la recommandation';

  @override
  String get mapaLabelRecebidoEm => 'Reçu le';

  @override
  String get mapaEditarRota => 'Modifier l\'Itinéraire';

  @override
  String get mapaNovaRotaPlanejada => 'Nouvel Itinéraire Planifié';

  @override
  String get mapaRecomendacaoFallback => 'Recommandation';

  @override
  String get mapaRotaHistorico => 'Itinéraire de l\'historique';

  @override
  String get mapaMenuDoMapaTooltip => 'Menu de la carte';

  @override
  String get mapaMeusPontosTooltip => 'Mes Points';

  @override
  String get mapaCarregandoCarta => 'Chargement de la carte nautique...';

  @override
  String mapaErroCarregarCarta(String erro) {
    return 'Erreur lors du chargement de la carte : $erro';
  }

  @override
  String get mapaApontarCentro =>
      'Pointez le centre de la carte vers l\'endroit souhaité';

  @override
  String get mapaNomeLocalLabel => 'Nom du lieu (facultatif)';

  @override
  String get mapaNomeLocalHint => 'Ex : Puits de Camurupim';

  @override
  String get mapaMarcarPontoBotao => 'Marquer le point';

  @override
  String get mapaRotaTocarPrimeiroPonto =>
      'Touchez la carte ou un point marqué pour ajouter le premier point';

  @override
  String mapaRotaPontosAdicionados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n points ajoutés',
      one: '1 point ajouté',
    );
    return '$_temp0 — touchez pour continuer';
  }

  @override
  String get mapaNomeRotaLabel => 'Nom de l\'itinéraire';

  @override
  String get mapaNomeRotaHint => 'Ex : Coin de pêche de Camurupim';

  @override
  String get mapaDesfazerUltimo => 'Annuler le dernier';

  @override
  String get mapaSalvarAlteracoes => 'Enregistrer les modifications';

  @override
  String get mapaSalvarRota => 'Enregistrer l\'itinéraire';

  @override
  String get shellHome => 'Accueil';

  @override
  String get shellCartasTab => 'Cartes';

  @override
  String cartasSemConexao(String horario) {
    return 'Pas de connexion — affichage de la dernière liste synchronisée à $horario';
  }

  @override
  String get cartasDataDesconhecida => 'date inconnue';

  @override
  String get minhasSolicitacoesTooltip => 'Mes demandes';

  @override
  String get minhasSolicitacoesTitulo => 'Mes Demandes';

  @override
  String minhasSolicitacoesErro(String erro) {
    return 'Erreur lors du chargement des demandes : $erro';
  }

  @override
  String get minhasSolicitacoesVazio =>
      'Aucune demande de carte pour l\'instant';

  @override
  String minhasSolicitacoesPedidoEm(String data) {
    return 'Demandée le $data';
  }

  @override
  String get minhasSolicitacoesPendente => 'En attente';

  @override
  String get solicitarCartaTitulo => 'Demander une Carte Nautique';

  @override
  String get solicitarCartaCoordenadaGeografica => 'Coordonnée Géographique';

  @override
  String get solicitarCartaInstrucao =>
      'Tournez les sélecteurs comme une horloge pour ajuster les degrés et les minutes';

  @override
  String get solicitarCartaBotao => 'DEMANDER LA CARTE NAUTIQUE';

  @override
  String get solicitarCartaSucesso =>
      'Demande enregistrée ! Consultez « Mes Demandes ».';

  @override
  String solicitarCartaErro(String erro) {
    return 'Erreur lors de la demande de carte : $erro';
  }

  @override
  String get embarcacaoTitulo => 'Mon Embarcation';

  @override
  String embarcacaoErroCarregar(String erro) {
    return 'Erreur lors du chargement de l\'embarcation : $erro';
  }

  @override
  String get embarcacaoSincronizadaSucesso =>
      'Embarcation synchronisée avec le voyage actif.';

  @override
  String get embarcacaoSemProprietario => 'Aucun propriétaire enregistré';

  @override
  String get embarcacaoAtiva => 'Active';

  @override
  String get embarcacaoInativa => 'Inactive';

  @override
  String get embarcacaoCapacidadesTitulo => 'CAPACITÉS ET ÉQUIPAGE';

  @override
  String get embarcacaoUrnas => 'Cales';

  @override
  String get embarcacaoGelo => 'Glace';

  @override
  String get embarcacaoDiesel => 'Diesel';

  @override
  String get embarcacaoTripulantes => 'Équipage';

  @override
  String get embarcacaoDetalhesTitulo => 'DÉTAILS';

  @override
  String get embarcacaoMotorUsado => 'Moteur Utilisé';

  @override
  String get embarcacaoIdMestre => 'ID Patron/Capitaine';

  @override
  String get embarcacaoIdRastreio => 'ID DE SUIVI';

  @override
  String get embarcacaoVinculacaoAutomatica =>
      'L\'embarcation est liée automatiquement à partir de votre voyage actif sur la plateforme.';

  @override
  String get embarcacaoRastrear => 'Suivre';

  @override
  String get embarcacaoConfigTooltipSincronizar =>
      'Synchroniser avec le voyage actif';

  @override
  String get embarcacaoConfigTesteDisparado =>
      'Test lancé — voir le résultat dans la console/le journal';

  @override
  String get embarcacaoConfigSemEmbarcacaoTexto =>
      'L\'embarcation est liée automatiquement à partir de votre voyage actif sur la plateforme. Touchez synchroniser pour la récupérer à nouveau.';

  @override
  String get embarcacaoConfigVinculadaTexto =>
      'Liée par le voyage actif sur la plateforme.';

  @override
  String get embarcacaoConfigIdLabel => 'ID de l\'Embarcation';

  @override
  String get embarcacaoConfigCapacidadeGelo => 'Capacité de glace';

  @override
  String get embarcacaoConfigCapacidadeDiesel => 'Capacité de diesel';

  @override
  String get embarcacaoConfigMotorUsado => 'Moteur utilisé';

  @override
  String get embarcacaoConfigNumeroTripulantes =>
      'Nombre de membres d\'équipage';

  @override
  String get embarcacaoConfigTestarEnvio => 'Tester l\'envoi de position';

  @override
  String viagemErroCarregarHistorico(String erro) {
    return 'Erreur lors du chargement de l\'historique : $erro';
  }

  @override
  String get viagemResumoDaViagemFallback => 'Résumé du voyage';

  @override
  String viagemCompartilharInicio(String data) {
    return 'Début : $data';
  }

  @override
  String viagemCompartilharDistancia(String mn) {
    return 'Distance : $mn mn';
  }

  @override
  String viagemCompartilharDuracao(String valor) {
    return 'Durée : $valor';
  }

  @override
  String viagemCompartilharVelMedia(String valor) {
    return 'Vitesse moy. : $valor km/h';
  }

  @override
  String viagemCompartilharVelMaxima(String valor) {
    return 'Vitesse max. : $valor km/h';
  }

  @override
  String get viagemCompartilharProducaoTitulo => '🐟 Production :';

  @override
  String get viagemFinalizarTitulo => 'Terminer le voyage';

  @override
  String get viagemFinalizarTexto =>
      'Voulez-vous vraiment terminer ce voyage ? Le suivi de position en arrière-plan s\'arrête avec lui — l\'app ne recommencera à envoyer la position que lorsqu\'un autre voyage sera démarré.';

  @override
  String get viagemFinalizarBotao => 'Terminer';

  @override
  String viagemErroFinalizar(String erro) {
    return 'Erreur lors de la fin du voyage : $erro';
  }

  @override
  String get viagemVerRotaTooltip => 'Voir l\'itinéraire sur la carte';

  @override
  String get viagemCompartilharTooltip => 'Partager le résumé du voyage';

  @override
  String get viagemAtualizarTooltip => 'Actualiser';

  @override
  String get viagemNenhumRegistro => 'Aucun enregistrement trouvé';

  @override
  String get viagemCriadasNaPlataforma =>
      'Les voyages sont désormais créés sur la plateforme. Touchez synchroniser pour récupérer le voyage actif.';

  @override
  String get viagemEmAndamentoFallback => 'Voyage en cours';

  @override
  String viagemIniciadaEm(String data) {
    return 'Débuté le $data';
  }

  @override
  String get viagemDuracaoLabel => 'Durée';

  @override
  String get viagemVelMediaLabel => 'Vitesse moy.';

  @override
  String get viagemVelMaximaLabel => 'Vitesse max.';

  @override
  String viagemPrecLabel(String m) {
    return 'Préc : ${m}m';
  }
}
