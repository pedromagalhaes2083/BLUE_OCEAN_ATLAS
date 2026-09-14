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
