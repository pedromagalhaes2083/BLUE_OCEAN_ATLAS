import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// Nome do app, mostrado no login e no topo do painel
  ///
  /// In pt, this message translates to:
  /// **'Atlas Blue Ocean'**
  String get appTitulo;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @sair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get sair;

  /// No description provided for @salvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get salvar;

  /// No description provided for @sincronizar.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar'**
  String get sincronizar;

  /// No description provided for @idiomaSistema.
  ///
  /// In pt, this message translates to:
  /// **'Idioma do sistema'**
  String get idiomaSistema;

  /// No description provided for @idiomaPortugues.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get idiomaPortugues;

  /// No description provided for @idiomaIngles.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get idiomaIngles;

  /// No description provided for @idiomaEspanhol.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get idiomaEspanhol;

  /// No description provided for @idiomaItaliano.
  ///
  /// In pt, this message translates to:
  /// **'Italiano'**
  String get idiomaItaliano;

  /// No description provided for @idiomaFrances.
  ///
  /// In pt, this message translates to:
  /// **'Français'**
  String get idiomaFrances;

  /// No description provided for @loginSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Login do Mestre'**
  String get loginSubtitulo;

  /// No description provided for @loginUsuarioLabel.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get loginUsuarioLabel;

  /// No description provided for @loginUsuarioObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Informe o usuário'**
  String get loginUsuarioObrigatorio;

  /// No description provided for @loginSenhaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginSenhaLabel;

  /// No description provided for @loginSenhaObrigatoria.
  ///
  /// In pt, this message translates to:
  /// **'Informe a senha'**
  String get loginSenhaObrigatoria;

  /// No description provided for @loginLembrarCredenciais.
  ///
  /// In pt, this message translates to:
  /// **'Lembrar minhas credenciais'**
  String get loginLembrarCredenciais;

  /// No description provided for @loginLembrarCredenciaisSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Entra automaticamente da próxima vez, até você sair da conta.'**
  String get loginLembrarCredenciaisSubtitulo;

  /// No description provided for @loginBotaoEntrar.
  ///
  /// In pt, this message translates to:
  /// **'ENTRAR'**
  String get loginBotaoEntrar;

  /// No description provided for @loginErroCredenciaisInvalidas.
  ///
  /// In pt, this message translates to:
  /// **'Usuário ou senha incorretos.'**
  String get loginErroCredenciaisInvalidas;

  /// No description provided for @loginErroConexao.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao conectar. Tente novamente.'**
  String get loginErroConexao;

  /// No description provided for @loginEscolherOrganizacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a organização'**
  String get loginEscolherOrganizacaoTitulo;

  /// No description provided for @configuracoesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get configuracoesTitulo;

  /// No description provided for @configIdentificacaoAparelho.
  ///
  /// In pt, this message translates to:
  /// **'Identificação do Aparelho'**
  String get configIdentificacaoAparelho;

  /// No description provided for @configIdDispositivo.
  ///
  /// In pt, this message translates to:
  /// **'ID do Dispositivo'**
  String get configIdDispositivo;

  /// No description provided for @configCopiar.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get configCopiar;

  /// No description provided for @configIdCopiado.
  ///
  /// In pt, this message translates to:
  /// **'ID copiado para a área de transferência'**
  String get configIdCopiado;

  /// No description provided for @configEmbarcacao.
  ///
  /// In pt, this message translates to:
  /// **'Embarcação'**
  String get configEmbarcacao;

  /// No description provided for @configConfigurarEmbarcacao.
  ///
  /// In pt, this message translates to:
  /// **'Configurar Embarcação'**
  String get configConfigurarEmbarcacao;

  /// No description provided for @configConfigurarEmbarcacaoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Capacidades, tripulação, mestre e ID de envio de localização.'**
  String get configConfigurarEmbarcacaoSubtitulo;

  /// No description provided for @configRastreamentoLocalizacao.
  ///
  /// In pt, this message translates to:
  /// **'Rastreamento de Localização'**
  String get configRastreamentoLocalizacao;

  /// No description provided for @configIntervaloCapturaEnvio.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo de captura e envio'**
  String get configIntervaloCapturaEnvio;

  /// No description provided for @configIntervaloExplicacao.
  ///
  /// In pt, this message translates to:
  /// **'A cada intervalo, o app captura a posição, grava localmente e envia pra API. Sem internet, fica guardado e é enviado assim que a conexão voltar.'**
  String get configIntervaloExplicacao;

  /// No description provided for @configMinutos.
  ///
  /// In pt, this message translates to:
  /// **'{min} minutos'**
  String configMinutos(int min);

  /// No description provided for @configIntervaloSalvo.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo de rastreamento: {min} min'**
  String configIntervaloSalvo(int min);

  /// No description provided for @configOtimizacaoBateriaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Otimização de bateria pode interromper o rastreamento'**
  String get configOtimizacaoBateriaTitulo;

  /// No description provided for @configOtimizacaoBateriaTexto.
  ///
  /// In pt, this message translates to:
  /// **'O aparelho pode parar de registrar a posição a cada 15 minutos durante uma viagem, sem nenhum aviso, se o Atlas não estiver isento da otimização de bateria do sistema.'**
  String get configOtimizacaoBateriaTexto;

  /// No description provided for @configIsentarApp.
  ///
  /// In pt, this message translates to:
  /// **'Isentar o app'**
  String get configIsentarApp;

  /// No description provided for @configAparencia.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get configAparencia;

  /// No description provided for @configTemaEscuro.
  ///
  /// In pt, this message translates to:
  /// **'Tema Escuro'**
  String get configTemaEscuro;

  /// No description provided for @configTemaClaro.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get configTemaClaro;

  /// No description provided for @configTemaSistema.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get configTemaSistema;

  /// No description provided for @configTemaEscuroSegmento.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get configTemaEscuroSegmento;

  /// No description provided for @configModoNoturno.
  ///
  /// In pt, this message translates to:
  /// **'Modo Noturno'**
  String get configModoNoturno;

  /// No description provided for @configModoNoturnoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Tela em vermelho para preservar a visão no escuro.'**
  String get configModoNoturnoSubtitulo;

  /// No description provided for @configRecomendacoes.
  ///
  /// In pt, this message translates to:
  /// **'Recomendações'**
  String get configRecomendacoes;

  /// No description provided for @configOcultarRecomendacoesExpiradas.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar recomendações expiradas'**
  String get configOcultarRecomendacoesExpiradas;

  /// No description provided for @configOcultarRecomendacoesExpiradasSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Some da lista em \"Cartas Náuticas\" quem já passou da validade — continuam salvas, só não aparecem.'**
  String get configOcultarRecomendacoesExpiradasSubtitulo;

  /// No description provided for @configEmergencia.
  ///
  /// In pt, this message translates to:
  /// **'Emergência'**
  String get configEmergencia;

  /// No description provided for @configContatoEmergencia.
  ///
  /// In pt, this message translates to:
  /// **'Contato de emergência (WhatsApp)'**
  String get configContatoEmergencia;

  /// No description provided for @configContatoEmergenciaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Se preenchido, o botão de EMERGÊNCIA no painel abre direto uma conversa com esse número. Vazio, ele deixa você escolher o app na hora.'**
  String get configContatoEmergenciaSubtitulo;

  /// No description provided for @configNumeroLabel.
  ///
  /// In pt, this message translates to:
  /// **'Número com DDD e país'**
  String get configNumeroLabel;

  /// No description provided for @configNumeroHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: 5588999998888'**
  String get configNumeroHint;

  /// No description provided for @configContatoSalvo.
  ///
  /// In pt, this message translates to:
  /// **'Contato de emergência salvo'**
  String get configContatoSalvo;

  /// No description provided for @configDadosBackup.
  ///
  /// In pt, this message translates to:
  /// **'Dados e Backup'**
  String get configDadosBackup;

  /// No description provided for @configBackupManual.
  ///
  /// In pt, this message translates to:
  /// **'Backup manual'**
  String get configBackupManual;

  /// No description provided for @configBackupExplicacao.
  ///
  /// In pt, this message translates to:
  /// **'Rotas planejadas, pontos marcados, pedidos de carta e produção só existem neste aparelho — nada disso é enviado a um servidor. Gere um backup de vez em quando e guarde num lugar seguro (e-mail, nuvem, outro aparelho).'**
  String get configBackupExplicacao;

  /// No description provided for @configGerarBackup.
  ///
  /// In pt, this message translates to:
  /// **'Gerar e compartilhar backup'**
  String get configGerarBackup;

  /// No description provided for @configBackupCompartilhado.
  ///
  /// In pt, this message translates to:
  /// **'Backup do Atlas Blue Ocean — {carimbo}'**
  String configBackupCompartilhado(String carimbo);

  /// No description provided for @configErroBackup.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao gerar backup: {erro}'**
  String configErroBackup(String erro);

  /// No description provided for @configDetalhesAparelho.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Aparelho'**
  String get configDetalhesAparelho;

  /// No description provided for @configModelo.
  ///
  /// In pt, this message translates to:
  /// **'Modelo'**
  String get configModelo;

  /// No description provided for @configFabricante.
  ///
  /// In pt, this message translates to:
  /// **'Fabricante'**
  String get configFabricante;

  /// No description provided for @configSistemaOperacional.
  ///
  /// In pt, this message translates to:
  /// **'Sistema Operacional'**
  String get configSistemaOperacional;

  /// No description provided for @configTesteDispositivo.
  ///
  /// In pt, this message translates to:
  /// **'Teste — Dispositivo & Recomendações'**
  String get configTesteDispositivo;

  /// No description provided for @configIdioma.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get configIdioma;

  /// No description provided for @configIdiomaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Idioma usado em todo o aplicativo'**
  String get configIdiomaSubtitulo;

  /// No description provided for @dashboardAtivarModoNoturno.
  ///
  /// In pt, this message translates to:
  /// **'Ativar modo noturno'**
  String get dashboardAtivarModoNoturno;

  /// No description provided for @dashboardDesativarModoNoturno.
  ///
  /// In pt, this message translates to:
  /// **'Desativar modo noturno'**
  String get dashboardDesativarModoNoturno;

  /// No description provided for @dashboardBoasVindas.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo, Mestre!'**
  String get dashboardBoasVindas;

  /// No description provided for @dashboardEmbarcacaoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Embarcação: {nome}'**
  String dashboardEmbarcacaoLabel(String nome);

  /// No description provided for @dashboardEmbarcacaoNaoDefinida.
  ///
  /// In pt, this message translates to:
  /// **'Não definida'**
  String get dashboardEmbarcacaoNaoDefinida;

  /// No description provided for @dashboardEmergenciaBotao.
  ///
  /// In pt, this message translates to:
  /// **'EMERGÊNCIA — Enviar Posição'**
  String get dashboardEmergenciaBotao;

  /// No description provided for @dashboardRastreamentoAtivo.
  ///
  /// In pt, this message translates to:
  /// **'Rastreamento Ativo'**
  String get dashboardRastreamentoAtivo;

  /// No description provided for @dashboardRastreamentoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Registrando posição a cada {min} minutos'**
  String dashboardRastreamentoSubtitulo(int min);

  /// No description provided for @dashboardPosicoesPendentes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 posição aguardando sincronização} other{{count} posições aguardando sincronização}}'**
  String dashboardPosicoesPendentes(int count);

  /// No description provided for @dashboardPosicoesPendentesSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Serão enviadas automaticamente assim que houver conexão.'**
  String get dashboardPosicoesPendentesSubtitulo;

  /// No description provided for @dashboardSincronizarAgora.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar agora'**
  String get dashboardSincronizarAgora;

  /// No description provided for @dashboardBateriaBaixa.
  ///
  /// In pt, this message translates to:
  /// **'Bateria do celular em {percent}%'**
  String dashboardBateriaBaixa(int percent);

  /// No description provided for @dashboardBateriaBaixaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'O rastreamento pode parar se a bateria acabar.'**
  String get dashboardBateriaBaixaSubtitulo;

  /// No description provided for @dashboardSemPosicaoRecente.
  ///
  /// In pt, this message translates to:
  /// **'Sem posição recente registrada'**
  String get dashboardSemPosicaoRecente;

  /// No description provided for @dashboardSemPosicaoRecenteSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Última posição há {tempo}. Verifique o sinal de GPS.'**
  String dashboardSemPosicaoRecenteSubtitulo(String tempo);

  /// No description provided for @dashboardTempoMinutos.
  ///
  /// In pt, this message translates to:
  /// **'{min} min'**
  String dashboardTempoMinutos(int min);

  /// No description provided for @dashboardTempoHoras.
  ///
  /// In pt, this message translates to:
  /// **'{h} h'**
  String dashboardTempoHoras(int h);

  /// No description provided for @dashboardTempoDias.
  ///
  /// In pt, this message translates to:
  /// **'{d, plural, =1{1 dia} other{{d} dias}}'**
  String dashboardTempoDias(int d);

  /// No description provided for @dashboardBat.
  ///
  /// In pt, this message translates to:
  /// **'BAT'**
  String get dashboardBat;

  /// No description provided for @dashboardMetros.
  ///
  /// In pt, this message translates to:
  /// **'metros'**
  String get dashboardMetros;

  /// No description provided for @dashboardSst.
  ///
  /// In pt, this message translates to:
  /// **'SST'**
  String get dashboardSst;

  /// No description provided for @dashboardMapa.
  ///
  /// In pt, this message translates to:
  /// **'Mapa'**
  String get dashboardMapa;

  /// No description provided for @dashboardRodape.
  ///
  /// In pt, this message translates to:
  /// **'Todos os dados são salvos localmente.\nA sincronização com o servidor será feita quando houver conexão.'**
  String get dashboardRodape;

  /// No description provided for @dashboardErroCarregar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados do painel.'**
  String get dashboardErroCarregar;

  /// No description provided for @dashboardTentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get dashboardTentarNovamente;

  /// No description provided for @dashboardPosicoesEnviadas.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 posição enviada} other{{count} posições enviadas}}'**
  String dashboardPosicoesEnviadas(int count);

  /// No description provided for @dashboardAindaPendentes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 ainda pendente} other{{count} ainda pendentes}}'**
  String dashboardAindaPendentes(int count);

  /// No description provided for @dashboardSincronizacaoFalhou.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível sincronizar agora. Verifique a conexão.'**
  String get dashboardSincronizacaoFalhou;

  /// No description provided for @dashboardErroSincronizar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao sincronizar: {erro}'**
  String dashboardErroSincronizar(String erro);

  /// No description provided for @dashboardSosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Enviar sinal de emergência?'**
  String get dashboardSosTitulo;

  /// No description provided for @dashboardSosTexto.
  ///
  /// In pt, this message translates to:
  /// **'Isso vai abrir um app de mensagem com sua posição atual e um pedido de ajuda, pra você enviar a quem puder socorrer.'**
  String get dashboardSosTexto;

  /// No description provided for @dashboardSosConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'EMERGÊNCIA'**
  String get dashboardSosConfirmar;

  /// No description provided for @dashboardSosErroPosicao.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter a posição: {erro}'**
  String dashboardSosErroPosicao(String erro);

  /// No description provided for @dashboardSosMensagem.
  ///
  /// In pt, this message translates to:
  /// **'🆘 EMERGÊNCIA — preciso de ajuda!\nEmbarcação: {embarcacao}\nPosição: {posicao}\nHorário: {horario}\n{url}'**
  String dashboardSosMensagem(
      String embarcacao, String posicao, String horario, String url);

  /// No description provided for @dashboardEmbarcacaoNaoInformada.
  ///
  /// In pt, this message translates to:
  /// **'não informada'**
  String get dashboardEmbarcacaoNaoInformada;

  /// No description provided for @drawerViagemAtual.
  ///
  /// In pt, this message translates to:
  /// **'Viagem Atual'**
  String get drawerViagemAtual;

  /// No description provided for @drawerProducao.
  ///
  /// In pt, this message translates to:
  /// **'Produção'**
  String get drawerProducao;

  /// No description provided for @drawerSolicitarCarta.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar Carta'**
  String get drawerSolicitarCarta;

  /// No description provided for @drawerCartasNauticas.
  ///
  /// In pt, this message translates to:
  /// **'Cartas Náuticas'**
  String get drawerCartasNauticas;

  /// No description provided for @drawerMinhasRotas.
  ///
  /// In pt, this message translates to:
  /// **'Minhas Rotas'**
  String get drawerMinhasRotas;

  /// No description provided for @drawerEmbarcacao.
  ///
  /// In pt, this message translates to:
  /// **'Embarcação'**
  String get drawerEmbarcacao;

  /// No description provided for @drawerCondicoesMar.
  ///
  /// In pt, this message translates to:
  /// **'Condições do Mar'**
  String get drawerCondicoesMar;

  /// No description provided for @drawerAlertaRota.
  ///
  /// In pt, this message translates to:
  /// **'Alerta de Rota'**
  String get drawerAlertaRota;

  /// No description provided for @drawerTabuaMare.
  ///
  /// In pt, this message translates to:
  /// **'Tábua de Maré'**
  String get drawerTabuaMare;

  /// No description provided for @drawerMareEPesca.
  ///
  /// In pt, this message translates to:
  /// **'Maré e Pesca'**
  String get drawerMareEPesca;

  /// No description provided for @drawerFaseLua.
  ///
  /// In pt, this message translates to:
  /// **'Fase da Lua'**
  String get drawerFaseLua;

  /// No description provided for @drawerAvisosNavegantes.
  ///
  /// In pt, this message translates to:
  /// **'Avisos aos Navegantes'**
  String get drawerAvisosNavegantes;

  /// No description provided for @drawerConfiguracoes.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get drawerConfiguracoes;

  /// No description provided for @drawerSair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get drawerSair;

  /// No description provided for @dashboardCartaSolicitadaSucesso.
  ///
  /// In pt, this message translates to:
  /// **'Carta solicitada com sucesso!'**
  String get dashboardCartaSolicitadaSucesso;

  /// No description provided for @dashboardNenhumaEmbarcacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma embarcação vinculada'**
  String get dashboardNenhumaEmbarcacaoTitulo;

  /// No description provided for @dashboardNenhumaEmbarcacaoTexto.
  ///
  /// In pt, this message translates to:
  /// **'A embarcação é vinculada automaticamente pela sua viagem ativa na plataforma. Sincronize antes de {motivo}.'**
  String dashboardNenhumaEmbarcacaoTexto(String motivo);

  /// No description provided for @dashboardNenhumaViagemTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma viagem em andamento'**
  String get dashboardNenhumaViagemTitulo;

  /// No description provided for @dashboardNenhumaViagemTexto.
  ///
  /// In pt, this message translates to:
  /// **'As viagens agora são criadas na plataforma. Sincronize antes de {motivo}, ou peça pra iniciar a viagem por lá.'**
  String dashboardNenhumaViagemTexto(String motivo);

  /// No description provided for @dashboardMotivoRegistrarProducao.
  ///
  /// In pt, this message translates to:
  /// **'registrar produção'**
  String get dashboardMotivoRegistrarProducao;

  /// No description provided for @dashboardViagemSincronizada.
  ///
  /// In pt, this message translates to:
  /// **'Viagem ativa sincronizada.'**
  String get dashboardViagemSincronizada;

  /// No description provided for @dashboardNenhumaViagemEncontrada.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma viagem ativa encontrada na plataforma agora.'**
  String get dashboardNenhumaViagemEncontrada;

  /// No description provided for @dashboardSairTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sair do Sistema'**
  String get dashboardSairTitulo;

  /// No description provided for @dashboardSairTexto.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente sair?'**
  String get dashboardSairTexto;

  /// No description provided for @producaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Registro de Produção'**
  String get producaoTitulo;

  /// No description provided for @producaoVerHistorico.
  ///
  /// In pt, this message translates to:
  /// **'Ver histórico e totais'**
  String get producaoVerHistorico;

  /// No description provided for @producaoDataLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data: {data}'**
  String producaoDataLabel(String data);

  /// No description provided for @producaoSemViagemAviso.
  ///
  /// In pt, this message translates to:
  /// **'Sem viagem em andamento — registro não será associado a uma viagem.'**
  String get producaoSemViagemAviso;

  /// No description provided for @producaoClassificacaoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Classificação *'**
  String get producaoClassificacaoLabel;

  /// No description provided for @producaoSelecioneClassificacao.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a classificação'**
  String get producaoSelecioneClassificacao;

  /// No description provided for @producaoQuantidadeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade (unidades) *'**
  String get producaoQuantidadeLabel;

  /// No description provided for @producaoInformeQuantidade.
  ///
  /// In pt, this message translates to:
  /// **'Informe a quantidade'**
  String get producaoInformeQuantidade;

  /// No description provided for @producaoQuantidadeInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Informe um número inteiro maior que zero'**
  String get producaoQuantidadeInvalida;

  /// No description provided for @producaoObservacaoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Observação (opcional)'**
  String get producaoObservacaoLabel;

  /// No description provided for @producaoCapturandoLocalizacao.
  ///
  /// In pt, this message translates to:
  /// **'Capturando localização...'**
  String get producaoCapturandoLocalizacao;

  /// No description provided for @producaoSalvando.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get producaoSalvando;

  /// No description provided for @producaoSalvarBotao.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR PRODUÇÃO'**
  String get producaoSalvarBotao;

  /// No description provided for @producaoTipoPeixeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo do peixe *'**
  String get producaoTipoPeixeLabel;

  /// No description provided for @producaoSelecioneTipoPeixe.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o tipo do peixe'**
  String get producaoSelecioneTipoPeixe;

  /// No description provided for @producaoPesoEstimadoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Peso estimado'**
  String get producaoPesoEstimadoLabel;

  /// No description provided for @producaoSemEmbarcacaoVinculada.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma embarcação vinculada — configure em Configurações → Embarcação antes de registrar produção.'**
  String get producaoSemEmbarcacaoVinculada;

  /// No description provided for @producaoErroGps.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter o GPS agora ({erro}). Registro será salvo sem coordenada.'**
  String producaoErroGps(String erro);

  /// No description provided for @producaoSalvaSucesso.
  ///
  /// In pt, this message translates to:
  /// **'✅ Produção salva com sucesso!'**
  String get producaoSalvaSucesso;

  /// No description provided for @producaoErroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar: {erro}'**
  String producaoErroSalvar(String erro);

  /// No description provided for @producaoKgPorUnidade.
  ///
  /// In pt, this message translates to:
  /// **'{min}–{max} kg/un.'**
  String producaoKgPorUnidade(String min, String max);

  /// No description provided for @producaoEmbarcacaoNaoDefinida.
  ///
  /// In pt, this message translates to:
  /// **'Não definida'**
  String get producaoEmbarcacaoNaoDefinida;

  /// No description provided for @fechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get fechar;

  /// No description provided for @remover.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get remover;

  /// No description provided for @mapaCartaRecomendacaoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Carta da recomendação não disponível (o link pode ter expirado)'**
  String get mapaCartaRecomendacaoIndisponivel;

  /// No description provided for @mapaErroCarregarCartaRecomendacao.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a carta da recomendação'**
  String get mapaErroCarregarCartaRecomendacao;

  /// No description provided for @mapaErroSalvarRota.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar rota: {erro}'**
  String mapaErroSalvarRota(String erro);

  /// No description provided for @mapaLabelData.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get mapaLabelData;

  /// No description provided for @mapaLabelClassificacaoCurto.
  ///
  /// In pt, this message translates to:
  /// **'Classificação'**
  String get mapaLabelClassificacaoCurto;

  /// No description provided for @mapaLabelPeso.
  ///
  /// In pt, this message translates to:
  /// **'Peso'**
  String get mapaLabelPeso;

  /// No description provided for @mapaProducaoTotal.
  ///
  /// In pt, this message translates to:
  /// **'{kg} kg no total'**
  String mapaProducaoTotal(String kg);

  /// No description provided for @mapaEspecieNaoInformada.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get mapaEspecieNaoInformada;

  /// No description provided for @mapaClorofilaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Clorofila-a'**
  String get mapaClorofilaTitulo;

  /// No description provided for @mapaClorofilaSemDado.
  ///
  /// In pt, this message translates to:
  /// **'Sem dado válido pra esse ponto (nuvem, terra próxima ou falha do sensor no dia mais recente disponível)'**
  String get mapaClorofilaSemDado;

  /// No description provided for @mapaClorofilaData.
  ///
  /// In pt, this message translates to:
  /// **'Data: {data}'**
  String mapaClorofilaData(String data);

  /// No description provided for @mapaClorofilaFonte.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: {fonte}'**
  String mapaClorofilaFonte(String fonte);

  /// No description provided for @mapaClorofilaDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Indicador de produtividade biológica/oceanográfica — não representa diretamente quantidade de peixe.'**
  String get mapaClorofilaDisclaimer;

  /// No description provided for @mapaAdicionarPontoClorofila.
  ///
  /// In pt, this message translates to:
  /// **'Marcar outro ponto de clorofila-a'**
  String get mapaAdicionarPontoClorofila;

  /// No description provided for @mapaIndiceProdutividadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Índice de Produtividade Blue Ocean'**
  String get mapaIndiceProdutividadeTitulo;

  /// No description provided for @mapaAdicionarPontoIndice.
  ///
  /// In pt, this message translates to:
  /// **'Marcar outro ponto de índice de produtividade'**
  String get mapaAdicionarPontoIndice;

  /// No description provided for @mapaIndiceDadosClorofilaData.
  ///
  /// In pt, this message translates to:
  /// **'Dados de clorofila-a de {data}'**
  String mapaIndiceDadosClorofilaData(String data);

  /// No description provided for @mapaIndiceFontes.
  ///
  /// In pt, this message translates to:
  /// **'Fontes: NOAA CoastWatch (ERDDAP) · Open-Meteo Marine'**
  String get mapaIndiceFontes;

  /// No description provided for @mapaIndiceDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa combinando clorofila-a e temperatura da superfície do mar — não representa diretamente quantidade de peixe, só um indicador indireto de produtividade.'**
  String get mapaIndiceDisclaimer;

  /// No description provided for @mapaTemperaturaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura da superfície do mar'**
  String get mapaTemperaturaTitulo;

  /// No description provided for @mapaConsultarPontoInstrucao.
  ///
  /// In pt, this message translates to:
  /// **'Consultar {titulo} — aponte o centro do mapa para o local desejado'**
  String mapaConsultarPontoInstrucao(String titulo);

  /// No description provided for @mapaConsultarBotao.
  ///
  /// In pt, this message translates to:
  /// **'Consultar'**
  String get mapaConsultarBotao;

  /// No description provided for @mapaTemperaturaResultado.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura no ponto: {valor} °C'**
  String mapaTemperaturaResultado(String valor);

  /// No description provided for @mapaTemperaturaSemDado.
  ///
  /// In pt, this message translates to:
  /// **'Sem dado de temperatura pra esse ponto agora'**
  String get mapaTemperaturaSemDado;

  /// No description provided for @mapaErroBuscarTemperatura.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao buscar temperatura'**
  String get mapaErroBuscarTemperatura;

  /// No description provided for @mapaErroBuscarClorofila.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao buscar clorofila-a'**
  String get mapaErroBuscarClorofila;

  /// No description provided for @mapaErroCalcularIndice.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao calcular índice de produtividade'**
  String get mapaErroCalcularIndice;

  /// No description provided for @mapaMenuTitulo.
  ///
  /// In pt, this message translates to:
  /// **'MENU DO MAPA'**
  String get mapaMenuTitulo;

  /// No description provided for @mapaCancelarMarcacao.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar marcação'**
  String get mapaCancelarMarcacao;

  /// No description provided for @mapaMarcarPonto.
  ///
  /// In pt, this message translates to:
  /// **'Marcar um ponto'**
  String get mapaMarcarPonto;

  /// No description provided for @mapaCamadasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'CAMADAS'**
  String get mapaCamadasTitulo;

  /// No description provided for @mapaCamadaRuasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Mapa de Ruas (OpenStreetMap)'**
  String get mapaCamadaRuasTitulo;

  /// No description provided for @mapaCamadaRuasSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Desligado: mostra a carta náutica carregada'**
  String get mapaCamadaRuasSubtitulo;

  /// No description provided for @mapaCamadaNauticaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Informações náuticas (OpenSeaMap)'**
  String get mapaCamadaNauticaTitulo;

  /// No description provided for @mapaCamadaNauticaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Boias, marcas, faróis e portos — só sobre o Mapa de Ruas'**
  String get mapaCamadaNauticaSubtitulo;

  /// No description provided for @mapaCamadaProfundidadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Profundidade'**
  String get mapaCamadaProfundidadeTitulo;

  /// No description provided for @mapaCamadaProfundidadeSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sombreamento batimétrico (GEBCO) · OpenSeaMap'**
  String get mapaCamadaProfundidadeSubtitulo;

  /// No description provided for @mapaCamadaCurvasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Curvas de profundidade'**
  String get mapaCamadaCurvasTitulo;

  /// No description provided for @mapaCamadaCurvasSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Isóbatas · OpenSeaMap'**
  String get mapaCamadaCurvasSubtitulo;

  /// No description provided for @mapaClorofilaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Indicador de produtividade · NOAA CoastWatch'**
  String get mapaClorofilaSubtitulo;

  /// No description provided for @mapaCamadaProducaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Pontos de pesca (calor de produção)'**
  String get mapaCamadaProducaoTitulo;

  /// No description provided for @mapaCamadaOverlayTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sobreposição de imagem'**
  String get mapaCamadaOverlayTitulo;

  /// No description provided for @mapaCamadaOverlaySubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'PNG georreferenciado — toque em \"Escolher imagem\" pra trocar'**
  String get mapaCamadaOverlaySubtitulo;

  /// No description provided for @mapaEscolherImagem.
  ///
  /// In pt, this message translates to:
  /// **'Escolher imagem'**
  String get mapaEscolherImagem;

  /// No description provided for @mapaIndiceProdutividadeSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Combina clorofila-a e temperatura — estimativa, não garantia de cardume'**
  String get mapaIndiceProdutividadeSubtitulo;

  /// No description provided for @mapaBaixarRegiao.
  ///
  /// In pt, this message translates to:
  /// **'Baixar região para uso offline'**
  String get mapaBaixarRegiao;

  /// No description provided for @mapaAtribuicao.
  ///
  /// In pt, this message translates to:
  /// **'© OpenStreetMap contributors · © OpenSeaMap contributors · Profundidade: GEBCO / OpenSeaMap depth project'**
  String get mapaAtribuicao;

  /// No description provided for @mapaOverlayDialogTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sobreposição PNG'**
  String get mapaOverlayDialogTitulo;

  /// No description provided for @mapaOverlayDialogTexto.
  ///
  /// In pt, this message translates to:
  /// **'Escolha, na galeria de fotos do dispositivo, um PNG georreferenciado (com o metadado \"geo_bounds\" embutido) para exibir sobre a carta.'**
  String get mapaOverlayDialogTexto;

  /// No description provided for @mapaSelecionarImagem.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar imagem'**
  String get mapaSelecionarImagem;

  /// No description provided for @mapaOverlayFallback.
  ///
  /// In pt, this message translates to:
  /// **'{erro} Usando área padrão do app.'**
  String mapaOverlayFallback(String erro);

  /// No description provided for @mapaErroSelecionarImagem.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao selecionar imagem: {erro}'**
  String mapaErroSelecionarImagem(String erro);

  /// No description provided for @mapaPontoMarcadoConfirmacao.
  ///
  /// In pt, this message translates to:
  /// **'Ponto marcado: {valor}'**
  String mapaPontoMarcadoConfirmacao(String valor);

  /// No description provided for @mapaPontoMarcadoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ponto marcado'**
  String get mapaPontoMarcadoTitulo;

  /// No description provided for @mapaLabelCoordenadas.
  ///
  /// In pt, this message translates to:
  /// **'Coordenadas'**
  String get mapaLabelCoordenadas;

  /// No description provided for @mapaLabelMarcadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Marcado em'**
  String get mapaLabelMarcadoEm;

  /// No description provided for @mapaLabelDistancia.
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get mapaLabelDistancia;

  /// No description provided for @mapaLabelRumo.
  ///
  /// In pt, this message translates to:
  /// **'Rumo'**
  String get mapaLabelRumo;

  /// No description provided for @mapaConsultarAqui.
  ///
  /// In pt, this message translates to:
  /// **'Consultar aqui'**
  String get mapaConsultarAqui;

  /// No description provided for @mapaPontoRecomendacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ponto da recomendação'**
  String get mapaPontoRecomendacaoTitulo;

  /// No description provided for @mapaLabelRecebidoEm.
  ///
  /// In pt, this message translates to:
  /// **'Recebido em'**
  String get mapaLabelRecebidoEm;

  /// No description provided for @mapaEditarRota.
  ///
  /// In pt, this message translates to:
  /// **'Editar Rota'**
  String get mapaEditarRota;

  /// No description provided for @mapaNovaRotaPlanejada.
  ///
  /// In pt, this message translates to:
  /// **'Nova Rota Planejada'**
  String get mapaNovaRotaPlanejada;

  /// No description provided for @mapaRecomendacaoFallback.
  ///
  /// In pt, this message translates to:
  /// **'Recomendação'**
  String get mapaRecomendacaoFallback;

  /// No description provided for @mapaRotaHistorico.
  ///
  /// In pt, this message translates to:
  /// **'Rota do histórico'**
  String get mapaRotaHistorico;

  /// No description provided for @mapaMenuDoMapaTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Menu do mapa'**
  String get mapaMenuDoMapaTooltip;

  /// No description provided for @mapaMeusPontosTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Meus Pontos'**
  String get mapaMeusPontosTooltip;

  /// No description provided for @mapaCarregandoCarta.
  ///
  /// In pt, this message translates to:
  /// **'Carregando carta náutica...'**
  String get mapaCarregandoCarta;

  /// No description provided for @mapaErroCarregarCarta.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar carta: {erro}'**
  String mapaErroCarregarCarta(String erro);

  /// No description provided for @mapaApontarCentro.
  ///
  /// In pt, this message translates to:
  /// **'Aponte o centro do mapa para o local desejado'**
  String get mapaApontarCentro;

  /// No description provided for @mapaNomeLocalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do local (opcional)'**
  String get mapaNomeLocalLabel;

  /// No description provided for @mapaNomeLocalHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Poço do Camurupim'**
  String get mapaNomeLocalHint;

  /// No description provided for @mapaMarcarPontoBotao.
  ///
  /// In pt, this message translates to:
  /// **'Marcar ponto'**
  String get mapaMarcarPontoBotao;

  /// No description provided for @mapaRotaTocarPrimeiroPonto.
  ///
  /// In pt, this message translates to:
  /// **'Toque no mapa ou num ponto marcado para adicionar o primeiro ponto'**
  String get mapaRotaTocarPrimeiroPonto;

  /// No description provided for @mapaRotaPontosAdicionados.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 ponto adicionado} other{{n} pontos adicionados}} — toque para continuar'**
  String mapaRotaPontosAdicionados(int n);

  /// No description provided for @mapaNomeRotaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da rota'**
  String get mapaNomeRotaLabel;

  /// No description provided for @mapaNomeRotaHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Pesqueiro do Camurupim'**
  String get mapaNomeRotaHint;

  /// No description provided for @mapaDesfazerUltimo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer último'**
  String get mapaDesfazerUltimo;

  /// No description provided for @mapaSalvarAlteracoes.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get mapaSalvarAlteracoes;

  /// No description provided for @mapaSalvarRota.
  ///
  /// In pt, this message translates to:
  /// **'Salvar rota'**
  String get mapaSalvarRota;

  /// No description provided for @shellHome.
  ///
  /// In pt, this message translates to:
  /// **'Home'**
  String get shellHome;

  /// No description provided for @shellCartasTab.
  ///
  /// In pt, this message translates to:
  /// **'Cartas'**
  String get shellCartasTab;

  /// No description provided for @cartasSemConexao.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão — mostrando a última lista sincronizada em {horario}'**
  String cartasSemConexao(String horario);

  /// No description provided for @cartasDataDesconhecida.
  ///
  /// In pt, this message translates to:
  /// **'data desconhecida'**
  String get cartasDataDesconhecida;

  /// No description provided for @minhasSolicitacoesTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Minhas solicitações'**
  String get minhasSolicitacoesTooltip;

  /// No description provided for @minhasSolicitacoesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Minhas Solicitações'**
  String get minhasSolicitacoesTitulo;

  /// No description provided for @minhasSolicitacoesErro.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar solicitações: {erro}'**
  String minhasSolicitacoesErro(String erro);

  /// No description provided for @minhasSolicitacoesVazio.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma solicitação de carta ainda'**
  String get minhasSolicitacoesVazio;

  /// No description provided for @minhasSolicitacoesPedidoEm.
  ///
  /// In pt, this message translates to:
  /// **'Pedido em {data}'**
  String minhasSolicitacoesPedidoEm(String data);

  /// No description provided for @minhasSolicitacoesPendente.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get minhasSolicitacoesPendente;

  /// No description provided for @solicitarCartaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar Carta Náutica'**
  String get solicitarCartaTitulo;

  /// No description provided for @solicitarCartaCoordenadaGeografica.
  ///
  /// In pt, this message translates to:
  /// **'Coordenada Geográfica'**
  String get solicitarCartaCoordenadaGeografica;

  /// No description provided for @solicitarCartaInstrucao.
  ///
  /// In pt, this message translates to:
  /// **'Gire os seletores como no relógio para ajustar graus e minutos'**
  String get solicitarCartaInstrucao;

  /// No description provided for @solicitarCartaBotao.
  ///
  /// In pt, this message translates to:
  /// **'SOLICITAR CARTA NÁUTICA'**
  String get solicitarCartaBotao;

  /// No description provided for @solicitarCartaSucesso.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação registrada! Veja em \"Minhas Solicitações\".'**
  String get solicitarCartaSucesso;

  /// No description provided for @solicitarCartaErro.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao solicitar carta: {erro}'**
  String solicitarCartaErro(String erro);

  /// No description provided for @embarcacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Minha Embarcação'**
  String get embarcacaoTitulo;

  /// No description provided for @embarcacaoErroCarregar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar embarcação: {erro}'**
  String embarcacaoErroCarregar(String erro);

  /// No description provided for @embarcacaoSincronizadaSucesso.
  ///
  /// In pt, this message translates to:
  /// **'Embarcação sincronizada com a viagem ativa.'**
  String get embarcacaoSincronizadaSucesso;

  /// No description provided for @embarcacaoSemProprietario.
  ///
  /// In pt, this message translates to:
  /// **'Sem proprietário cadastrado'**
  String get embarcacaoSemProprietario;

  /// No description provided for @embarcacaoAtiva.
  ///
  /// In pt, this message translates to:
  /// **'Ativa'**
  String get embarcacaoAtiva;

  /// No description provided for @embarcacaoInativa.
  ///
  /// In pt, this message translates to:
  /// **'Inativa'**
  String get embarcacaoInativa;

  /// No description provided for @embarcacaoCapacidadesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'CAPACIDADES E TRIPULAÇÃO'**
  String get embarcacaoCapacidadesTitulo;

  /// No description provided for @embarcacaoUrnas.
  ///
  /// In pt, this message translates to:
  /// **'Urnas'**
  String get embarcacaoUrnas;

  /// No description provided for @embarcacaoGelo.
  ///
  /// In pt, this message translates to:
  /// **'Gelo'**
  String get embarcacaoGelo;

  /// No description provided for @embarcacaoDiesel.
  ///
  /// In pt, this message translates to:
  /// **'Diesel'**
  String get embarcacaoDiesel;

  /// No description provided for @embarcacaoTripulantes.
  ///
  /// In pt, this message translates to:
  /// **'Tripulantes'**
  String get embarcacaoTripulantes;

  /// No description provided for @embarcacaoDetalhesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'DETALHES'**
  String get embarcacaoDetalhesTitulo;

  /// No description provided for @embarcacaoMotorUsado.
  ///
  /// In pt, this message translates to:
  /// **'Motor Usado'**
  String get embarcacaoMotorUsado;

  /// No description provided for @embarcacaoIdMestre.
  ///
  /// In pt, this message translates to:
  /// **'ID Mestre / Capitão'**
  String get embarcacaoIdMestre;

  /// No description provided for @embarcacaoIdRastreio.
  ///
  /// In pt, this message translates to:
  /// **'ID DE RASTREIO'**
  String get embarcacaoIdRastreio;

  /// No description provided for @embarcacaoVinculacaoAutomatica.
  ///
  /// In pt, this message translates to:
  /// **'A embarcação é vinculada automaticamente a partir da sua viagem ativa na plataforma.'**
  String get embarcacaoVinculacaoAutomatica;

  /// No description provided for @embarcacaoRastrear.
  ///
  /// In pt, this message translates to:
  /// **'Rastrear'**
  String get embarcacaoRastrear;

  /// No description provided for @embarcacaoConfigTooltipSincronizar.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar com a viagem ativa'**
  String get embarcacaoConfigTooltipSincronizar;

  /// No description provided for @embarcacaoConfigTesteDisparado.
  ///
  /// In pt, this message translates to:
  /// **'Teste disparado — veja o resultado no console/log'**
  String get embarcacaoConfigTesteDisparado;

  /// No description provided for @embarcacaoConfigSemEmbarcacaoTexto.
  ///
  /// In pt, this message translates to:
  /// **'A embarcação é vinculada automaticamente a partir da sua viagem ativa na plataforma. Toque em sincronizar para buscar de novo.'**
  String get embarcacaoConfigSemEmbarcacaoTexto;

  /// No description provided for @embarcacaoConfigVinculadaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Vinculada pela viagem ativa na plataforma.'**
  String get embarcacaoConfigVinculadaTexto;

  /// No description provided for @embarcacaoConfigIdLabel.
  ///
  /// In pt, this message translates to:
  /// **'ID Embarcação'**
  String get embarcacaoConfigIdLabel;

  /// No description provided for @embarcacaoConfigCapacidadeGelo.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade de gelo'**
  String get embarcacaoConfigCapacidadeGelo;

  /// No description provided for @embarcacaoConfigCapacidadeDiesel.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade de diesel'**
  String get embarcacaoConfigCapacidadeDiesel;

  /// No description provided for @embarcacaoConfigMotorUsado.
  ///
  /// In pt, this message translates to:
  /// **'Motor usado'**
  String get embarcacaoConfigMotorUsado;

  /// No description provided for @embarcacaoConfigNumeroTripulantes.
  ///
  /// In pt, this message translates to:
  /// **'Número de tripulantes'**
  String get embarcacaoConfigNumeroTripulantes;

  /// No description provided for @embarcacaoConfigTestarEnvio.
  ///
  /// In pt, this message translates to:
  /// **'Testar envio de localização'**
  String get embarcacaoConfigTestarEnvio;

  /// No description provided for @viagemErroCarregarHistorico.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar histórico: {erro}'**
  String viagemErroCarregarHistorico(String erro);

  /// No description provided for @viagemResumoDaViagemFallback.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da viagem'**
  String get viagemResumoDaViagemFallback;

  /// No description provided for @viagemCompartilharInicio.
  ///
  /// In pt, this message translates to:
  /// **'Início: {data}'**
  String viagemCompartilharInicio(String data);

  /// No description provided for @viagemCompartilharDistancia.
  ///
  /// In pt, this message translates to:
  /// **'Distância: {mn} mn'**
  String viagemCompartilharDistancia(String mn);

  /// No description provided for @viagemCompartilharDuracao.
  ///
  /// In pt, this message translates to:
  /// **'Duração: {valor}'**
  String viagemCompartilharDuracao(String valor);

  /// No description provided for @viagemCompartilharVelMedia.
  ///
  /// In pt, this message translates to:
  /// **'Vel. média: {valor} km/h'**
  String viagemCompartilharVelMedia(String valor);

  /// No description provided for @viagemCompartilharVelMaxima.
  ///
  /// In pt, this message translates to:
  /// **'Vel. máxima: {valor} km/h'**
  String viagemCompartilharVelMaxima(String valor);

  /// No description provided for @viagemCompartilharProducaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'🐟 Produção:'**
  String get viagemCompartilharProducaoTitulo;

  /// No description provided for @viagemFinalizarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar viagem'**
  String get viagemFinalizarTitulo;

  /// No description provided for @viagemFinalizarTexto.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja encerrar esta viagem? O rastreamento de posição em segundo plano para junto — o app só volta a enviar a posição quando outra viagem for iniciada.'**
  String get viagemFinalizarTexto;

  /// No description provided for @viagemFinalizarBotao.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get viagemFinalizarBotao;

  /// No description provided for @viagemErroFinalizar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao finalizar viagem: {erro}'**
  String viagemErroFinalizar(String erro);

  /// No description provided for @viagemVerRotaTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Ver rota na carta'**
  String get viagemVerRotaTooltip;

  /// No description provided for @viagemCompartilharTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar resumo da viagem'**
  String get viagemCompartilharTooltip;

  /// No description provided for @viagemAtualizarTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get viagemAtualizarTooltip;

  /// No description provided for @viagemNenhumRegistro.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro encontrado'**
  String get viagemNenhumRegistro;

  /// No description provided for @viagemCriadasNaPlataforma.
  ///
  /// In pt, this message translates to:
  /// **'As viagens agora são criadas na plataforma. Toque em sincronizar para buscar a viagem ativa.'**
  String get viagemCriadasNaPlataforma;

  /// No description provided for @viagemEmAndamentoFallback.
  ///
  /// In pt, this message translates to:
  /// **'Viagem em andamento'**
  String get viagemEmAndamentoFallback;

  /// No description provided for @viagemIniciadaEm.
  ///
  /// In pt, this message translates to:
  /// **'Iniciada em {data}'**
  String viagemIniciadaEm(String data);

  /// No description provided for @viagemDuracaoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get viagemDuracaoLabel;

  /// No description provided for @viagemVelMediaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Vel. média'**
  String get viagemVelMediaLabel;

  /// No description provided for @viagemVelMaximaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Vel. máxima'**
  String get viagemVelMaximaLabel;

  /// No description provided for @viagemPrecLabel.
  ///
  /// In pt, this message translates to:
  /// **'Prec: {m}m'**
  String viagemPrecLabel(String m);

  /// No description provided for @apagar.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get apagar;

  /// No description provided for @rotasErroCarregar.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar rotas: {erro}'**
  String rotasErroCarregar(String erro);

  /// No description provided for @rotasApagarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Apagar rota?'**
  String get rotasApagarTitulo;

  /// No description provided for @rotasApagarTexto.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" será removida permanentemente.'**
  String rotasApagarTexto(String nome);

  /// No description provided for @rotasNovaRota.
  ///
  /// In pt, this message translates to:
  /// **'Nova rota'**
  String get rotasNovaRota;

  /// No description provided for @rotasNenhumaAinda.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma rota planejada ainda'**
  String get rotasNenhumaAinda;

  /// No description provided for @rotasTocarNovaRota.
  ///
  /// In pt, this message translates to:
  /// **'Toque em \"Nova rota\" para marcar pontos no mapa'**
  String get rotasTocarNovaRota;

  /// No description provided for @rotasPontosEData.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 ponto} other{{n} pontos}} · {data}'**
  String rotasPontosEData(int n, String data);

  /// No description provided for @rotasAnalisarTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Analisar condições da rota'**
  String get rotasAnalisarTooltip;

  /// No description provided for @rotasEditarTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Editar rota'**
  String get rotasEditarTooltip;

  /// No description provided for @rotasApagarTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Apagar rota'**
  String get rotasApagarTooltip;

  /// No description provided for @rotasAnaliseTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Análise: {nome}'**
  String rotasAnaliseTitulo(String nome);

  /// No description provided for @rotasBuscandoCondicoes.
  ///
  /// In pt, this message translates to:
  /// **'Buscando condições ao longo da rota...'**
  String get rotasBuscandoCondicoes;

  /// No description provided for @rotasPontosComCondicaoSevera.
  ///
  /// In pt, this message translates to:
  /// **'{severos} de {total} pontos com condição severa'**
  String rotasPontosComCondicaoSevera(int severos, int total);

  /// No description provided for @rotasNenhumPontoSevero.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ponto com condição severa'**
  String get rotasNenhumPontoSevero;

  /// No description provided for @rotasPontosDistanciaTotal.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 ponto} other{{n} pontos}} · {distancia} mn no total'**
  String rotasPontosDistanciaTotal(int n, String distancia);

  /// No description provided for @rotasTrechoDesdePonto.
  ///
  /// In pt, this message translates to:
  /// **'+{trecho} mn desde o ponto {indice}'**
  String rotasTrechoDesdePonto(String trecho, int indice);

  /// No description provided for @metricaVento.
  ///
  /// In pt, this message translates to:
  /// **'Vento'**
  String get metricaVento;

  /// No description provided for @metricaOnda.
  ///
  /// In pt, this message translates to:
  /// **'Onda'**
  String get metricaOnda;

  /// No description provided for @metricaCorrente.
  ///
  /// In pt, this message translates to:
  /// **'Corrente'**
  String get metricaCorrente;

  /// No description provided for @metricaAgua.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get metricaAgua;

  /// No description provided for @metricaMare.
  ///
  /// In pt, this message translates to:
  /// **'Maré'**
  String get metricaMare;

  /// No description provided for @condicoesMarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Condições do Mar'**
  String get condicoesMarTitulo;

  /// No description provided for @condicoesMarAguardandoPosicao.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando posição atual da embarcação...'**
  String get condicoesMarAguardandoPosicao;

  /// No description provided for @erroBuscarPrevisaoPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao buscar previsão'**
  String get erroBuscarPrevisaoPrefixo;

  /// No description provided for @condicoesPontoTituloFallback.
  ///
  /// In pt, this message translates to:
  /// **'Condições do Ponto'**
  String get condicoesPontoTituloFallback;

  /// No description provided for @posicaoAtualTitulo.
  ///
  /// In pt, this message translates to:
  /// **'📍 Posição Atual'**
  String get posicaoAtualTitulo;

  /// No description provided for @posicaoAtualizarTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar posição'**
  String get posicaoAtualizarTooltip;

  /// No description provided for @posicaoTocarIcone.
  ///
  /// In pt, this message translates to:
  /// **'Toque no ícone para atualizar'**
  String get posicaoTocarIcone;

  /// No description provided for @posicaoTocarBotao.
  ///
  /// In pt, this message translates to:
  /// **'Toque no botão para atualizar'**
  String get posicaoTocarBotao;

  /// No description provided for @posicaoErroLocalizacaoDesativada.
  ///
  /// In pt, this message translates to:
  /// **'❌ Localização está desativada no dispositivo'**
  String get posicaoErroLocalizacaoDesativada;

  /// No description provided for @posicaoErroPermissaoNegadaPermanente.
  ///
  /// In pt, this message translates to:
  /// **'❌ Permissão negada permanentemente.\nVá em Configurações > Apps'**
  String get posicaoErroPermissaoNegadaPermanente;

  /// No description provided for @posicaoErroPermissaoNegada.
  ///
  /// In pt, this message translates to:
  /// **'❌ Permissão de localização negada'**
  String get posicaoErroPermissaoNegada;

  /// No description provided for @posicaoErroTimeout.
  ///
  /// In pt, this message translates to:
  /// **'❌ Tempo esgotado ao obter a posição.\nTente novamente em área aberta.'**
  String get posicaoErroTimeout;

  /// No description provided for @posicaoErroGenerico.
  ///
  /// In pt, this message translates to:
  /// **'❌ Erro: {erro}'**
  String posicaoErroGenerico(String erro);

  /// No description provided for @profundidadeCarregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando profundidade...'**
  String get profundidadeCarregando;

  /// No description provided for @pontoEmTerra.
  ///
  /// In pt, this message translates to:
  /// **'Ponto em terra'**
  String get pontoEmTerra;

  /// No description provided for @sstCarregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando temperatura da água...'**
  String get sstCarregando;

  /// No description provided for @sstSuperficieDoMar.
  ///
  /// In pt, this message translates to:
  /// **'Superfície do mar'**
  String get sstSuperficieDoMar;

  /// No description provided for @mareNivelAgora.
  ///
  /// In pt, this message translates to:
  /// **'{nivel} m agora'**
  String mareNivelAgora(String nivel);

  /// No description provided for @marePreamar.
  ///
  /// In pt, this message translates to:
  /// **'Preamar'**
  String get marePreamar;

  /// No description provided for @mareBaixaMar.
  ///
  /// In pt, this message translates to:
  /// **'Baixa-mar'**
  String get mareBaixaMar;

  /// No description provided for @luaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Lua'**
  String get luaLabel;

  /// No description provided for @luaIluminadaCiclo.
  ///
  /// In pt, this message translates to:
  /// **'{pct}% iluminada · dia {dia} do ciclo'**
  String luaIluminadaCiclo(int pct, int dia);

  /// No description provided for @luaNascer.
  ///
  /// In pt, this message translates to:
  /// **'Nascer'**
  String get luaNascer;

  /// No description provided for @luaPor.
  ///
  /// In pt, this message translates to:
  /// **'Pôr'**
  String get luaPor;

  /// No description provided for @luaProximasFases.
  ///
  /// In pt, this message translates to:
  /// **'PRÓXIMAS FASES'**
  String get luaProximasFases;

  /// No description provided for @luaHoje.
  ///
  /// In pt, this message translates to:
  /// **'hoje'**
  String get luaHoje;

  /// No description provided for @luaEmDias.
  ///
  /// In pt, this message translates to:
  /// **'em {d}d'**
  String luaEmDias(int d);

  /// No description provided for @solunarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Tabela Solunar'**
  String get solunarTitulo;

  /// No description provided for @solunarSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Períodos de maior atividade de alimentação, segundo a posição da lua'**
  String get solunarSubtitulo;

  /// No description provided for @ventoCarregando.
  ///
  /// In pt, this message translates to:
  /// **'Carregando previsão do tempo...'**
  String get ventoCarregando;

  /// No description provided for @ventoClimaAtual.
  ///
  /// In pt, this message translates to:
  /// **'Clima Atual'**
  String get ventoClimaAtual;

  /// No description provided for @ventoVelocidadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'VELOCIDADE DO VENTO'**
  String get ventoVelocidadeTitulo;

  /// No description provided for @ventoDirecao.
  ///
  /// In pt, this message translates to:
  /// **'Direção: {graus}°'**
  String ventoDirecao(int graus);

  /// No description provided for @labelTemperatura.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura'**
  String get labelTemperatura;

  /// No description provided for @labelPressao.
  ///
  /// In pt, this message translates to:
  /// **'Pressão'**
  String get labelPressao;

  /// No description provided for @ventoPrevisaoHoraria.
  ///
  /// In pt, this message translates to:
  /// **'Previsão horária'**
  String get ventoPrevisaoHoraria;

  /// No description provided for @ventoIntensidadeCalmo.
  ///
  /// In pt, this message translates to:
  /// **'Calmo'**
  String get ventoIntensidadeCalmo;

  /// No description provided for @ventoIntensidadeLeve.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get ventoIntensidadeLeve;

  /// No description provided for @ventoIntensidadeModerado.
  ///
  /// In pt, this message translates to:
  /// **'Moderado'**
  String get ventoIntensidadeModerado;

  /// No description provided for @ventoIntensidadeForte.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get ventoIntensidadeForte;

  /// No description provided for @ventoIntensidadeMuitoForte.
  ///
  /// In pt, this message translates to:
  /// **'Muito forte'**
  String get ventoIntensidadeMuitoForte;

  /// No description provided for @ondaCondicoesAtuais.
  ///
  /// In pt, this message translates to:
  /// **'Condições Atuais'**
  String get ondaCondicoesAtuais;

  /// No description provided for @ondaAlturaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'ALTURA DE ONDA'**
  String get ondaAlturaTitulo;

  /// No description provided for @ondaPeriodo.
  ///
  /// In pt, this message translates to:
  /// **'Período {n} s'**
  String ondaPeriodo(String n);

  /// No description provided for @ondaCorrenteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'CORRENTE'**
  String get ondaCorrenteTitulo;

  /// No description provided for @ondaSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados'**
  String get ondaSemDados;

  /// No description provided for @ondaSwellPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Swell'**
  String get ondaSwellPrefixo;

  /// No description provided for @ondaDirecaoOnda.
  ///
  /// In pt, this message translates to:
  /// **'Dir. onda {graus}°'**
  String ondaDirecaoOnda(int graus);

  /// No description provided for @ondaAlturaCalmo.
  ///
  /// In pt, this message translates to:
  /// **'Calmo'**
  String get ondaAlturaCalmo;

  /// No description provided for @ondaAlturaLeve.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get ondaAlturaLeve;

  /// No description provided for @ondaAlturaModerado.
  ///
  /// In pt, this message translates to:
  /// **'Moderado'**
  String get ondaAlturaModerado;

  /// No description provided for @ondaAlturaAgitado.
  ///
  /// In pt, this message translates to:
  /// **'Agitado'**
  String get ondaAlturaAgitado;

  /// No description provided for @ondaAlturaMuitoAgitado.
  ///
  /// In pt, this message translates to:
  /// **'Muito agitado'**
  String get ondaAlturaMuitoAgitado;

  /// No description provided for @ondaAlturaTempestuoso.
  ///
  /// In pt, this message translates to:
  /// **'Tempestuoso'**
  String get ondaAlturaTempestuoso;

  /// No description provided for @meteoSheetPosicaoFallback.
  ///
  /// In pt, this message translates to:
  /// **'Posição'**
  String get meteoSheetPosicaoFallback;

  /// No description provided for @meteoSheetSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados meteorológicos'**
  String get meteoSheetSemDados;

  /// No description provided for @meteoSheetVentoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Vento'**
  String get meteoSheetVentoTitulo;

  /// No description provided for @meteoSheetMovimentoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Movimento'**
  String get meteoSheetMovimentoTitulo;

  /// No description provided for @meteoSheetAtmosferaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Atmosfera'**
  String get meteoSheetAtmosferaTitulo;

  /// No description provided for @meteoSheetOndasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ondas'**
  String get meteoSheetOndasTitulo;

  /// No description provided for @meteoSheetVelocidadeRealTws.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade real (TWS)'**
  String get meteoSheetVelocidadeRealTws;

  /// No description provided for @meteoSheetDirecaoRealTwd.
  ///
  /// In pt, this message translates to:
  /// **'Direção real (TWD)'**
  String get meteoSheetDirecaoRealTwd;

  /// No description provided for @meteoSheetAnguloRealTwa.
  ///
  /// In pt, this message translates to:
  /// **'Ângulo real (TWA)'**
  String get meteoSheetAnguloRealTwa;

  /// No description provided for @meteoSheetVelocidadeAparenteAws.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade aparente (AWS)'**
  String get meteoSheetVelocidadeAparenteAws;

  /// No description provided for @meteoSheetAnguloAparenteAwa.
  ///
  /// In pt, this message translates to:
  /// **'Ângulo aparente (AWA)'**
  String get meteoSheetAnguloAparenteAwa;

  /// No description provided for @meteoSheetRajadas.
  ///
  /// In pt, this message translates to:
  /// **'Rajadas'**
  String get meteoSheetRajadas;

  /// No description provided for @meteoSheetVelocidadeRealSog.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade Real (SOG)'**
  String get meteoSheetVelocidadeRealSog;

  /// No description provided for @meteoSheetDirecaoRealCog.
  ///
  /// In pt, this message translates to:
  /// **'Direção Real (COG)'**
  String get meteoSheetDirecaoRealCog;

  /// No description provided for @meteoSheetVelocidadeAparenteStw.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade Aparente (STW)'**
  String get meteoSheetVelocidadeAparenteStw;

  /// No description provided for @meteoSheetAnguloAparenteCtw.
  ///
  /// In pt, this message translates to:
  /// **'Ângulo Aparente (CTW)'**
  String get meteoSheetAnguloAparenteCtw;

  /// No description provided for @meteoSheetNuvens.
  ///
  /// In pt, this message translates to:
  /// **'Nuvens'**
  String get meteoSheetNuvens;

  /// No description provided for @meteoSheetChuva.
  ///
  /// In pt, this message translates to:
  /// **'Chuva'**
  String get meteoSheetChuva;

  /// No description provided for @meteoSheetAlturaCombinada.
  ///
  /// In pt, this message translates to:
  /// **'Altura combinada'**
  String get meteoSheetAlturaCombinada;

  /// No description provided for @meteoSheetVentoAltura.
  ///
  /// In pt, this message translates to:
  /// **'Vento — altura'**
  String get meteoSheetVentoAltura;

  /// No description provided for @meteoSheetVentoDirecao.
  ///
  /// In pt, this message translates to:
  /// **'Vento — direção'**
  String get meteoSheetVentoDirecao;

  /// No description provided for @meteoSheetVentoPeriodo.
  ///
  /// In pt, this message translates to:
  /// **'Vento — período'**
  String get meteoSheetVentoPeriodo;

  /// No description provided for @meteoSheetSwellAltura.
  ///
  /// In pt, this message translates to:
  /// **'Swell — altura'**
  String get meteoSheetSwellAltura;

  /// No description provided for @meteoSheetSwellDirecao.
  ///
  /// In pt, this message translates to:
  /// **'Swell — direção'**
  String get meteoSheetSwellDirecao;

  /// No description provided for @meteoSheetSwellPeriodo.
  ///
  /// In pt, this message translates to:
  /// **'Swell — período'**
  String get meteoSheetSwellPeriodo;

  /// No description provided for @alertaConfigTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Configurar Alertas'**
  String get alertaConfigTitulo;

  /// No description provided for @alertaConfigDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a partir de que ponto cada condição no caminho da embarcação dispara uma notificação (com vibração). Vale tanto pra checagem manual em \"Alerta de Rota\" quanto pro rastreamento em segundo plano durante uma viagem.'**
  String get alertaConfigDescricao;

  /// No description provided for @alertaConfigVentoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Vento'**
  String get alertaConfigVentoTitulo;

  /// No description provided for @alertaConfigVentoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Alerta quando o vento à frente passar de'**
  String get alertaConfigVentoSubtitulo;

  /// No description provided for @alertaConfigOndaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Altura de onda e swell'**
  String get alertaConfigOndaTitulo;

  /// No description provided for @alertaConfigOndaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Alerta quando onda ou swell passarem de'**
  String get alertaConfigOndaSubtitulo;

  /// No description provided for @alertaConfigCorrenteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Corrente de maré'**
  String get alertaConfigCorrenteTitulo;

  /// No description provided for @alertaConfigCorrenteSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Alerta quando a corrente passar de'**
  String get alertaConfigCorrenteSubtitulo;

  /// No description provided for @alertaConfigTemperaturaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura da água'**
  String get alertaConfigTemperaturaTitulo;

  /// No description provided for @alertaConfigTemperaturaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Alerta quando a temperatura passar de'**
  String get alertaConfigTemperaturaSubtitulo;

  /// No description provided for @alertaRotaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Alerta de Rota'**
  String get alertaRotaTitulo;

  /// No description provided for @alertaRotaTooltipConfigurar.
  ///
  /// In pt, this message translates to:
  /// **'Configurar alertas'**
  String get alertaRotaTooltipConfigurar;

  /// No description provided for @alertaRotaTooltipSimular.
  ///
  /// In pt, this message translates to:
  /// **'Simular com ponto marcado'**
  String get alertaRotaTooltipSimular;

  /// No description provided for @alertaRotaErroPosicaoPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao obter posição: {erro}'**
  String alertaRotaErroPosicaoPrefixo(String erro);

  /// No description provided for @alertaRotaNenhumPontoMarcado.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ponto marcado ainda'**
  String get alertaRotaNenhumPontoMarcado;

  /// No description provided for @alertaRotaSimularDialogTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Simular a partir de qual ponto?'**
  String get alertaRotaSimularDialogTitulo;

  /// No description provided for @alertaRotaRumoSimuladoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Rumo simulado'**
  String get alertaRotaRumoSimuladoTitulo;

  /// No description provided for @alertaRotaBotaoSimular.
  ///
  /// In pt, this message translates to:
  /// **'Simular'**
  String get alertaRotaBotaoSimular;

  /// No description provided for @alertaRotaVentoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Vento à frente'**
  String get alertaRotaVentoTitulo;

  /// No description provided for @alertaRotaCorrenteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Corrente à frente'**
  String get alertaRotaCorrenteTitulo;

  /// No description provided for @alertaRotaOndaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Onda à frente'**
  String get alertaRotaOndaTitulo;

  /// No description provided for @alertaRotaSwellTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Swell à frente'**
  String get alertaRotaSwellTitulo;

  /// No description provided for @alertaRotaBussolaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Bússola'**
  String get alertaRotaBussolaTitulo;

  /// No description provided for @alertaRotaSemSinal.
  ///
  /// In pt, this message translates to:
  /// **'Sem sinal'**
  String get alertaRotaSemSinal;

  /// No description provided for @alertaRotaAlcanceTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Alcance do alerta'**
  String get alertaRotaAlcanceTitulo;

  /// No description provided for @alertaRotaAlcanceDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Distância à frente da embarcação, no rumo atual, onde as condições são checadas.'**
  String get alertaRotaAlcanceDescricao;

  /// No description provided for @alertaRotaRumoEAlcance.
  ///
  /// In pt, this message translates to:
  /// **'Rumo {rumo}° · {alcance} mn à frente'**
  String alertaRotaRumoEAlcance(String rumo, String alcance);

  /// No description provided for @alertaRotaSemRumoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Rumo indisponível — a embarcação precisa estar em movimento para o GPS calcular um rumo válido.'**
  String get alertaRotaSemRumoDescricao;

  /// No description provided for @alertaRotaSimulacaoAtiva.
  ///
  /// In pt, this message translates to:
  /// **'Simulação ativa — usando \"{nome}\" com rumo {rumo}° (não é o GPS real)'**
  String alertaRotaSimulacaoAtiva(String nome, String rumo);

  /// No description provided for @alertaRotaCorrenteFraca.
  ///
  /// In pt, this message translates to:
  /// **'Fraca'**
  String get alertaRotaCorrenteFraca;

  /// No description provided for @alertaRotaCorrenteModerada.
  ///
  /// In pt, this message translates to:
  /// **'Moderada'**
  String get alertaRotaCorrenteModerada;

  /// No description provided for @alertaRotaCorrenteForte.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get alertaRotaCorrenteForte;

  /// No description provided for @alertaRotaCorrenteMuitoForte.
  ///
  /// In pt, this message translates to:
  /// **'Muito forte'**
  String get alertaRotaCorrenteMuitoForte;

  /// No description provided for @alertaRotaCorrenteExtrema.
  ///
  /// In pt, this message translates to:
  /// **'Extrema'**
  String get alertaRotaCorrenteExtrema;

  /// No description provided for @diaSemanaSegunda.
  ///
  /// In pt, this message translates to:
  /// **'Segunda-feira'**
  String get diaSemanaSegunda;

  /// No description provided for @diaSemanaTerca.
  ///
  /// In pt, this message translates to:
  /// **'Terça-feira'**
  String get diaSemanaTerca;

  /// No description provided for @diaSemanaQuarta.
  ///
  /// In pt, this message translates to:
  /// **'Quarta-feira'**
  String get diaSemanaQuarta;

  /// No description provided for @diaSemanaQuinta.
  ///
  /// In pt, this message translates to:
  /// **'Quinta-feira'**
  String get diaSemanaQuinta;

  /// No description provided for @diaSemanaSexta.
  ///
  /// In pt, this message translates to:
  /// **'Sexta-feira'**
  String get diaSemanaSexta;

  /// No description provided for @diaSemanaSabado.
  ///
  /// In pt, this message translates to:
  /// **'Sábado'**
  String get diaSemanaSabado;

  /// No description provided for @diaSemanaDomingo.
  ///
  /// In pt, this message translates to:
  /// **'Domingo'**
  String get diaSemanaDomingo;

  /// No description provided for @faseLuaScreenTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Fase da Lua'**
  String get faseLuaScreenTitulo;

  /// No description provided for @faseLuaErroBuscarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao buscar nascer/pôr da lua'**
  String get faseLuaErroBuscarPrefixo;

  /// No description provided for @faseLuaAguardandoPosicao.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando posição atual da embarcação para os horários de nascer/pôr da lua — a fase acima não depende disso.'**
  String get faseLuaAguardandoPosicao;

  /// No description provided for @faseLuaNascerEPorTitulo.
  ///
  /// In pt, this message translates to:
  /// **'NASCER E PÔR DA LUA'**
  String get faseLuaNascerEPorTitulo;

  /// No description provided for @faseLuaHojeData.
  ///
  /// In pt, this message translates to:
  /// **'Hoje, {data}'**
  String faseLuaHojeData(String data);

  /// No description provided for @erroSincronizarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao sincronizar'**
  String get erroSincronizarPrefixo;

  /// No description provided for @tabuaMareTooltipRemoverPorto.
  ///
  /// In pt, this message translates to:
  /// **'Remover porto'**
  String get tabuaMareTooltipRemoverPorto;

  /// No description provided for @tabuaMareRemoverPortoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Remover porto?'**
  String get tabuaMareRemoverPortoTitulo;

  /// No description provided for @tabuaMareRemoverPortoConteudo.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" será removido da lista.'**
  String tabuaMareRemoverPortoConteudo(String nome);

  /// No description provided for @tabuaMareSincronizando.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizando...'**
  String get tabuaMareSincronizando;

  /// No description provided for @tabuaMareSincronizarDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizar de novo'**
  String get tabuaMareSincronizarDeNovo;

  /// No description provided for @tabuaMareSincronizadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Sincronizado em {data} · disponível offline'**
  String tabuaMareSincronizadoEm(String data);

  /// No description provided for @tabuaMareAindaNaoSincronizado.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não sincronizado — precisa de internet na 1ª vez'**
  String get tabuaMareAindaNaoSincronizado;

  /// No description provided for @tabuaMareSincronizePrimeiraVez.
  ///
  /// In pt, this message translates to:
  /// **'Sincronize pelo menos uma vez, com internet, pra calcular a tábua de maré offline deste porto.'**
  String get tabuaMareSincronizePrimeiraVez;

  /// No description provided for @tabuaMareNivelAgoraTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nível agora'**
  String get tabuaMareNivelAgoraTitulo;

  /// No description provided for @tabuaMareTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Tábua de Maré'**
  String get tabuaMareTitulo;

  /// No description provided for @tabuaMareBotaoPorto.
  ///
  /// In pt, this message translates to:
  /// **'Porto'**
  String get tabuaMareBotaoPorto;

  /// No description provided for @tabuaMareErroCarregarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar portos: {erro}'**
  String tabuaMareErroCarregarPrefixo(String erro);

  /// No description provided for @tabuaMareErroSincronizarNome.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao sincronizar \"{nome}\"'**
  String tabuaMareErroSincronizarNome(String nome);

  /// No description provided for @tabuaMareNovoPortoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Novo porto'**
  String get tabuaMareNovoPortoTitulo;

  /// No description provided for @tabuaMareNomeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get tabuaMareNomeLabel;

  /// No description provided for @tabuaMareNomeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Porto de Itarema'**
  String get tabuaMareNomeHint;

  /// No description provided for @tabuaMarePreencherNome.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o nome do porto'**
  String get tabuaMarePreencherNome;

  /// No description provided for @tabuaMareNenhumPortoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum porto salvo ainda'**
  String get tabuaMareNenhumPortoTitulo;

  /// No description provided for @tabuaMareNenhumPortoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Salve a coordenada de um porto (ex: Itarema, Acaraú, Camocim) pra consultar a maré prevista, mesmo offline depois de sincronizado.'**
  String get tabuaMareNenhumPortoDescricao;

  /// No description provided for @tabuaMarePoucosDados.
  ///
  /// In pt, this message translates to:
  /// **'Poucos dados de maré retornados pra esse ponto'**
  String get tabuaMarePoucosDados;

  /// No description provided for @mareEPescaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Maré e Pesca'**
  String get mareEPescaTitulo;

  /// No description provided for @mareEPescaErroBuscarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao buscar previsão de maré'**
  String get mareEPescaErroBuscarPrefixo;

  /// No description provided for @mareEPescaAguardandoPosicao.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando posição atual da embarcação...'**
  String get mareEPescaAguardandoPosicao;

  /// No description provided for @mareEPescaCabecalhoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Influência da Maré na Pesca de Atum'**
  String get mareEPescaCabecalhoTitulo;

  /// No description provided for @mareEPescaCabecalhoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Entenda como a amplitude das marés pode alterar correntes, mistura da água e condições de alimentação dos atuns.'**
  String get mareEPescaCabecalhoDescricao;

  /// No description provided for @mareEPescaCondicaoAtual.
  ///
  /// In pt, this message translates to:
  /// **'Condição atual da maré: {tipo}'**
  String mareEPescaCondicaoAtual(String tipo);

  /// No description provided for @mareEPescaGrafico24hTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Maré nas próximas 24h'**
  String get mareEPescaGrafico24hTitulo;

  /// No description provided for @mareEPescaEntendaSizigia.
  ///
  /// In pt, this message translates to:
  /// **'Entenda a sizígia'**
  String get mareEPescaEntendaSizigia;

  /// No description provided for @mareEPescaEntendaQuadratura.
  ///
  /// In pt, this message translates to:
  /// **'Entenda a quadratura'**
  String get mareEPescaEntendaQuadratura;

  /// No description provided for @mareEPescaImportante.
  ///
  /// In pt, this message translates to:
  /// **'Importante'**
  String get mareEPescaImportante;

  /// No description provided for @mareEPescaAvisoPrincipal.
  ///
  /// In pt, this message translates to:
  /// **'A fase da maré não deve ser utilizada isoladamente para determinar uma área de pesca. A resposta do ambiente varia conforme localização, profundidade, topografia, regime de correntes, temperatura, disponibilidade de alimento, vento e outros fatores oceanográficos.'**
  String get mareEPescaAvisoPrincipal;

  /// No description provided for @mareEPescaAvisoSecundario.
  ///
  /// In pt, this message translates to:
  /// **'Utilize a maré como um dos indicadores dentro de uma análise integrada.'**
  String get mareEPescaAvisoSecundario;

  /// No description provided for @producaoHistoricoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de Produção'**
  String get producaoHistoricoTitulo;

  /// No description provided for @producaoHistoricoTooltipPorPonto.
  ///
  /// In pt, this message translates to:
  /// **'Produção por ponto'**
  String get producaoHistoricoTooltipPorPonto;

  /// No description provided for @producaoHistoricoTooltipVerMapa.
  ///
  /// In pt, this message translates to:
  /// **'Ver no mapa'**
  String get producaoHistoricoTooltipVerMapa;

  /// No description provided for @producaoHistoricoTooltipExportarCsv.
  ///
  /// In pt, this message translates to:
  /// **'Exportar como CSV'**
  String get producaoHistoricoTooltipExportarCsv;

  /// No description provided for @producaoHistoricoErroCarregarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar produção: {erro}'**
  String producaoHistoricoErroCarregarPrefixo(String erro);

  /// No description provided for @producaoHistoricoErroExportarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao exportar: {erro}'**
  String producaoHistoricoErroExportarPrefixo(String erro);

  /// No description provided for @producaoHistoricoCsvCabecalho.
  ///
  /// In pt, this message translates to:
  /// **'Data/Hora,Espécie,Classificação,Quantidade (un.),Quantidade (kg),Latitude,Longitude,Observação'**
  String get producaoHistoricoCsvCabecalho;

  /// No description provided for @producaoHistoricoCompartilharTexto.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de produção — {kg} kg'**
  String producaoHistoricoCompartilharTexto(String kg);

  /// No description provided for @producaoHistoricoNenhumRegistro.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro de produção ainda'**
  String get producaoHistoricoNenhumRegistro;

  /// No description provided for @producaoHistoricoTotalResumo.
  ///
  /// In pt, this message translates to:
  /// **'Total: {kg} kg em {n} registro(s)'**
  String producaoHistoricoTotalResumo(String kg, int n);

  /// No description provided for @producaoHistoricoClassificacaoEUnidades.
  ///
  /// In pt, this message translates to:
  /// **'Classificação {classificacao} kg · {unidades} un.'**
  String producaoHistoricoClassificacaoEUnidades(
      String classificacao, int unidades);

  /// No description provided for @producaoPorPontoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Produção por Ponto'**
  String get producaoPorPontoTitulo;

  /// No description provided for @producaoPorPontoErroCarregarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar: {erro}'**
  String producaoPorPontoErroCarregarPrefixo(String erro);

  /// No description provided for @producaoPorPontoVazioTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma produção associada a um ponto marcado ainda'**
  String get producaoPorPontoVazioTitulo;

  /// No description provided for @producaoPorPontoVazioDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Registre capturas com coordenada e marque pontos no mapa para ver aqui os pontos mais produtivos'**
  String get producaoPorPontoVazioDescricao;

  /// No description provided for @producaoPorPontoTotalRegistros.
  ///
  /// In pt, this message translates to:
  /// **'{n} registro(s)'**
  String producaoPorPontoTotalRegistros(int n);

  /// No description provided for @producaoPorPontoEspecieDestaque.
  ///
  /// In pt, this message translates to:
  /// **' · {especie} em destaque'**
  String producaoPorPontoEspecieDestaque(String especie);

  /// No description provided for @meusPontosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Meus Pontos'**
  String get meusPontosTitulo;

  /// No description provided for @meusPontosNenhumTituloERecomendacao.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ponto marcado nem recomendação ainda'**
  String get meusPontosNenhumTituloERecomendacao;

  /// No description provided for @meusPontosSecaoPontosMarcados.
  ///
  /// In pt, this message translates to:
  /// **'PONTOS MARCADOS'**
  String get meusPontosSecaoPontosMarcados;

  /// No description provided for @meusPontosSecaoRecomendacoes.
  ///
  /// In pt, this message translates to:
  /// **'RECOMENDAÇÕES'**
  String get meusPontosSecaoRecomendacoes;

  /// No description provided for @meusPontosDataDesconhecida.
  ///
  /// In pt, this message translates to:
  /// **'data desconhecida'**
  String get meusPontosDataDesconhecida;

  /// No description provided for @meusPontosBannerOffline.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão — mostrando as últimas recomendações sincronizadas em {horario}'**
  String meusPontosBannerOffline(String horario);

  /// No description provided for @meusPontosMarcadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Marcado em'**
  String get meusPontosMarcadoEm;

  /// No description provided for @meusPontosProducaoAqui.
  ///
  /// In pt, this message translates to:
  /// **'Produção aqui'**
  String get meusPontosProducaoAqui;

  /// No description provided for @meusPontosProducaoAquiValor.
  ///
  /// In pt, this message translates to:
  /// **'{kg} kg ({n} registro(s))'**
  String meusPontosProducaoAquiValor(String kg, int n);

  /// No description provided for @meusPontosConsultarAqui.
  ///
  /// In pt, this message translates to:
  /// **'Consultar aqui'**
  String get meusPontosConsultarAqui;

  /// No description provided for @meusPontosMareEPescaAqui.
  ///
  /// In pt, this message translates to:
  /// **'Maré e Pesca aqui'**
  String get meusPontosMareEPescaAqui;

  /// No description provided for @mapaScreenTituloFallback.
  ///
  /// In pt, this message translates to:
  /// **'Mapa'**
  String get mapaScreenTituloFallback;

  /// No description provided for @mapaRotaProducao.
  ///
  /// In pt, this message translates to:
  /// **'Rota de Produção'**
  String get mapaRotaProducao;

  /// No description provided for @mapaSstLabel.
  ///
  /// In pt, this message translates to:
  /// **'SST'**
  String get mapaSstLabel;

  /// No description provided for @recomendacaoSemTitulo.
  ///
  /// In pt, this message translates to:
  /// **'(sem título)'**
  String get recomendacaoSemTitulo;

  /// No description provided for @recomendacaoNenhumaDisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma recomendação disponível'**
  String get recomendacaoNenhumaDisponivel;

  /// No description provided for @recomendacaoExpirada.
  ///
  /// In pt, this message translates to:
  /// **'Expirada'**
  String get recomendacaoExpirada;

  /// No description provided for @recomendacaoValidaAte.
  ///
  /// In pt, this message translates to:
  /// **'Válida até {data}'**
  String recomendacaoValidaAte(String data);

  /// No description provided for @recomendacaoVarPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Var. {variavel}: {valor}'**
  String recomendacaoVarPrefixo(String variavel, String valor);

  /// No description provided for @recomendacaoPontosAbrev.
  ///
  /// In pt, this message translates to:
  /// **'{n} pts'**
  String recomendacaoPontosAbrev(int n);

  /// No description provided for @recomendacaoVerNaCarta.
  ///
  /// In pt, this message translates to:
  /// **'Ver na Carta'**
  String get recomendacaoVerNaCarta;

  /// No description provided for @recomendacaoKgEstimados.
  ///
  /// In pt, this message translates to:
  /// **'{kg} kg estimados'**
  String recomendacaoKgEstimados(String kg);

  /// No description provided for @recomendacaoPontosAmostrados.
  ///
  /// In pt, this message translates to:
  /// **'{n} pontos amostrados'**
  String recomendacaoPontosAmostrados(int n);

  /// No description provided for @faseLuaTipoNovaLua.
  ///
  /// In pt, this message translates to:
  /// **'Lua Nova'**
  String get faseLuaTipoNovaLua;

  /// No description provided for @faseLuaTipoCrescente.
  ///
  /// In pt, this message translates to:
  /// **'Lua Crescente'**
  String get faseLuaTipoCrescente;

  /// No description provided for @faseLuaTipoQuartoCrescente.
  ///
  /// In pt, this message translates to:
  /// **'Quarto Crescente'**
  String get faseLuaTipoQuartoCrescente;

  /// No description provided for @faseLuaTipoGibosaCrescente.
  ///
  /// In pt, this message translates to:
  /// **'Gibosa Crescente'**
  String get faseLuaTipoGibosaCrescente;

  /// No description provided for @faseLuaTipoCheia.
  ///
  /// In pt, this message translates to:
  /// **'Lua Cheia'**
  String get faseLuaTipoCheia;

  /// No description provided for @faseLuaTipoGibosaMinguante.
  ///
  /// In pt, this message translates to:
  /// **'Gibosa Minguante'**
  String get faseLuaTipoGibosaMinguante;

  /// No description provided for @faseLuaTipoQuartoMinguante.
  ///
  /// In pt, this message translates to:
  /// **'Quarto Minguante'**
  String get faseLuaTipoQuartoMinguante;

  /// No description provided for @faseLuaTipoMinguante.
  ///
  /// In pt, this message translates to:
  /// **'Lua Minguante'**
  String get faseLuaTipoMinguante;

  /// No description provided for @tipoMareSizigiaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sizígia'**
  String get tipoMareSizigiaLabel;

  /// No description provided for @tipoMareSizigiaNota.
  ///
  /// In pt, this message translates to:
  /// **'Correntes mais fortes, maior amplitude de maré.'**
  String get tipoMareSizigiaNota;

  /// No description provided for @tipoMareQuadraturaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quadratura'**
  String get tipoMareQuadraturaLabel;

  /// No description provided for @tipoMareQuadraturaNota.
  ///
  /// In pt, this message translates to:
  /// **'Correntes mais fracas, menor amplitude de maré.'**
  String get tipoMareQuadraturaNota;

  /// No description provided for @tipoMareTransicaoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Transição'**
  String get tipoMareTransicaoLabel;

  /// No description provided for @tipoMareTransicaoNota.
  ///
  /// In pt, this message translates to:
  /// **'Nem sizígia nem quadratura — período de meio de caminho.'**
  String get tipoMareTransicaoNota;

  /// No description provided for @tendenciaPressaoCaindo.
  ///
  /// In pt, this message translates to:
  /// **'Caindo'**
  String get tendenciaPressaoCaindo;

  /// No description provided for @tendenciaPressaoEstavel.
  ///
  /// In pt, this message translates to:
  /// **'Estável'**
  String get tendenciaPressaoEstavel;

  /// No description provided for @tendenciaPressaoSubindo.
  ///
  /// In pt, this message translates to:
  /// **'Subindo'**
  String get tendenciaPressaoSubindo;

  /// No description provided for @tipoPeriodoSolunarMaior.
  ///
  /// In pt, this message translates to:
  /// **'Período Maior'**
  String get tipoPeriodoSolunarMaior;

  /// No description provided for @tipoPeriodoSolunarMenor.
  ///
  /// In pt, this message translates to:
  /// **'Período Menor'**
  String get tipoPeriodoSolunarMenor;

  /// No description provided for @variavelAmbientalVento.
  ///
  /// In pt, this message translates to:
  /// **'Vento'**
  String get variavelAmbientalVento;

  /// No description provided for @variavelAmbientalCorrente.
  ///
  /// In pt, this message translates to:
  /// **'Corrente'**
  String get variavelAmbientalCorrente;

  /// No description provided for @variavelAmbientalClorofila.
  ///
  /// In pt, this message translates to:
  /// **'Clorofila'**
  String get variavelAmbientalClorofila;

  /// No description provided for @variavelAmbientalOnda.
  ///
  /// In pt, this message translates to:
  /// **'Onda'**
  String get variavelAmbientalOnda;

  /// No description provided for @variavelAmbientalTemperatura.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura'**
  String get variavelAmbientalTemperatura;

  /// No description provided for @nivelOperacionalFavoravelTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Condição potencialmente favorável'**
  String get nivelOperacionalFavoravelTitulo;

  /// No description provided for @nivelOperacionalFavoravelTexto.
  ///
  /// In pt, this message translates to:
  /// **'Quando vários indicadores oceanográficos convergem, a influência da maré pode reforçar uma condição já favorável.'**
  String get nivelOperacionalFavoravelTexto;

  /// No description provided for @nivelOperacionalAtencaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Condição de atenção'**
  String get nivelOperacionalAtencaoTitulo;

  /// No description provided for @nivelOperacionalAtencaoTexto.
  ///
  /// In pt, this message translates to:
  /// **'A maré isoladamente não é suficiente para indicar uma boa área de pesca.'**
  String get nivelOperacionalAtencaoTexto;

  /// No description provided for @nivelOperacionalBaixaEvidenciaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Baixa evidência'**
  String get nivelOperacionalBaixaEvidenciaTitulo;

  /// No description provided for @nivelOperacionalBaixaEvidenciaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Não utilizar a fase da maré como único motivo para deslocar a embarcação.'**
  String get nivelOperacionalBaixaEvidenciaTexto;

  /// No description provided for @nivelOperacionalCardTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Classificação Atual'**
  String get nivelOperacionalCardTitulo;

  /// No description provided for @nivelOperacionalCardDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Classificação a partir dos indicadores que o app tem hoje (maré astronômica + corrente medida) — não é previsão de captura.'**
  String get nivelOperacionalCardDescricao;

  /// No description provided for @nivelOperacionalAgora.
  ///
  /// In pt, this message translates to:
  /// **'AGORA'**
  String get nivelOperacionalAgora;

  /// No description provided for @estadoMareTitulo.
  ///
  /// In pt, this message translates to:
  /// **'ESTADO ATUAL'**
  String get estadoMareTitulo;

  /// No description provided for @estadoMareTituloMare.
  ///
  /// In pt, this message translates to:
  /// **'MARÉ DE {tipo}'**
  String estadoMareTituloMare(String tipo);

  /// No description provided for @estadoMareFaseDaLua.
  ///
  /// In pt, this message translates to:
  /// **'FASE DA LUA'**
  String get estadoMareFaseDaLua;

  /// No description provided for @estadoMareDiaDoCiclo.
  ///
  /// In pt, this message translates to:
  /// **'dia {n} do ciclo'**
  String estadoMareDiaDoCiclo(int n);

  /// No description provided for @estadoMareAmplitudePrevista.
  ///
  /// In pt, this message translates to:
  /// **'AMPLITUDE PREVISTA (24H)'**
  String get estadoMareAmplitudePrevista;

  /// No description provided for @estadoMareProximaPreamar.
  ///
  /// In pt, this message translates to:
  /// **'PRÓXIMA PREAMAR'**
  String get estadoMareProximaPreamar;

  /// No description provided for @estadoMareProximaBaixaMar.
  ///
  /// In pt, this message translates to:
  /// **'PRÓXIMA BAIXA-MAR'**
  String get estadoMareProximaBaixaMar;

  /// No description provided for @estadoMareDadoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Dado indisponível'**
  String get estadoMareDadoIndisponivel;

  /// No description provided for @estadoMareQuadratura.
  ///
  /// In pt, this message translates to:
  /// **'QUADRATURA'**
  String get estadoMareQuadratura;

  /// No description provided for @estadoMareSizigia.
  ///
  /// In pt, this message translates to:
  /// **'SIZÍGIA'**
  String get estadoMareSizigia;

  /// No description provided for @classificacaoIndiceBaixa.
  ///
  /// In pt, this message translates to:
  /// **'Baixo'**
  String get classificacaoIndiceBaixa;

  /// No description provided for @classificacaoIndiceModerada.
  ///
  /// In pt, this message translates to:
  /// **'Moderado'**
  String get classificacaoIndiceModerada;

  /// No description provided for @classificacaoIndiceAlta.
  ///
  /// In pt, this message translates to:
  /// **'Alto'**
  String get classificacaoIndiceAlta;

  /// No description provided for @indiceFatorFaseLunarNome.
  ///
  /// In pt, this message translates to:
  /// **'Fase lunar (proximidade da sizígia)'**
  String get indiceFatorFaseLunarNome;

  /// No description provided for @indiceFatorAmplitudeNome.
  ///
  /// In pt, this message translates to:
  /// **'Amplitude de maré prevista'**
  String get indiceFatorAmplitudeNome;

  /// No description provided for @indiceFatorCorrenteNome.
  ///
  /// In pt, this message translates to:
  /// **'Velocidade da corrente'**
  String get indiceFatorCorrenteNome;

  /// No description provided for @indiceFatorFaseLunarDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'{fase} · dia {dia} do ciclo'**
  String indiceFatorFaseLunarDetalhe(String fase, int dia);

  /// No description provided for @indiceFatorAmplitudeDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'{m} m nas próximas 24h'**
  String indiceFatorAmplitudeDetalhe(String m);

  /// No description provided for @indiceFatorCorrenteDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'{ms} m/s agora'**
  String indiceFatorCorrenteDetalhe(String ms);

  /// No description provided for @indiceInformativoDirecaoCorrente.
  ///
  /// In pt, this message translates to:
  /// **'Direção da corrente'**
  String get indiceInformativoDirecaoCorrente;

  /// No description provided for @indiceInformativoDiferencaTemperatura.
  ///
  /// In pt, this message translates to:
  /// **'Diferença de temperatura'**
  String get indiceInformativoDiferencaTemperatura;

  /// No description provided for @indiceInformativoProximidadeFrentes.
  ///
  /// In pt, this message translates to:
  /// **'Proximidade de frentes térmicas'**
  String get indiceInformativoProximidadeFrentes;

  /// No description provided for @indiceCardTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Potencial de Influência'**
  String get indiceCardTitulo;

  /// No description provided for @indiceCardDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Quanto as condições de maré podem estar contribuindo para a dinâmica oceanográfica da região — não é chance de pegar atum.'**
  String get indiceCardDescricao;

  /// No description provided for @indiceCardPotencialPrefixo.
  ///
  /// In pt, this message translates to:
  /// **'Potencial {classificacao}'**
  String indiceCardPotencialPrefixo(String classificacao);

  /// No description provided for @indiceCardFatoresConsiderados.
  ///
  /// In pt, this message translates to:
  /// **'FATORES CONSIDERADOS'**
  String get indiceCardFatoresConsiderados;

  /// No description provided for @indiceCardInformativos.
  ///
  /// In pt, this message translates to:
  /// **'INFORMATIVOS (NÃO ENTRAM NA PONTUAÇÃO)'**
  String get indiceCardInformativos;

  /// No description provided for @comparacaoSizigiaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Maré de Sizígia'**
  String get comparacaoSizigiaTitulo;

  /// No description provided for @comparacaoSizigiaResumo.
  ///
  /// In pt, this message translates to:
  /// **'Maior amplitude de maré'**
  String get comparacaoSizigiaResumo;

  /// No description provided for @comparacaoSizigiaEfeito1.
  ///
  /// In pt, this message translates to:
  /// **'Maior variação do nível do mar'**
  String get comparacaoSizigiaEfeito1;

  /// No description provided for @comparacaoSizigiaEfeito2.
  ///
  /// In pt, this message translates to:
  /// **'Correntes de maré potencialmente mais intensas em determinadas regiões'**
  String get comparacaoSizigiaEfeito2;

  /// No description provided for @comparacaoSizigiaEfeito3.
  ///
  /// In pt, this message translates to:
  /// **'Maior transporte horizontal de água'**
  String get comparacaoSizigiaEfeito3;

  /// No description provided for @comparacaoSizigiaEfeito4.
  ///
  /// In pt, this message translates to:
  /// **'Maior mistura em ambientes onde a maré exerce forte influência'**
  String get comparacaoSizigiaEfeito4;

  /// No description provided for @comparacaoSizigiaEfeito5.
  ///
  /// In pt, this message translates to:
  /// **'Alteração na distribuição/concentração de organismos que servem de alimento aos peixes'**
  String get comparacaoSizigiaEfeito5;

  /// No description provided for @comparacaoSizigiaRelacaoPesca.
  ///
  /// In pt, this message translates to:
  /// **'Em áreas onde as correntes de maré possuem influência significativa, períodos de maior amplitude podem aumentar a movimentação e a mistura da água, podendo alterar a distribuição de presas e criar condições favoráveis à atividade dos atuns.'**
  String get comparacaoSizigiaRelacaoPesca;

  /// No description provided for @comparacaoSizigiaPotencial.
  ///
  /// In pt, this message translates to:
  /// **'ALTO'**
  String get comparacaoSizigiaPotencial;

  /// No description provided for @comparacaoQuadraturaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Maré de Quadratura'**
  String get comparacaoQuadraturaTitulo;

  /// No description provided for @comparacaoQuadraturaResumo.
  ///
  /// In pt, this message translates to:
  /// **'Menor amplitude de maré'**
  String get comparacaoQuadraturaResumo;

  /// No description provided for @comparacaoQuadraturaEfeito1.
  ///
  /// In pt, this message translates to:
  /// **'Correntes de maré potencialmente menos intensas'**
  String get comparacaoQuadraturaEfeito1;

  /// No description provided for @comparacaoQuadraturaEfeito2.
  ///
  /// In pt, this message translates to:
  /// **'Menor variação do nível da água'**
  String get comparacaoQuadraturaEfeito2;

  /// No description provided for @comparacaoQuadraturaEfeito3.
  ///
  /// In pt, this message translates to:
  /// **'Menor influência da maré sobre a mistura em determinadas regiões'**
  String get comparacaoQuadraturaEfeito3;

  /// No description provided for @comparacaoQuadraturaEfeito4.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição diferente de organismos e presas'**
  String get comparacaoQuadraturaEfeito4;

  /// No description provided for @comparacaoQuadraturaRelacaoPesca.
  ///
  /// In pt, this message translates to:
  /// **'Durante a quadratura, a menor amplitude da maré pode resultar em menor influência das correntes de maré em determinadas áreas. Entretanto, isso não significa necessariamente menor atividade de atum, pois temperatura, frentes oceânicas, alimento, profundidade e outros fatores podem ser mais importantes.'**
  String get comparacaoQuadraturaRelacaoPesca;

  /// No description provided for @comparacaoQuadraturaPotencial.
  ///
  /// In pt, this message translates to:
  /// **'MODERADO'**
  String get comparacaoQuadraturaPotencial;

  /// No description provided for @comparacaoRelacaoPescaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'RELAÇÃO COM A PESCA DE ATUM'**
  String get comparacaoRelacaoPescaTitulo;

  /// No description provided for @comparacaoPotencialInfluencia.
  ///
  /// In pt, this message translates to:
  /// **'Potencial de influência: {potencial}'**
  String comparacaoPotencialInfluencia(String potencial);

  /// No description provided for @comparacaoRodape.
  ///
  /// In pt, this message translates to:
  /// **'Representa a força potencial da influência da maré, não uma previsão direta de captura.'**
  String get comparacaoRodape;

  /// No description provided for @graficoMareSemDado.
  ///
  /// In pt, this message translates to:
  /// **'Dado indisponível para o gráfico de 24h'**
  String get graficoMareSemDado;

  /// No description provided for @graficoMareCorrenteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Corrente'**
  String get graficoMareCorrenteLabel;

  /// No description provided for @graficoMareAgoraLabel.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get graficoMareAgoraLabel;

  /// No description provided for @janelaOperacionalTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Janela operacional'**
  String get janelaOperacionalTitulo;

  /// No description provided for @janelaOperacionalDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Próximas horas — maré, corrente e temperatura reais de cada horário.'**
  String get janelaOperacionalDescricao;

  /// No description provided for @janelaObsSemDado.
  ///
  /// In pt, this message translates to:
  /// **'Sem dado de maré suficiente para esse horário.'**
  String get janelaObsSemDado;

  /// No description provided for @janelaObsEstofa.
  ///
  /// In pt, this message translates to:
  /// **'Período de estofa (maré parada). Corrente de maré tende a ficar fraca nesse horário.'**
  String get janelaObsEstofa;

  /// No description provided for @janelaObsEnchente.
  ///
  /// In pt, this message translates to:
  /// **'Período de enchente. Observar regiões de convergência e concentração de presas.'**
  String get janelaObsEnchente;

  /// No description provided for @janelaObsVazante.
  ///
  /// In pt, this message translates to:
  /// **'Período de vazante. Observar bordas de banco e canais onde a correnteza pode concentrar alimento.'**
  String get janelaObsVazante;

  /// No description provided for @explicacaoSizigiaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Na Lua Nova e na Lua Cheia, as forças gravitacionais do Sol e da Lua se combinam, aumentando a amplitude das marés.'**
  String get explicacaoSizigiaTexto;

  /// No description provided for @explicacaoQuadraturaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Nos quartos crescente e minguante, Sol e Lua exercem suas forças gravitacionais em direções aproximadamente perpendiculares, resultando em menor amplitude das marés.'**
  String get explicacaoQuadraturaTexto;

  /// No description provided for @explicacaoEntendiBotao.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get explicacaoEntendiBotao;

  /// No description provided for @explicacaoSol.
  ///
  /// In pt, this message translates to:
  /// **'Sol'**
  String get explicacaoSol;

  /// No description provided for @explicacaoTerra.
  ///
  /// In pt, this message translates to:
  /// **'Terra'**
  String get explicacaoTerra;

  /// No description provided for @explicacaoLua.
  ///
  /// In pt, this message translates to:
  /// **'Lua'**
  String get explicacaoLua;

  /// No description provided for @fluxoInfluenciaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo de Influência'**
  String get fluxoInfluenciaTitulo;

  /// No description provided for @fluxoInfluenciaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Por que isso importa para o atum?'**
  String get fluxoInfluenciaSubtitulo;

  /// No description provided for @fluxoEtapa1Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Maré'**
  String get fluxoEtapa1Titulo;

  /// No description provided for @fluxoEtapa1Sub.
  ///
  /// In pt, this message translates to:
  /// **'Sizígia ou quadratura'**
  String get fluxoEtapa1Sub;

  /// No description provided for @fluxoEtapa2Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Correntes'**
  String get fluxoEtapa2Titulo;

  /// No description provided for @fluxoEtapa2Sub.
  ///
  /// In pt, this message translates to:
  /// **'Mais ou menos intensas'**
  String get fluxoEtapa2Sub;

  /// No description provided for @fluxoEtapa3Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Mistura / transporte de água'**
  String get fluxoEtapa3Titulo;

  /// No description provided for @fluxoEtapa3Sub.
  ///
  /// In pt, this message translates to:
  /// **'Movimentação da coluna d\'água'**
  String get fluxoEtapa3Sub;

  /// No description provided for @fluxoEtapa4Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição de nutrientes e presas'**
  String get fluxoEtapa4Titulo;

  /// No description provided for @fluxoEtapa4Sub.
  ///
  /// In pt, this message translates to:
  /// **'Onde o alimento se concentra'**
  String get fluxoEtapa4Sub;

  /// No description provided for @fluxoEtapa5Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Concentração de alimento'**
  String get fluxoEtapa5Titulo;

  /// No description provided for @fluxoEtapa5Sub.
  ///
  /// In pt, this message translates to:
  /// **'Disponibilidade pro atum'**
  String get fluxoEtapa5Sub;

  /// No description provided for @fluxoEtapa6Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Comportamento dos atuns'**
  String get fluxoEtapa6Titulo;

  /// No description provided for @fluxoEtapa6Sub.
  ///
  /// In pt, this message translates to:
  /// **'Deslocamento e agregação'**
  String get fluxoEtapa6Sub;

  /// No description provided for @fluxoEtapa7Titulo.
  ///
  /// In pt, this message translates to:
  /// **'Potencial de atividade de pesca'**
  String get fluxoEtapa7Titulo;

  /// No description provided for @fluxoEtapa7Sub.
  ///
  /// In pt, this message translates to:
  /// **'Um indicador entre vários'**
  String get fluxoEtapa7Sub;

  /// No description provided for @fluxoRodape.
  ///
  /// In pt, this message translates to:
  /// **'Essa é uma cadeia de influência possível, não uma relação determinística: cada etapa depende de fatores locais (batimetria, topografia, regime de correntes da região) que a maré sozinha não explica.'**
  String get fluxoRodape;

  /// No description provided for @mareCardTipoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Maré de {tipo}'**
  String mareCardTipoLabel(String tipo);

  /// No description provided for @mapaCamadaTrilhaViagemTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Trilha da viagem'**
  String get mapaCamadaTrilhaViagemTitulo;

  /// No description provided for @mapaCamadaTrilhaViagemSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Trajeto da viagem em andamento, atualizado ao vivo'**
  String get mapaCamadaTrilhaViagemSubtitulo;

  /// No description provided for @mapaTrilhaSemViagemAtiva.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma viagem em andamento para mostrar a trilha'**
  String get mapaTrilhaSemViagemAtiva;

  /// No description provided for @mapaModoNavegacaoTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Modo Navegação'**
  String get mapaModoNavegacaoTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
