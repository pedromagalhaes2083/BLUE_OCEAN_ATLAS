class Constantes {
  static const String api = 'api_url';
  static const String authToken = 'auth_token';
  static const String authCredencial = 'auth_credencial';
  static const String deviceId = 'device_id';
  static const String organizacaoId = 'organizacao_id';
  static const String embarcacaoId = 'embarcacao_id';
  static const String intervaloRastreamentoMinutos =
      'intervalo_rastreamento_minutos';
  static const String modoNoturno = 'modo_noturno';
  static const String lembrarCredenciais = 'lembrar_credenciais';
  static const String contatoEmergenciaWhatsapp =
      'contato_emergencia_whatsapp';
  static const String ocultarRecomendacoesExpiradas =
      'ocultar_recomendacoes_expiradas';
  static const String temaModo = 'tema_modo';
  static const String idioma = 'idioma';
  static const String ultimaVerificacaoRecomendacoes =
      'ultima_verificacao_recomendacoes';
  static const String alcanceAlertaRotaMn = 'alcance_alerta_rota_mn';
  static const String ultimoAlertaCondicaoSeveraEm =
      'ultimo_alerta_condicao_severa_em';
  static const String cacheRecomendacoes = 'cache_recomendacoes';
  static const String cacheRecomendacoesEm = 'cache_recomendacoes_em';
  static const String alertaVentoAtivo = 'alerta_vento_ativo';
  static const String alertaVentoLimiarKmh = 'alerta_vento_limiar_kmh';
  static const String alertaOndaAtivo = 'alerta_onda_ativo';
  static const String alertaOndaLimiarM = 'alerta_onda_limiar_m';
  static const String alertaCorrenteAtivo = 'alerta_corrente_ativo';
  static const String alertaCorrenteLimiarNos = 'alerta_corrente_limiar_nos';
  static const String alertaTemperaturaAtivo = 'alerta_temperatura_ativo';
  static const String alertaTemperaturaLimiarC = 'alerta_temperatura_limiar_c';

  /// Pesos relativos de cada fator no cálculo da "Inteligência Oceânica"
  /// (ver `CalibracaoIntelligence`/`IntelligenceEngine`) — configuráveis na
  /// tela "Calibrar Inteligência".
  static const String intelligencePesoSst = 'intelligence_peso_sst';
  static const String intelligencePesoCorrente = 'intelligence_peso_corrente';
  static const String intelligencePesoClorofila = 'intelligence_peso_clorofila';
  static const String intelligencePesoOndas = 'intelligence_peso_ondas';
  static const String intelligencePesoVento = 'intelligence_peso_vento';

  /// Quantidade ideal de cada variável — o valor que dá a nota máxima no
  /// fator correspondente (ver `CalibracaoIntelligence`), também
  /// configurável na tela "Calibrar Inteligência".
  static const String intelligenceIdealSstC = 'intelligence_ideal_sst_c';
  static const String intelligenceIdealCorrenteNos =
      'intelligence_ideal_corrente_nos';
  static const String intelligenceIdealClorofilaMgM3 =
      'intelligence_ideal_clorofila_mg_m3';
  static const String intelligenceIdealOndaM = 'intelligence_ideal_onda_m';
  static const String intelligenceIdealVentoKmh =
      'intelligence_ideal_vento_kmh';

  /// Id do usuário do último login bem-sucedido — comparado a cada login
  /// novo pra detectar troca de usuário no mesmo aparelho (ver
  /// `AuthService._tratarTrocaDeUsuario`) e decidir se limpa os dados
  /// locais do usuário anterior.
  static const String ultimoUsuarioId = 'ultimo_usuario_id';

  /// Plano comercial ativo (`PlanoAtlas.name`) — hoje só lido/gravado
  /// localmente (`FontePlanoLocal`, sem backend expondo plano ainda; ver
  /// `core/planos/`). Seletor de troca fica em Configurações, só em modo
  /// debug (ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md` §2.2).
  static const String planoAtual = 'plano_atual';
}
