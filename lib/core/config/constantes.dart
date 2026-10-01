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
  /// — hoje o índice de favorabilidade de atum (temperatura, salinidade,
  /// clorofila, corrente, batimetria; ver `CalibracaoIntelligence`/
  /// `IntelligenceEngine`) — configuráveis na tela "Calibrar Inteligência".
  static const String intelligencePesoTemperatura =
      'intelligence_peso_temperatura';
  static const String intelligencePesoSalinidade =
      'intelligence_peso_salinidade';
  static const String intelligencePesoClorofila = 'intelligence_peso_clorofila';
  static const String intelligencePesoCorrente = 'intelligence_peso_corrente';
  static const String intelligencePesoBatimetria =
      'intelligence_peso_batimetria';

  /// Faixa ideal (nota máxima) e margem além dela (nota parcial, "moderada")
  /// de cada variável (ver `CalibracaoIntelligence`), configuráveis na tela
  /// "Calibrar Inteligência".
  static const String intelligenceTemperaturaIdealMinC =
      'intelligence_temperatura_ideal_min_c';
  static const String intelligenceTemperaturaIdealMaxC =
      'intelligence_temperatura_ideal_max_c';
  static const String intelligenceTemperaturaMargemC =
      'intelligence_temperatura_margem_c';
  static const String intelligenceSalinidadeIdealMinUps =
      'intelligence_salinidade_ideal_min_ups';
  static const String intelligenceSalinidadeIdealMaxUps =
      'intelligence_salinidade_ideal_max_ups';
  static const String intelligenceSalinidadeMargemUps =
      'intelligence_salinidade_margem_ups';
  static const String intelligenceClorofilaIdealMinMgM3 =
      'intelligence_clorofila_ideal_min_mg_m3';
  static const String intelligenceClorofilaIdealMaxMgM3 =
      'intelligence_clorofila_ideal_max_mg_m3';
  static const String intelligenceClorofilaMargemMgM3 =
      'intelligence_clorofila_margem_mg_m3';
  static const String intelligenceCorrenteIdealMinNos =
      'intelligence_corrente_ideal_min_nos';
  static const String intelligenceCorrenteIdealMaxNos =
      'intelligence_corrente_ideal_max_nos';
  static const String intelligenceCorrenteMargemNos =
      'intelligence_corrente_margem_nos';
  static const String intelligenceBatimetriaIdealMinM =
      'intelligence_batimetria_ideal_min_m';
  static const String intelligenceBatimetriaIdealMaxM =
      'intelligence_batimetria_ideal_max_m';
  static const String intelligenceBatimetriaMargemM =
      'intelligence_batimetria_margem_m';

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
