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
}
