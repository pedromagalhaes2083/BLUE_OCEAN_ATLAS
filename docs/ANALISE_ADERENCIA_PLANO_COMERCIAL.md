# Análise de Aderência — Plano Comercial × Código Atual

**Data:** 2026-09-24
**Escopo:** leitura de `docs/Plano_Comercial_Blue_Ocean_Atlas.docx`, `DOCUMENTACAO.md`, `AUDITORIA_BLUE_OCEAN_ATLAS.md` e o código em `lib/`. **Nenhum código de produção foi alterado nesta fase.**
**Metodologia:** para cada item, o código-fonte foi lido diretamente (`grep`/leitura de arquivo) — a `DOCUMENTACAO.md` foi usada só como mapa inicial, nunca como fonte final, porque **está desatualizada em pontos estruturais** (ver nota abaixo). Onde a documentação e o código atual divergem, o código manda.

> ⚠️ **`DOCUMENTACAO.md` está parcialmente desatualizada.** Ela descreve `CadastrarEmbarcacaoScreen` e `NovaViagemScreen` como telas do app — **essas telas não existem mais no código atual**. Uma mudança de arquitetura de 2026-09 (ver `ContextoViagemService`) moveu a criação de viagem e de embarcação inteiramente para a retaguarda/plataforma: o app hoje só *espelha* a viagem ativa e a embarcação vinculada a ela (`ViagemRepository.buscarAtual()`, `EmbarcacaoRepository`), nunca cria ou edita nenhuma das duas localmente. Isso tem impacto direto na leitura do item "Cadastro de embarcação e tripulação" do plano (seção 3, abaixo) e é a primeira coisa que recomendo atualizar na própria `DOCUMENTACAO.md`, fora do escopo desta análise.

> ℹ️ **Idiomas:** o plano/prompt fala em pt/es/fr, mas o `l10n.yaml` atual declara **5 idiomas**: `pt` (template), `en`, `es`, `fr`, `it`. Toda string nova da Fase 2 deve cobrir os 5, não só 3.

> ℹ️ **Testes:** a `AUDITORIA_BLUE_OCEAN_ATLAS.md` (2026-09-02) registra 91/91. O `flutter analyze`/`flutter test` executados agora, nesta análise, confirmam o estado atual (ver rodapé deste documento) — o número de testes cresceu desde a auditoria por causa de features novas no meio tempo.

---

## 1. Inventário de funcionalidades × código

Legenda de status: **Existe** (implementado e funcionando hoje, sem gate de plano) · **Parcial** (existe uma versão, mas não cobre tudo que o plano promete pro item, ou falta a variante "básica"/"completa") · **Não existe**.

### 1.1 Matriz funcional (seção 8 do plano)

| # | Funcionalidade (matriz) | Status | Onde está | Plano que deveria liberar | Observações |
|---|---|---|---|---|---|
| 1 | GPS / posição | Existe | `core/services/location_service.dart`, `PosicaoAtualWidget`, GPS em toda tela de mapa/produção | Todos (Start+) | Essencial — não deve ser bloqueado por plano (regra 5 do pedido). |
| 2 | Mapas e pontos | Existe | `features/mapa/` inteiro (`MapaWidget`, `ponto_marcado`) | Todos (Start+) | Idem — navegação essencial. |
| 3 | Rotas — Manual | Existe | `features/rotas/` + modo "Planejar rota" em `mapa_widget.dart` (retículo + botão "Adicionar ponto", calibrado nesta mesma sessão) | Start+ | — |
| 4 | Rotas — Manual + histórico | Existe | `RotaPlanejada.embarcacaoId != null` — gerada automaticamente ao finalizar viagem a partir de `producao_registro` (`HistoricoLocalizacoesScreen._finalizarViagem`) | Pro+ | Hoje roda pra qualquer usuário, sem gate. |
| 5 | Rotas — Manual + inteligente | **Não existe** | — | Offshore | Nenhum código, modelo ou endpoint com esse conceito foi encontrado (busca por "inteligente"/"IA"/"algoritmo" em `rotas/` e `recomendacao/` não retornou nada). É 100% a construir — provavelmente depende de backend (roteamento derivado de recomendações/histórico), não é um "gate de UI" sobre algo que já existe. |
| 6 | Cartas offline — Básico (Start) vs completo (Pro/Offshore) | Parcial | `assets/cartas/OUTPUT_FILE.mbtiles` (carta única, embutida, sempre disponível) + `CartasScreen`/`MinhasSolicitacoesScreen` (lista/baixa cartas do S3, `carta_nautica`) + `StreetMapCacheService.baixarRegiao` (cache de mapa de ruas por região) | Start = básico, Pro/Offshore = completo | **Não há hoje nenhuma distinção de nível** — todo usuário vê a mesma carta bundled e pode baixar as mesmas cartas do S3 e a mesma região de ruas. Ver ambiguidade §3.1. |
| 7 | Meteorologia — Básica vs Completa | Parcial | `CondicoesMarScreen`/`CondicoesPontoScreen` (vento, corrente, onda, swell, maré, SST — tudo junto, uma tela só) via `PrevisaoTempoRepository`/`WaveForecastRepository` | Start = básica, Pro/Offshore = completa | **Só existe a versão completa hoje** — não há uma tela/variante "básica" com menos variáveis. Ver ambiguidade §3.2. |
| 8 | Maré | Existe | `WaveForecast.eventosMare`, `MareCard`, `DadosOceanicosPonto` | Todos (Start+) | Já incluso na mesma chamada de vento/onda — não é "destacável" sozinho sem refatorar `WaveForecastRepository.buscar()`. |
| 9 | Profundidade | Existe | `ProfundidadeRepository`, `ProfundidadeCard`, camada no mapa | Todos (Start+) | — |
| 10 | SST | Existe | Grade de temperatura no mapa (`_mostrarGradeTemperatura`, `WaveForecastRepository.buscarGrade`, com múltiplos pontos e botão "+", calibrado nesta sessão) + campo em `DadosOceanicosPonto` | Pro+ | Hoje visível a todos via o menu lateral do mapa. Bom candidato a `RecursoAtlas.sst` claro. |
| 11 | Correntes | Existe (não é feature nova) | `WaveForecast.oceanCurrentVelocity/Direction`, já mostrado em `CondicoesMarScreen`, `DadosOceanicosPonto`, `AlertaRotaScreen` | Pro+ | O plano trata "Correntes" como item ✓/— separado de "Meteorologia" na tabela, mas no código é **o mesmo dado da mesma chamada** de vento/onda — não dá pra gatear "correntes" sem também decidir o que fazer com o resto da tela que já mostra vento/onda/maré junto. Ver ambiguidade §3.4. |
| 12 | Produção — Básica vs Detalhada | Parcial | `ProducaoScreen` (tipo do peixe, classificação por faixa de peso, quantidade, peso estimado — já é "detalhado" por padrão), `producao_registro` (schema v11 completo) | Start = básica, Pro/Offshore = detalhada | **Só existe a versão detalhada hoje.** Não há um formulário "básico" (ex: só peso total, sem espécie/classificação). Ver ambiguidade §3.3. |
| 13 | Mapa de produtividade | Existe (local, heurístico) | `IndiceProdutividadeBlueOcean` (`features/mapa/domain/models/`) — combina clorofila-a + SST num nível (Ruim/Bom/Ótimo/Excelente), camada "Índice de Produtividade Blue Ocean" no mapa (`_mostrarIndiceProdutividade`) | Pro+ | É um cálculo **local**, no dispositivo, não vem do backend — não é o mesmo conceito de "produtividade por área" da seção Offshore do plano (que soa a agregação histórica de produção real, não heurística ambiental). Ver ambiguidade §3.5 — pode ser que o plano precise de DOIS conceitos distintos aqui. |
| 14 | Rastreamento | Existe | `LocationTrackingService`, `LocalizacaoReporterService`, roda automaticamente com viagem ativa (`DashboardScreen`) | Pro+ | Hoje roda pra qualquer usuário logado com viagem ativa, sem gate — inclui envio de posição em segundo plano (WorkManager, 15 min). |
| 15 | Recomendações | Existe | `features/recomendacao/` inteiro — `Recomendacao` já tem `score` (num), `confianca` (int), `validoAte` (DateTime?), pontos sugeridos (`PontoRecomendacao`), vem 100% do backend (`RecomendacaoRepository`) | Pro = "—/básicas", Offshore = "Avançadas" | Modelo já suporta tudo que o plano pede pro Offshore (score/confiança/validade) — **não há hoje diferença de "básica" vs "avançada" no app**, o app só exibe o que a API manda. A diferenciação Pro-vs-Offshore, se existir, provavelmente é decidida no **backend** (o que ele retorna pra cada plano), não no app. Ver ambiguidade §3.3. |
| 16 | Alertas — Básicos vs Avançados | Parcial | `AlertaCondicaoNotificationService` (vento/corrente/onda/swell severos no ponto à frente, foreground **e** background) + `AlertaRotaScreen` (mesmos dados, manual) | Pro = básicos, Offshore = avançados | **Só existe UM nível de alerta hoje** — os mesmos 4 tipos (vento/corrente/onda/swell), o mesmo limiar, tanto em primeiro quanto em segundo plano. Regra 5 do pedido: alertas críticos de condição adversa **não podem ser bloqueados por plano**. Ver ambiguidade §3.6. |
| 17 | Dashboard web | Não existe (fora de escopo mobile) | — | Offshore | Plataforma separada — só documentar necessidade, não implementar (regra "fora de escopo" do pedido). |
| 18 | Gestão de frota | Não existe no app | — | Offshore/Fleet | Mesma observação — web/B2B, fora de escopo mobile. |
| 19 | Suporte (Padrão/Prioritário/Especializado) | Não existe no app | — | — | Não é uma feature de código, é um SLA operacional — não requer nada no app além de, talvez, mostrar o nível de suporte na tela Planos (Fase 2.4). |

### 1.2 Itens das seções 4–7 do plano (detalhamento por plano)

| Item do plano | Status | Onde está |
|---|---|---|
| Distância até pontos (Start) | Existe | Cálculo de distância náutica já usado em `_mostrarInfoPontoMarcado`/`DadosOceanicosPonto` (`calcularDistanciaNauticas`, `core/utils/proximidade.dart`) |
| Registro básico da produção (Start) | Parcial | Ver item 12 acima — hoje só existe a versão completa |
| Funcionamento offline + sincronização (todos os planos) | Existe | Confirmado pela própria `AUDITORIA_BLUE_OCEAN_ATLAS.md` (seção "Offline") — modelo local-first real em viagem/produção/localização/portos/embarcação. **Este item deve continuar liberado em todos os planos** — já é assim, e é requisito explícito do plano comercial. |
| Registro detalhado da produção por espécie/quantidade/peso/localização (Pro) | Existe | `ProducaoScreen`, `producao_registro` v11 |
| Histórico das capturas (Pro) | Existe | `ProducaoHistoricoScreen` |
| Produção por ponto (Pro) | Existe | `ProducaoPorPontoScreen`, `producao_pontos_analyzer.dart` |
| Histórico da trajetória (Pro) | Existe | `HistoricoLocalizacoesScreen` |
| Pontos de pesca salvos (Pro) | Existe | `ponto_marcado` (na prática já funciona no Start hoje — "Mapas e pontos" é item comum a todos os planos na matriz da seção 8; a seção 5 lista "Pontos de pesca salvos" só no Pro — **contradição interna do próprio plano**, ver ambiguidade §3.7) |
| Score/confiança/validade da recomendação (Offshore) | Existe no modelo | Ver item 15 acima |
| Cruzamento de condições oceanográficas (Offshore) | Parcial | `IndiceProdutividadeBlueOcean` já cruza SST+clorofila; não cruza vento/onda/corrente/profundidade |
| Histórico de produtividade por área (Offshore) | Não existe | Nenhuma agregação por "área" (região/polígono) encontrada — `producao_pontos_analyzer.dart` agrupa por **ponto marcado** (raio de 5mn), não por área arbitrária |
| Alertas de vento/ondas/condições adversas (Offshore) | Existe, sem gate | Ver item 16 acima — hoje é universal |
| Gestão de viagens (Offshore) | **Mudou de arquitetura** | Viagem hoje vem 100% do backend (`ContextoViagemService`/`ViagemRepository.buscarAtual()`) — o app não cria/edita viagem, só espelha a ativa. "Gestão de viagens" como o plano descreve (cadastro, múltiplas viagens) parece já ter migrado pra fora do app mobile. Precisa de decisão do usuário — ver ambiguidade §3.8. |
| Cadastro de embarcação e tripulação (Offshore) | **Mudou de arquitetura** / Parcial | Embarcação: mesmo caso da viagem, vem do backend (`EmbarcacaoRepository`), sem tela de cadastro local. Tripulação: `Tripulante` **ainda não tem nenhuma persistência** (nem local nem remota) — `nova_tripulacao.dart` existe mas o modelo não serializa. |
| Produção por viagem (Offshore) | Existe (já é assim pra todos) | `producao_registro.viagem_id`, filtros por viagem em `ProducaoHistoricoScreen` |
| Rotas derivadas da operação (Offshore) | Existe (já é assim pra todos) | Mesmo mecanismo do item 4 acima (`rota_planejada.embarcacaoId != null`) |

---

## 2. Lacunas

Priorizadas pelo fluxo de demonstração comercial (seção 11 do plano): **posição → rota/ponto → SST/vento/ondas/corrente/profundidade → captura georreferenciada → histórico → mapa de produtividade → recomendação → offline → (dashboard de frota, quando aplicável)**.

| Prioridade | Lacuna | Impacto na demo |
|---|---|---|
| 🔴 Alta | **Nenhum conceito de plano/assinatura/entitlement existe no app.** Todo usuário logado vê tudo. | Bloqueia a Fase 2 inteira — é o objetivo central deste trabalho. |
| 🔴 Alta | Sem card de upgrade / UI de "isto é Pro/Offshore" em lugar nenhum. | A demo comercial de hoje não consegue mostrar a diferença entre planos — tudo aparece igual pra qualquer conta. |
| 🟠 Média | "Rotas inteligentes" (Offshore) não existe em nenhuma forma — nem heurística local, nem placeholder. | Passo 2 do fluxo de demo ("mostrar uma rota") funciona para manual/histórico, mas "inteligente" não tem o que mostrar. |
| 🟠 Média | "Produtividade por área" (agregação histórica por região, Offshore) não existe — só o índice heurístico ambiental (SST+clorofila) e o ranking por ponto marcado. | Passo 6 da demo ("mostrar o mapa de produtividade") tem uma versão real pra mostrar (o índice), mas não é exatamente o que o plano descreve pro Offshore. |
| 🟡 Baixa | Sem variante "básica" pra Cartas offline, Meteorologia e Produção — hoje é tudo-ou-nada. | Só afeta a diferenciação Start-vs-Pro, não trava a demo em si (a versão completa cobre a demo de sobra). |
| 🟡 Baixa | Sem distinção de "alerta básico" vs "avançado". | Idem — a demo mostra o alerta que já existe hoje; a diferenciação de nível é decisão a tomar, não um bloqueio técnico. |
| 🟢 Ignorável pro mobile | Dashboard web e gestão de frota (Offshore/Fleet) | Fora de escopo do app — só precisa aparecer documentado/mencionado na tela Planos como "disponível na plataforma web". |

---

## 3. Ambiguidades do plano que precisam de decisão

### 3.1 Cartas offline — "Básico" (Start) vs "completo" (Pro/Offshore)
Hoje **não existe diferença de nível**: a carta bundled (`OUTPUT_FILE.mbtiles`) e o download de cartas do S3/região de ruas funcionam igual pra qualquer usuário. Possíveis interpretações, preciso que você escolha uma (ou proponha outra):
- **(a)** Start = só a carta bundled; Pro/Offshore = pode baixar cartas adicionais do S3 e regiões de mapa de ruas.
- **(b)** Start = carta bundled + baixar cartas, mas sem cache de região de ruas (`StreetMapCacheService.baixarRegiao` vira Pro+).
- **(c)** Não gatear nada aqui agora (cartas offline sempre liberado a todos, já que é segurança de navegação) — manter fora da matriz de entitlements.

### 3.2 Meteorologia — "Básica" (Start) vs "Completa" (Pro/Offshore)
`CondicoesMarScreen`/`CondicoesPontoScreen` mostram vento + onda/swell + corrente + maré + SST numa tela só, sem separação. Preciso saber o que "básica" deveria esconder:
- **(a)** Básica = só vento + previsão do tempo (`PrevisaoTempoRepository`); completa = adiciona onda/swell/corrente/SST/maré (`WaveForecastRepository`).
- **(b)** Básica = mostra tudo, mas só o valor atual (sem a série horária/próximas horas); completa = com a série.
- **(c)** Não distinguir — meteorologia sempre completa pra todos (é dado de segurança de navegação, mesma lógica do item 3.1-c).

### 3.3 Produção — "Básica" (Start) vs "Detalhada" (Pro/Offshore); e Recomendações "—/básicas" (Pro)
- Produção: **(a)** Básica = só peso total + posição (sem espécie/classificação/quantidade de unidades); Detalhada = formulário completo atual. **(b)** Não distinguir, produção sempre completa.
- Recomendações no Pro: o plano marca "—/básicas" (incerto no próprio documento). **(a)** Pro não vê recomendação nenhuma (só Offshore); **(b)** Pro vê recomendação sem score/confiança/pontos sugeridos (só título/descrição); **(c)** a diferenciação é feita pelo **backend** (retorna menos/mais recomendações pro Pro) e o app só teria um `RecursoAtlas.recomendacoes` (Pro+) e `RecursoAtlas.recomendacoesAvancadas` (Offshore, controla exibição de score/confiança/pontos).

### 3.4 "Correntes" como item separado de "Meteorologia" na matriz
No código, corrente é só mais um campo de `WaveForecast`, obtido na mesma chamada de vento/onda/maré — não dá pra "esconder só corrente" sem redesenhar a tela. Preciso saber se:
- **(a)** É pra valer como redação da matriz mas, na prática, cai dentro do gate geral de "Meteorologia completa" (§3.2) — ou seja, `RecursoAtlas.meteorologiaCompleta` cobre onda+corrente+SST+maré juntos.
- **(b)** É pra ter um gate próprio (`RecursoAtlas.correntes`), escondendo só a linha/card de corrente na tela, com onda/vento/maré continuando liberados no Start.

### 3.5 "Mapa de produtividade" — o índice heurístico local é a mesma coisa?
`IndiceProdutividadeBlueOcean` (SST+clorofila, calculado no dispositivo) é o candidato mais próximo hoje, mas "produtividade por área"/"pontos mais produtivos" (seção 6 do plano) soa como agregação **histórica de produção real** por região — que não existe (`producao_pontos_analyzer.dart` agrupa por ponto marcado, não por área). Preciso saber se, pra efeito de Fase 2:
- **(a)** `RecursoAtlas.mapaProdutividade` gateia o índice heurístico existente (rápido de implementar, já existe).
- **(b)** É outra coisa a construir (histórico de produção por área/polígono) — nesse caso fica marcado como lacuna a implementar depois do backend suportar, não algo que a Fase 2 resolve com gate de UI.

### 3.6 Alertas — "Básicos" (Pro) vs "Avançados" (Offshore)
Só existe um nível de alerta hoje (vento/corrente/onda/swell severos, mesmo limiar). Preciso saber:
- **(a)** Básico = só notificação em primeiro plano (`AlertaRotaScreen`, manual); Avançado = também em segundo plano/background (viagem em andamento, `location_worker`).
- **(b)** Básico = só vento+onda; Avançado = adiciona corrente+swell.
- **(c)** Não é gateável hoje sem mudar os limiares/pipeline — deixar liberado pra todos por ora (reforça a regra 5: nunca bloquear alerta crítico de condição adversa), e resolver "avançado" como trabalho futuro (ex: alertas customizáveis, mais variáveis).

Independente da resposta, a regra 5 do pedido (nunca bloquear alerta crítico de segurança) deve prevalecer — o `RecursoAtlas` de alerta, se existir, deveria no mínimo garantir que o alerta de condição severa nunca fique totalmente mudo, mesmo no Start.

### 3.7 Contradição interna do próprio plano — "Pontos de pesca salvos"
A seção 5 (Atlas Pro) lista "Pontos de pesca salvos" como diferencial do Pro, mas a seção 8 (matriz) marca "Mapas e pontos" com ✓ pros três planos, incluindo Start. Preciso que você decida qual das duas prevalece — a matriz (item comum a todos) ou a lista do Pro (exclusivo). Assumi a matriz como fonte de verdade no inventário acima (item 1.1), mas quero confirmação.

### 3.8 Como o Fleet (e a mudança de arquitetura viagem/embarcação) se manifesta no mobile
Com viagem e embarcação já vindas do backend pra todo mundo (não só Fleet), o que resta pro app mobile distinguir Fleet de Offshore? Possibilidades:
- **(a)** Fleet no mobile é idêntico ao Offshore (a diferença de frota é 100% na plataforma web) — o app só precisa reconhecer o plano `fleet` como "tem tudo que Offshore tem".
- **(b)** Fleet no mobile ganha um seletor de embarcação (hoje o app já tem conceito de "embarcação ativa" em `Constantes.embarcacaoId`/Configurações) pra trocar entre embarcações da frota sem precisar de outra conta.

---

## 4. Proposta de arquitetura de entitlements

### 4.1 Fonte do plano (abstraída, sem inventar contrato de backend)

```
lib/core/planos/
├── plano_atlas.dart          # enum PlanoAtlas
├── recurso_atlas.dart        # enum RecursoAtlas
├── matriz_entitlements.dart  # Map<PlanoAtlas, Set<RecursoAtlas>> — fonte única, testável
├── fonte_plano.dart          # abstract class FontePlano { Future<PlanoAtlas> obterPlanoAtual(); }
├── fonte_plano_local.dart    # implementação local/config (via Config/Hive) — usada hoje
├── fonte_plano_remota.dart   # implementação futura — lê de Organizacao/Embarcacao/endpoint dedicado
└── plano_service.dart        # PlanoService — namespace estático, mesmo padrão de AuthService/Config
```

`FontePlano` é uma interface simples (`abstract class`, sem pacote de DI — o projeto não usa Provider/Riverpod/get_it, então a escolha de implementação é feita dentro do próprio `PlanoService`, no mesmo espírito de como `ApiService`/`Config` já resolvem coisas hoje: um método estático decide qual fonte usar). Isso cumpre a regra 2 do pedido (fonte abstraída, local agora / remota depois) sem introduzir gerenciador de estado novo.

### 4.2 Onde o plano da embarcação ativa deveria vir, quando o backend existir

Duas opções, ambas plausíveis dado o que já existe:
1. **Campo em `Organizacao`** (`GET autenticacao/eu/organizacoes` já retorna `{id, nome, documento}` — adicionar `plano`). Mais simples, mas assume plano por organização, não por embarcação — **não bate com o modelo "SaaS por embarcação ativa" do plano comercial** (uma organização pode ter Start pra uma embarcação e Fleet pra outra, no caso de armador com frota mista).
2. **Campo em `Embarcacao`/`EmbarcacaoRemota`** (`features/embarcacao/domain/models/embarcacao_remota.dart`, já vem do backend via `EmbarcacaoRepository`) — mais alinhado ao "por embarcação ativa", mas exige que o backend já resolva "qual embarcação" antes de saber o plano.

Recomendo **(2)**, com fallback pra **(1)** se o backend não conseguir resolver embarcação (ex: usuário sem viagem ativa ainda) — replicando exatamente o padrão que `ContextoViagemService` já usa pra resolver embarcação a partir da viagem ativa. Ver proposta de contrato em §5.

### 4.3 Cache offline e período de carência

Mesmo padrão de `Config`/Hive já usado por token/credenciais/preferências:
- `PlanoService` grava o último plano confirmado (`Config.grava('planoAtual', plano.name)`) toda vez que consegue resolver via `FontePlanoRemota`.
- Junto, grava um timestamp (`Config.grava('planoAtualObtidoEm', DateTime.now().toIso8601String())`).
- **Precisa de decisão sua:** qual o período de carência sem conexão antes de um plano "expirado" cair pro Start (ou continuar valendo indefinidamente offline)? Proposta de default, ajustável: **7 dias** — dá margem pra uma maré/embarque longo sem sinal, sem virar uma brecha permanente de "nunca mais preciso confirmar o plano". Depois de expirado, mostrar aviso "não foi possível confirmar seu plano — funcionalidades completas voltam assim que sincronizar" em vez de simplesmente travar.

### 4.4 Downgrade

Regra proposta: **dados já criados continuam visíveis e em modo somente-leitura**; a criação de dado novo é que fica bloqueada. Ex: usuário tinha Pro, registrou 50 pontos de SST no mapa, faz downgrade pra Start — os 50 pontos continuam no banco local e visíveis (já foram baixados/gravados), mas o botão "+" de adicionar mais um some (ou vira card de upgrade). Isso é consistente com o modelo offline-first do app (nunca apagar dado local por causa de uma mudança de permissão remota) — **precisa de confirmação sua**, é a interpretação mais conservadora, mas existe a alternativa "esconder tudo que não é do plano atual, mesmo já criado".

### 4.5 Teste da matriz como fonte da verdade

`test/core/planos/matriz_entitlements_test.dart` — um teste por linha da tabela da seção 8, comparando `matrizEntitlements[PlanoAtlas.x].contains(RecursoAtlas.y)` contra o valor esperado transcrito diretamente da tabela do plano (não do código) — garante que qualquer edição futura na matriz seja intencional e vísivel no diff do teste.

---

## 5. Proposta de contrato de API (backend não existe neste repo — isto é uma proposta, não uma implementação)

### 5.1 Opção recomendada — campo em `Embarcacao`

`GET /api/v1/embarcacoes/{id}` (endpoint já implícito em `EmbarcacaoRepository`, a confirmar nome exato com o backend) passaria a incluir:

```json
{
  "id": "c8f1da10-...",
  "nome": "Blue Ocean Navy",
  "organizacaoId": "...",
  "plano": {
    "codigo": "pro",
    "nome": "Atlas Pro",
    "ativo": true,
    "expiraEm": "2026-10-24T00:00:00Z",
    "recursos": ["sst", "correntes", "mapaProdutividade", "rastreamento", "rotasHistorico", "recomendacoes"]
  }
}
```

Campos:
- `codigo`: um dos valores de `PlanoAtlas` (`start`/`pro`/`offshore`/`fleet`) — meio de resolver o plano mesmo se a matriz local estiver desatualizada em relação ao backend.
- `recursos`: **opcional, mas recomendado** — lista explícita dos `RecursoAtlas` liberados. Permite ao backend fazer exceções pontuais (ex: cliente negociou um recurso extra fora do plano padrão) sem esperar uma nova versão do app. Se ausente, o app usa a matriz local (`matrizEntitlements[codigo]`) como fallback.
- `expiraEm`: usado pro período de carência (§4.3) — se `null`, assume-se sem expiração conhecida (assinatura ativa sem data de corte visível ao app).

### 5.2 Alternativa — endpoint dedicado

`GET /api/v1/embarcacoes/{id}/plano` (ou `/organizacoes/{id}/plano`), corpo igual ao campo `plano` acima. Mais simples de versionar independente do resto do cadastro de embarcação, mas mais uma chamada de rede — só faz sentido se o backend preferir não misturar dado comercial com dado operacional na mesma resposta.

**Ambos exigem decisão do time de backend** — o app está pronto pra consumir qualquer um dos dois formatos, a interface `FontePlano` isola essa escolha.

---

## 6. Riscos

### 6.1 Política das lojas para assinaturas digitais
Como o plano determina explicitamente "não implementar cobrança nem pagamento dentro do app" (regra 4), o app fica na categoria de **"reader app"/serviço externo** — Google Play e App Store toleram isso desde que **nenhuma tela do app** direcione pra compra/assinatura de forma que pareça ser dentro do app. A tela Planos (Fase 2.4) deve deixar claro que o CTA ("Falar com a Blue Ocean") abre um canal externo (WhatsApp/e-mail via `url_launcher`, que já é dependência do projeto) — nunca simular um checkout. Risco principal: a Apple é historicamente mais rígida com esse tipo de app do que a Google — se e quando o app for pra iOS de verdade (a própria auditoria já registra que o rastreamento em background não funciona lá hoje), vale revisar a política de "External Purchase" da Apple antes de publicar a tela Planos lá.

### 6.2 Bloqueios que poderiam afetar segurança
Nenhum encontrado nesta análise que já exista no código — o risco é **introduzir** um na Fase 2. Pontos a proteger explicitamente (regra 5 do pedido), com um teste dedicado depois:
- GPS/posição atual, mapa base, marcação de ponto.
- `AlertaCondicaoNotificationService` (condição severa) — mesmo se "alertas avançados" virar Offshore, o alerta básico de segurança não pode ficar mudo no Start.
- SOS — **não encontrei uma feature de SOS explícita no código atual** (nenhum arquivo/tela com esse nome). Se existir sob outro nome, sinalizar antes da Fase 2 pra garantir que fique fora de qualquer gate; se realmente não existir ainda, não é escopo desta análise criá-la, só registrar que a regra 5 do pedido já a menciona como preexistente.

### 6.3 Textos que prometem captura ou se apresentam como substituto de equipamento certificado
Busca ampla (ARBs em pt, telas de splash/login/sobre, `README.md`) **não encontrou nenhuma frase prometendo resultado de captura** nem se apresentando como substituto de equipamento náutico certificado. Também **não encontrei nenhum aviso/disclaimer existente** no sentido oposto — hoje o app simplesmente não fala sobre isso em nenhuma direção. A tarefa da Fase 2.5 (adicionar o aviso "sistema de apoio à navegação") é, portanto, **puramente aditiva** — não há texto de risco pra remover, só o aviso novo pra inserir.

---

## 7. Plano de implementação da Fase 2 (proposto — aguardando aprovação + respostas do §3)

Ordem sugerida, cada uma como commit próprio na branch `feat/planos-comerciais`:

1. **Domínio de planos** (`core/planos/`: enums, matriz, `PlanoService`) + teste da matriz linha-a-linha. Sem nenhum ponto de UI tocado ainda — só a fundação, testável isoladamente.
2. **Seletor de plano em debug** (Configurações ou `api_tester`, `kDebugMode`-gated) — necessário antes do passo 3 pra poder testar visualmente cada gate sem esperar o backend.
3. **Widget `RecursoProtegido` + card de upgrade** — genérico, sem aplicar em nenhuma tela ainda; um teste de widget cobrindo os dois caminhos (libera o `child`; mostra o card).
4. **Aplicar `RecursoProtegido`** nos pontos mapeados no §1 — um commit por área (`mapa` primeiro, por concentrar mais itens: SST, índice de produtividade; depois `metereologia`/alertas; depois `producao`/histórico/por-ponto; depois `viagem`/tripulação se as ambiguidades §3.6/§3.8 forem resolvidas a tempo).
5. **Tela "Planos"** (Configurações) — depende do passo 1 pronto, independente dos passos 3–4.
6. **Textos de posicionamento** (aviso "sistema de apoio à navegação", mensagem comercial, ARBs nos 5 idiomas) — pode rodar em paralelo com qualquer passo acima, sem dependência.
7. **Documentação** (`README.md`, seção nova em `DOCUMENTACAO.md`, `docs/ROTEIRO_DEMONSTRACAO.md`) — por último, depois que os nomes de tela/recurso reais já estiverem estáveis.
8. **Verificação final** (`flutter analyze` + `flutter test`, sem regressão sobre a baseline desta análise — ver rodapé) + atualização deste documento com o status "feito/pendente/depende de backend" por item.

Estimativa de arquivos tocados: **~10-14 novos** (domínio de planos, widget de proteção, tela Planos, `docs/ROTEIRO_DEMONSTRACAO.md`) + **~15-20 modificados** (pontos de gate espalhados em `mapa_widget.dart`, telas de meteorologia/produção/viagem, `README.md`, `DOCUMENTACAO.md`, ARBs × 5 idiomas × N chaves novas). Nenhuma migração de banco prevista — plano é um dado remoto/config, não precisa de tabela SQLite nova (a menos que decidamos cachear o payload completo do plano em vez de só `Config`/Hive, o que não parece necessário).

---

## Verificação executada nesta análise (Fase 1, somente leitura)

```
flutter analyze  → ver saída abaixo (executado nesta sessão, sem nenhuma alteração de código)
flutter test     → ver saída abaixo (idem)
```

```
$ flutter analyze
Analyzing atlas...
No issues found! (ran in 182.6s)

$ flutter test
...
163/163 — All tests passed!
```

Baseline confirmada nesta sessão, sem nenhuma alteração de código de produção: **`flutter analyze` 0 issues · `flutter test` 163/163**. Esse é o número de referência que a Fase 2 não pode regredir (a auditoria de 2026-09-02 registrou 91/91 — o crescimento pra 163 reflete features adicionadas depois daquela auditoria, dentro do próprio período coberto por esta sessão de trabalho).

---

## Perguntas em aberto para você (resumo do §3, pra facilitar a resposta)

1. Cartas offline — o que "básico" esconde? (§3.1)
2. Meteorologia — o que "básica" esconde? (§3.2)
3. Produção — o que "básica" esconde? E Recomendações no Pro: nada, versão reduzida, ou decisão do backend? (§3.3)
4. Correntes — gate próprio ou dentro do gate geral de meteorologia completa? (§3.4)
5. Mapa de produtividade — é o índice heurístico (SST+clorofila) já existente, ou é outra coisa a construir depois? (§3.5)
6. Alertas — o que distingue "básico" de "avançado"? (§3.6)
7. "Pontos de pesca salvos": matriz (todos os planos) ou lista do Pro (exclusivo)? (§3.7)
8. Fleet no mobile: idêntico ao Offshore, ou ganha um seletor de embarcação da frota? (§3.8)
9. Período de carência offline proposto: 7 dias — confirma ou muda? (§4.3)
10. Downgrade: dados antigos ficam visíveis/somente-leitura (proposta) ou somem da UI? (§4.4)
