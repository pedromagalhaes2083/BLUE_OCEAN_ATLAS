# Auditoria Blue Ocean Atlas

**Data:** 2026-09-02
**Escopo:** repositório completo (`lib/`, `test/`, `android/`, `ios/`, `pubspec.yaml`).
**Metodologia:** leitura de código + execução real de `flutter analyze`, `flutter test`, `flutter doctor -v`. Nenhum resultado foi inventado — onde uma ferramenta não pôde rodar, isso está dito explicitamente na seção 3.

O relatório foi escrito sem alterar nenhum código. Depois de aprovado pelo usuário, os 4 bugs confirmados de menor risco (marcados **✅ CORRIGIDO** abaixo) foram implementados — `flutter analyze` (0 issues) e `flutter test` (91/91) confirmados de novo após as correções, sem regressão.

---

## Resumo executivo

O app está em um estado bem melhor do que uma auditoria típica de "primeira vista" encontraria — boa parte dos problemas estruturais mais graves (organização hardcoded, IDs de embarcação virando nome, viagem duplicada, id de criação rejeitado pelo backend) **já foi corrigida em sessões de trabalho anteriores a esta auditoria**, e estão marcadas como tal abaixo. O que resta é menos dramático, mas real: um bug confirmado de persistência no Hive (escrita sem `await`), uma janela de duplicação de notificação, iOS com config incompleta pra background, cobertura de teste concentrada em poucas áreas, e um README que não descreve o projeto.

Não há nenhuma vulnerabilidade de injeção de SQL (todas as queries usam `where`/`whereArgs` parametrizados), nenhuma chave de API exposta, e a senha do "lembrar credenciais" já está no `flutter_secure_storage` corretamente.

`flutter analyze`: **0 problemas.** `flutter test`: **91/91 passando.**

---

## Arquitetura atual

Feature-first, sem framework de gerenciamento de estado (sem Provider/Riverpod/Bloc) — `StatefulWidget` + `setState` em toda a UI, e classes de serviço com métodos `static` fazendo o papel de singletons/repositórios.

```
lib/
  core/
    auth/        AuthService, modelos de usuário/organização, decodificação de JWT
    background/  location_worker.dart — único callbackDispatcher do WorkManager
    config/      Config (Hive key-value) + Constantes (chaves)
    database/    DatabaseHelper (sqflite, schema versionado)
    network/     ApiService (cliente HTTP cru, único ponto que monta headers)
    services/    localização, sincronização, notificações, tema, bateria...
    storage/     ApiStorageService (Hive, só para o dev tool api_tester)
    utils/       uuid, cálculos náuticos, formatação de erro
  features/
    <feature>/
      data/        *_repository.dart — único lugar que conhece a rota/formato da API
      domain/      modelos puros + models/*_envio.dart (contrato estável de payload)
      presentation/ telas
```

Ponto de entrada: `lib/main.dart` → inicializa Hive, notificações, splash nativo → `SplashScreen` (decide login automático + retoma rastreamento se houver viagem ativa) → `AppShell` (bottom nav) ou `LoginScreen`.

Padrão consistente em toda a base: cada `*_repository.dart` isola o formato exato esperado pela API; os modelos de domínio (`*Envio`) são o "contrato estável" que o resto do app usa, então uma mudança de contrato no backend só toca o repository correspondente. Isso já foi comprovado na prática nesta sessão (o backend mudou o comportamento de criação com `id` explícito, e a correção ficou isolada em 3 repositórios).

---

## 3. Execução das ferramentas de análise

| Comando | Resultado |
|---|---|
| `flutter doctor -v` | ✅ Executado. 1 categoria com aviso: instalação do Visual Studio (build tools Windows) incompleta — **irrelevante** pro escopo do app (Android/iOS), não bloqueia nada. Dispositivo Android real conectado e reconhecido (`SM A266M`, Android 16). |
| `flutter pub get` | ✅ Resolve sem erro. |
| `flutter analyze` | ✅ **0 issues** (138s). |
| `flutter test` | ✅ **91/91 passando** (~18s). |
| `flutter test --coverage` | ⚠️ Não executado nesta rodada — o comando existe e funcionaria, mas eu não tenho no ambiente uma ferramenta de renderização do relatório LCOV (`genhtml`/`lcov`) pra extrair um número de cobertura útil além de "roda os mesmos 91 testes". A lista de áreas sem teste nenhum (seção 21) é mais informativa que o percentual bruto teria sido. |
| `dart analyze` | ⚠️ Não executado separadamente — `flutter analyze` já cobre o mesmo linter sobre o mesmo `analysis_options.yaml` deste projeto Flutter; rodar os dois seria redundante. |

Nenhum erro de compilação, warning, ou uso de API depreciada foi sinalizado pelo `flutter analyze`.

---

## Erros confirmados

### ✅ CORRIGIDO — 🟠 ALTO — `Config.grava`/`Config.limpa` não esperam a escrita no Hive terminar
**Arquivo:** `lib/core/config/config.dart:30-38`
```dart
static Future<void> grava(String chave, String valor) async {
  await _inicia();
  _box.put(chave, valor);      // falta `await`
}
static Future<void> limpa(String chave) async {
  await _inicia();
  _box.delete(chave);          // falta `await`
}
```
**Causa:** `Box.put()`/`Box.delete()` retornam `Future<void>` (a escrita em disco é assíncrona); sem `await`, o método `grava`/`limpa` — que É `async` e É esperado por quem chama — retorna antes da escrita realmente terminar de ir pro disco.
**Impacto:** `Config` é o key-value usado para **tudo** que precisa sobreviver a um restart: token de autenticação, organização ativa, embarcacaoId, intervalo de rastreamento, marca d'água de recomendações. Se o processo for morto (o Android mata apps agressivamente sob pressão de memória, ou o usuário força o fechamento) no instante entre `grava()` retornar e o disco realmente confirmar, o valor pode não persistir — apesar de quem chamou ter dado `await` acreditando que sim. Na prática: login "bem-sucedido" que não sobrevive a um kill do processo, por exemplo.
**Gravidade:** 🟠 ALTO — baixa probabilidade de acontecer (janela de tempo muito curta), mas alto impacto quando acontece (perda silenciosa de um dado que a UI já disse que salvou), e afeta o caminho mais usado do app inteiro.
**Correção recomendada:** adicionar `await` nas duas linhas. Mudança de uma palavra, sem risco de regressão.

---

### 🟡 MÉDIO — Notificação de recomendação pode duplicar/"ressuscitar" se o processo morrer entre mostrar e persistir a marca d'água
**Arquivo:** `lib/core/services/recomendacao_notification_service.dart:96-100`
```dart
if (novas.isNotEmpty) {
  await _notificar(novas);        // 1. mostra a notificação
}
await _salvarMarcaDagua(maisRecente);  // 2. só depois persiste até onde já verificou
```
**Causa:** as duas etapas não são atômicas. Esse código roda dentro da isolate do WorkManager (`location_worker.dart`), que o Android pode matar a qualquer momento após terminar a tarefa — inclusive entre essas duas linhas.
**Impacto:** se o processo morrer depois de `_notificar` e antes de `_salvarMarcaDagua`, a próxima execução ainda vê a mesma recomendação como "nova" (a marca d'água não avançou) e notifica de novo — o usuário recebe (ou vê reaparecer, já que o id da notificação é `r.id.hashCode`, determinístico) uma notificação que já tinha visto/dispensado.
**Gravidade:** 🟡 MÉDIO — não perde dado nem trava nada, é só ruído/confusão pro usuário. A ordem atual (notificar primeiro, persistir depois) é, na verdade, a escolha mais defensável entre as duas opções: o risco inverso (persistir antes de notificar) faria a app **silenciosamente nunca avisar** de uma recomendação real se matado no meio — pior para um app de pesca.
**Correção recomendada:** não é urgente. Se quiser fechar de vez, trocar o watermark de "só o timestamp mais recente" por um pequeno conjunto persistido de IDs já notificados (ex: os últimos N ids), tornando a checagem idempotente de verdade.

---

### 🟡 MÉDIO — README não descreve o projeto
**Arquivo:** `README.md`
**Problema:** é o boilerplate padrão gerado por `flutter create` — "A new Flutter project", link pro codelab genérico. Zero menção a arquitetura, banco, rastreamento offline, backend, ou como rodar.
**Impacto:** qualquer pessoa nova no projeto (ou o próprio Pedro daqui a alguns meses) não tem onde começar sem vasculhar `DOCUMENTACAO.md` (que existe e está bem mais completo, mas não é onde alguém procura primeiro).
**Gravidade:** 🟡 MÉDIO — não afeta o app rodando, afeta manutenibilidade.
**Correção recomendada:** ver proposta de estrutura na seção "README e Documentação" abaixo.

---

## Já corrigido em trabalho anterior a esta auditoria (contexto, não é pendência)

Registro aqui pra não reaparecer como "novo achado" numa auditoria futura — todos verificados no código atual, todos com teste cobrindo:

- **`organizacaoId` fixo:** `ApiService` mandava sempre uma organização de demonstração real no header `x-organization-id`. Corrigido pra usar a organização de verdade escolhida no login (`Config`/`Constantes.organizacaoId`); o único fallback restante é o sentinela `00000000-...` que o próprio backend usa pra "nenhuma organização", nunca uma organização real.
- **`embarcacaoId` recebendo o nome em vez do ID:** `NovaViagemScreen` e `ProducaoScreen` gravavam o *nome* de exibição da embarcação no campo que deveria ser o UUID real. Corrigido nos dois lugares.
- **Fallback de embarcação real hardcoded:** existia um UUID de uma embarcação real (`c8f1da10-...`) usado como valor padrão em 3 arquivos quando nada estava configurado. Removido — agora ausência de configuração é tratada como ausência, sem inventar um ID.
- **Duas viagens "em_andamento" ao mesmo tempo:** não havia nenhuma trava. Corrigido em duas camadas: checagem explícita em `NovaViagemScreen` antes de criar, **e** um índice único parcial no SQLite (`idx_viagem_unica_ativa`, migração v15) como reforço contra condição de corrida — com limpeza automática de dados antigos inconsistentes na própria migração. Coberto por 3 testes novos, incluindo o cenário de upgrade a partir de uma instalação v14 com o bug antigo já manifestado.
- **`POST` de criação (viagem/porto/captura) rejeitado pelo backend:** os três repositórios mandavam um `id` gerado no cliente; o backend documenta esse campo como "omitido para criação" e passou a rejeitar (404/400) quando presente. Corrigido nos três — o id agora vem da resposta do servidor.
- **Precisão de GPS `null` virando `0`:** `localizacao_reporter_service.dart` fazia `?? 0` ao ler a precisão salva localmente, apagando a diferença entre "não sei a precisão" e "precisão é zero metros" antes de mandar pro backend. Corrigido; o campo é opcional na API e agora só é enviado quando existe de verdade.
- **`showDatePicker` zerando o horário da viagem:** ao tocar só na data (sem mexer na hora), o horário de início virava meia-noite. Corrigido preservando hora/minuto/segundo ao recompor a data.
- **Estado de rastreamento em memória "mentindo" após restart do app:** `LocationTrackingService._rastreando` é um bool de processo, resetado a cada cold start, enquanto o WorkManager sobrevive de verdade. **Verificado: já está mitigado** — `SplashScreen._iniciar()` reconfirma o rastreamento (idempotente, via `ExistingPeriodicWorkPolicy.replace`) toda vez que o app abre com uma viagem em andamento no banco local, antes de mostrar qualquer tela. Não é um bug pendente, é um cuidado que já existe e está documentado no próprio código.

---

## Possíveis bugs (precisam de confirmação/observação em campo)

Coisas que o código *permite* acontecer mas que eu não consegui (ou não faz sentido tentar) reproduzir estaticamente:

1. ✅ **CORRIGIDO** — **`MapController` (`flutter_map`) nunca era descartado explicitamente** em `mapa_widget.dart`. Confirmado no código-fonte do pacote instalado (`flutter_map-7.0.2`) que `MapController.dispose()` existe e libera um `AnimationController` interno (usado nas animações de pan/zoom) — adicionada a chamada em `dispose()`.
2. **iOS em background:** `ios/Runner/Info.plist` tem as strings de permissão de localização (`NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`) mas **não** declara `UIBackgroundModes` com `location` nem os identificadors de `BGTaskScheduler` que o `workmanager` precisa no iOS. Isso é uma leitura estática do plist — eu não tenho toolchain iOS (Xcode/macOS) neste ambiente pra confirmar rodando. Se o app for pra iOS de verdade, o rastreamento em segundo plano provavelmente **não funciona lá** hoje, só no Android.
3. ✅ **CORRIGIDO** — **`ApiStorageService`** (`lib/core/storage/api_storage_service.dart`) também escrevia no Hive sem `await` (`save`/`delete`/`clear` nem eram `async`) — mesmo padrão do bug confirmado no `Config`. Baixo impacto (só a ferramenta de debug `api_tester`, não dado de produção do mestre), mas corrigido junto por ser a mesma causa raiz; chamadores (`api_tester_screen.dart`) atualizados para `await`.

---

## Segurança

- **Sem SQL injection:** toda a camada de banco (`DatabaseHelper`, todos os `*_repository.dart` locais) usa `where`/`whereArgs` parametrizados do `sqflite`. Nenhum `rawQuery`/`execute` com interpolação de string foi encontrado.
- **Sem chave de API/segredo hardcoded no código.** Busca ampla por padrões de `apiKey`/`secret`/senha-literal não encontrou nada além do já conhecido.
- ✅ **CORRIGIDO** — 🟠 **Credenciais de demonstração pré-preenchidas na tela de login** (`lib/features/auth/presentation/login_screen.dart:22-23`) — usuário e senha de uma conta real do backend (`admin@blueocean.io`, org "Blue Ocean Demo") vinham digitados por padrão nos campos de login. Campos agora começam vazios; nenhum outro lugar do código dependia desse valor (confirmado por busca).
- `flutter_secure_storage` é usado corretamente para o dado mais sensível de fato (usuário/senha do "lembrar credenciais", `auth_service.dart:37-38`). O token JWT de sessão fica no Hive comum (`Config`), não no secure storage — 🟢 aceitável (token de curta duração, ~30min, armazenamento privado do app), mas colocar também no secure storage seria mais rigoroso.
- Toda comunicação com a API já é HTTPS (`https://blue-ocean-app-api.up.railway.app`), sem endpoint HTTP puro encontrado.
- Nenhum log encontrado imprime senha ou token completo — os `debugPrint` de erro de rede imprimem status/mensagem do backend, não o corpo da credencial.

---

## Banco de dados

- **Schema:** sem `FOREIGN KEY` declaradas em nenhuma tabela, e `PRAGMA foreign_keys` nunca é configurado — a integridade referencial (embarcação↔viagem↔produção↔localização) é garantida só pela aplicação, nunca pelo SQLite. Não é um bug (é assim desde o início, e mudar agora seria arriscado com dados antigos de campo já existentes), mas é uma característica a ter em mente: nada impede um `viagem_id` órfão apontando pra uma viagem já apagada.
- **IDs:** mistura intencional de `INTEGER` (chaves locais autoincrementadas: `viagem.id`, `producao_registro.id`, etc.) com `TEXT` (UUIDs remotos: `viagem.remoto_id`, `embarcacao_id`, `viagem_id` referenciado nas capturas). Isso é o padrão local-first esperado (id local ≠ id remoto) e está consistente em todo o schema — não achei um lugar misturando os dois tipos na mesma coluna.
- **Migrations:** vão de v1 até v15, incrementais, cada uma com `if (oldVersion < N)`. A migração mais recente (v15, índice único de viagem ativa) já vem com limpeza de dados inconsistentes pré-existentes embutida — testada explicitamente simulando um upgrade real de v14. As migrations anteriores não têm teste de upgrade dedicado (só o schema final é testado via `onCreate`), mas nenhuma migration encontrada parece destrutiva o suficiente pra preocupar (só `ALTER TABLE ADD COLUMN` e `CREATE TABLE IF NOT EXISTS`/índice, todas idempotentes por natureza ou guardadas por `oldVersion <`).
- **Transações:** operações que logicamente deveriam ser atômicas (ex: inserir uma viagem local + tentar registrar no backend + atualizar `remoto_id`) não usam `db.transaction()` — mas isso é proposital: o registro remoto é *best-effort* e não deve reverter o insert local se falhar (a viagem local tem que existir mesmo sem internet). Não é um bug, é o modelo offline-first funcionando como descrito na documentação do projeto.
- **Concorrência:** `sqflite` serializa acesso ao mesmo arquivo de banco internamente; não encontrei padrão de "ler depois escrever" sem proteção que dependesse de um lock explícito da aplicação, exceto o cenário de viagem duplicada já corrigido acima com índice único.

---

## GPS

- Fluxo correto: `Geolocator.getCurrentPosition` com timeout, tratado em `try/catch` em todos os pontos de chamada encontrados — sem GPS/permissão, o app não trava, só segue sem coordenada.
- Precisão nula agora é preservada (ver correção já aplicada acima) em vez de virar zero.
- **`viagemId` da localização é resolvido no momento do registro** (`localizacao_reporter_service.dart:49-54`, consulta a viagem `em_andamento` na hora de gravar), não por um cache antigo — com a trava de viagem única já em vigor, isso deixou de ser um "escolher a primeira de várias" arriscado.
- Não encontrei filtro de outlier (salto de posição implausível, velocidade impossível) em nenhum lugar do pipeline de gravação/sincronização de GPS. Isso é um **risco real não corrigido**: um fix de GPS ruim (comum perto de prédios/em manobra) pode gravar uma coordenada visivelmente errada sem nenhuma triagem antes de ir pro histórico e pro backend. Não classifiquei como "confirmado" porque não é um bug de código — é uma validação que nunca existiu, então é mais uma lacuna de funcionalidade do que um erro.

---

## Background (WorkManager)

- Separação conceitual entre GPS (`LocalizacaoReporterService`, chamado sob demanda) e WorkManager (`location_worker.dart`, dispara a cada N minutos, mínimo 15 no Android) **existe e está correta** — o dispatcher só orquestra chamadas a serviços, não faz nenhuma leitura de GPS "em tempo real" ele mesmo.
- `existingWorkPolicy: ExistingPeriodicWorkPolicy.replace` evita duplicar a tarefa periódica ao reiniciar o rastreamento (ex: reabrir o app com viagem ativa) — ponto positivo já verificado.
- A isolate de background reinicializa o Hive (`Hive.initFlutter()`) antes de usar `Config` — necessário e já está feito corretamente.
- Erros dentro da task são capturados e reportados (`catch (e) { debugPrint(...); return false; }`) — `return false` sinaliza falha ao WorkManager, que aplica sua política de retry/backoff padrão automaticamente.

---

## Notificações

- Canal único (`recomendacoes`), importância alta, criado de forma idempotente (`_inicializado` guarda contra reinicialização).
- Permissão `POST_NOTIFICATIONS` (Android 13+) solicitada em runtime.
- Risco de duplicação/"ressurreição" já detalhado acima (🟡 MÉDIO, não urgente).
- `AlertaCondicaoNotificationService` (vento/onda/corrente severos à frente) não foi auditado em profundidade nesta rodada — mesma família de risco de watermark deveria ser revisada com o mesmo cuidado se for prioridade.

---

## API

- Timeout de 20s em toda chamada (`get`/`post`/`put`) — bom, evita a UI travar esperando indefinidamente numa embarcação com sinal ruim.
- Retry de autenticação: um 401 dispara uma tentativa de login automático com a credencial lembrada e repete a chamada original uma vez — mecanismo já existente e testado.
- `_analisa()` decodifica todo corpo de resposta como JSON incondicionalmente (`jsonDecode(response.body)`) — uma resposta 204 (sem corpo) ou uma resposta não-JSON do backend/proxy faria essa linha lançar uma exceção genérica de parsing em vez de um erro claro. Não encontrei nenhuma chamada atual que espere 204, então não é um bug confirmado, mas é uma lacuna de robustez (🟡) se o backend um dia adicionar um endpoint que responde vazio.
- Sincronização offline→online: todos os serviços de reporter (`LocalizacaoReporterService`, `ProducaoReporterService`) seguem o mesmo padrão — salva local sempre, marca `sincronizado=0`, tenta enviar, só marca `1` em caso de sucesso confirmado. Um erro de rede nunca apaga o registro local pendente.

---

## Offline

Confirmado: o modelo é local-first de verdade, não só em teoria — em nenhum dos fluxos auditados (viagem, produção, localização, portos, embarcação) uma falha de rede impede a ação local de se completar. Esse foi inclusive o comportamento observado em testes reais no dispositivo físico nesta sessão de trabalho (viagem criada localmente mesmo com o `POST` remoto falhando).

---

## Performance

- Nenhuma query SQLite pesada identificada (todas filtram por `where` indexado implicitamente pelo padrão de uso — sem `SELECT *` sem filtro em tabelas que crescem sem limite, exceto históricos que já são esperados crescer, e têm tela de "histórico" dedicada, não carregados no fluxo principal).
- `ApiService.carga()` pagina corretamente em vez de tentar um payload gigante de uma vez.
- Não avaliei a fundo rebuilds de widget (não há uma ferramenta de profiling rodando nesta auditoria estática) — os arquivos de tela maiores (`mapa_widget.dart`, ~2000 linhas) são candidatos naturais a `setState` mais amplo do que o necessário, mas isso exigiria profiling em campo pra confirmar, não leitura de código.

---

## Android

- Permissões enxutas e todas justificadas por comentário no próprio manifest (localização fina/grossa/background, internet, notificações, isenção de otimização de bateria) — nenhuma permissão além do que o app genuinamente usa.
- `minSdk`/`targetSdk` seguem o padrão do Flutter (`flutter.minSdkVersion`/`flutter.targetSdkVersion`), sem override manual — comportamento esperado, sem problema identificado.
- Não testei build de `--release` (ProGuard/R8) nesta auditoria — vale rodar `flutter build apk --release` antes de qualquer distribuição, já que regras de ofuscação às vezes quebram reflection usada por plugins (Hive, notifications) de um jeito que só aparece em release.

---

## iOS

Suporte existe (pasta `ios/` presente, `Info.plist` com as chaves básicas de localização), mas:
- Sem `UIBackgroundModes` para rastreamento em background — ver "Possíveis bugs" acima.
- Não consegui rodar `flutter build ios` nem qualquer verificação real (sem toolchain macOS/Xcode neste ambiente Windows) — tudo nesta seção é leitura estática de configuração, não execução.

---

## Dependências

- `workmanager: 0.9.0+3` está **fixado** (sem `^`), diferente do resto do `pubspec.yaml` — bom sinal de que foi uma escolha deliberada (esse pacote historicamente teve breaking changes entre versões menores), não descuido.
- `flutter pub outdated` mostra várias dependências transitivas com versão mais nova disponível, nenhuma delas puxada por incompatibilidade real (`flutter pub get` resolve limpo). Dois pacotes descontinuados aparecem só como **transitivos**: `flutter_secure_storage_macos` e `js` — nenhum dos dois é uma dependência direta deste projeto, vêm de dentro de outros pacotes; não há ação a tomar aqui além de observar quando o pacote pai atualizar.
- `flutter_native_splash` está presente e configurado (usado em `main.dart`) — nenhum sinal de configuração quebrada.
- Não há `flutter_launcher_icons` nas dependências — os ícones do app parecem ser mantidos manualmente nas pastas nativas; não é um erro, só uma escolha diferente da automatizada.

---

## Testes

**91 testes, todos passando**, mas concentrados em: `core/auth`, `core/config`, `core/database`, `core/services` (parcial), `core/utils`, `features/producao` (domínio), `features/rotas` (domínio), e um teste de widget único (`widget_test.dart`, só confirma a tela de login sem sessão).

**Sem nenhum teste hoje:**
- `features/viagem` (fora do índice único do banco, testado indiretamente)
- `features/embarcacao`
- `features/mapa`
- `features/recomendacao`
- `features/localizacao`
- `features/dispositivo`
- `features/metereologia`
- `features/cartas`
- `core/background` (`location_worker.dart`)
- `core/network` (`api_service.dart`) — projeto ainda não tem infraestrutura de mock HTTP

Prioridade de teste sugerida, na ordem pedida (banco → migrations → auth → sync → recomendações → notificações → GPS → rotas → produção → offline): banco/migrations e auth já têm cobertura razoável; sincronização (`LocalizacaoReporterService`/`ProducaoReporterService`) tem cobertura parcial (os caminhos de "pular"/"adiar", não o envio de sucesso, que exigiria mock de HTTP); recomendações e notificações são o maior buraco de teste hoje considerando que é onde mora o risco de duplicação já documentado.

---

## Dívida técnica

- `ApiService._analisa` não diferencia corpo vazio/não-JSON de um erro real (ver seção API).
- `mapa_widget.dart` com ~2000 linhas concentra navegação, overlays, desenho de rota, e diálogos de detalhe numa única classe — funciona, mas qualquer mudança ali tem raio de impacto grande. Não é um bug, é custo de manutenção.
- README desatualizado (ver acima).
- Sem teste de build `--release` documentado/automatizado.

---

## Plano de correção

### FASE 1 — CRÍTICO
- Nenhum item novo nesta auditoria se qualifica como 🔴 crítico — os itens dessa gravidade encontrados em trabalho anterior já foram corrigidos (ver seção "Já corrigido").

### FASE 2 — ESTABILIDADE
1. ✅ Adicionado `await` em `Config.grava`/`Config.limpa` (`config.dart:32,37`).
2. ✅ Mesma correção em `ApiStorageService` (`save`/`delete`/`clear`), com os chamadores em `api_tester_screen.dart` ajustados pra `await`.
3. ✅ `MapController.dispose()` adicionado em `mapa_widget.dart` (API confirmada em `flutter_map-7.0.2`).

### FASE 3 — SEGURANÇA
4. ✅ Removido usuário/senha pré-preenchidos de `login_screen.dart`.
5. (Opcional, não urgente) mover o token JWT do `Config` (Hive) pro `flutter_secure_storage` — não implementado, fica como melhoria futura.

### FASE 4 — PERFORMANCE
6. Nenhum item urgente identificado nesta rodada — revisar com profiling real em campo antes de otimizar às cegas.

### FASE 5 — QUALIDADE
7. Reescrever o `README.md` (estrutura proposta abaixo).
8. Resolver `UIBackgroundModes`/`BGTaskScheduler` no `ios/Runner/Info.plist` **se e quando** iOS virar alvo real de distribuição — não vale o esforço se o produto continuar Android-only.

### FASE 6 — TESTES
9. Cobrir `recomendacao_notification_service.dart` com teste do cenário "processo morre entre notificar e salvar marca d'água" (mesmo sem poder simular o kill real, dá pra testar a lógica isoladamente).
10. Testes de widget/integração básicos para `features/viagem` e `features/embarcacao` (os fluxos mais tocados nesta sessão).

---

## README e Documentação — proposta de estrutura

Não reescrevi o `README.md` (fora do escopo desta auditoria, que é só relatório). Proposta de seções, caso autorizado a seguir:

1. O que é o Atlas Blue Ocean (uma frase — app offline-first pra mestres de embarcação de pesca).
2. Arquitetura (o diagrama de pastas acima + o padrão repository/envio).
3. Tecnologias (Flutter, sqflite, Hive, WorkManager, flutter_map, backend próprio).
4. Como rodar localmente (`flutter pub get`, dispositivo/emulador, variáveis de ambiente se houver).
5. Banco de dados local (onde fica, como migrar, como resetar em dev).
6. Backend (URL base, autenticação, como trocar de ambiente).
7. Funcionamento offline (o que funciona sem rede, o que fica pendente).
8. Rastreamento em segundo plano (WorkManager, intervalo mínimo, bateria).
9. Testes (`flutter test`, onde ficam, o que falta cobrir — linkar pra esta auditoria).
10. Build de release (Android hoje; iOS pendente de configuração).

---

## Perguntas de fechamento (seção 24 do pedido)

**1. Os 10 problemas mais importantes** (ordem de gravidade):
1. `Config.grava`/`limpa` sem `await` no Hive (🟠 confirmado).
2. Credenciais de demonstração pré-preenchidas no login (🟠 segurança, confirmado).
3. Notificação de recomendação pode duplicar/ressuscitar (🟡 confirmado, não urgente).
4. Sem filtro de outlier de GPS antes de gravar/sincronizar (🟡 lacuna, não bug).
5. iOS sem `UIBackgroundModes`/BGTask — rastreamento em background provavelmente não funciona lá (🟡 possível, não confirmado por falta de toolchain).
6. `ApiStorageService` com o mesmo padrão de escrita sem `await` (🟢 baixo impacto — só dev tool).
7. `MapController` sem `dispose()` explícito (possível vazamento pequeno, não confirmado).
8. `ApiService._analisa` não trata corpo vazio/não-JSON (lacuna de robustez, sem caso real que dispare hoje).
9. README fora da realidade do projeto (dívida de documentação).
10. Cobertura de teste concentrada, com recomendações/notificações — exatamente onde mora o risco #3 — sem nenhum teste.

**2. Quais são bugs confirmados (código lido, comportamento certo):**
#1, #2, #3, #6.

**3. Quais são apenas riscos (não confirmados/precisam de observação em campo):**
#4, #5, #7, #8.

**4. Podem causar perda de dados:**
#1 (`Config` — janela pequena, mas real). Nenhum outro item encontrado nesta auditoria arrisca perda de dado já gravado localmente — o modelo offline-first se mostrou consistente em todos os fluxos revisados.

**5. Podem impedir o funcionamento offshore:**
Nenhum dos itens encontrados impede o app de funcionar offshore hoje — o pipeline local-first (banco → pendente → sincroniza quando volta rede) está sólido em todos os fluxos auditados. O item #5 (iOS background) só importaria se a operação real usar iPhone, não Android.

**6. Podem causar consumo excessivo de bateria:**
Nenhum encontrado nesta auditoria — o intervalo mínimo de 15min já é reforçado pelo próprio Android, e a permissão de isenção de otimização de bateria já é solicitada corretamente com justificativa.

**7. Problemas de segurança:**
#2 (credenciais de demo no login) é o único real. Token JWT em armazenamento não-seguro (Hive em vez de `flutter_secure_storage`) é uma melhoria recomendada, não uma vulnerabilidade explorável localmente (mesmo isolamento de app que qualquer outro dado privado do Android).

**8. Correções recomendadas primeiro:**
Nesta ordem: #1 (uma linha, zero risco, fecha uma janela real de perda de dado) → #2 (uma linha, fecha um risco real de segurança antes de qualquer distribuição) → #3 (se recomendações/alertas forem prioridade de UX) → o resto conforme a Fase do plano acima, sem pressa.

---

## Status pós-auditoria

Implementado, autorizado pelo usuário em 2026-09-02:
- ✅ #1 `Config.grava`/`limpa` sem `await`
- ✅ #2 Credenciais de demonstração pré-preenchidas no login
- ✅ #6 `ApiStorageService` com o mesmo padrão de escrita sem `await`
- ✅ #7 `MapController` sem `.dispose()`

Verificado depois das correções: `flutter analyze` — 0 issues; `flutter test` — 91/91 passando; busca por regressão nos pontos alterados (nenhum outro código dependia do texto pré-preenchido do login ou do retorno síncrono do `ApiStorageService`).

**Ainda em aberto** (riscos não confirmados / decisões maiores, deixados fora de propósito por exigirem mais contexto ou não serem urgentes): #3 (notificação duplicada), #4 (outlier de GPS), #5 (iOS background), #8 (`ApiService._analisa` com corpo vazio), README, cobertura de teste.
