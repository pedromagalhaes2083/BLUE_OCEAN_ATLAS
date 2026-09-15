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

  @override
  String get apagar => 'Supprimer';

  @override
  String rotasErroCarregar(String erro) {
    return 'Erreur lors du chargement des itinéraires : $erro';
  }

  @override
  String get rotasApagarTitulo => 'Supprimer l\'itinéraire ?';

  @override
  String rotasApagarTexto(String nome) {
    return '« $nome » sera définitivement supprimé.';
  }

  @override
  String get rotasNovaRota => 'Nouvel itinéraire';

  @override
  String get rotasNenhumaAinda => 'Aucun itinéraire planifié pour l\'instant';

  @override
  String get rotasTocarNovaRota =>
      'Touchez « Nouvel itinéraire » pour marquer des points sur la carte';

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
  String get rotasAnalisarTooltip => 'Analyser les conditions de l\'itinéraire';

  @override
  String get rotasEditarTooltip => 'Modifier l\'itinéraire';

  @override
  String get rotasApagarTooltip => 'Supprimer l\'itinéraire';

  @override
  String rotasAnaliseTitulo(String nome) {
    return 'Analyse : $nome';
  }

  @override
  String get rotasBuscandoCondicoes =>
      'Récupération des conditions le long de l\'itinéraire...';

  @override
  String rotasPontosComCondicaoSevera(int severos, int total) {
    return '$severos sur $total points avec une condition sévère';
  }

  @override
  String get rotasNenhumPontoSevero => 'Aucun point avec une condition sévère';

  @override
  String rotasPontosDistanciaTotal(int n, String distancia) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n points',
      one: '1 point',
    );
    return '$_temp0 · $distancia mn au total';
  }

  @override
  String rotasTrechoDesdePonto(String trecho, int indice) {
    return '+$trecho mn depuis le point $indice';
  }

  @override
  String get metricaVento => 'Vent';

  @override
  String get metricaOnda => 'Vague';

  @override
  String get metricaCorrente => 'Courant';

  @override
  String get metricaAgua => 'Eau';

  @override
  String get metricaMare => 'Marée';

  @override
  String get condicoesMarTitulo => 'Conditions de Mer';

  @override
  String get condicoesMarAguardandoPosicao =>
      'En attente de la position actuelle de l\'embarcation...';

  @override
  String get erroBuscarPrevisaoPrefixo =>
      'Erreur lors de la récupération des prévisions';

  @override
  String get condicoesPontoTituloFallback => 'Conditions du Point';

  @override
  String get posicaoAtualTitulo => '📍 Position Actuelle';

  @override
  String get posicaoAtualizarTooltip => 'Actualiser la position';

  @override
  String get posicaoTocarIcone => 'Touchez l\'icône pour actualiser';

  @override
  String get posicaoTocarBotao => 'Touchez le bouton pour actualiser';

  @override
  String get posicaoErroLocalizacaoDesativada =>
      '❌ La localisation est désactivée sur l\'appareil';

  @override
  String get posicaoErroPermissaoNegadaPermanente =>
      '❌ Permission refusée définitivement.\nAllez dans Paramètres > Applications';

  @override
  String get posicaoErroPermissaoNegada =>
      '❌ Permission de localisation refusée';

  @override
  String get posicaoErroTimeout =>
      '❌ Délai dépassé pour obtenir la position.\nRéessayez dans un espace dégagé.';

  @override
  String posicaoErroGenerico(String erro) {
    return '❌ Erreur : $erro';
  }

  @override
  String get profundidadeCarregando => 'Chargement de la profondeur...';

  @override
  String get pontoEmTerra => 'Point sur la terre';

  @override
  String get sstCarregando => 'Chargement de la température de l\'eau...';

  @override
  String get sstSuperficieDoMar => 'Surface de la mer';

  @override
  String mareNivelAgora(String nivel) {
    return '$nivel m maintenant';
  }

  @override
  String get marePreamar => 'Marée haute';

  @override
  String get mareBaixaMar => 'Marée basse';

  @override
  String get luaLabel => 'Lune';

  @override
  String luaIluminadaCiclo(int pct, int dia) {
    return '$pct % illuminée · jour $dia du cycle';
  }

  @override
  String get luaNascer => 'Lever';

  @override
  String get luaPor => 'Coucher';

  @override
  String get luaProximasFases => 'PROCHAINES PHASES';

  @override
  String get luaHoje => 'aujourd\'hui';

  @override
  String luaEmDias(int d) {
    return 'dans ${d}j';
  }

  @override
  String get solunarTitulo => 'Tableau Solunaire';

  @override
  String get solunarSubtitulo =>
      'Périodes de plus forte activité alimentaire, selon la position de la lune';

  @override
  String get ventoCarregando => 'Chargement des prévisions météo...';

  @override
  String get ventoClimaAtual => 'Météo Actuelle';

  @override
  String get ventoVelocidadeTitulo => 'VITESSE DU VENT';

  @override
  String ventoDirecao(int graus) {
    return 'Direction : $graus°';
  }

  @override
  String get labelTemperatura => 'Température';

  @override
  String get labelPressao => 'Pression';

  @override
  String get ventoPrevisaoHoraria => 'Prévisions horaires';

  @override
  String get ventoIntensidadeCalmo => 'Calme';

  @override
  String get ventoIntensidadeLeve => 'Léger';

  @override
  String get ventoIntensidadeModerado => 'Modéré';

  @override
  String get ventoIntensidadeForte => 'Fort';

  @override
  String get ventoIntensidadeMuitoForte => 'Très fort';

  @override
  String get ondaCondicoesAtuais => 'Conditions Actuelles';

  @override
  String get ondaAlturaTitulo => 'HAUTEUR DE VAGUE';

  @override
  String ondaPeriodo(String n) {
    return 'Période $n s';
  }

  @override
  String get ondaCorrenteTitulo => 'COURANT';

  @override
  String get ondaSemDados => 'Aucune donnée';

  @override
  String get ondaSwellPrefixo => 'Houle';

  @override
  String ondaDirecaoOnda(int graus) {
    return 'Dir. vague $graus°';
  }

  @override
  String get ondaAlturaCalmo => 'Calme';

  @override
  String get ondaAlturaLeve => 'Légère';

  @override
  String get ondaAlturaModerado => 'Modérée';

  @override
  String get ondaAlturaAgitado => 'Agitée';

  @override
  String get ondaAlturaMuitoAgitado => 'Très agitée';

  @override
  String get ondaAlturaTempestuoso => 'Forte tempête';

  @override
  String get meteoSheetPosicaoFallback => 'Position';

  @override
  String get meteoSheetSemDados => 'Aucune donnée météo';

  @override
  String get meteoSheetVentoTitulo => 'Vent';

  @override
  String get meteoSheetMovimentoTitulo => 'Mouvement';

  @override
  String get meteoSheetAtmosferaTitulo => 'Atmosphère';

  @override
  String get meteoSheetOndasTitulo => 'Vagues';

  @override
  String get meteoSheetVelocidadeRealTws => 'Vitesse réelle du vent (TWS)';

  @override
  String get meteoSheetDirecaoRealTwd => 'Direction réelle du vent (TWD)';

  @override
  String get meteoSheetAnguloRealTwa => 'Angle réel du vent (TWA)';

  @override
  String get meteoSheetVelocidadeAparenteAws =>
      'Vitesse apparente du vent (AWS)';

  @override
  String get meteoSheetAnguloAparenteAwa => 'Angle apparent du vent (AWA)';

  @override
  String get meteoSheetRajadas => 'Rafales';

  @override
  String get meteoSheetVelocidadeRealSog => 'Vitesse fond (SOG)';

  @override
  String get meteoSheetDirecaoRealCog => 'Cap fond (COG)';

  @override
  String get meteoSheetVelocidadeAparenteStw => 'Vitesse surface (STW)';

  @override
  String get meteoSheetAnguloAparenteCtw => 'Cap surface (CTW)';

  @override
  String get meteoSheetNuvens => 'Nuages';

  @override
  String get meteoSheetChuva => 'Pluie';

  @override
  String get meteoSheetAlturaCombinada => 'Hauteur combinée';

  @override
  String get meteoSheetVentoAltura => 'Vent — hauteur';

  @override
  String get meteoSheetVentoDirecao => 'Vent — direction';

  @override
  String get meteoSheetVentoPeriodo => 'Vent — période';

  @override
  String get meteoSheetSwellAltura => 'Houle — hauteur';

  @override
  String get meteoSheetSwellDirecao => 'Houle — direction';

  @override
  String get meteoSheetSwellPeriodo => 'Houle — période';

  @override
  String get alertaConfigTitulo => 'Configurer les alertes';

  @override
  String get alertaConfigDescricao =>
      'Choisissez à partir de quel point chaque condition sur la trajectoire du navire déclenche une notification (avec vibration). S\'applique à la fois à la vérification manuelle dans \"Alerte de route\" et au suivi en arrière-plan pendant un voyage.';

  @override
  String get alertaConfigVentoTitulo => 'Vent';

  @override
  String get alertaConfigVentoSubtitulo =>
      'Alerte quand le vent en amont dépasse';

  @override
  String get alertaConfigOndaTitulo => 'Hauteur de vague et houle';

  @override
  String get alertaConfigOndaSubtitulo =>
      'Alerte quand la vague ou la houle dépassent';

  @override
  String get alertaConfigCorrenteTitulo => 'Courant de marée';

  @override
  String get alertaConfigCorrenteSubtitulo => 'Alerte quand le courant dépasse';

  @override
  String get alertaConfigTemperaturaTitulo => 'Température de l\'eau';

  @override
  String get alertaConfigTemperaturaSubtitulo =>
      'Alerte quand la température dépasse';

  @override
  String get alertaRotaTitulo => 'Alerte de Route';

  @override
  String get alertaRotaTooltipConfigurar => 'Configurer les alertes';

  @override
  String get alertaRotaTooltipSimular => 'Simuler avec un point marqué';

  @override
  String alertaRotaErroPosicaoPrefixo(String erro) {
    return 'Erreur lors de l\'obtention de la position : $erro';
  }

  @override
  String get alertaRotaNenhumPontoMarcado =>
      'Aucun point marqué pour l\'instant';

  @override
  String get alertaRotaSimularDialogTitulo =>
      'Simuler à partir de quel point ?';

  @override
  String get alertaRotaRumoSimuladoTitulo => 'Cap simulé';

  @override
  String get alertaRotaBotaoSimular => 'Simuler';

  @override
  String get alertaRotaVentoTitulo => 'Vent en amont';

  @override
  String get alertaRotaCorrenteTitulo => 'Courant en amont';

  @override
  String get alertaRotaOndaTitulo => 'Vague en amont';

  @override
  String get alertaRotaSwellTitulo => 'Houle en amont';

  @override
  String get alertaRotaBussolaTitulo => 'Boussole';

  @override
  String get alertaRotaSemSinal => 'Aucun signal';

  @override
  String get alertaRotaAlcanceTitulo => 'Portée de l\'alerte';

  @override
  String get alertaRotaAlcanceDescricao =>
      'Distance en amont du navire, sur le cap actuel, où les conditions sont vérifiées.';

  @override
  String alertaRotaRumoEAlcance(String rumo, String alcance) {
    return 'Cap $rumo° · $alcance mn en amont';
  }

  @override
  String get alertaRotaSemRumoDescricao =>
      'Cap indisponible — le navire doit être en mouvement pour que le GPS calcule un cap valide.';

  @override
  String alertaRotaSimulacaoAtiva(String nome, String rumo) {
    return 'Simulation active — utilisant \"$nome\" avec un cap de $rumo° (pas le GPS réel)';
  }

  @override
  String get alertaRotaCorrenteFraca => 'Faible';

  @override
  String get alertaRotaCorrenteModerada => 'Modéré';

  @override
  String get alertaRotaCorrenteForte => 'Fort';

  @override
  String get alertaRotaCorrenteMuitoForte => 'Très fort';

  @override
  String get alertaRotaCorrenteExtrema => 'Extrême';

  @override
  String get diaSemanaSegunda => 'Lundi';

  @override
  String get diaSemanaTerca => 'Mardi';

  @override
  String get diaSemanaQuarta => 'Mercredi';

  @override
  String get diaSemanaQuinta => 'Jeudi';

  @override
  String get diaSemanaSexta => 'Vendredi';

  @override
  String get diaSemanaSabado => 'Samedi';

  @override
  String get diaSemanaDomingo => 'Dimanche';

  @override
  String get faseLuaScreenTitulo => 'Phase Lunaire';

  @override
  String get faseLuaErroBuscarPrefixo =>
      'Erreur lors de la recherche du lever/coucher de lune';

  @override
  String get faseLuaAguardandoPosicao =>
      'En attente de la position actuelle du navire pour les heures de lever/coucher de lune — la phase ci-dessus n\'en dépend pas.';

  @override
  String get faseLuaNascerEPorTitulo => 'LEVER ET COUCHER DE LA LUNE';

  @override
  String faseLuaHojeData(String data) {
    return 'Aujourd\'hui, $data';
  }

  @override
  String get erroSincronizarPrefixo => 'Erreur de synchronisation';

  @override
  String get tabuaMareTooltipRemoverPorto => 'Supprimer le port';

  @override
  String get tabuaMareRemoverPortoTitulo => 'Supprimer le port ?';

  @override
  String tabuaMareRemoverPortoConteudo(String nome) {
    return '\"$nome\" sera retiré de la liste.';
  }

  @override
  String get tabuaMareSincronizando => 'Synchronisation...';

  @override
  String get tabuaMareSincronizarDeNovo => 'Synchroniser à nouveau';

  @override
  String tabuaMareSincronizadoEm(String data) {
    return 'Synchronisé le $data · disponible hors ligne';
  }

  @override
  String get tabuaMareAindaNaoSincronizado =>
      'Pas encore synchronisé — internet nécessaire la première fois';

  @override
  String get tabuaMareSincronizePrimeiraVez =>
      'Synchronisez au moins une fois, avec internet, pour calculer la table des marées hors ligne de ce port.';

  @override
  String get tabuaMareNivelAgoraTitulo => 'Niveau actuel';

  @override
  String get tabuaMareTitulo => 'Table des Marées';

  @override
  String get tabuaMareBotaoPorto => 'Port';

  @override
  String tabuaMareErroCarregarPrefixo(String erro) {
    return 'Erreur lors du chargement des ports : $erro';
  }

  @override
  String tabuaMareErroSincronizarNome(String nome) {
    return 'Erreur de synchronisation de \"$nome\"';
  }

  @override
  String get tabuaMareNovoPortoTitulo => 'Nouveau port';

  @override
  String get tabuaMareNomeLabel => 'Nom';

  @override
  String get tabuaMareNomeHint => 'Ex : Port d\'Itarema';

  @override
  String get tabuaMarePreencherNome => 'Renseignez le nom du port';

  @override
  String get tabuaMareNenhumPortoTitulo =>
      'Aucun port enregistré pour l\'instant';

  @override
  String get tabuaMareNenhumPortoDescricao =>
      'Enregistrez les coordonnées d\'un port (ex : Itarema, Acaraú, Camocim) pour consulter la marée prévue, même hors ligne une fois synchronisé.';

  @override
  String get tabuaMarePoucosDados =>
      'Trop peu de données de marée renvoyées pour ce point';

  @override
  String get mareEPescaTitulo => 'Marée et Pêche';

  @override
  String get mareEPescaErroBuscarPrefixo =>
      'Erreur lors de la récupération des prévisions de marée';

  @override
  String get mareEPescaAguardandoPosicao =>
      'En attente de la position actuelle du navire...';

  @override
  String get mareEPescaCabecalhoTitulo =>
      'Influence de la Marée sur la Pêche au Thon';

  @override
  String get mareEPescaCabecalhoDescricao =>
      'Comprenez comment l\'amplitude des marées peut modifier les courants, le mélange de l\'eau et les conditions d\'alimentation des thons.';

  @override
  String mareEPescaCondicaoAtual(String tipo) {
    return 'Condition actuelle de la marée : $tipo';
  }

  @override
  String get mareEPescaGrafico24hTitulo => 'Marée sur les prochaines 24h';

  @override
  String get mareEPescaEntendaSizigia => 'Comprendre les marées de vives-eaux';

  @override
  String get mareEPescaEntendaQuadratura =>
      'Comprendre les marées de mortes-eaux';

  @override
  String get mareEPescaImportante => 'Important';

  @override
  String get mareEPescaAvisoPrincipal =>
      'La phase de la marée ne doit pas être utilisée isolément pour déterminer une zone de pêche. La réponse de l\'environnement varie selon l\'emplacement, la profondeur, la topographie, le régime des courants, la température, la disponibilité de nourriture, le vent et d\'autres facteurs océanographiques.';

  @override
  String get mareEPescaAvisoSecundario =>
      'Utilisez la marée comme l\'un des indicateurs dans une analyse intégrée.';

  @override
  String get producaoHistoricoTitulo => 'Historique de Production';

  @override
  String get producaoHistoricoTooltipPorPonto => 'Production par point';

  @override
  String get producaoHistoricoTooltipVerMapa => 'Voir sur la carte';

  @override
  String get producaoHistoricoTooltipExportarCsv => 'Exporter en CSV';

  @override
  String producaoHistoricoErroCarregarPrefixo(String erro) {
    return 'Erreur lors du chargement de la production : $erro';
  }

  @override
  String producaoHistoricoErroExportarPrefixo(String erro) {
    return 'Erreur lors de l\'exportation : $erro';
  }

  @override
  String get producaoHistoricoCsvCabecalho =>
      'Date/Heure,Espèce,Classification,Quantité (un.),Quantité (kg),Latitude,Longitude,Remarque';

  @override
  String producaoHistoricoCompartilharTexto(String kg) {
    return 'Historique de production — $kg kg';
  }

  @override
  String get producaoHistoricoNenhumRegistro =>
      'Aucun enregistrement de production pour l\'instant';

  @override
  String producaoHistoricoTotalResumo(String kg, int n) {
    return 'Total : $kg kg en $n enregistrement(s)';
  }

  @override
  String producaoHistoricoClassificacaoEUnidades(
      String classificacao, int unidades) {
    return 'Classification $classificacao kg · $unidades un.';
  }

  @override
  String get producaoPorPontoTitulo => 'Production par Point';

  @override
  String producaoPorPontoErroCarregarPrefixo(String erro) {
    return 'Erreur lors du chargement : $erro';
  }

  @override
  String get producaoPorPontoVazioTitulo =>
      'Aucune production associée à un point marqué pour l\'instant';

  @override
  String get producaoPorPontoVazioDescricao =>
      'Enregistrez des captures avec coordonnées et marquez des points sur la carte pour voir ici les points les plus productifs';

  @override
  String producaoPorPontoTotalRegistros(int n) {
    return '$n enregistrement(s)';
  }

  @override
  String producaoPorPontoEspecieDestaque(String especie) {
    return ' · $especie en tête';
  }

  @override
  String get meusPontosTitulo => 'Mes Points';

  @override
  String get meusPontosNenhumTituloERecomendacao =>
      'Aucun point marqué ni recommandation pour l\'instant';

  @override
  String get meusPontosSecaoPontosMarcados => 'POINTS MARQUÉS';

  @override
  String get meusPontosSecaoRecomendacoes => 'RECOMMANDATIONS';

  @override
  String get meusPontosDataDesconhecida => 'date inconnue';

  @override
  String meusPontosBannerOffline(String horario) {
    return 'Pas de connexion — affichage des dernières recommandations synchronisées à $horario';
  }

  @override
  String get meusPontosMarcadoEm => 'Marqué le';

  @override
  String get meusPontosProducaoAqui => 'Production ici';

  @override
  String meusPontosProducaoAquiValor(String kg, int n) {
    return '$kg kg ($n enregistrement(s))';
  }

  @override
  String get meusPontosConsultarAqui => 'Consulter ici';

  @override
  String get meusPontosMareEPescaAqui => 'Marée et Pêche ici';

  @override
  String get mapaScreenTituloFallback => 'Carte';

  @override
  String get mapaRotaProducao => 'Route de Production';

  @override
  String get mapaSstLabel => 'SST';

  @override
  String get recomendacaoSemTitulo => '(sans titre)';

  @override
  String get recomendacaoNenhumaDisponivel =>
      'Aucune recommandation disponible';

  @override
  String get recomendacaoExpirada => 'Expirée';

  @override
  String recomendacaoValidaAte(String data) {
    return 'Valide jusqu\'au $data';
  }

  @override
  String recomendacaoVarPrefixo(String variavel, String valor) {
    return 'Var. $variavel : $valor';
  }

  @override
  String recomendacaoPontosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get recomendacaoVerNaCarta => 'Voir sur la Carte';

  @override
  String recomendacaoKgEstimados(String kg) {
    return '$kg kg estimés';
  }

  @override
  String recomendacaoPontosAmostrados(int n) {
    return '$n points échantillonnés';
  }

  @override
  String get faseLuaTipoNovaLua => 'Nouvelle Lune';

  @override
  String get faseLuaTipoCrescente => 'Premier Croissant';

  @override
  String get faseLuaTipoQuartoCrescente => 'Premier Quartier';

  @override
  String get faseLuaTipoGibosaCrescente => 'Gibbeuse Croissante';

  @override
  String get faseLuaTipoCheia => 'Pleine Lune';

  @override
  String get faseLuaTipoGibosaMinguante => 'Gibbeuse Décroissante';

  @override
  String get faseLuaTipoQuartoMinguante => 'Dernier Quartier';

  @override
  String get faseLuaTipoMinguante => 'Dernier Croissant';

  @override
  String get tipoMareSizigiaLabel => 'Vive-eau';

  @override
  String get tipoMareSizigiaNota =>
      'Courants plus forts, plus grande amplitude de marée.';

  @override
  String get tipoMareQuadraturaLabel => 'Morte-eau';

  @override
  String get tipoMareQuadraturaNota =>
      'Courants plus faibles, plus petite amplitude de marée.';

  @override
  String get tipoMareTransicaoLabel => 'Transition';

  @override
  String get tipoMareTransicaoNota =>
      'Ni vive-eau ni morte-eau — une période intermédiaire.';

  @override
  String get tendenciaPressaoCaindo => 'En baisse';

  @override
  String get tendenciaPressaoEstavel => 'Stable';

  @override
  String get tendenciaPressaoSubindo => 'En hausse';

  @override
  String get tipoPeriodoSolunarMaior => 'Période Majeure';

  @override
  String get tipoPeriodoSolunarMenor => 'Période Mineure';

  @override
  String get variavelAmbientalVento => 'Vent';

  @override
  String get variavelAmbientalCorrente => 'Courant';

  @override
  String get variavelAmbientalClorofila => 'Chlorophylle';

  @override
  String get variavelAmbientalOnda => 'Vague';

  @override
  String get variavelAmbientalTemperatura => 'Température';

  @override
  String get nivelOperacionalFavoravelTitulo =>
      'Condition potentiellement favorable';

  @override
  String get nivelOperacionalFavoravelTexto =>
      'Quand plusieurs indicateurs océanographiques convergent, l\'influence de la marée peut renforcer une condition déjà favorable.';

  @override
  String get nivelOperacionalAtencaoTitulo => 'Condition à surveiller';

  @override
  String get nivelOperacionalAtencaoTexto =>
      'La marée seule ne suffit pas à indiquer une bonne zone de pêche.';

  @override
  String get nivelOperacionalBaixaEvidenciaTitulo => 'Faible évidence';

  @override
  String get nivelOperacionalBaixaEvidenciaTexto =>
      'Ne pas utiliser la phase de marée comme seule raison pour déplacer le navire.';

  @override
  String get nivelOperacionalCardTitulo => 'Classification Actuelle';

  @override
  String get nivelOperacionalCardDescricao =>
      'Classification à partir des indicateurs que l\'application a aujourd\'hui (marée astronomique + courant mesuré) — pas une prédiction de capture.';

  @override
  String get nivelOperacionalAgora => 'MAINTENANT';

  @override
  String get estadoMareTitulo => 'ÉTAT ACTUEL';

  @override
  String estadoMareTituloMare(String tipo) {
    return 'MARÉE DE $tipo';
  }

  @override
  String get estadoMareFaseDaLua => 'PHASE LUNAIRE';

  @override
  String estadoMareDiaDoCiclo(int n) {
    return 'jour $n du cycle';
  }

  @override
  String get estadoMareAmplitudePrevista => 'AMPLITUDE PRÉVUE (24H)';

  @override
  String get estadoMareProximaPreamar => 'PROCHAINE MARÉE HAUTE';

  @override
  String get estadoMareProximaBaixaMar => 'PROCHAINE MARÉE BASSE';

  @override
  String get estadoMareDadoIndisponivel => 'Donnée indisponible';

  @override
  String get estadoMareQuadratura => 'MORTE-EAU';

  @override
  String get estadoMareSizigia => 'VIVE-EAU';

  @override
  String get classificacaoIndiceBaixa => 'Faible';

  @override
  String get classificacaoIndiceModerada => 'Modéré';

  @override
  String get classificacaoIndiceAlta => 'Élevé';

  @override
  String get indiceFatorFaseLunarNome =>
      'Phase lunaire (proximité de la vive-eau)';

  @override
  String get indiceFatorAmplitudeNome => 'Amplitude de marée prévue';

  @override
  String get indiceFatorCorrenteNome => 'Vitesse du courant';

  @override
  String indiceFatorFaseLunarDetalhe(String fase, int dia) {
    return '$fase · jour $dia du cycle';
  }

  @override
  String indiceFatorAmplitudeDetalhe(String m) {
    return '$m m dans les prochaines 24h';
  }

  @override
  String indiceFatorCorrenteDetalhe(String ms) {
    return '$ms m/s maintenant';
  }

  @override
  String get indiceInformativoDirecaoCorrente => 'Direction du courant';

  @override
  String get indiceInformativoDiferencaTemperatura =>
      'Différence de température';

  @override
  String get indiceInformativoProximidadeFrentes =>
      'Proximité de fronts thermiques';

  @override
  String get indiceCardTitulo => 'Potentiel d\'Influence';

  @override
  String get indiceCardDescricao =>
      'Dans quelle mesure les conditions de marée contribuent à la dynamique océanographique de la région — pas une chance d\'attraper du thon.';

  @override
  String indiceCardPotencialPrefixo(String classificacao) {
    return 'Potentiel $classificacao';
  }

  @override
  String get indiceCardFatoresConsiderados => 'FACTEURS CONSIDÉRÉS';

  @override
  String get indiceCardInformativos =>
      'INFORMATIFS (NE COMPTENT PAS DANS LE SCORE)';

  @override
  String get comparacaoSizigiaTitulo => 'Marée de Vive-eau';

  @override
  String get comparacaoSizigiaResumo => 'Plus grande amplitude de marée';

  @override
  String get comparacaoSizigiaEfeito1 =>
      'Plus grande variation du niveau de la mer';

  @override
  String get comparacaoSizigiaEfeito2 =>
      'Courants de marée potentiellement plus intenses dans certaines régions';

  @override
  String get comparacaoSizigiaEfeito3 =>
      'Plus grand transport horizontal d\'eau';

  @override
  String get comparacaoSizigiaEfeito4 =>
      'Plus de mélange dans les environnements où la marée a une forte influence';

  @override
  String get comparacaoSizigiaEfeito5 =>
      'Modification de la distribution/concentration des organismes servant de nourriture aux poissons';

  @override
  String get comparacaoSizigiaRelacaoPesca =>
      'Dans les zones où les courants de marée ont une influence significative, les périodes de plus grande amplitude peuvent augmenter le mouvement et le mélange de l\'eau, pouvant modifier la distribution des proies et créer des conditions favorables à l\'activité des thons.';

  @override
  String get comparacaoSizigiaPotencial => 'ÉLEVÉ';

  @override
  String get comparacaoQuadraturaTitulo => 'Marée de Morte-eau';

  @override
  String get comparacaoQuadraturaResumo => 'Plus petite amplitude de marée';

  @override
  String get comparacaoQuadraturaEfeito1 =>
      'Courants de marée potentiellement moins intenses';

  @override
  String get comparacaoQuadraturaEfeito2 =>
      'Plus petite variation du niveau de l\'eau';

  @override
  String get comparacaoQuadraturaEfeito3 =>
      'Moindre influence de la marée sur le mélange dans certaines régions';

  @override
  String get comparacaoQuadraturaEfeito4 =>
      'Distribution différente des organismes et proies';

  @override
  String get comparacaoQuadraturaRelacaoPesca =>
      'Pendant la morte-eau, la plus petite amplitude de marée peut entraîner une influence moindre des courants de marée dans certaines zones. Cependant, cela ne signifie pas nécessairement moins d\'activité de thon, car la température, les fronts océaniques, la nourriture, la profondeur et d\'autres facteurs peuvent être plus importants.';

  @override
  String get comparacaoQuadraturaPotencial => 'MODÉRÉ';

  @override
  String get comparacaoRelacaoPescaTitulo => 'RELATION AVEC LA PÊCHE AU THON';

  @override
  String comparacaoPotencialInfluencia(String potencial) {
    return 'Potentiel d\'influence : $potencial';
  }

  @override
  String get comparacaoRodape =>
      'Représente la force potentielle de l\'influence de la marée, pas une prévision directe de capture.';

  @override
  String get graficoMareSemDado =>
      'Donnée indisponible pour le graphique de 24h';

  @override
  String get graficoMareCorrenteLabel => 'Courant';

  @override
  String get graficoMareAgoraLabel => 'Maintenant';

  @override
  String get janelaOperacionalTitulo => 'Fenêtre opérationnelle';

  @override
  String get janelaOperacionalDescricao =>
      'Prochaines heures — marée, courant et température réels de chaque horaire.';

  @override
  String get janelaObsSemDado =>
      'Données de marée insuffisantes pour cet horaire.';

  @override
  String get janelaObsEstofa =>
      'Période d\'étale (marée arrêtée). Le courant de marée tend à être faible à cette heure.';

  @override
  String get janelaObsEnchente =>
      'Période de flot. Observer les zones de convergence et de concentration de proies.';

  @override
  String get janelaObsVazante =>
      'Période de jusant. Observer les bords de bancs et chenaux où le courant peut concentrer la nourriture.';

  @override
  String get explicacaoSizigiaTexto =>
      'À la Nouvelle Lune et à la Pleine Lune, les forces gravitationnelles du Soleil et de la Lune se combinent, augmentant l\'amplitude des marées.';

  @override
  String get explicacaoQuadraturaTexto =>
      'Aux premier et dernier quartiers, le Soleil et la Lune exercent leurs forces gravitationnelles dans des directions à peu près perpendiculaires, ce qui réduit l\'amplitude des marées.';

  @override
  String get explicacaoEntendiBotao => 'Compris';

  @override
  String get explicacaoSol => 'Soleil';

  @override
  String get explicacaoTerra => 'Terre';

  @override
  String get explicacaoLua => 'Lune';

  @override
  String get fluxoInfluenciaTitulo => 'Flux d\'Influence';

  @override
  String get fluxoInfluenciaSubtitulo =>
      'Pourquoi est-ce important pour le thon ?';

  @override
  String get fluxoEtapa1Titulo => 'Marée';

  @override
  String get fluxoEtapa1Sub => 'Vive-eau ou morte-eau';

  @override
  String get fluxoEtapa2Titulo => 'Courants';

  @override
  String get fluxoEtapa2Sub => 'Plus ou moins intenses';

  @override
  String get fluxoEtapa3Titulo => 'Mélange / transport d\'eau';

  @override
  String get fluxoEtapa3Sub => 'Mouvement de la colonne d\'eau';

  @override
  String get fluxoEtapa4Titulo => 'Distribution des nutriments et proies';

  @override
  String get fluxoEtapa4Sub => 'Où la nourriture se concentre';

  @override
  String get fluxoEtapa5Titulo => 'Concentration de nourriture';

  @override
  String get fluxoEtapa5Sub => 'Disponibilité pour le thon';

  @override
  String get fluxoEtapa6Titulo => 'Comportement des thons';

  @override
  String get fluxoEtapa6Sub => 'Déplacement et agrégation';

  @override
  String get fluxoEtapa7Titulo => 'Potentiel d\'activité de pêche';

  @override
  String get fluxoEtapa7Sub => 'Un indicateur parmi d\'autres';

  @override
  String get fluxoRodape =>
      'Ceci est une chaîne d\'influence possible, pas une relation déterministe : chaque étape dépend de facteurs locaux (bathymétrie, topographie, régime des courants de la région) que la marée seule n\'explique pas.';

  @override
  String mareCardTipoLabel(String tipo) {
    return 'Marée de $tipo';
  }

  @override
  String get mapaCamadaTrilhaViagemTitulo => 'Trace du voyage';

  @override
  String get mapaCamadaTrilhaViagemSubtitulo =>
      'Trajet du voyage en cours, mis à jour en direct';

  @override
  String get mapaTrilhaSemViagemAtiva =>
      'Aucun voyage en cours pour afficher le trace';
}
