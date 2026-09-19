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

  @override
  String get producaoTitulo => 'Registro de Producción';

  @override
  String get producaoVerHistorico => 'Ver historial y totales';

  @override
  String producaoDataLabel(String data) {
    return 'Fecha: $data';
  }

  @override
  String get producaoSemViagemAviso =>
      'Ningún viaje en curso — el registro no se asociará a un viaje.';

  @override
  String get producaoClassificacaoLabel => 'Clasificación *';

  @override
  String get producaoSelecioneClassificacao => 'Seleccione la clasificación';

  @override
  String get producaoQuantidadeLabel => 'Cantidad (unidades) *';

  @override
  String get producaoInformeQuantidade => 'Ingrese la cantidad';

  @override
  String get producaoQuantidadeInvalida =>
      'Ingrese un número entero mayor que cero';

  @override
  String get producaoObservacaoLabel => 'Observación (opcional)';

  @override
  String get producaoCapturandoLocalizacao => 'Obteniendo ubicación...';

  @override
  String get producaoSalvando => 'Guardando...';

  @override
  String get producaoSalvarBotao => 'GUARDAR PRODUCCIÓN';

  @override
  String get producaoTipoPeixeLabel => 'Tipo de pez *';

  @override
  String get producaoSelecioneTipoPeixe => 'Seleccione el tipo de pez';

  @override
  String get producaoPesoEstimadoLabel => 'Peso estimado';

  @override
  String get producaoSemEmbarcacaoVinculada =>
      'Ninguna embarcación vinculada — configúrela en Configuración → Embarcación antes de registrar producción.';

  @override
  String producaoErroGps(String erro) {
    return 'No se pudo obtener el GPS ahora ($erro). El registro se guardará sin coordenada.';
  }

  @override
  String get producaoSalvaSucesso => '✅ ¡Producción guardada con éxito!';

  @override
  String producaoErroSalvar(String erro) {
    return 'Error al guardar: $erro';
  }

  @override
  String producaoKgPorUnidade(String min, String max) {
    return '$min–$max kg/ud.';
  }

  @override
  String get producaoEmbarcacaoNaoDefinida => 'No definida';

  @override
  String get fechar => 'Cerrar';

  @override
  String get remover => 'Eliminar';

  @override
  String get mapaCartaRecomendacaoIndisponivel =>
      'Carta de la recomendación no disponible (el enlace pudo haber expirado)';

  @override
  String get mapaErroCarregarCartaRecomendacao =>
      'No se pudo cargar la carta de la recomendación';

  @override
  String mapaErroSalvarRota(String erro) {
    return 'Error al guardar la ruta: $erro';
  }

  @override
  String get mapaLabelData => 'Fecha';

  @override
  String get mapaLabelClassificacaoCurto => 'Clasificación';

  @override
  String get mapaLabelPeso => 'Peso';

  @override
  String mapaProducaoTotal(String kg) {
    return '$kg kg en total';
  }

  @override
  String get mapaEspecieNaoInformada => 'No informado';

  @override
  String get mapaClorofilaTitulo => 'Clorofila-a';

  @override
  String get mapaClorofilaSemDado =>
      'Sin dato válido para este punto (nube, tierra cercana o falla del sensor en el día más reciente disponible)';

  @override
  String mapaClorofilaData(String data) {
    return 'Fecha: $data';
  }

  @override
  String mapaClorofilaFonte(String fonte) {
    return 'Fuente: $fonte';
  }

  @override
  String get mapaClorofilaDisclaimer =>
      'Indicador de productividad biológica/oceanográfica — no representa directamente la cantidad de peces.';

  @override
  String get mapaAdicionarPontoClorofila => 'Marcar otro punto de clorofila-a';

  @override
  String get mapaIndiceProdutividadeTitulo =>
      'Índice de Productividad Blue Ocean';

  @override
  String get mapaAdicionarPontoIndice =>
      'Marcar otro punto de índice de productividad';

  @override
  String mapaIndiceDadosClorofilaData(String data) {
    return 'Datos de clorofila-a del $data';
  }

  @override
  String get mapaIndiceFontes =>
      'Fuentes: NOAA CoastWatch (ERDDAP) · Open-Meteo Marine';

  @override
  String get mapaIndiceDisclaimer =>
      'Estimación que combina clorofila-a y temperatura de la superficie del mar — no representa directamente la cantidad de peces, solo un indicador indirecto de productividad.';

  @override
  String get mapaTemperaturaTitulo => 'Temperatura de la superficie del mar';

  @override
  String mapaConsultarPontoInstrucao(String titulo) {
    return 'Consultar $titulo — apunte el centro del mapa hacia el lugar deseado';
  }

  @override
  String get mapaConsultarBotao => 'Consultar';

  @override
  String mapaTemperaturaResultado(String valor) {
    return 'Temperatura en el punto: $valor °C';
  }

  @override
  String get mapaTemperaturaSemDado =>
      'Sin dato de temperatura para este punto ahora';

  @override
  String get mapaErroBuscarTemperatura => 'Error al buscar la temperatura';

  @override
  String get mapaErroBuscarClorofila => 'Error al buscar la clorofila-a';

  @override
  String get mapaErroCalcularIndice =>
      'Error al calcular el índice de productividad';

  @override
  String get mapaMenuTitulo => 'MENÚ DEL MAPA';

  @override
  String get mapaCancelarMarcacao => 'Cancelar marcación';

  @override
  String get mapaMarcarPonto => 'Marcar un punto';

  @override
  String get mapaCamadasTitulo => 'CAPAS';

  @override
  String get mapaCamadaRuasTitulo => 'Mapa de Calles (OpenStreetMap)';

  @override
  String get mapaCamadaRuasSubtitulo =>
      'Apagado: muestra la carta náutica cargada';

  @override
  String get mapaCamadaNauticaTitulo => 'Información náutica (OpenSeaMap)';

  @override
  String get mapaCamadaNauticaSubtitulo =>
      'Boyas, marcas, faros y puertos — solo sobre el Mapa de Calles';

  @override
  String get mapaCamadaProfundidadeTitulo => 'Profundidad';

  @override
  String get mapaCamadaProfundidadeSubtitulo =>
      'Sombreado batimétrico (GEBCO) · OpenSeaMap';

  @override
  String get mapaCamadaCurvasTitulo => 'Curvas de profundidad';

  @override
  String get mapaCamadaCurvasSubtitulo => 'Isóbatas · OpenSeaMap';

  @override
  String get mapaClorofilaSubtitulo =>
      'Indicador de productividad · NOAA CoastWatch';

  @override
  String get mapaCamadaProducaoTitulo =>
      'Puntos de pesca (calor de producción)';

  @override
  String get mapaCamadaOverlayTitulo => 'Superposición de imagen';

  @override
  String get mapaCamadaOverlaySubtitulo =>
      'PNG georreferenciado — toque \"Elegir imagen\" para cambiarlo';

  @override
  String get mapaEscolherImagem => 'Elegir imagen';

  @override
  String get mapaIndiceProdutividadeSubtitulo =>
      'Combina clorofila-a y temperatura — una estimación, no una garantía de cardumen';

  @override
  String get mapaBaixarRegiao => 'Descargar región para uso sin conexión';

  @override
  String get mapaAtribuicao =>
      '© OpenStreetMap contributors · © OpenSeaMap contributors · Profundidad: GEBCO / OpenSeaMap depth project';

  @override
  String get mapaOverlayDialogTitulo => 'Superposición PNG';

  @override
  String get mapaOverlayDialogTexto =>
      'Elija, en la galería de fotos del dispositivo, un PNG georreferenciado (con el metadato \"geo_bounds\" incorporado) para mostrar sobre la carta.';

  @override
  String get mapaSelecionarImagem => 'Seleccionar imagen';

  @override
  String mapaOverlayFallback(String erro) {
    return '$erro Usando el área predeterminada de la app.';
  }

  @override
  String mapaErroSelecionarImagem(String erro) {
    return 'Error al seleccionar la imagen: $erro';
  }

  @override
  String mapaPontoMarcadoConfirmacao(String valor) {
    return 'Punto marcado: $valor';
  }

  @override
  String get mapaPontoMarcadoTitulo => 'Punto marcado';

  @override
  String get mapaLabelCoordenadas => 'Coordenadas';

  @override
  String get mapaLabelMarcadoEm => 'Marcado el';

  @override
  String get mapaLabelDistancia => 'Distancia';

  @override
  String get mapaLabelRumo => 'Rumbo';

  @override
  String get mapaConsultarAqui => 'Consultar aquí';

  @override
  String get mapaPontoRecomendacaoTitulo => 'Punto de la recomendación';

  @override
  String get mapaLabelRecebidoEm => 'Recibido el';

  @override
  String get mapaEditarRota => 'Editar Ruta';

  @override
  String get mapaNovaRotaPlanejada => 'Nueva Ruta Planificada';

  @override
  String get mapaRecomendacaoFallback => 'Recomendación';

  @override
  String get mapaRotaHistorico => 'Ruta del historial';

  @override
  String get mapaMenuDoMapaTooltip => 'Menú del mapa';

  @override
  String get mapaMeusPontosTooltip => 'Mis Puntos';

  @override
  String get mapaCarregandoCarta => 'Cargando carta náutica...';

  @override
  String mapaErroCarregarCarta(String erro) {
    return 'Error al cargar la carta: $erro';
  }

  @override
  String get mapaApontarCentro =>
      'Apunte el centro del mapa hacia el lugar deseado';

  @override
  String get mapaNomeLocalLabel => 'Nombre del lugar (opcional)';

  @override
  String get mapaNomeLocalHint => 'Ej: Pozo del Camurupim';

  @override
  String get mapaMarcarPontoBotao => 'Marcar punto';

  @override
  String get mapaRotaTocarPrimeiroPonto =>
      'Toque el mapa o un punto marcado para añadir el primer punto';

  @override
  String mapaRotaPontosAdicionados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n puntos añadidos',
      one: '1 punto añadido',
    );
    return '$_temp0 — toque para continuar';
  }

  @override
  String get mapaNomeRotaLabel => 'Nombre de la ruta';

  @override
  String get mapaNomeRotaHint => 'Ej: Pesquero del Camurupim';

  @override
  String get mapaDesfazerUltimo => 'Deshacer último';

  @override
  String get mapaSalvarAlteracoes => 'Guardar cambios';

  @override
  String get mapaSalvarRota => 'Guardar ruta';

  @override
  String get shellHome => 'Inicio';

  @override
  String get shellCartasTab => 'Cartas';

  @override
  String cartasSemConexao(String horario) {
    return 'Sin conexión — mostrando la última lista sincronizada a las $horario';
  }

  @override
  String get cartasDataDesconhecida => 'fecha desconocida';

  @override
  String get minhasSolicitacoesTooltip => 'Mis solicitudes';

  @override
  String get minhasSolicitacoesTitulo => 'Mis Solicitudes';

  @override
  String minhasSolicitacoesErro(String erro) {
    return 'Error al cargar las solicitudes: $erro';
  }

  @override
  String get minhasSolicitacoesVazio => 'Ninguna solicitud de carta todavía';

  @override
  String minhasSolicitacoesPedidoEm(String data) {
    return 'Solicitado el $data';
  }

  @override
  String get minhasSolicitacoesPendente => 'Pendiente';

  @override
  String get solicitarCartaTitulo => 'Solicitar Carta Náutica';

  @override
  String get solicitarCartaCoordenadaGeografica => 'Coordenada Geográfica';

  @override
  String get solicitarCartaInstrucao =>
      'Gire los selectores como un reloj para ajustar grados y minutos';

  @override
  String get solicitarCartaBotao => 'SOLICITAR CARTA NÁUTICA';

  @override
  String get solicitarCartaSucesso =>
      '¡Solicitud registrada! Véala en \"Mis Solicitudes\".';

  @override
  String solicitarCartaErro(String erro) {
    return 'Error al solicitar la carta: $erro';
  }

  @override
  String get embarcacaoTitulo => 'Mi Embarcación';

  @override
  String embarcacaoErroCarregar(String erro) {
    return 'Error al cargar la embarcación: $erro';
  }

  @override
  String get embarcacaoSincronizadaSucesso =>
      'Embarcación sincronizada con el viaje activo.';

  @override
  String get embarcacaoSemProprietario => 'Sin propietario registrado';

  @override
  String get embarcacaoAtiva => 'Activa';

  @override
  String get embarcacaoInativa => 'Inactiva';

  @override
  String get embarcacaoCapacidadesTitulo => 'CAPACIDADES Y TRIPULACIÓN';

  @override
  String get embarcacaoUrnas => 'Cajas';

  @override
  String get embarcacaoGelo => 'Hielo';

  @override
  String get embarcacaoDiesel => 'Diésel';

  @override
  String get embarcacaoTripulantes => 'Tripulantes';

  @override
  String get embarcacaoDetalhesTitulo => 'DETALLES';

  @override
  String get embarcacaoMotorUsado => 'Motor Usado';

  @override
  String get embarcacaoIdMestre => 'ID de Patrón/Capitán';

  @override
  String get embarcacaoIdRastreio => 'ID DE SEGUIMIENTO';

  @override
  String get embarcacaoVinculacaoAutomatica =>
      'La embarcación se vincula automáticamente a partir de su viaje activo en la plataforma.';

  @override
  String get embarcacaoRastrear => 'Rastrear';

  @override
  String get embarcacaoConfigTooltipSincronizar =>
      'Sincronizar con el viaje activo';

  @override
  String get embarcacaoConfigTesteDisparado =>
      'Prueba iniciada — vea el resultado en la consola/registro';

  @override
  String get embarcacaoConfigSemEmbarcacaoTexto =>
      'La embarcación se vincula automáticamente a partir de su viaje activo en la plataforma. Toque sincronizar para buscarla de nuevo.';

  @override
  String get embarcacaoConfigVinculadaTexto =>
      'Vinculada por el viaje activo en la plataforma.';

  @override
  String get embarcacaoConfigIdLabel => 'ID de la Embarcación';

  @override
  String get embarcacaoConfigCapacidadeGelo => 'Capacidad de hielo';

  @override
  String get embarcacaoConfigCapacidadeDiesel => 'Capacidad de diésel';

  @override
  String get embarcacaoConfigMotorUsado => 'Motor usado';

  @override
  String get embarcacaoConfigNumeroTripulantes => 'Número de tripulantes';

  @override
  String get embarcacaoConfigTestarEnvio => 'Probar envío de ubicación';

  @override
  String viagemErroCarregarHistorico(String erro) {
    return 'Error al cargar el historial: $erro';
  }

  @override
  String get viagemResumoDaViagemFallback => 'Resumen del viaje';

  @override
  String viagemCompartilharInicio(String data) {
    return 'Inicio: $data';
  }

  @override
  String viagemCompartilharDistancia(String mn) {
    return 'Distancia: $mn mn';
  }

  @override
  String viagemCompartilharDuracao(String valor) {
    return 'Duración: $valor';
  }

  @override
  String viagemCompartilharVelMedia(String valor) {
    return 'Vel. media: $valor km/h';
  }

  @override
  String viagemCompartilharVelMaxima(String valor) {
    return 'Vel. máxima: $valor km/h';
  }

  @override
  String get viagemCompartilharProducaoTitulo => '🐟 Producción:';

  @override
  String get viagemFinalizarTitulo => 'Finalizar viaje';

  @override
  String get viagemFinalizarTexto =>
      '¿Seguro que desea finalizar este viaje? El seguimiento de posición en segundo plano se detiene junto con él — la app solo vuelve a enviar la posición cuando se inicie otro viaje.';

  @override
  String get viagemFinalizarBotao => 'Finalizar';

  @override
  String viagemErroFinalizar(String erro) {
    return 'Error al finalizar el viaje: $erro';
  }

  @override
  String get viagemVerRotaTooltip => 'Ver ruta en la carta';

  @override
  String get viagemCompartilharTooltip => 'Compartir resumen del viaje';

  @override
  String get viagemAtualizarTooltip => 'Actualizar';

  @override
  String get viagemNenhumRegistro => 'Ningún registro encontrado';

  @override
  String get viagemCriadasNaPlataforma =>
      'Los viajes ahora se crean en la plataforma. Toque sincronizar para buscar el viaje activo.';

  @override
  String get viagemEmAndamentoFallback => 'Viaje en curso';

  @override
  String viagemIniciadaEm(String data) {
    return 'Iniciado el $data';
  }

  @override
  String get viagemDuracaoLabel => 'Duración';

  @override
  String get viagemVelMediaLabel => 'Vel. media';

  @override
  String get viagemVelMaximaLabel => 'Vel. máxima';

  @override
  String viagemPrecLabel(String m) {
    return 'Prec: ${m}m';
  }

  @override
  String get apagar => 'Eliminar';

  @override
  String rotasErroCarregar(String erro) {
    return 'Error al cargar las rutas: $erro';
  }

  @override
  String get rotasApagarTitulo => '¿Eliminar ruta?';

  @override
  String rotasApagarTexto(String nome) {
    return '\"$nome\" se eliminará de forma permanente.';
  }

  @override
  String get rotasNovaRota => 'Nueva ruta';

  @override
  String get rotasNenhumaAinda => 'Ninguna ruta planificada todavía';

  @override
  String get rotasTocarNovaRota =>
      'Toque \"Nueva ruta\" para marcar puntos en el mapa';

  @override
  String rotasPontosEData(int n, String data) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n puntos',
      one: '1 punto',
    );
    return '$_temp0 · $data';
  }

  @override
  String get rotasAnalisarTooltip => 'Analizar condiciones de la ruta';

  @override
  String get rotasEditarTooltip => 'Editar ruta';

  @override
  String get rotasApagarTooltip => 'Eliminar ruta';

  @override
  String rotasAnaliseTitulo(String nome) {
    return 'Análisis: $nome';
  }

  @override
  String get rotasBuscandoCondicoes =>
      'Buscando condiciones a lo largo de la ruta...';

  @override
  String rotasPontosComCondicaoSevera(int severos, int total) {
    return '$severos de $total puntos con condición severa';
  }

  @override
  String get rotasNenhumPontoSevero => 'Ningún punto con condición severa';

  @override
  String rotasPontosDistanciaTotal(int n, String distancia) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n puntos',
      one: '1 punto',
    );
    return '$_temp0 · $distancia mn en total';
  }

  @override
  String rotasTrechoDesdePonto(String trecho, int indice) {
    return '+$trecho mn desde el punto $indice';
  }

  @override
  String get metricaVento => 'Viento';

  @override
  String get metricaOnda => 'Ola';

  @override
  String get metricaCorrente => 'Corriente';

  @override
  String get metricaAgua => 'Agua';

  @override
  String get metricaMare => 'Marea';

  @override
  String get condicoesMarTitulo => 'Condiciones del Mar';

  @override
  String get condicoesMarAguardandoPosicao =>
      'Esperando la posición actual de la embarcación...';

  @override
  String get erroBuscarPrevisaoPrefixo => 'Error al buscar el pronóstico';

  @override
  String get condicoesPontoTituloFallback => 'Condiciones del Punto';

  @override
  String get posicaoAtualTitulo => '📍 Posición Actual';

  @override
  String get posicaoAtualizarTooltip => 'Actualizar posición';

  @override
  String get posicaoTocarIcone => 'Toque el ícono para actualizar';

  @override
  String get posicaoTocarBotao => 'Toque el botón para actualizar';

  @override
  String get posicaoErroLocalizacaoDesativada =>
      '❌ La ubicación está desactivada en el dispositivo';

  @override
  String get posicaoErroPermissaoNegadaPermanente =>
      '❌ Permiso denegado permanentemente.\nVaya a Configuración > Apps';

  @override
  String get posicaoErroPermissaoNegada => '❌ Permiso de ubicación denegado';

  @override
  String get posicaoErroTimeout =>
      '❌ Tiempo agotado al obtener la posición.\nInténtelo de nuevo en un área abierta.';

  @override
  String posicaoErroGenerico(String erro) {
    return '❌ Error: $erro';
  }

  @override
  String get profundidadeCarregando => 'Cargando profundidad...';

  @override
  String get pontoEmTerra => 'Punto en tierra';

  @override
  String get sstCarregando => 'Cargando temperatura del agua...';

  @override
  String get sstSuperficieDoMar => 'Superficie del mar';

  @override
  String mareNivelAgora(String nivel) {
    return '$nivel m ahora';
  }

  @override
  String get marePreamar => 'Marea alta';

  @override
  String get mareBaixaMar => 'Marea baja';

  @override
  String get luaLabel => 'Luna';

  @override
  String luaIluminadaCiclo(int pct, int dia) {
    return '$pct% iluminada · día $dia del ciclo';
  }

  @override
  String get luaNascer => 'Salida';

  @override
  String get luaPor => 'Puesta';

  @override
  String get luaProximasFases => 'PRÓXIMAS FASES';

  @override
  String get luaHoje => 'hoy';

  @override
  String luaEmDias(int d) {
    return 'en ${d}d';
  }

  @override
  String get solunarTitulo => 'Tabla Solunar';

  @override
  String get solunarSubtitulo =>
      'Períodos de mayor actividad de alimentación, según la posición de la luna';

  @override
  String get ventoCarregando => 'Cargando el pronóstico del tiempo...';

  @override
  String get ventoClimaAtual => 'Clima Actual';

  @override
  String get ventoVelocidadeTitulo => 'VELOCIDAD DEL VIENTO';

  @override
  String ventoDirecao(int graus) {
    return 'Dirección: $graus°';
  }

  @override
  String get labelTemperatura => 'Temperatura';

  @override
  String get labelPressao => 'Presión';

  @override
  String get ventoPrevisaoHoraria => 'Pronóstico horario';

  @override
  String get ventoIntensidadeCalmo => 'Calma';

  @override
  String get ventoIntensidadeLeve => 'Leve';

  @override
  String get ventoIntensidadeModerado => 'Moderado';

  @override
  String get ventoIntensidadeForte => 'Fuerte';

  @override
  String get ventoIntensidadeMuitoForte => 'Muy fuerte';

  @override
  String get ondaCondicoesAtuais => 'Condiciones Actuales';

  @override
  String get ondaAlturaTitulo => 'ALTURA DE OLA';

  @override
  String ondaPeriodo(String n) {
    return 'Período $n s';
  }

  @override
  String get ondaCorrenteTitulo => 'CORRIENTE';

  @override
  String get ondaSemDados => 'Sin datos';

  @override
  String get ondaSwellPrefixo => 'Marejada';

  @override
  String ondaDirecaoOnda(int graus) {
    return 'Dir. ola $graus°';
  }

  @override
  String get ondaAlturaCalmo => 'Calma';

  @override
  String get ondaAlturaLeve => 'Leve';

  @override
  String get ondaAlturaModerado => 'Moderada';

  @override
  String get ondaAlturaAgitado => 'Agitada';

  @override
  String get ondaAlturaMuitoAgitado => 'Muy agitada';

  @override
  String get ondaAlturaTempestuoso => 'Tempestuosa';

  @override
  String get meteoSheetPosicaoFallback => 'Posición';

  @override
  String get meteoSheetSemDados => 'Sin datos meteorológicos';

  @override
  String get meteoSheetVentoTitulo => 'Viento';

  @override
  String get meteoSheetMovimentoTitulo => 'Movimiento';

  @override
  String get meteoSheetAtmosferaTitulo => 'Atmósfera';

  @override
  String get meteoSheetOndasTitulo => 'Olas';

  @override
  String get meteoSheetVelocidadeRealTws => 'Velocidad real del viento (TWS)';

  @override
  String get meteoSheetDirecaoRealTwd => 'Dirección real del viento (TWD)';

  @override
  String get meteoSheetAnguloRealTwa => 'Ángulo real del viento (TWA)';

  @override
  String get meteoSheetVelocidadeAparenteAws =>
      'Velocidad aparente del viento (AWS)';

  @override
  String get meteoSheetAnguloAparenteAwa => 'Ángulo aparente del viento (AWA)';

  @override
  String get meteoSheetRajadas => 'Rachas';

  @override
  String get meteoSheetVelocidadeRealSog => 'Velocidad sobre el fondo (SOG)';

  @override
  String get meteoSheetDirecaoRealCog => 'Rumbo sobre el fondo (COG)';

  @override
  String get meteoSheetVelocidadeAparenteStw =>
      'Velocidad a través del agua (STW)';

  @override
  String get meteoSheetAnguloAparenteCtw => 'Rumbo a través del agua (CTW)';

  @override
  String get meteoSheetNuvens => 'Nubes';

  @override
  String get meteoSheetChuva => 'Lluvia';

  @override
  String get meteoSheetAlturaCombinada => 'Altura combinada';

  @override
  String get meteoSheetVentoAltura => 'Viento — altura';

  @override
  String get meteoSheetVentoDirecao => 'Viento — dirección';

  @override
  String get meteoSheetVentoPeriodo => 'Viento — período';

  @override
  String get meteoSheetSwellAltura => 'Swell — altura';

  @override
  String get meteoSheetSwellDirecao => 'Swell — dirección';

  @override
  String get meteoSheetSwellPeriodo => 'Swell — período';

  @override
  String get alertaConfigTitulo => 'Configurar Alertas';

  @override
  String get alertaConfigDescricao =>
      'Elija a partir de qué punto cada condición en el camino de la embarcación dispara una notificación (con vibración). Aplica tanto a la comprobación manual en \"Alerta de Ruta\" como al seguimiento en segundo plano durante un viaje.';

  @override
  String get alertaConfigVentoTitulo => 'Viento';

  @override
  String get alertaConfigVentoSubtitulo =>
      'Alerta cuando el viento por delante supere';

  @override
  String get alertaConfigOndaTitulo => 'Altura de ola y swell';

  @override
  String get alertaConfigOndaSubtitulo =>
      'Alerta cuando la ola o el swell superen';

  @override
  String get alertaConfigCorrenteTitulo => 'Corriente de marea';

  @override
  String get alertaConfigCorrenteSubtitulo =>
      'Alerta cuando la corriente supere';

  @override
  String get alertaConfigTemperaturaTitulo => 'Temperatura del agua';

  @override
  String get alertaConfigTemperaturaSubtitulo =>
      'Alerta cuando la temperatura supere';

  @override
  String get alertaRotaTitulo => 'Alerta de Ruta';

  @override
  String get alertaRotaTooltipConfigurar => 'Configurar alertas';

  @override
  String get alertaRotaTooltipSimular => 'Simular con punto marcado';

  @override
  String alertaRotaErroPosicaoPrefixo(String erro) {
    return 'Error al obtener la posición: $erro';
  }

  @override
  String get alertaRotaNenhumPontoMarcado => 'Aún no hay puntos marcados';

  @override
  String get alertaRotaSimularDialogTitulo => '¿Simular a partir de qué punto?';

  @override
  String get alertaRotaRumoSimuladoTitulo => 'Rumbo simulado';

  @override
  String get alertaRotaBotaoSimular => 'Simular';

  @override
  String get alertaRotaVentoTitulo => 'Viento por delante';

  @override
  String get alertaRotaCorrenteTitulo => 'Corriente por delante';

  @override
  String get alertaRotaOndaTitulo => 'Ola por delante';

  @override
  String get alertaRotaSwellTitulo => 'Swell por delante';

  @override
  String get alertaRotaBussolaTitulo => 'Brújula';

  @override
  String get alertaRotaSemSinal => 'Sin señal';

  @override
  String get alertaRotaAlcanceTitulo => 'Alcance de la alerta';

  @override
  String get alertaRotaAlcanceDescricao =>
      'Distancia por delante de la embarcación, en el rumbo actual, donde se comprueban las condiciones.';

  @override
  String alertaRotaRumoEAlcance(String rumo, String alcance) {
    return 'Rumbo $rumo° · $alcance mn por delante';
  }

  @override
  String get alertaRotaSemRumoDescricao =>
      'Rumbo no disponible — la embarcación debe estar en movimiento para que el GPS calcule un rumbo válido.';

  @override
  String alertaRotaSimulacaoAtiva(String nome, String rumo) {
    return 'Simulación activa — usando \"$nome\" con rumbo $rumo° (no es el GPS real)';
  }

  @override
  String get alertaRotaCorrenteFraca => 'Débil';

  @override
  String get alertaRotaCorrenteModerada => 'Moderada';

  @override
  String get alertaRotaCorrenteForte => 'Fuerte';

  @override
  String get alertaRotaCorrenteMuitoForte => 'Muy fuerte';

  @override
  String get alertaRotaCorrenteExtrema => 'Extrema';

  @override
  String get diaSemanaSegunda => 'Lunes';

  @override
  String get diaSemanaTerca => 'Martes';

  @override
  String get diaSemanaQuarta => 'Miércoles';

  @override
  String get diaSemanaQuinta => 'Jueves';

  @override
  String get diaSemanaSexta => 'Viernes';

  @override
  String get diaSemanaSabado => 'Sábado';

  @override
  String get diaSemanaDomingo => 'Domingo';

  @override
  String get faseLuaScreenTitulo => 'Fase Lunar';

  @override
  String get faseLuaErroBuscarPrefixo =>
      'Error al buscar salida/puesta de la luna';

  @override
  String get faseLuaAguardandoPosicao =>
      'Esperando la posición actual de la embarcación para los horarios de salida/puesta de la luna — la fase de arriba no depende de eso.';

  @override
  String get faseLuaNascerEPorTitulo => 'SALIDA Y PUESTA DE LA LUNA';

  @override
  String faseLuaHojeData(String data) {
    return 'Hoy, $data';
  }

  @override
  String get erroSincronizarPrefixo => 'Error al sincronizar';

  @override
  String get tabuaMareTooltipRemoverPorto => 'Eliminar puerto';

  @override
  String get tabuaMareRemoverPortoTitulo => '¿Eliminar puerto?';

  @override
  String tabuaMareRemoverPortoConteudo(String nome) {
    return '\"$nome\" se eliminará de la lista.';
  }

  @override
  String get tabuaMareSincronizando => 'Sincronizando...';

  @override
  String get tabuaMareSincronizarDeNovo => 'Sincronizar de nuevo';

  @override
  String tabuaMareSincronizadoEm(String data) {
    return 'Sincronizado el $data · disponible sin conexión';
  }

  @override
  String get tabuaMareAindaNaoSincronizado =>
      'Aún no sincronizado — necesita internet la primera vez';

  @override
  String get tabuaMareSincronizePrimeiraVez =>
      'Sincronice al menos una vez, con internet, para calcular la tabla de mareas sin conexión de este puerto.';

  @override
  String get tabuaMareNivelAgoraTitulo => 'Nivel ahora';

  @override
  String get tabuaMareTitulo => 'Tabla de Mareas';

  @override
  String get tabuaMareBotaoPorto => 'Puerto';

  @override
  String tabuaMareErroCarregarPrefixo(String erro) {
    return 'Error al cargar puertos: $erro';
  }

  @override
  String tabuaMareErroSincronizarNome(String nome) {
    return 'Error al sincronizar \"$nome\"';
  }

  @override
  String get tabuaMareNovoPortoTitulo => 'Nuevo puerto';

  @override
  String get tabuaMareNomeLabel => 'Nombre';

  @override
  String get tabuaMareNomeHint => 'Ej: Puerto de Itarema';

  @override
  String get tabuaMarePreencherNome => 'Complete el nombre del puerto';

  @override
  String get tabuaMareNenhumPortoTitulo => 'Aún no hay puertos guardados';

  @override
  String get tabuaMareNenhumPortoDescricao =>
      'Guarde la coordenada de un puerto (ej: Itarema, Acaraú, Camocim) para consultar la marea prevista, incluso sin conexión tras sincronizar.';

  @override
  String get tabuaMarePoucosDados =>
      'Se devolvieron muy pocos datos de marea para este punto';

  @override
  String get mareEPescaTitulo => 'Marea y Pesca';

  @override
  String get mareEPescaErroBuscarPrefixo =>
      'Error al buscar la previsión de marea';

  @override
  String get mareEPescaAguardandoPosicao =>
      'Esperando la posición actual de la embarcación...';

  @override
  String get mareEPescaCabecalhoTitulo =>
      'Influencia de la Marea en la Pesca de Atún';

  @override
  String get mareEPescaCabecalhoDescricao =>
      'Comprenda cómo la amplitud de las mareas puede alterar las corrientes, la mezcla del agua y las condiciones de alimentación de los atunes.';

  @override
  String mareEPescaCondicaoAtual(String tipo) {
    return 'Condición actual de la marea: $tipo';
  }

  @override
  String get mareEPescaGrafico24hTitulo => 'Marea en las próximas 24h';

  @override
  String get mareEPescaEntendaSizigia => 'Entienda las mareas vivas';

  @override
  String get mareEPescaEntendaQuadratura => 'Entienda las mareas muertas';

  @override
  String get mareEPescaImportante => 'Importante';

  @override
  String get mareEPescaAvisoPrincipal =>
      'La fase de la marea no debe utilizarse de forma aislada para determinar un área de pesca. La respuesta del ambiente varía según la ubicación, profundidad, topografía, régimen de corrientes, temperatura, disponibilidad de alimento, viento y otros factores oceanográficos.';

  @override
  String get mareEPescaAvisoSecundario =>
      'Utilice la marea como uno de los indicadores dentro de un análisis integrado.';

  @override
  String get producaoHistoricoTitulo => 'Historial de Producción';

  @override
  String get producaoHistoricoTooltipPorPonto => 'Producción por punto';

  @override
  String get producaoHistoricoTooltipVerMapa => 'Ver en el mapa';

  @override
  String get producaoHistoricoTooltipExportarCsv => 'Exportar como CSV';

  @override
  String producaoHistoricoErroCarregarPrefixo(String erro) {
    return 'Error al cargar la producción: $erro';
  }

  @override
  String producaoHistoricoErroExportarPrefixo(String erro) {
    return 'Error al exportar: $erro';
  }

  @override
  String get producaoHistoricoCsvCabecalho =>
      'Fecha/Hora,Especie,Clasificación,Cantidad (un.),Cantidad (kg),Latitud,Longitud,Observación';

  @override
  String producaoHistoricoCompartilharTexto(String kg) {
    return 'Historial de producción — $kg kg';
  }

  @override
  String get producaoHistoricoNenhumRegistro =>
      'Aún no hay registros de producción';

  @override
  String producaoHistoricoTotalResumo(String kg, int n) {
    return 'Total: $kg kg en $n registro(s)';
  }

  @override
  String producaoHistoricoClassificacaoEUnidades(
      String classificacao, int unidades) {
    return 'Clasificación $classificacao kg · $unidades un.';
  }

  @override
  String get producaoPorPontoTitulo => 'Producción por Punto';

  @override
  String producaoPorPontoErroCarregarPrefixo(String erro) {
    return 'Error al cargar: $erro';
  }

  @override
  String get producaoPorPontoVazioTitulo =>
      'Aún no hay producción asociada a un punto marcado';

  @override
  String get producaoPorPontoVazioDescricao =>
      'Registre capturas con coordenada y marque puntos en el mapa para ver aquí los puntos más productivos';

  @override
  String producaoPorPontoTotalRegistros(int n) {
    return '$n registro(s)';
  }

  @override
  String producaoPorPontoEspecieDestaque(String especie) {
    return ' · $especie destacada';
  }

  @override
  String get meusPontosTitulo => 'Mis Puntos';

  @override
  String get meusPontosNenhumTituloERecomendacao =>
      'Aún no hay puntos marcados ni recomendaciones';

  @override
  String get meusPontosSecaoPontosMarcados => 'PUNTOS MARCADOS';

  @override
  String get meusPontosSecaoRecomendacoes => 'RECOMENDACIONES';

  @override
  String get meusPontosDataDesconhecida => 'fecha desconocida';

  @override
  String meusPontosBannerOffline(String horario) {
    return 'Sin conexión — mostrando las últimas recomendaciones sincronizadas a las $horario';
  }

  @override
  String get meusPontosMarcadoEm => 'Marcado el';

  @override
  String get meusPontosProducaoAqui => 'Producción aquí';

  @override
  String meusPontosProducaoAquiValor(String kg, int n) {
    return '$kg kg ($n registro(s))';
  }

  @override
  String get meusPontosConsultarAqui => 'Consultar aquí';

  @override
  String get meusPontosMareEPescaAqui => 'Marea y Pesca aquí';

  @override
  String get mapaScreenTituloFallback => 'Mapa';

  @override
  String get mapaRotaProducao => 'Ruta de Producción';

  @override
  String get mapaSstLabel => 'SST';

  @override
  String get recomendacaoSemTitulo => '(sin título)';

  @override
  String get recomendacaoNenhumaDisponivel =>
      'No hay recomendaciones disponibles';

  @override
  String get recomendacaoExpirada => 'Expirada';

  @override
  String recomendacaoValidaAte(String data) {
    return 'Válida hasta $data';
  }

  @override
  String recomendacaoVarPrefixo(String variavel, String valor) {
    return 'Var. $variavel: $valor';
  }

  @override
  String recomendacaoPontosAbrev(int n) {
    return '$n pts';
  }

  @override
  String get recomendacaoVerNaCarta => 'Ver en la Carta';

  @override
  String recomendacaoKgEstimados(String kg) {
    return '$kg kg estimados';
  }

  @override
  String recomendacaoPontosAmostrados(int n) {
    return '$n puntos muestreados';
  }

  @override
  String get faseLuaTipoNovaLua => 'Luna Nueva';

  @override
  String get faseLuaTipoCrescente => 'Luna Creciente';

  @override
  String get faseLuaTipoQuartoCrescente => 'Cuarto Creciente';

  @override
  String get faseLuaTipoGibosaCrescente => 'Gibosa Creciente';

  @override
  String get faseLuaTipoCheia => 'Luna Llena';

  @override
  String get faseLuaTipoGibosaMinguante => 'Gibosa Menguante';

  @override
  String get faseLuaTipoQuartoMinguante => 'Cuarto Menguante';

  @override
  String get faseLuaTipoMinguante => 'Luna Menguante';

  @override
  String get tipoMareSizigiaLabel => 'Marea Viva';

  @override
  String get tipoMareSizigiaNota =>
      'Corrientes más fuertes, mayor amplitud de marea.';

  @override
  String get tipoMareQuadraturaLabel => 'Marea Muerta';

  @override
  String get tipoMareQuadraturaNota =>
      'Corrientes más débiles, menor amplitud de marea.';

  @override
  String get tipoMareTransicaoLabel => 'Transición';

  @override
  String get tipoMareTransicaoNota =>
      'Ni marea viva ni marea muerta — un período intermedio.';

  @override
  String get tendenciaPressaoCaindo => 'Bajando';

  @override
  String get tendenciaPressaoEstavel => 'Estable';

  @override
  String get tendenciaPressaoSubindo => 'Subiendo';

  @override
  String get tipoPeriodoSolunarMaior => 'Período Mayor';

  @override
  String get tipoPeriodoSolunarMenor => 'Período Menor';

  @override
  String get variavelAmbientalVento => 'Viento';

  @override
  String get variavelAmbientalCorrente => 'Corriente';

  @override
  String get variavelAmbientalClorofila => 'Clorofila';

  @override
  String get variavelAmbientalOnda => 'Ola';

  @override
  String get variavelAmbientalTemperatura => 'Temperatura';

  @override
  String get nivelOperacionalFavoravelTitulo =>
      'Condición potencialmente favorable';

  @override
  String get nivelOperacionalFavoravelTexto =>
      'Cuando varios indicadores oceanográficos convergen, la influencia de la marea puede reforzar una condición ya favorable.';

  @override
  String get nivelOperacionalAtencaoTitulo => 'Condición de atención';

  @override
  String get nivelOperacionalAtencaoTexto =>
      'La marea por sí sola no es suficiente para indicar una buena área de pesca.';

  @override
  String get nivelOperacionalBaixaEvidenciaTitulo => 'Baja evidencia';

  @override
  String get nivelOperacionalBaixaEvidenciaTexto =>
      'No utilice la fase de la marea como único motivo para desplazar la embarcación.';

  @override
  String get nivelOperacionalCardTitulo => 'Clasificación Actual';

  @override
  String get nivelOperacionalCardDescricao =>
      'Clasificación a partir de los indicadores que la app tiene hoy (marea astronómica + corriente medida) — no es una predicción de captura.';

  @override
  String get nivelOperacionalAgora => 'AHORA';

  @override
  String get estadoMareTitulo => 'ESTADO ACTUAL';

  @override
  String estadoMareTituloMare(String tipo) {
    return 'MAREA DE $tipo';
  }

  @override
  String get estadoMareFaseDaLua => 'FASE LUNAR';

  @override
  String estadoMareDiaDoCiclo(int n) {
    return 'día $n del ciclo';
  }

  @override
  String get estadoMareAmplitudePrevista => 'AMPLITUD PREVISTA (24H)';

  @override
  String get estadoMareProximaPreamar => 'PRÓXIMA PLEAMAR';

  @override
  String get estadoMareProximaBaixaMar => 'PRÓXIMA BAJAMAR';

  @override
  String get estadoMareDadoIndisponivel => 'Dato no disponible';

  @override
  String get estadoMareQuadratura => 'MAREA MUERTA';

  @override
  String get estadoMareSizigia => 'MAREA VIVA';

  @override
  String get classificacaoIndiceBaixa => 'Bajo';

  @override
  String get classificacaoIndiceModerada => 'Moderado';

  @override
  String get classificacaoIndiceAlta => 'Alto';

  @override
  String get indiceFatorFaseLunarNome =>
      'Fase lunar (proximidad a la marea viva)';

  @override
  String get indiceFatorAmplitudeNome => 'Amplitud de marea prevista';

  @override
  String get indiceFatorCorrenteNome => 'Velocidad de la corriente';

  @override
  String indiceFatorFaseLunarDetalhe(String fase, int dia) {
    return '$fase · día $dia del ciclo';
  }

  @override
  String indiceFatorAmplitudeDetalhe(String m) {
    return '$m m en las próximas 24h';
  }

  @override
  String indiceFatorCorrenteDetalhe(String ms) {
    return '$ms m/s ahora';
  }

  @override
  String get indiceInformativoDirecaoCorrente => 'Dirección de la corriente';

  @override
  String get indiceInformativoDiferencaTemperatura =>
      'Diferencia de temperatura';

  @override
  String get indiceInformativoProximidadeFrentes =>
      'Proximidad a frentes térmicos';

  @override
  String get indiceCardTitulo => 'Potencial de Influencia';

  @override
  String get indiceCardDescricao =>
      'Cuánto las condiciones de marea pueden estar contribuyendo a la dinámica oceanográfica de la región — no es una probabilidad de pescar atún.';

  @override
  String indiceCardPotencialPrefixo(String classificacao) {
    return 'Potencial $classificacao';
  }

  @override
  String get indiceCardFatoresConsiderados => 'FACTORES CONSIDERADOS';

  @override
  String get indiceCardInformativos =>
      'INFORMATIVOS (NO ENTRAN EN LA PUNTUACIÓN)';

  @override
  String get comparacaoSizigiaTitulo => 'Marea Viva';

  @override
  String get comparacaoSizigiaResumo => 'Mayor amplitud de marea';

  @override
  String get comparacaoSizigiaEfeito1 => 'Mayor variación del nivel del mar';

  @override
  String get comparacaoSizigiaEfeito2 =>
      'Corrientes de marea potencialmente más intensas en determinadas regiones';

  @override
  String get comparacaoSizigiaEfeito3 => 'Mayor transporte horizontal de agua';

  @override
  String get comparacaoSizigiaEfeito4 =>
      'Mayor mezcla en ambientes donde la marea ejerce fuerte influencia';

  @override
  String get comparacaoSizigiaEfeito5 =>
      'Alteración en la distribución/concentración de organismos que sirven de alimento a los peces';

  @override
  String get comparacaoSizigiaRelacaoPesca =>
      'En áreas donde las corrientes de marea tienen influencia significativa, los períodos de mayor amplitud pueden aumentar el movimiento y la mezcla del agua, pudiendo alterar la distribución de presas y crear condiciones favorables para la actividad de los atunes.';

  @override
  String get comparacaoSizigiaPotencial => 'ALTO';

  @override
  String get comparacaoQuadraturaTitulo => 'Marea Muerta';

  @override
  String get comparacaoQuadraturaResumo => 'Menor amplitud de marea';

  @override
  String get comparacaoQuadraturaEfeito1 =>
      'Corrientes de marea potencialmente menos intensas';

  @override
  String get comparacaoQuadraturaEfeito2 =>
      'Menor variación del nivel del agua';

  @override
  String get comparacaoQuadraturaEfeito3 =>
      'Menor influencia de la marea sobre la mezcla en determinadas regiones';

  @override
  String get comparacaoQuadraturaEfeito4 =>
      'Distribución diferente de organismos y presas';

  @override
  String get comparacaoQuadraturaRelacaoPesca =>
      'Durante la marea muerta, la menor amplitud de la marea puede resultar en menor influencia de las corrientes de marea en determinadas áreas. Sin embargo, esto no significa necesariamente menor actividad de atún, ya que temperatura, frentes oceánicos, alimento, profundidad y otros factores pueden ser más importantes.';

  @override
  String get comparacaoQuadraturaPotencial => 'MODERADO';

  @override
  String get comparacaoRelacaoPescaTitulo => 'RELACIÓN CON LA PESCA DE ATÚN';

  @override
  String comparacaoPotencialInfluencia(String potencial) {
    return 'Potencial de influencia: $potencial';
  }

  @override
  String get comparacaoRodape =>
      'Representa la fuerza potencial de la influencia de la marea, no una predicción directa de captura.';

  @override
  String get graficoMareSemDado => 'Dato no disponible para el gráfico de 24h';

  @override
  String get graficoMareCorrenteLabel => 'Corriente';

  @override
  String get graficoMareAgoraLabel => 'Ahora';

  @override
  String get janelaOperacionalTitulo => 'Ventana operativa';

  @override
  String get janelaOperacionalDescricao =>
      'Próximas horas — marea, corriente y temperatura reales de cada horario.';

  @override
  String get janelaObsSemDado =>
      'No hay suficiente dato de marea para este horario.';

  @override
  String get janelaObsEstofa =>
      'Período de estoa (marea parada). La corriente de marea tiende a ser débil en este horario.';

  @override
  String get janelaObsEnchente =>
      'Período de creciente. Observar zonas de convergencia y concentración de presas.';

  @override
  String get janelaObsVazante =>
      'Período de vaciante. Observar bordes de bancos y canales donde la corriente puede concentrar alimento.';

  @override
  String get explicacaoSizigiaTexto =>
      'En la Luna Nueva y la Luna Llena, las fuerzas gravitacionales del Sol y la Luna se combinan, aumentando la amplitud de las mareas.';

  @override
  String get explicacaoQuadraturaTexto =>
      'En los cuartos creciente y menguante, el Sol y la Luna ejercen sus fuerzas gravitacionales en direcciones aproximadamente perpendiculares, resultando en una menor amplitud de las mareas.';

  @override
  String get explicacaoEntendiBotao => 'Entendido';

  @override
  String get explicacaoSol => 'Sol';

  @override
  String get explicacaoTerra => 'Tierra';

  @override
  String get explicacaoLua => 'Luna';

  @override
  String get fluxoInfluenciaTitulo => 'Flujo de Influencia';

  @override
  String get fluxoInfluenciaSubtitulo => '¿Por qué esto importa para el atún?';

  @override
  String get fluxoEtapa1Titulo => 'Marea';

  @override
  String get fluxoEtapa1Sub => 'Marea viva o muerta';

  @override
  String get fluxoEtapa2Titulo => 'Corrientes';

  @override
  String get fluxoEtapa2Sub => 'Más o menos intensas';

  @override
  String get fluxoEtapa3Titulo => 'Mezcla / transporte de agua';

  @override
  String get fluxoEtapa3Sub => 'Movimiento de la columna de agua';

  @override
  String get fluxoEtapa4Titulo => 'Distribución de nutrientes y presas';

  @override
  String get fluxoEtapa4Sub => 'Dónde se concentra el alimento';

  @override
  String get fluxoEtapa5Titulo => 'Concentración de alimento';

  @override
  String get fluxoEtapa5Sub => 'Disponibilidad para el atún';

  @override
  String get fluxoEtapa6Titulo => 'Comportamiento de los atunes';

  @override
  String get fluxoEtapa6Sub => 'Desplazamiento y agregación';

  @override
  String get fluxoEtapa7Titulo => 'Potencial de actividad de pesca';

  @override
  String get fluxoEtapa7Sub => 'Un indicador entre varios';

  @override
  String get fluxoRodape =>
      'Esta es una posible cadena de influencia, no una relación determinística: cada etapa depende de factores locales (batimetría, topografía, régimen de corrientes de la región) que la marea por sí sola no explica.';

  @override
  String mareCardTipoLabel(String tipo) {
    return 'Marea de $tipo';
  }

  @override
  String get mapaCamadaTrilhaViagemTitulo => 'Trayecto del viaje';

  @override
  String get mapaCamadaTrilhaViagemSubtitulo =>
      'Trayecto del viaje en curso, actualizado en vivo';

  @override
  String get mapaTrilhaSemViagemAtiva =>
      'No hay ningún viaje en curso para mostrar el trayecto';

  @override
  String get mapaModoNavegacaoTooltip => 'Modo Navegación';
}
