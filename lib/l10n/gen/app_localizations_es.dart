// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitulo => 'Atlas Blue Ocean';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get sair => 'Cerrar sesión';

  @override
  String get salvar => 'Guardar';

  @override
  String get sincronizar => 'Sincronizar';

  @override
  String get idiomaSistema => 'Idioma del sistema';

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
  String get loginSubtitulo => 'Inicio de sesión del patrón';

  @override
  String get loginUsuarioLabel => 'Usuario';

  @override
  String get loginUsuarioObrigatorio => 'Ingrese el usuario';

  @override
  String get loginSenhaLabel => 'Contraseña';

  @override
  String get loginSenhaObrigatoria => 'Ingrese la contraseña';

  @override
  String get loginLembrarCredenciais => 'Recordar mis credenciales';

  @override
  String get loginLembrarCredenciaisSubtitulo =>
      'Inicia sesión automáticamente la próxima vez, hasta que cierre sesión.';

  @override
  String get loginBotaoEntrar => 'ENTRAR';

  @override
  String get loginErroCredenciaisInvalidas =>
      'Usuario o contraseña incorrectos.';

  @override
  String get loginErroConexao => 'Error de conexión. Inténtelo de nuevo.';

  @override
  String get loginEscolherOrganizacaoTitulo => 'Elija la organización';

  @override
  String get configuracoesTitulo => 'Configuración';

  @override
  String get configIdentificacaoAparelho => 'Identificación del Dispositivo';

  @override
  String get configIdDispositivo => 'ID del Dispositivo';

  @override
  String get configCopiar => 'Copiar';

  @override
  String get configIdCopiado => 'ID copiado al portapapeles';

  @override
  String get configEmbarcacao => 'Embarcación';

  @override
  String get configConfigurarEmbarcacao => 'Configurar Embarcación';

  @override
  String get configConfigurarEmbarcacaoSubtitulo =>
      'Capacidades, tripulación, patrón e ID de envío de ubicación.';

  @override
  String get configRastreamentoLocalizacao => 'Seguimiento de Ubicación';

  @override
  String get configIntervaloCapturaEnvio => 'Intervalo de captura y envío';

  @override
  String get configIntervaloExplicacao =>
      'En cada intervalo, la app captura la posición, la guarda localmente y la envía a la API. Sin internet, se guarda y se envía en cuanto vuelva la conexión.';

  @override
  String configMinutos(int min) {
    return '$min minutos';
  }

  @override
  String configIntervaloSalvo(int min) {
    return 'Intervalo de seguimiento: $min min';
  }

  @override
  String get configOtimizacaoBateriaTitulo =>
      'La optimización de batería puede interrumpir el seguimiento';

  @override
  String get configOtimizacaoBateriaTexto =>
      'El dispositivo puede dejar de registrar la posición cada 15 minutos durante un viaje, sin ningún aviso, si Atlas no está exento de la optimización de batería del sistema.';

  @override
  String get configIsentarApp => 'Eximir la app';

  @override
  String get configAparencia => 'Apariencia';

  @override
  String get configTemaEscuro => 'Tema Oscuro';

  @override
  String get configTemaClaro => 'Claro';

  @override
  String get configTemaSistema => 'Sistema';

  @override
  String get configTemaEscuroSegmento => 'Oscuro';

  @override
  String get configModoNoturno => 'Modo Nocturno';

  @override
  String get configModoNoturnoSubtitulo =>
      'Pantalla en rojo para preservar la visión nocturna.';

  @override
  String get configRecomendacoes => 'Recomendaciones';

  @override
  String get configOcultarRecomendacoesExpiradas =>
      'Ocultar recomendaciones vencidas';

  @override
  String get configOcultarRecomendacoesExpiradasSubtitulo =>
      'Quita de la lista de \"Cartas Náuticas\" las que ya vencieron — siguen guardadas, solo no aparecen.';

  @override
  String get configEmergencia => 'Emergencia';

  @override
  String get configContatoEmergencia => 'Contacto de emergencia (WhatsApp)';

  @override
  String get configContatoEmergenciaSubtitulo =>
      'Si está completo, el botón de EMERGENCIA del panel abre directamente una conversación con ese número. Si está vacío, le deja elegir la app en el momento.';

  @override
  String get configNumeroLabel => 'Número con código de área y país';

  @override
  String get configNumeroHint => 'Ej: 5588999998888';

  @override
  String get configContatoSalvo => 'Contacto de emergencia guardado';

  @override
  String get configDadosBackup => 'Datos y Copia de Seguridad';

  @override
  String get configBackupManual => 'Copia de seguridad manual';

  @override
  String get configBackupExplicacao =>
      'Las rutas planificadas, puntos marcados, pedidos de carta y producción solo existen en este dispositivo — nada de eso se envía a un servidor. Genere una copia de seguridad de vez en cuando y guárdela en un lugar seguro (correo, nube, otro dispositivo).';

  @override
  String get configGerarBackup => 'Generar y compartir copia de seguridad';

  @override
  String configBackupCompartilhado(String carimbo) {
    return 'Copia de seguridad de Atlas Blue Ocean — $carimbo';
  }

  @override
  String configErroBackup(String erro) {
    return 'Error al generar la copia de seguridad: $erro';
  }

  @override
  String get configDetalhesAparelho => 'Detalles del Dispositivo';

  @override
  String get configModelo => 'Modelo';

  @override
  String get configFabricante => 'Fabricante';

  @override
  String get configSistemaOperacional => 'Sistema Operativo';

  @override
  String get configTesteDispositivo => 'Prueba — Dispositivo y Recomendaciones';

  @override
  String get configIdioma => 'Idioma';

  @override
  String get configIdiomaSubtitulo => 'Idioma usado en toda la aplicación';

  @override
  String get dashboardAtivarModoNoturno => 'Activar modo nocturno';

  @override
  String get dashboardDesativarModoNoturno => 'Desactivar modo nocturno';

  @override
  String get dashboardBoasVindas => '¡Bienvenido, Patrón!';

  @override
  String dashboardEmbarcacaoLabel(String nome) {
    return 'Embarcación: $nome';
  }

  @override
  String get dashboardEmbarcacaoNaoDefinida => 'No definida';

  @override
  String get dashboardEmergenciaBotao => 'EMERGENCIA — Enviar Posición';

  @override
  String get dashboardRastreamentoAtivo => 'Seguimiento Activo';

  @override
  String dashboardRastreamentoSubtitulo(int min) {
    return 'Registrando posición cada $min minutos';
  }

  @override
  String dashboardPosicoesPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posiciones esperando sincronización',
      one: '1 posición esperando sincronización',
    );
    return '$_temp0';
  }

  @override
  String get dashboardPosicoesPendentesSubtitulo =>
      'Se enviarán automáticamente en cuanto haya conexión.';

  @override
  String get dashboardSincronizarAgora => 'Sincronizar ahora';

  @override
  String dashboardBateriaBaixa(int percent) {
    return 'Batería del celular al $percent%';
  }

  @override
  String get dashboardBateriaBaixaSubtitulo =>
      'El seguimiento puede detenerse si se acaba la batería.';

  @override
  String get dashboardSemPosicaoRecente => 'Sin posición reciente registrada';

  @override
  String dashboardSemPosicaoRecenteSubtitulo(String tempo) {
    return 'Última posición hace $tempo. Verifique la señal del GPS.';
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
      other: '$d días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get dashboardBat => 'PROF';

  @override
  String get dashboardMetros => 'metros';

  @override
  String get dashboardSst => 'TSM';

  @override
  String get dashboardMapa => 'Mapa';

  @override
  String get dashboardRodape =>
      'Todos los datos se guardan localmente.\nLa sincronización con el servidor se hará en cuanto haya conexión.';

  @override
  String get dashboardErroCarregar =>
      'No se pudieron cargar los datos del panel.';

  @override
  String get dashboardTentarNovamente => 'Intentar de nuevo';

  @override
  String dashboardPosicoesEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posiciones enviadas',
      one: '1 posición enviada',
    );
    return '$_temp0';
  }

  @override
  String dashboardAindaPendentes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aún pendientes',
      one: '1 aún pendiente',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSincronizacaoFalhou =>
      'No se pudo sincronizar ahora. Verifique la conexión.';

  @override
  String dashboardErroSincronizar(String erro) {
    return 'Error al sincronizar: $erro';
  }

  @override
  String get dashboardSosTitulo => '¿Enviar señal de emergencia?';

  @override
  String get dashboardSosTexto =>
      'Esto abrirá una app de mensajería con su posición actual y un pedido de ayuda, para que lo envíe a quien pueda socorrerlo.';

  @override
  String get dashboardSosConfirmar => 'EMERGENCIA';

  @override
  String dashboardSosErroPosicao(String erro) {
    return 'No se pudo obtener la posición: $erro';
  }

  @override
  String dashboardSosMensagem(
      String embarcacao, String posicao, String horario, String url) {
    return '🆘 EMERGENCIA — ¡necesito ayuda!\nEmbarcación: $embarcacao\nPosición: $posicao\nHora: $horario\n$url';
  }

  @override
  String get dashboardEmbarcacaoNaoInformada => 'no informada';

  @override
  String get drawerViagemAtual => 'Viaje Actual';

  @override
  String get drawerProducao => 'Producción';

  @override
  String get drawerSolicitarCarta => 'Solicitar Carta';

  @override
  String get drawerCartasNauticas => 'Cartas Náuticas';

  @override
  String get drawerMinhasRotas => 'Mis Rutas';

  @override
  String get drawerEmbarcacao => 'Embarcación';

  @override
  String get drawerCondicoesMar => 'Condiciones del Mar';

  @override
  String get drawerAlertaRota => 'Alerta de Ruta';

  @override
  String get drawerTabuaMare => 'Tabla de Mareas';

  @override
  String get drawerMareEPesca => 'Marea y Pesca';

  @override
  String get drawerFaseLua => 'Fase Lunar';

  @override
  String get drawerAvisosNavegantes => 'Avisos a los Navegantes';

  @override
  String get drawerConfiguracoes => 'Configuración';

  @override
  String get drawerSair => 'Cerrar sesión';

  @override
  String get dashboardCartaSolicitadaSucesso => '¡Carta solicitada con éxito!';

  @override
  String get dashboardNenhumaEmbarcacaoTitulo =>
      'Ninguna embarcación vinculada';

  @override
  String dashboardNenhumaEmbarcacaoTexto(String motivo) {
    return 'La embarcación se vincula automáticamente con su viaje activo en la plataforma. Sincronice antes de $motivo.';
  }

  @override
  String get dashboardNenhumaViagemTitulo => 'Ningún viaje en curso';

  @override
  String dashboardNenhumaViagemTexto(String motivo) {
    return 'Los viajes ahora se crean en la plataforma. Sincronice antes de $motivo, o pida que el viaje se inicie allí.';
  }

  @override
  String get dashboardMotivoRegistrarProducao => 'registrar la producción';

  @override
  String get dashboardViagemSincronizada => 'Viaje activo sincronizado.';

  @override
  String get dashboardNenhumaViagemEncontrada =>
      'No se encontró ningún viaje activo en la plataforma en este momento.';

  @override
  String get dashboardSairTitulo => 'Cerrar Sesión';

  @override
  String get dashboardSairTexto => '¿Realmente desea salir?';
}
