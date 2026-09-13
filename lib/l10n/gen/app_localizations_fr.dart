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
}
