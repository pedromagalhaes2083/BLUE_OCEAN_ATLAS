# Atlas Blue Ocean — Documentação Técnica

> Versão: 1.0.0+1 · Flutter ≥ 3.6.0 · Última atualização: Agosto 2026

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Configuração do Ambiente](#2-configuração-do-ambiente)
3. [Arquitetura do Projeto](#3-arquitetura-do-projeto)
4. [Estrutura de Pastas](#4-estrutura-de-pastas)
5. [Dependências](#5-dependências)
6. [Banco de Dados SQLite](#6-banco-de-dados-sqlite)
7. [Serviços Principais (`core/`)](#7-serviços-principais-core)
8. [Repositórios de API (`data/`)](#8-repositórios-de-api-data)
9. [Features — Telas e Funcionalidades](#9-features--telas-e-funcionalidades)
10. [Modelos de Dados](#10-modelos-de-dados)
11. [Armazenamento Local (Hive)](#11-armazenamento-local-hive)
12. [Assets](#12-assets)
13. [Fluxos Principais](#13-fluxos-principais)
14. [Permissões Android/iOS](#14-permissões-androidios)
15. [Convenções e Padrões](#15-convenções-e-padrões)
16. [Diagrama de Classes (UML)](#16-diagrama-de-classes-uml)
17. [Próximos Passos](#17-próximos-passos)

---

## 1. Visão Geral

**Atlas Blue Ocean** é um aplicativo móvel multiplataforma desenvolvido em Flutter para **embarcações pesqueiras**. Ele centraliza operações de navegação, rastreamento de posição, registro de produção (capturas), consulta de dados meteorológicos e recomendações de pesca, funcionando **predominantemente offline**, com sincronização oportunista com um backend próprio (Blue Ocean API) quando há conectividade.

### Funcionalidades principais

| Área | O que faz |
|------|-----------|
| **Mapa Offline** | Cartas náuticas em MBTiles, overlay de GeoTIFF e de PNG georreferenciado, mapa de ruas com cache, marcação de pontos, planejamento de rotas |
| **Rastreamento GPS** | Registra a posição a cada 5 min (foreground) e 15 min (background), sincroniza com o backend quando logado |
| **Meteorologia** | Vento, correntes, clorofila, previsão do tempo, ondas e profundidade — parte de arquivos JSON locais, parte de APIs públicas (Open-Meteo, OpenTopoData) |
| **Produção** | Registra capturas de pesca (espécie, quantidade, posição GPS, viagem) e mostra histórico/totais |
| **Recomendação** | Exibe recomendações de pesca vindas do backend (score, confiança, variáveis ambientais, pontos sugeridos) |
| **Cartas Náuticas** | Gerencia, baixa e visualiza PDFs de cartas náuticas; permite solicitar novas cartas |
| **Rotas Planejadas** | Cria e gerencia rotas desenhadas manualmente sobre o mapa |
| **Viagem** | Início/fim de viagem, tripulação, histórico de localizações da viagem |
| **Embarcação** | Cadastro, configuração e foto da embarcação |
| **Autenticação** | Login real contra a Blue Ocean API, sessão controlada pela expiração (`exp`) do JWT |
| **Configurações** | Intervalo de rastreamento, modo noturno, contato de emergência, embarcação ativa |
| **Teste de API / Dispositivo** | Ferramentas internas de debug para chamadas HTTP manuais e teste do registro de dispositivo |

### Stack Tecnológica

- **Frontend:** Flutter (Dart)
- **Banco de dados relacional:** SQLite via `sqflite` (dados locais: embarcação, viagens, produção, pontos, rotas)
- **Banco de dados NoSQL:** Hive via `hive_flutter` (preferências/tokens e histórico de chamadas de teste)
- **Mapas:** `flutter_map` com tiles MBTiles, overlay de GeoTIFF, overlay de PNG georreferenciado e cache de mapa de ruas
- **GPS:** `geolocator`
- **Background tasks:** `workmanager`
- **Armazenamento seguro:** `flutter_secure_storage` (usado pontualmente, ex. ID de dispositivo no iOS)
- **Backend:** Blue Ocean API (REST, `blue-ocean-app-api.up.railway.app`), consumida via `ApiService`
- **APIs externas:** Open-Meteo (previsão do tempo e ondas), OpenTopoData (profundidade/batimetria)

---

## 2. Configuração do Ambiente

### Pré-requisitos

- Flutter SDK ≥ 3.6.0 (`flutter --version` para verificar)
- Dart SDK compatível com o Flutter instalado
- Android Studio ou VS Code com extensões Flutter/Dart
- Dispositivo Android físico ou emulador (recomendado físico para GPS)

### Como rodar o projeto

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd atlas

# 2. Instale as dependências
flutter pub get

# 3. Execute o app
flutter run
```

### Autenticação em ambiente de desenvolvimento

O login é feito contra a Blue Ocean API real (`ApiService.login` → `POST /api/v1/autenticacao`); não há mais credenciais fixas no código. É necessário um usuário válido cadastrado no backend. O token retornado é salvo (`Config`/Hive) e a sessão permanece válida até a expiração (`exp`) do JWT — depois disso o app desloga automaticamente.

---

## 3. Arquitetura do Projeto

O projeto segue uma arquitetura **Feature-First**, com separação em até três camadas dentro de cada feature — mas nem toda feature usa as três:

```
feature/
├── domain/
│   └── models/        ← Entidades de dados (fromJson/fromMap/toMap, sem lógica de negócio)
├── data/               ← Repositórios (só nas features que falam com a API REST)
└── presentation/       ← Telas e widgets (Screens)
```

Features que só persistem localmente (`producao`, `embarcacao`, `mapa`, `viagem`, `cartas`, `rotas`) **não têm `data/`** — as telas acessam `DatabaseHelper` diretamente. Já as features que falam com o backend (`dispositivo`, `localizacao`, `recomendacao`) têm um repositório dedicado em `data/` que usa `ApiService`.

A camada `core/` contém tudo que é compartilhado entre features:

```
core/
├── auth/               ← Autenticação (AuthService, JWT, Usuario)
├── background/         ← Callback do WorkManager (rastreamento em background)
├── config/              ← Config (key-value sobre Hive) e Constantes de chaves
├── database/            ← DatabaseHelper (SQLite)
├── models/              ← Modelos usados por múltiplas features (clorofila, ondas)
├── network/              ← ApiService, Endpoints, exceções de rede
├── services/             ← Lógica de negócio reutilizável (GPS, mapas, sync, etc.)
├── storage/              ← ApiStorageService (Hive, ferramenta de debug)
└── utils/                ← Funções puras (formatação de coordenadas, proximidade)
```

### Dois mundos de persistência local + um remoto

| Camada | Tecnologia | Uso |
|---|---|---|
| **SQLite** | `sqflite`, via `DatabaseHelper` (CRUD genérico por nome de tabela, sem ORM) | Dados operacionais do app: embarcação, viagem, produção, localizações, pontos marcados, rotas, solicitações de carta |
| **Hive** | `hive_flutter`, chave-valor puro (sem `TypeAdapter`/`build_runner`) | `config` (preferências/tokens) e `api_responses` (histórico do Teste de API) |
| **Blue Ocean API** | REST via `ApiService`/repositórios em `data/` | Autenticação, dispositivo, localização (envio), recomendações |

### Padrões utilizados

| Padrão | Onde é usado |
|--------|-------------|
| **Singleton (instância)** | `DatabaseHelper.instance`, `LocationService()`, `LocationTrackingService()`, `StreetMapCacheService()` |
| **Namespace estático (singleton implícito, sem instância)** | `Config`, `ApiService`, `AuthService`, `NightModeService`, `DeviceIdService`, `SincronizacaoService`, `LocalizacaoReporterService` |
| **Repository** | `DispositivoRepository`, `LocalizacaoRepository`, `RecomendacaoRepository`, `PrevisaoTempoRepository`, `ProfundidadeRepository`, `WaveForecastRepository` |
| **Abstract Base Class** | `BaseMeteorologyCard` para os cards de meteorologia |
| **Isolates (compute)** | `GeotiffService` para não bloquear a UI ao processar imagens |
| **Estado global simples (`ValueNotifier`)** | `NightModeService.ativo`, consumido no `builder` do `MaterialApp` |

Não há gerenciador de estado global (Provider/Bloc/Riverpod) nem geração de código para modelos (`json_serializable`/`freezed`) — toda (de)serialização é manual.

---

## 4. Estrutura de Pastas

```
atlas/
├── assets/
│   ├── cartas/                        # Carta náutica PDF e MBTiles bundled
│   │   ├── Carta_Navegacao_Nordeste.pdf
│   │   └── OUTPUT_FILE.mbtiles        # Mapa base offline (sempre carregado)
│   ├── icons/                         # Ícones customizados / launcher icon
│   ├── overlays/                      # Pasta de referência para PNGs georreferenciados
│   └── json/
│       ├── vento.json                 # Dados de vento (modelo GFS)
│       ├── correntes.json             # Dados de correntes (modelo HYCOM)
│       ├── clorofila.json             # Dados de clorofila (NOAA)
│       └── posicoes/
│           └── Routing3.json          # Pontos de rota de exemplo com dados meteorológicos
│
├── lib/
│   ├── main.dart                      # Ponto de entrada (Hive, splash nativo, modo noturno)
│   ├── app_shell.dart                 # BottomNavigationBar: Home / Cartas / Mapa
│   │
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_service.dart
│   │   │   ├── jwt_utils.dart
│   │   │   └── models/usuario.dart
│   │   ├── background/
│   │   │   └── location_worker.dart
│   │   ├── config/
│   │   │   ├── config.dart
│   │   │   └── constantes.dart
│   │   ├── database/
│   │   │   └── database_helper.dart
│   │   ├── models/
│   │   │   ├── chlorophyll_reading.dart
│   │   │   └── wave_forecast.dart
│   │   ├── network/
│   │   │   ├── api_service.dart
│   │   │   ├── endpoints.dart
│   │   │   └── excecoes.dart
│   │   ├── services/
│   │   │   ├── device_id_service.dart
│   │   │   ├── foto_embarcacao_service.dart
│   │   │   ├── geo_png_helper.dart
│   │   │   ├── geotiff_service.dart
│   │   │   ├── localizacao_reporter_service.dart
│   │   │   ├── location_service.dart
│   │   │   ├── location_tracking_service.dart
│   │   │   ├── mbtiles_service.dart
│   │   │   ├── night_mode_service.dart
│   │   │   ├── pontos_service.dart
│   │   │   ├── sincronizacao_service.dart
│   │   │   └── street_map_cache_service.dart
│   │   ├── storage/
│   │   │   └── api_storage_service.dart
│   │   └── utils/
│   │       ├── coordenadas_format.dart
│   │       └── proximidade.dart
│   │
│   └── features/
│       ├── api_tester/presentation/
│       │   └── api_tester_screen.dart
│       ├── auth/presentation/
│       │   └── login_screen.dart
│       ├── cartas/
│       │   ├── domain/models/carta_nautica.dart
│       │   └── presentation/
│       │       ├── cartas_screen.dart
│       │       ├── minhas_solicitacoes_screen.dart
│       │       ├── pdf_viewer_screen.dart
│       │       └── solicitar_cartas_screen.dart
│       ├── configuracoes/presentation/
│       │   └── configuracoes_screen.dart
│       ├── dashboard/presentation/
│       │   └── dashboard_screen.dart
│       ├── dispositivo/
│       │   ├── data/dispositivo_repository.dart
│       │   ├── domain/models/dispositivo.dart
│       │   └── presentation/dispositivo_teste_screen.dart
│       ├── embarcacao/
│       │   ├── domain/models/embarcacao.dart
│       │   └── presentation/
│       │       ├── cadastrar_embarcacao_screen.dart
│       │       ├── embarcacao_configuracao_screen.dart
│       │       ├── embarcacao_screen.dart
│       │       └── widgets/foto_embarcacao_picker.dart
│       ├── localizacao/
│       │   ├── data/localizacao_repository.dart
│       │   └── domain/models/localizacao_envio.dart
│       ├── mapa/
│       │   ├── domain/models/ponto_marcado.dart
│       │   ├── presentation/
│       │   │   ├── mapa_screen.dart
│       │   │   └── mapa_widget.dart
│       │   └── widgets/
│       │       ├── download_regiao_dialog.dart
│       │       ├── mbtiles_tile_provider.dart
│       │       ├── meteorologia_sheet.dart
│       │       └── street_map_tile_provider.dart
│       ├── metereologia/
│       │   ├── data/
│       │   │   ├── previsao_tempo_repository.dart
│       │   │   ├── profundidade_repository.dart
│       │   │   └── wave_forecast_repository.dart
│       │   ├── domain/models/
│       │   │   ├── leitura_profundidade.dart
│       │   │   └── previsao_tempo.dart
│       │   └── presentation/
│       │       ├── condicoes_mar_screen.dart
│       │       └── gribs_screen.dart
│       ├── producao/
│       │   ├── domain/
│       │   │   ├── especies_comuns.dart
│       │   │   └── models/producao_registro.dart
│       │   └── presentation/
│       │       ├── producao_historico_screen.dart
│       │       └── producao_screen.dart
│       ├── recomendacao/
│       │   ├── data/recomendacao_repository.dart
│       │   ├── domain/models/recomendacao.dart
│       │   └── widgets/
│       │       ├── recomendacao_card.dart
│       │       ├── recomendacao_confianca_dots.dart
│       │       ├── recomendacao_list_tile.dart
│       │       ├── recomendacao_ponto_card.dart
│       │       ├── recomendacao_pontos_list.dart
│       │       ├── recomendacao_score_badge.dart
│       │       ├── recomendacao_validade_chip.dart
│       │       ├── recomendacao_variavel_chip.dart
│       │       ├── recomendacao_widgets.dart      # barrel
│       │       └── recomendacoes_list.dart
│       ├── rotas/
│       │   ├── domain/models/rota_planejada.dart
│       │   └── presentation/minhas_rotas_screen.dart
│       ├── splash/
│       │   └── splash_screen.dart
│       ├── viagem/
│       │   ├── domain/models/
│       │   │   ├── tripulante.dart
│       │   │   └── viagem.dart
│       │   └── presentation/
│       │       ├── historico_localizacoes_screen.dart
│       │       ├── nova_tripulacao.dart
│       │       └── nova_viagem_screen.dart
│       └── widgets/
│           ├── base_meteorology_card.dart
│           ├── info_column.dart
│           ├── posicao_atual_widget.dart
│           ├── posicao_manual_widget.dart
│           ├── position_card.dart
│           ├── profundidade_card.dart
│           ├── web_view_screen.dart
│           ├── meteorology_widgets/
│           │   ├── chlorophyll_card.dart
│           │   ├── chlorophyll_chip.dart
│           │   ├── chlorophyll_legend.dart
│           │   ├── chlorophyll_nearby_list.dart
│           │   ├── chlorophyll_widgets.dart        # barrel
│           │   ├── current_card.dart
│           │   └── wind_card.dart
│           ├── previsao_tempo/
│           │   ├── condicoes_vento_card.dart
│           │   └── previsao_tempo_widgets.dart      # barrel
│           └── wave_forecast/
│               ├── condicoes_atuais_card.dart
│               ├── sea_surface_temperature_card.dart
│               └── wave_forecast_widgets.dart       # barrel
│
└── pubspec.yaml
```

---

## 5. Dependências

### Principais

| Pacote | Versão | Finalidade |
|--------|--------|-----------|
| `http` | ^1.2.2 | Requisições HTTP (backend + APIs externas) |
| `sqflite` | ^2.3.3 | Banco de dados SQLite local |
| `path_provider` | ^2.1.5 | Diretórios do dispositivo |
| `path` | ^1.9.0 | Manipulação de caminhos |
| `pdfrx` | ^1.0.0 | Visualizador de PDF (cartas náuticas) |
| `geolocator` | ^13.0.0 | GPS e geolocalização |
| `workmanager` | 0.9.0+3 | Tarefas em background (rastreamento) |
| `permission_handler` | ^12.0.0 | Gerenciamento de permissões |
| `flutter_map` | ^7.0.2 | Mapa interativo offline |
| `latlong2` | ^0.9.1 | Operações com coordenadas |
| `file_picker` | ^8.1.6 | Seletor de arquivos do dispositivo (MBTiles, GeoTIFF, PNG de overlay) |
| `image` | ^4.5.0 | Processamento de GeoTIFF e leitura de metadados de PNG (`GeoPngHelper`) |
| `hive_flutter` | ^1.1.0 | Armazenamento NoSQL local (config e histórico de API) |
| `intl` | ^0.19.0 | Formatação de datas/números |
| `flutter_secure_storage` | ^9.2.0 | Armazenamento seguro (ID de dispositivo no iOS) |
| `device_info_plus` | ^12.4.0 | Dados descritivos do dispositivo |
| `android_id` | ^0.5.2+1 | ID estável de dispositivo Android |
| `battery_plus` | ^6.2.1 | Nível de bateria (enviado junto com a localização) |
| `flutter_native_splash` | ^2.4.3 | Splash screen nativa |
| `url_launcher` | ^6.3.1 | Abrir links/telefone/WhatsApp externos |
| `share_plus` | ^10.1.4 | Compartilhamento (ex: resumo de viagem) |
| `webview_flutter` | ^4.10.0 | WebView embutida (`WebViewScreen`) |

### Dev

| Pacote | Versão | Finalidade |
|--------|--------|-----------|
| `flutter_test` | SDK | Testes |
| `flutter_lints` | ^5.0.0 | Regras de lint |
| `flutter_launcher_icons` | ^0.14.3 | Geração do ícone do app a partir de `assets/icons/blue_ocean.png` |

---

## 6. Banco de Dados SQLite

**Arquivo:** `blue_ocean.db` (em `ApplicationDocumentsDirectory`)
**Gerenciado por:** `lib/core/database/database_helper.dart` — **Singleton** (`DatabaseHelper.instance`), atualmente na **versão 10** do schema (`onCreate`/`onUpgrade` incrementais desde a v2).

O `DatabaseHelper` expõe métodos genéricos CRUD reaproveitados por toda a app — não há DAO por entidade:

```dart
Future<int> insert(String table, Map<String, dynamic> data)
Future<List<Map<String, dynamic>>> query(String table)
Future<List<Map<String, dynamic>>> queryWhere(String table, {required String where, List<Object?>? whereArgs, String? orderBy})
Future<int> update(String table, Map<String, dynamic> data, {required int id})
Future<int> delete(String table, {required int id})
Future<int> deleteWhere(String table, {required String where, List<Object?>? whereArgs})
```

### Tabelas

#### `embarcacao`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `nome` | TEXT | Nome da embarcação |
| `dono` | TEXT | Nome do proprietário |
| `quantidade_urnas` | INTEGER | Nº de compartimentos/urnas (default 1) |
| `registro` | TEXT | Código/placa (ex: PE-1234) |
| `data_cadastro` | TEXT | ISO 8601 |
| `ativo` | INTEGER | 1=ativo, 0=inativo |
| `capacidade_gelo_kg` | REAL | *(desde v4)* |
| `capacidade_diesel_litros` | REAL | *(desde v4)* |
| `numero_tripulantes` | INTEGER | *(desde v4)* |
| `mestre_id` | TEXT | *(desde v4)* |
| `motor_usado` | TEXT | *(desde v5)* |
| `foto` | TEXT | Caminho local da foto *(desde v6)* |

#### `viagem`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `nome` | TEXT | Nome opcional da viagem |
| `data_inicio` | TEXT | ISO 8601 |
| `data_termino` | TEXT | ISO 8601 (nullable) |
| `embarcacao_id` | TEXT | ID da embarcação |
| `status` | TEXT | `'em_andamento'` ou `'finalizada'` |

#### `localizacao_historico`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `data_hora` | TEXT | ISO 8601 |
| `latitude` / `longitude` | REAL | Graus decimais |
| `velocidade` | REAL | m/s (nullable) |
| `precisao` | REAL | Metros (nullable) |
| `altitude` | REAL | *(desde v3)* |
| `direcao` | INTEGER | Rumo em graus *(desde v3)* |
| `bateria_nivel` | INTEGER | % de bateria no momento *(desde v3)* |
| `viagem_id` | INTEGER | FK lógica para `viagem.id` |
| `sincronizado` | INTEGER | 0=pendente, 1=enviado ao servidor |

#### `carta_nautica`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `codigo` | TEXT UNIQUE | Código identificador da carta |
| `nome` | TEXT | Nome descritivo |
| `url_s3` | TEXT | URL para download no S3 |
| `caminho_local` | TEXT | Caminho local após download (nullable) |
| `data_publicacao` / `data_atualizacao` | TEXT | ISO 8601 |
| `esta_baixada` | INTEGER | 0=não baixada, 1=baixada |

#### `producao_registro`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `embarcacao_id` | TEXT | ID da embarcação |
| `data_hora` | TEXT | ISO 8601 |
| `especie` | TEXT | Nome da espécie capturada |
| `quantidade_kg` | REAL | Peso em quilogramas |
| `latitude` / `longitude` | REAL | Posição da captura (nullable) |
| `carta_codigo` | TEXT | Referência da carta usada (nullable) |
| `observacao` | TEXT | Obs. livre (nullable) |
| `viagem_id` | INTEGER | FK lógica para `viagem.id` *(desde v7)* |
| `sincronizado` | INTEGER | 0=pendente, 1=enviado ao servidor |

#### `ponto_marcado` *(desde v2, coluna `nome` desde v8)*
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `latitude` / `longitude` | REAL | Posição marcada manualmente no mapa |
| `data_criacao` | TEXT | ISO 8601 |
| `nome` | TEXT | Nome opcional do ponto |

#### `solicitacao_carta` *(desde v9)*
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `latitude_texto` / `longitude_texto` | TEXT | Coordenadas formatadas do pedido |
| `data_solicitacao` | TEXT | ISO 8601 |

#### `rota_planejada` *(desde v10)*
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `nome` | TEXT | Nome da rota |
| `data_criacao` | TEXT | ISO 8601 |

#### `rota_planejada_ponto` *(desde v10)*
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `rota_planejada_id` | INTEGER | FK lógica para `rota_planejada.id` |
| `latitude` / `longitude` | REAL | Ponto da rota |
| `ordem` | INTEGER | Posição do ponto na sequência da rota |

> Não existe tabela `recomendacao` nem `tripulante` — recomendações vêm sempre da API (`RecomendacaoRepository`, sem cache local) e tripulantes ainda não são persistidos.

---

## 7. Serviços Principais (`core/`)

### 7.1 Config
**Localização:** `core/config/config.dart` — namespace estático sobre uma `Box<String>` do Hive (`config`), aberta sob demanda.

```dart
Config.obtem(String chave, [String valorPadrao = ''])  // → Future<String>
Config.grava(String chave, String valor)                // → Future<void>
Config.limpa(String chave)                               // → Future<void>
```

As chaves usadas ficam centralizadas em `Constantes` (`api`, `authToken`, `authCredencial`, `deviceId`, `organizacaoId`, `embarcacaoId`, `intervaloRastreamentoMinutos`, `modoNoturno`, `contatoEmergenciaWhatsapp`). É a base de armazenamento de quase todos os outros serviços.

---

### 7.2 ApiService
**Localização:** `core/network/api_service.dart` — namespace estático, cliente HTTP cru da Blue Ocean API.

```dart
ApiService.login(String usuario, String senha)   // POST /api/v1/autenticacao — salva token/credencial/organizacaoId
ApiService.get(String recurso)                   // → Future<dynamic>
ApiService.post(String recurso, dynamic data)
ApiService.put(String recurso, dynamic data)
ApiService.carga(String recurso, DateTime inicio) // pagina até esgotar
```

Lança `UnauthorisedException` em respostas `401`. Todos os repositórios do backend (`DispositivoRepository`, `LocalizacaoRepository`, `RecomendacaoRepository`) passam por aqui — os repositórios de APIs externas (Open-Meteo, OpenTopoData) chamam `http` diretamente, sem `ApiService`.

---

### 7.3 AuthService
**Localização:** `core/auth/auth_service.dart`

```dart
AuthService.login(usuario, senha)   // delega a ApiService.login
AuthService.isLoggedIn()            // → bool, compara exp do JWT salvo com agora
AuthService.usuarioLogado()         // → Usuario? montado a partir da credencial salva + claims do JWT
AuthService.logout()                // limpa token/credencial/organizacaoId
```

---

### 7.4 DeviceIdService
**Localização:** `core/services/device_id_service.dart`

Obtém um ID estável do dispositivo: `AndroidId` no Android, Keychain (`flutter_secure_storage`, com fallback `identifierForVendor`) no iOS, e um ID persistente genérico (salvo via `Config`) nas demais plataformas. Também expõe `DeviceInfoResumo` (modelo, fabricante, SO, versão).

---

### 7.5 LocationService
**Localização:** `core/services/location_service.dart` — Singleton.

```dart
getCurrentPosition({accuracy, requestPermission})  // → Future<Position?>, trata permissões
decimalToDMS(double decimal, bool isLatitude)       // → String
```

---

### 7.6 LocationTrackingService
**Localização:** `core/services/location_tracking_service.dart` — Singleton.

```dart
initialize()                                       // Workmanager().initialize(callbackDispatcher)
iniciarRastreamento({required int intervaloMinutos}) // mínimo de 15 min, registra task periódica
pararRastreamento()
getHistory({int? viagemId})                        // → histórico em localizacao_historico
```

---

### 7.7 LocalizacaoReporterService
**Localização:** `core/services/localizacao_reporter_service.dart` — orquestrador central do rastreamento (namespace estático).

```dart
registrarESincronizar({Position? posicaoConhecida})
// captura GPS + bateria, salva em localizacao_historico (sincronizado=0), chama sincronizarPendentes()

sincronizarPendentes()
// se não estiver logado, para o rastreamento; resolve embarcacaoId/dispositivoId reais
// (via DispositivoRepository + DeviceIdService) e envia cada pendência via LocalizacaoRepository,
// convertendo velocidade m/s → nós
```

Chamado pelo callback do WorkManager (`location_worker.dart`) e por `PosicaoAtualWidget` na abertura do app.

---

### 7.8 MbtilesService
**Localização:** `core/services/mbtiles_service.dart`

Lê arquivos `.mbtiles` (SQLite) para servir tiles ao `flutter_map`. Auto-detecta convenção TMS vs. XYZ (eixo Y) na primeira requisição e cacheia o resultado (`_isTms`).

```dart
openFromAsset(String assetPath)   // copia do bundle na 1ª vez
open(String filePath)             // abre arquivo externo
getMetadata()                     // name, bounds, center, min/maxzoom
getTileBytes(int z, int x, int y)
```

---

### 7.9 GeotiffService
**Localização:** `core/services/geotiff_service.dart`

Extrai bounds geográficos de tags GeoTIFF (`ModelPixelScale`, `ModelTiepoint`, `ModelTransformation`) e decodifica os pixels em isolate (`compute`), redimensionando para no máximo 4096px.

```dart
load(String filePath) → Future<GeotiffResult>  // {north, south, east, west, imageBytes}
```

---

### 7.10 GeoPngHelper
**Localização:** `core/services/geo_png_helper.dart`

Lê os limites geográficos (bounds) de um PNG georreferenciado a partir de um metadado de texto (chunk `tEXt`) **embutido no próprio arquivo**, eliminando a necessidade de hardcodar coordenadas de overlay no código. É só leitura — a gravação do metadado é feita por uma ferramenta externa ao app, fora do escopo do Flutter.

```dart
GeoPngHelper.readBounds(File pngFile) → Future<LatLngBounds>
```

- Faz um parse leve do PNG (percorre os *chunks* via `img.PngDecoder().startDecode()`, sem decodificar os pixels) — rápido mesmo em imagens grandes.
- Procura a chave **`geo_bounds`**, com valor no formato `sw_lat=X;sw_lng=Y;ne_lat=X;ne_lng=Y`.
- Lança `Exception` com mensagem clara se o arquivo não for um PNG válido, o metadado estiver ausente ou malformado — tratada pela tela de mapa com fallback para bounds fixos (ver [9.6](#96-mapa-offline-mapa)).

---

### 7.11 PontosService
**Localização:** `core/services/pontos_service.dart`

Carrega pontos de exemplo/demonstração a partir de JSON nos assets (`assets/json/posicoes/`), incluindo dados meteorológicos completos por ponto (`PontoMapa` + `Meteorologia`).

---

### 7.12 NightModeService
**Localização:** `core/services/night_mode_service.dart`

Estado global (`ValueNotifier<bool> ativo`) do modo noturno — converte a UI para tons de vermelho (preserva a visão no escuro), aplicado no `builder` do `MaterialApp` em `main.dart`. Persistido via `Config`.

---

### 7.13 SincronizacaoService
**Localização:** `core/services/sincronizacao_service.dart`

Ponto de entrada de sincronização inicial (chamado pelo Dashboard): resolve o `deviceId`, busca o `Dispositivo` correspondente e a lista de `Recomendacao` do backend, retornando os dois num `ResultadoSincronizacao`.

---

### 7.14 StreetMapCacheService
**Localização:** `core/services/street_map_cache_service.dart` — Singleton.

Cache em disco de tiles do OpenStreetMap (`<documents>/street_cache/{z}/{x}/{y}.png`), com download sob demanda e download em lote de uma região (`baixarRegiao`, com progresso via `Stream<ProgressoDownload>` e `CancelToken`).

---

### 7.15 FotoEmbarcacaoService
**Localização:** `core/services/foto_embarcacao_service.dart`

```dart
FotoEmbarcacaoService.salvar(String origemPath) → Future<String>
// copia para <documents>/embarcacao_fotos/embarcacao_<timestamp><ext>
```

---

### 7.16 ApiStorageService
**Localização:** `core/storage/api_storage_service.dart` — Hive, box `api_responses`.

Persiste respostas HTTP da tela de Teste de API (`ApiEntry`): `save`, `getAll` (mais recente primeiro), `delete`, `clear`, `count`.

---

## 8. Repositórios de API (`data/`)

| Repository | Métodos | Backend |
|---|---|---|
| `DispositivoRepository` (`features/dispositivo/data`) | `buscarPorIdentificador(String identificador) → Future<Dispositivo>` | Blue Ocean API, via `ApiService` |
| `LocalizacaoRepository` (`features/localizacao/data`) | `enviar(LocalizacaoEnvio dados) → Future<void>` | Blue Ocean API, via `ApiService` |
| `RecomendacaoRepository` (`features/recomendacao/data`) | `listar() → Future<List<Recomendacao>>`, `buscarPorId(String id) → Future<Recomendacao>` | Blue Ocean API, via `ApiService` |
| `PrevisaoTempoRepository` (`features/metereologia/data`) | `buscar({latitude, longitude}) → Future<PrevisaoTempo>` | Open-Meteo (`http` direto) |
| `ProfundidadeRepository` (`features/metereologia/data`) | `buscarPonto(...)`, `buscarVarios(List<LatLng>)` | OpenTopoData/GEBCO (`http` direto) |
| `WaveForecastRepository` (`features/metereologia/data`) | `buscar({latitude, longitude}) → Future<WaveForecast>` | Open-Meteo Marine (`http` direto) |

Endpoints do backend próprio ficam centralizados em `core/network/endpoints.dart` (`Endpoints.dispositivoPorIdentificador`, `Endpoints.recomendacoes`, `Endpoints.recomendacaoPorId`, `Endpoints.localizacaoDispositivo`).

---

## 9. Features — Telas e Funcionalidades

### 9.1 Splash (`splash/`)
**Tela:** `SplashScreen` — decide o destino inicial (`AppShell` vs `LoginScreen`) com base em `AuthService.isLoggedIn()`, e reconfirma o estado do rastreamento via `LocationTrackingService`.

### 9.2 Login (`auth/`)
**Tela:** `LoginScreen` — formulário de usuário/senha, chama `AuthService.login()` (backend real) → navega para `AppShell` em caso de sucesso.

### 9.3 Dashboard (`dashboard/`)
**Tela:** `DashboardScreen` — tela inicial (aba "Home"). Dispara `SincronizacaoService.sincronizar()`, exibe posição GPS ao vivo, viagem em andamento, estatísticas, recomendações e atalhos para as demais features. Se houver viagem ativa, inicia o rastreamento automaticamente.

### 9.4 Cartas Náuticas (`cartas/`)
**Telas:** `CartasScreen` (lista/baixa cartas com busca), `PdfViewerScreen` (zoom/pan via `pdfrx`), `SolicitarCartaScreen` (formulário de pedido, salvo em `solicitacao_carta`), `MinhasSolicitacoesScreen` (lista os pedidos feitos).

### 9.5 Embarcação (`embarcacao/`)
**Telas:** `EmbarcacaoScreen`, `CadastrarEmbarcacaoScreen`, `EmbarcacaoConfiguracaoScreen`; widget `FotoEmbarcacaoPicker` (usa `FotoEmbarcacaoService`). A placa/registro é sempre convertida para maiúsculas.

### 9.6 Mapa Offline (`mapa/`)
**Telas:** `MapaScreen` (container) → `MapaWidget` (mapa principal, autocontido).

Suporta os modos:

| Modo | Como ativar |
|------|------------|
| **MBTiles bundled** | Carregado automaticamente ao abrir (`OUTPUT_FILE.mbtiles`) |
| **MBTiles externo** | Botão de pasta na AppBar → file picker |
| **GeoTIFF** | Botão de pasta na AppBar → selecionar `.tif/.tiff` |
| **Mapa de ruas** | Alterna camada, com cache via `StreetMapCacheService` |

**Camadas do mapa (ordem de renderização):**
1. `TileLayer` — MBTiles (`MbtilesTileProvider`) ou mapa de ruas (`StreetMapTileProvider`)
2. `OverlayImageLayer` — GeoTIFF (se modo GeoTIFF ativo)
3. `OverlayImageLayer` — **PNG georreferenciado escolhido pelo usuário** (ver abaixo)
4. `MarkerLayer` — calor de produção (círculos proporcionais ao total em kg)
5. `PolylineLayer` — rota sendo planejada manualmente
6. `MarkerLayer` — pontos marcados manualmente, pontos de recomendação, rota de histórico, posição GPS

**Sobreposição de PNG georreferenciado:** o botão de camadas (ícone de "layers") abre um diálogo (`AlertDialog`) explicando o fluxo e, ao confirmar, abre o seletor de arquivos (`FilePicker`, filtrado para `.png` — no Android inclui a galeria de fotos como origem). Os bounds (sudoeste/nordeste) são lidos automaticamente do metadado `geo_bounds` embutido no arquivo via `GeoPngHelper.readBounds`. Se o PNG não tiver o metadado, o app cai num retângulo fixo de fallback (`_overlaySudoesteFallback`/`_overlayNordesteFallback`, em `mapa_widget.dart`) e avisa o usuário por `SnackBar`, em vez de travar. Toque curto no botão liga/desliga a camada já carregada; toque longo reabre o diálogo para trocar de imagem. Um slider (`_buildOverlayOpacidadeControl`) ajusta a opacidade em tempo real (padrão 80%).

**Outras interações do mapa:**
- Marcar ponto manualmente (mira no centro, salvo em `ponto_marcado`)
- Planejar rota manualmente (sequência de toques, salva em `rota_planejada`/`rota_planejada_ponto`)
- Toque no label de um ponto → `MeteorologiaSheet` (bottom sheet com vento, movimento, atmosfera, ondas)
- Download de região do mapa de ruas para uso offline (`DownloadRegiaoDialog`)

**GPS:** estratégia de duas fases — `getLastKnownPosition()` (instantâneo) → `getCurrentPosition()` (fix fresco em segundo plano).

### 9.7 Meteorologia (`metereologia/`)
**Telas:** `CondicoesMarScreen` (agrega previsão do tempo, ondas, clorofila e profundidade num ponto), `GribProcessorScreen` (processamento de arquivos GRIB).

Combina três fontes: JSON local (`vento.json`, `correntes.json`, `clorofila.json` — filtrados por proximidade via Haversine, raio ≈ 80 mn) e APIs externas via `PrevisaoTempoRepository`/`ProfundidadeRepository`/`WaveForecastRepository`.

### 9.8 Produção (`producao/`)
**Telas:** `ProducaoScreen` (registro: espécie, kg, observação, posição GPS e data automáticas), `ProducaoHistoricoScreen` (histórico e totais por espécie). Salvo com `sincronizado = 0`.

### 9.9 Recomendação (`recomendacao/`)
Sem tela própria — é uma biblioteca de widgets (`RecomendacaoCard`, `RecomendacaoListTile`, `RecomendacaoPontoCard`, `RecomendacaoScoreBadge`, `RecomendacaoConfiancaDots`, `RecomendacaoValidadeChip`, `RecomendacaoVariavelChip`, `RecomendacoesList`) embutida em `dashboard`, `mapa` e `dispositivo`, alimentada por `RecomendacaoRepository`.

### 9.10 Rotas (`rotas/`)
**Tela:** `MinhasRotasScreen` — lista/gerencia rotas planejadas (CRUD local em `rota_planejada`/`rota_planejada_ponto`), editadas visualmente no mapa.

### 9.11 Viagem (`viagem/`)
**Telas:** `NovaViagemScreen` (inicia/finaliza viagem), `NovaTripulacao` (gerencia tripulantes — ainda sem persistência local), `HistoricoLocalizacoesScreen` (timeline de posições em DMS, trajeto no mapa).

### 9.12 Dispositivo (`dispositivo/`)
**Tela:** `DispositivoTesteScreen` — ferramenta de debug do registro de dispositivo (`DispositivoRepository`) e recomendações associadas.

### 9.13 Localização (`localizacao/`)
Sem tela própria — só `data/` (`LocalizacaoRepository`) e `domain/models` (`LocalizacaoEnvio`), consumida por `LocalizacaoReporterService` e widgets de posição.

### 9.14 Configurações (`configuracoes/`)
**Tela:** `ConfiguracoesScreen` — intervalo de rastreamento, modo noturno, contato de emergência (WhatsApp), embarcação ativa, backup manual do banco.

### 9.15 Teste de API (`api_tester/`)
**Tela:** `ApiTesterScreen` — ferramenta interna para testar endpoints HTTP manualmente.

**Aba "Testar":** GPS ao vivo, método (GET/POST/PUT/PATCH/DELETE), URL e body com placeholders `{latitude}`/`{longitude}`, resposta formatada e salva no Hive.
**Aba "Histórico":** lista expansível das respostas salvas (status, método, URL, tempo, timestamp, coordenadas), com opção de limpar tudo.

### 9.16 Widgets Compartilhados (`features/widgets/`)

| Widget | Descrição |
|--------|-----------|
| `PositionCard`, `PosicaoAtualWidget`, `PosicaoManualWidget` | Coordenadas GPS (ao vivo ou digitadas manualmente) |
| `BaseMeteorologyCard` | Classe abstrata base para todos os cards de meteorologia |
| `InfoColumn` | Coluna com ícone + label + valor |
| `WindCard`, `CurrentCard`, `ChlorophyllCard`/`ChlorophyllChip`/`ChlorophyllLegend`/`ChlorophyllNearbyList` | Cards de vento, corrente e clorofila |
| `CondicoesVentoCard` | Card de previsão do tempo/vento (Open-Meteo) |
| `CondicoesAtuaisCard`, `SeaSurfaceTemperatureCard` | Cards de ondas/temperatura da superfície do mar |
| `ProfundidadeCard` | Card de profundidade/batimetria |
| `MeteorologiaSheet` | Bottom sheet draggável com os dados completos de um `PontoMapa` |
| `WebViewScreen` | WebView genérica (`webview_flutter`) |

---

## 10. Modelos de Dados

### Usuario (`core/auth/models`)
```dart
class Usuario {
  final String id, email, nome;
  final String? organizacaoId, empresaId;
  factory Usuario.fromLoginResponse(Map<String,dynamic> json); // combina resposta de login + claims do JWT
}
```

### Dispositivo (`features/dispositivo/domain/models`)
```dart
class Dispositivo {
  final String id, organizacaoId, identificador, nome;
  final String? empresaId, sigla;
  final int status, tipo, ambiente;
  final bool atuante;
  final DateTime? criadoEm, atualizadoEm;
  factory Dispositivo.fromJson(Map<String,dynamic> json);
}
```

### Embarcacao (`features/embarcacao/domain/models`)
```dart
class Embarcacao {
  final int? id;
  final String nome;
  final String? dono, registro, mestreId, motorUsado, foto;
  final int quantidadeUrnas; // default 1
  final double? capacidadeGeloKg, capacidadeDieselLitros;
  final int? numeroTripulantes;
  final DateTime dataCadastro;
  final bool ativo;
  factory Embarcacao.fromMap(Map map); Map<String,dynamic> toMap(); Embarcacao copyWith(...);
}
```

### Viagem (`features/viagem/domain/models`)
```dart
class Viagem {
  final int id;
  final String? nome;
  final DateTime dataInicio;
  final DateTime? dataTermino;
  final String embarcacaoId;
  final String status;  // 'em_andamento' | 'finalizada'
  bool get isFinalizada => status == 'finalizada';
  factory Viagem.fromMap(Map map); Map<String,dynamic> toMap();
}
```

### Tripulante (`features/viagem/domain/models`)
```dart
class Tripulante {
  final int id;
  final String nome;
  final String? apelido;
  // sem (de)serialização — ainda não persistido no SQLite
}
```

### CartaNautica (`features/cartas/domain/models`)
```dart
class CartaNautica {
  final int id;
  final String codigo, nome, urlS3;
  final String? caminhoLocal;
  final DateTime dataPublicacao, dataAtualizacao;
  final bool estaBaixada;
  factory CartaNautica.fromMap(Map map); Map<String,dynamic> toMap();
}
```

### ProducaoRegistro (`features/producao/domain/models`)
```dart
class ProducaoRegistro {
  final int id;
  final String embarcacaoId, especie;
  final DateTime dataHora;
  final double quantidadeKg;
  final double? latitude, longitude;
  final String? cartaCodigo, observacao;
  final int? viagemId;
  final bool sincronizado;
  factory ProducaoRegistro.fromMap(Map map); Map<String,dynamic> toMap();
}
// + especiesComuns: List<String> e normalizarEspecie(String) em especies_comuns.dart
```

### PontoMarcado (`features/mapa/domain/models`)
```dart
class PontoMarcado {
  final int? id;
  final double latitude, longitude;
  final DateTime dataCriacao;
  final String? nome;
  factory PontoMarcado.fromMap(Map map); Map<String,dynamic> toMap();
}
```

### RotaPlanejada (`features/rotas/domain/models`)
```dart
class RotaPlanejada {
  final int? id;
  final String nome;
  final DateTime dataCriacao;
  final List<LatLng> pontos;  // gravados à parte, em rota_planejada_ponto
  factory RotaPlanejada.fromMap(Map map, {required List<LatLng> pontos}); Map<String,dynamic> toMap();
}
```

### LocalizacaoEnvio (`features/localizacao/domain/models`)
```dart
class LocalizacaoEnvio {
  final String embarcacaoId, dispositivoId;
  final DateTime instante;
  final double latitude, longitude, precisaoMetros;
  final double? altitude, velocidadeNos;
  final int? direcao, bateriaNivel;
  final int gpsStatus, origem; // defaults 1, 1
  // DTO write-only — sem fromJson, serializado manualmente em LocalizacaoRepository
}
```

### Recomendacao e agregados (`features/recomendacao/domain/models`)
```dart
enum VariavelAmbiental { vento(1), corrente(2), clorofila(3), onda(4), temperatura(5) }

class VariavelValor { final double valor; final int variavel; VariavelAmbiental get tipo; factory fromJson; }
class Centroide { final double latitude, longitude; factory fromJson; }
class PontoRecomendacao { final double latitude, longitude; final List<VariavelValor> variaveis; factory fromJson; }

class Recomendacao {
  final String id, organizacaoId, titulo;
  final int tipo, confianca, status;
  final num score;
  final String? descricao, motivoRejeicao, cartaNauticaUrl;
  final Centroide? centroide;
  final num? estimativaCapturaKg;
  final DateTime? criadoEm, validoAte;
  final List<PontoRecomendacao>? pontos;
  bool get temCoordenadas;
  factory Recomendacao.fromJson(Map<String,dynamic> json);
}
```

### PrevisaoTempo e agregados (`features/metereologia/domain/models`)
```dart
class PrevisaoTempoHoraria {
  final DateTime horario;
  final double velocidadeVento, precipitacao, temperatura, pressao, umidadeRelativa;
  final int direcaoVento;
  String get direcaoLabel; double get direcaoRadianos;
}
class PrevisaoTempoAtual { final DateTime horario; final double temperatura, velocidadeVento; final int direcaoVento; factory fromJson; }
class PrevisaoTempo {
  final double latitude, longitude;
  final String timezone;
  final PrevisaoTempoAtual? atual;
  final List<PrevisaoTempoHoraria> horaria;
  List<PrevisaoTempoHoraria> get proximasHoras;
  factory PrevisaoTempo.fromJson(Map<String,dynamic> json); // Open-Meteo
}
```

### LeituraProfundidade (`features/metereologia/domain/models`)
```dart
class LeituraProfundidade {
  final double latitude, longitude, elevacao; // negativo = profundidade
  bool get emAgua; double get profundidadeMetros;
  factory LeituraProfundidade.fromJson(Map<String,dynamic> json); // OpenTopoData
}
```

### PontoMapa + Meteorologia (`core/services/pontos_service.dart`)
```dart
class PontoMapa {
  final double latitude, longitude;
  final String? embarcacao, instante;
  final Meteorologia? meteorologia;
  String get label; // ex: "3.76°S, 32.35°W"
  factory PontoMapa.fromJson(Map<String,dynamic> json);
}
class Meteorologia {
  // vento: twsKts, twdDeg, twaDeg, awsKts, awaDeg, gustsKts
  // movimento: sogKts, cogDeg, stwKts, ctwDeg
  // atmosfera: airtempC, pressureHpa, cloudsPct, rainMmH
  // ondas: combWavesHeightM, windWavesHeightM, windWavesDirDeg, windWavesPeriodS, swellHeightM, swellDirDeg, swellPeriodS
  // todos double?
  factory Meteorologia.fromJson(Map<String,dynamic> json);
}
```

### ChlorophyllReading / ChlorophyllDataset (`core/models`)
```dart
enum ChlorophyllLevel { baixa, moderada, alta, muitoAlta } // + max, label, description, color

class ChlorophyllReading {
  final double latitude, longitude, concentration; // mg/m³
  final double? distanceNm;
  ChlorophyllLevel get level;
  factory ChlorophyllReading.fromMap(Map map, {double? distanceNm});
}
class ChlorophyllDataset {
  final List<ChlorophyllReading> readings;
  bool get isEmpty; ChlorophyllReading? get nearest;
  factory ChlorophyllDataset.fromRawList(List raw, {double? originLat, double? originLon});
}
```

### WaveForecast (`core/models`)
```dart
class WaveHourEntry {
  final DateTime time;
  final double waveHeight, waveDirection... /* ver tabela completa em wave_forecast.dart */
  final double? swellWaveHeight, oceanCurrentVelocity, seaSurfaceTemperature;
  String get directionLabel; double get directionRadians;
}
class WaveForecast {
  final double latitude, longitude;
  final String timezone;
  final List<WaveHourEntry> hourly;
  WaveHourEntry? get current; List<WaveHourEntry> get upcoming;
  factory WaveForecast.fromJson(Map<String,dynamic> json); // Open-Meteo Marine
}
```

### ApiEntry (`core/storage/api_storage_service.dart`)
```dart
class ApiEntry {
  final String url, method, responseBody;
  final int statusCode, elapsedMs;
  final double? latitude, longitude;
  final DateTime savedAt;
  Map<String,dynamic>? get parsedBody;
  Map<String,dynamic> toMap(); factory ApiEntry.fromMap(Map map);
}
```

### GeotiffResult (`core/services/geotiff_service.dart`)
```dart
class GeotiffResult {
  final double north, south, east, west;  // bounds geográficos
  final Uint8List imageBytes;             // PNG decodificado em memória
}
```

---

## 11. Armazenamento Local (Hive)

O Hive é inicializado em `main.dart` antes do `runApp`:

```dart
await Hive.initFlutter();
await Hive.openBox('api_responses');
```

A box `config` é aberta sob demanda pelo próprio `Config` (lazy init), na primeira chamada de `obtem`/`grava`/`limpa`.

**Boxes abertas:**

| Box | Tipo | Conteúdo | Gerenciada por |
|-----|------|----------|---------------|
| `config` | `Box<String>` | Preferências e tokens: `authToken`, `authCredencial`, `deviceId`, `organizacaoId`, `embarcacaoId`, `intervaloRastreamentoMinutos`, `modoNoturno`, `contatoEmergenciaWhatsapp`, `api` | `Config` |
| `api_responses` | `Box` (dynamic) | Respostas HTTP do Teste de API (`ApiEntry`) | `ApiStorageService` |

Os dados são armazenados sem `TypeAdapter`/geração de código, garantindo simplicidade — o body de resposta HTTP é salvo como String JSON formatada.

---

## 12. Assets

### `assets/cartas/`
- `OUTPUT_FILE.mbtiles` — mapa base offline bundled no app. Copiado do bundle para o diretório de documentos na primeira execução.
- `Carta_Navegacao_Nordeste.pdf` — carta de exemplo para a feature de Cartas.

### `assets/overlays/`
Pasta de referência para PNGs georreferenciados. O fluxo atual **não depende de um arquivo fixo aqui** — o usuário escolhe o PNG pelo seletor de arquivos na tela de Mapa (ver [9.6](#96-mapa-offline-mapa)), e os bounds são lidos do metadado `geo_bounds` embutido no arquivo (ver [`GeoPngHelper`](#710-geopnghelper)). O metadado é gravado por uma ferramenta externa ao app.

### `assets/json/`

**`vento.json`** — vento (modelo GFS, 0.25°): `latitude`, `longitude`, `u10`/`v10` (m/s), `velocidade` (nós), `direcao` (graus), `tmp2m` (K), `rh2m` (%).

**`correntes.json`** — correntes marinhas (modelo HYCOM): `latitude`, `longitude`, `velocidade` (nós), `direcao` (graus), `temperatura_agua` (°C), `salinidade` (PSU).

**`clorofila.json`** — clorofila (NOAA CoastWatch VIIRS): `latitude`, `longitude`, `chlor_a` (mg/m³).

**`posicoes/Routing3.json`** — pontos de rota de exemplo, no formato `PontoMapa` (`empresa`, `embarcacao`, `dispositivo`, `instante`, `latitude`, `longitude`, `meteorologia`).

---

## 13. Fluxos Principais

### Inicialização do App

```
main()
 ├─ WidgetsFlutterBinding.ensureInitialized() + FlutterNativeSplash.preserve()
 ├─ DatabaseHelper.instance          → abre blue_ocean.db
 ├─ Hive.initFlutter() + Hive.openBox('api_responses')
 ├─ NightModeService.carregar()
 ├─ FlutterNativeSplash.remove()
 └─ runApp(AtlasBlueOceanApp)
     └─ MaterialApp (builder aplica filtro de modo noturno global)
         └─ SplashScreen
             ├─ AuthService.isLoggedIn() == true  → AppShell
             │    └─ BottomNavigationBar: Home (Dashboard) | Cartas | Mapa
             └─ AuthService.isLoggedIn() == false → LoginScreen
```

### Fluxo de Autenticação

```
LoginScreen
 └─ AuthService.login(usuario, senha)
     └─ ApiService.login → POST /api/v1/autenticacao
         ├─ OK   → salva authToken/authCredencial/organizacaoId (Config)
         │         → Navigator.pushReplacement(AppShell)
         └─ FAIL → SnackBar com mensagem de erro (ex: UnauthorisedException)

[Em qualquer tela]
 └─ AuthService.logout() → limpa Config → Navigator.pushReplacement(LoginScreen)

[Verificação periódica]
 └─ AuthService.isLoggedIn() decodifica exp do JWT salvo; se expirado, desloga sozinho
```

### Fluxo de Rastreamento

```
DashboardScreen.initState()
 └─ se viagem em andamento:
     ├─ LocationTrackingService.iniciarRastreamento(intervaloMinutos)
     │   └─ WorkManager.registerPeriodicTask (mín. 15 min)
     │       └─ location_worker.callbackDispatcher()
     │           └─ LocalizacaoReporterService.registrarESincronizar()
     │               ├─ Geolocator.getCurrentPosition() + Battery.batteryLevel
     │               ├─ INSERT localizacao_historico (sincronizado=0)
     │               └─ sincronizarPendentes()
     │                   ├─ AuthService.isLoggedIn()? senão para o rastreamento
     │                   ├─ DispositivoRepository.buscarPorIdentificador(DeviceIdService.obtemId())
     │                   └─ LocalizacaoRepository.enviar(...) por pendência → marca sincronizado=1
     └─ (paralelo, foreground) mesma lógica disparada com frequência maior via Timer
```

### Fluxo do Mapa — sobreposição de PNG georreferenciado

```
MapaWidget — botão de camadas (ícone "layers")
 ├─ já tem PNG carregado?
 │   ├─ toque curto  → liga/desliga a camada (_overlayAtiva)
 │   └─ toque longo  → reabre o diálogo de seleção (trocar imagem)
 └─ ainda não tem PNG carregado → toque curto abre o diálogo direto
     └─ AlertDialog "Sobreposição PNG" → [Cancelar | Selecionar imagem]
         └─ FilePicker.pickFiles(type: custom, allowedExtensions: ['png'])
             └─ GeoPngHelper.readBounds(arquivo)
                 ├─ OK      → OverlayImageLayer com FileImage(arquivo) + bounds lidos
                 └─ Falha   → SnackBar explicando o erro + fallback para bounds fixos
                              (_overlaySudoesteFallback/_overlayNordesteFallback)
```

### Fluxo do Mapa — inicialização

```
MapaWidget.initState()
 ├─ _loadGpsPosition()      → getLastKnownPosition() (instantâneo) → getCurrentPosition() (até 30s)
 ├─ _loadBundledChart()     → MbtilesService.openFromAsset(...) → aplica center/zoom/min-max zoom
 ├─ _loadPontos()           → PontosService.loadFromAsset(...) → MarkerLayer (círculos + labels)
 └─ _carregarPontosMarcados() → DatabaseHelper.query('ponto_marcado')

[Toque no label de um ponto] → MeteorologiaSheet.show(context, ponto)
                                └─ DraggableScrollableSheet: Vento | Movimento | Atmosfera | Ondas
```

---

## 14. Permissões Android/iOS

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

Para o WorkManager funcionar corretamente em background, o serviço deve estar declarado no manifest. `READ_EXTERNAL_STORAGE`/o seletor de documentos do sistema também cobrem a seleção de PNG de overlay via `file_picker`.

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necessário para rastrear a posição da embarcação.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necessário para rastrear em segundo plano.</string>
```

---

## 15. Convenções e Padrões

### Nomenclatura de Arquivos

- Telas: `nome_screen.dart`
- Widgets reutilizáveis: `nome_card.dart`, `nome_widget.dart`, `nome_sheet.dart`, `nome_dialog.dart`
- Serviços: `nome_service.dart` (ou `nome_helper.dart` para utilitários sem estado, ex: `GeoPngHelper`)
- Repositórios: `nome_repository.dart`
- Modelos: `nome_modelo.dart` (snake_case)
- Barrels de widgets (re-export): `nome_widgets.dart`

### Coordenadas

O app usa **graus decimais** internamente em todos os modelos e no banco de dados. A conversão para DMS (graus/minutos/segundos) é feita apenas na camada de apresentação, via `core/utils/coordenadas_format.dart` e `LocationService.decimalToDMS()`.

### Sincronização

Dados gerados offline (`localizacao_historico`, `producao_registro`) são salvos com `sincronizado = 0`. A localização já é sincronizada de fato (`LocalizacaoReporterService.sincronizarPendentes`); produção ainda não.

### Boas práticas adotadas

- GPS usa estratégia de duas fases: **last known** (instantâneo) → **current position** (atualizado)
- Imagens GeoTIFF são processadas em **isolate** (`compute`) para não travar a UI
- Leitura de metadado de PNG (`GeoPngHelper`) usa parse leve de chunks em vez de decodificar todos os pixels
- Tiles MBTiles ausentes retornam pixel transparente em vez de erro
- Hive armazena sem `TypeAdapter`s (sem `build_runner`)
- Sessão de autenticação segue a expiração real do JWT (`exp`), sem cálculo local paralelo
- Imports de assets em subpastas (`assets/json/posicoes/`) devem estar **explícitos** no `pubspec.yaml`

---

## 16. Diagrama de Classes (UML)

Visão resumida das relações entre as principais classes do projeto. Para o diagrama completo e navegável (com todos os modelos por feature), veja a versão interativa publicada — link compartilhado à parte.

### 16.1 Camada de serviços e configuração

```mermaid
classDiagram
    class Config {
        <<static>>
        +obtem(chave, valorPadrao) Future~String~
        +grava(chave, valor) Future~void~
        +limpa(chave) Future~void~
    }
    class ApiService {
        <<static>>
        +login(usuario, senha) Future~void~
        +get(recurso) Future~dynamic~
        +post(recurso, data) Future~dynamic~
        +put(recurso, data) Future~dynamic~
        +carga(recurso, inicio) Future~List~
    }
    class AuthService {
        <<static>>
        +login(usuario, senha) Future~void~
        +isLoggedIn() Future~bool~
        +usuarioLogado() Future~Usuario~
        +logout() Future~void~
    }
    class DeviceIdService {
        <<static>>
        +obtemId() Future~String~
        +obtemInfo() Future~DeviceInfoResumo~
    }
    class DatabaseHelper {
        <<singleton>>
        +instance DatabaseHelper$
        +insert(table, data) Future~int~
        +query(table) Future~List~
        +queryWhere(table, where, whereArgs) Future~List~
        +update(table, data, id) Future~int~
        +delete(table, id) Future~int~
    }
    class LocationService {
        <<singleton>>
        +getCurrentPosition() Future~Position~
        +decimalToDMS(decimal, isLatitude) String
    }
    class LocationTrackingService {
        <<singleton>>
        +iniciarRastreamento(intervaloMinutos) Future~void~
        +pararRastreamento() Future~void~
        +getHistory(viagemId) Future~List~
    }
    class LocalizacaoReporterService {
        <<static>>
        +registrarESincronizar(posicaoConhecida) Future~void~
        +sincronizarPendentes() Future~void~
    }
    class SincronizacaoService {
        <<static>>
        +sincronizar() Future~ResultadoSincronizacao~
    }
    class MbtilesService {
        +openFromAsset(assetPath) Future~void~
        +open(filePath) Future~void~
        +getTileBytes(z, x, y) Future~Uint8List~
    }
    class GeotiffService {
        +load(filePath) Future~GeotiffResult~
    }
    class GeoPngHelper {
        <<static>>
        +readBounds(pngFile) Future~LatLngBounds~
    }
    class StreetMapCacheService {
        <<singleton>>
        +obterTile(z, x, y) Future~Uint8List~
        +baixarRegiao(...) Stream~ProgressoDownload~
    }
    class NightModeService {
        <<static>>
        +ativo ValueNotifier~bool~$
        +alternar(valor) Future~void~
    }
    class ApiStorageService {
        +save(entry) void
        +getAll() List~ApiEntry~
    }

    AuthService --> ApiService
    AuthService --> Config
    ApiService --> Config
    DeviceIdService --> Config
    NightModeService --> Config
    LocalizacaoReporterService --> DatabaseHelper
    LocalizacaoReporterService --> DeviceIdService
    LocalizacaoReporterService --> LocationTrackingService
    LocalizacaoReporterService --> AuthService
    LocationTrackingService --> DatabaseHelper
    SincronizacaoService --> DeviceIdService
    ApiStorageService --> ApiEntry
```

### 16.2 Repositórios e modelos de API

```mermaid
classDiagram
    class ApiService { <<static>> }
    class DispositivoRepository {
        +buscarPorIdentificador(identificador) Future~Dispositivo~
    }
    class LocalizacaoRepository {
        +enviar(dados) Future~void~
    }
    class RecomendacaoRepository {
        +listar() Future~List~Recomendacao~~
        +buscarPorId(id) Future~Recomendacao~
    }
    class Dispositivo {
        +String id
        +String identificador
        +String nome
        +int status
        +int tipo
        +bool atuante
    }
    class LocalizacaoEnvio {
        +String embarcacaoId
        +String dispositivoId
        +DateTime instante
        +double latitude
        +double longitude
        +double? velocidadeNos
    }
    class Recomendacao {
        +String id
        +String titulo
        +num score
        +int confianca
        +int status
        +Centroide? centroide
        +List~PontoRecomendacao~? pontos
    }
    class Centroide {
        +double latitude
        +double longitude
    }
    class PontoRecomendacao {
        +double latitude
        +double longitude
        +List~VariavelValor~ variaveis
    }
    class VariavelValor {
        +double valor
        +int variavel
    }
    class VariavelAmbiental {
        <<enumeration>>
        vento
        corrente
        clorofila
        onda
        temperatura
    }
    class Usuario {
        +String id
        +String email
        +String nome
        +String? organizacaoId
    }

    DispositivoRepository --> ApiService
    DispositivoRepository --> Dispositivo
    LocalizacaoRepository --> ApiService
    LocalizacaoRepository --> LocalizacaoEnvio
    RecomendacaoRepository --> ApiService
    RecomendacaoRepository --> Recomendacao
    Recomendacao *-- Centroide
    Recomendacao *-- "0..*" PontoRecomendacao
    PontoRecomendacao *-- "1..*" VariavelValor
    VariavelValor --> VariavelAmbiental
```

### 16.3 Modelos locais (SQLite) e domínio das features

```mermaid
classDiagram
    class Embarcacao {
        +int? id
        +String nome
        +String? dono
        +int quantidadeUrnas
        +String? registro
        +bool ativo
        +fromMap(map) Embarcacao$
        +toMap() Map
    }
    class Viagem {
        +int id
        +String? nome
        +DateTime dataInicio
        +DateTime? dataTermino
        +String embarcacaoId
        +String status
        +isFinalizada bool
    }
    class Tripulante {
        +int id
        +String nome
        +String? apelido
    }
    class ProducaoRegistro {
        +int id
        +String embarcacaoId
        +String especie
        +double quantidadeKg
        +double? latitude
        +double? longitude
        +int? viagemId
        +bool sincronizado
    }
    class PontoMarcado {
        +int? id
        +double latitude
        +double longitude
        +DateTime dataCriacao
        +String? nome
    }
    class RotaPlanejada {
        +int? id
        +String nome
        +DateTime dataCriacao
        +List~LatLng~ pontos
    }
    class CartaNautica {
        +int id
        +String codigo
        +String urlS3
        +bool estaBaixada
    }
    class GeotiffResult {
        +double north
        +double south
        +double east
        +double west
        +Uint8List imageBytes
    }
    class PontoMapa {
        +double latitude
        +double longitude
        +String? embarcacao
        +Meteorologia? meteorologia
        +label String
    }
    class Meteorologia {
        +double? twsKts
        +double? sogKts
        +double? airtempC
        +double? combWavesHeightM
    }
    class PrevisaoTempo {
        +double latitude
        +double longitude
        +PrevisaoTempoAtual? atual
        +List~PrevisaoTempoHoraria~ horaria
    }
    class WaveForecast {
        +double latitude
        +double longitude
        +List~WaveHourEntry~ hourly
    }
    class LeituraProfundidade {
        +double latitude
        +double longitude
        +double elevacao
        +emAgua bool
    }
    class ChlorophyllDataset {
        +List~ChlorophyllReading~ readings
        +nearest ChlorophyllReading?
    }
    class ChlorophyllReading {
        +double latitude
        +double longitude
        +double concentration
        +level ChlorophyllLevel
    }

    Viagem "1" --> "0..*" ProducaoRegistro : viagemId
    Embarcacao "1" --> "0..*" Viagem : embarcacaoId
    RotaPlanejada *-- "2..*" LatLng
    PontoMapa *-- Meteorologia
    PrevisaoTempo *-- "0..1" PrevisaoTempoAtual
    PrevisaoTempo *-- "0..*" PrevisaoTempoHoraria
    WaveForecast *-- "0..*" WaveHourEntry
    ChlorophyllDataset *-- "0..*" ChlorophyllReading
```

---

## 17. Próximos Passos

### Integração com Backend

- [x] ~~Substituir credenciais hardcoded por API de autenticação real~~ — feito (`AuthService`/`ApiService` já usam a Blue Ocean API)
- [x] ~~Implementar sincronização de `localizacao_historico`~~ — feito (`LocalizacaoReporterService.sincronizarPendentes`)
- [ ] Implementar sincronização de `producao_registro`
- [ ] Download de cartas náuticas a partir de S3 (hoje `CartasScreen` já lista `url_s3`, mas o download efetivo precisa ser confirmado/testado ponta a ponta)

### Melhorias de Produto

- [x] ~~Splash screen~~ — feito (`SplashScreen` + `flutter_native_splash`)
- [ ] Gerenciamento de múltiplas viagens (listar, encerrar, ver histórico completo)
- [ ] Exportar dados de produção em CSV/PDF
- [ ] Persistência local de tripulantes (`Tripulante` ainda não tem tabela/serialização)
- [ ] Modo de visualização de histórico de rota no mapa

### Sobreposição de PNG georreferenciado

- [x] ~~Ler bounds de um PNG a partir de metadado embutido~~ — feito (`GeoPngHelper.readBounds`, chunk `tEXt` `geo_bounds`)
- [x] ~~Selecionar o PNG por diálogo + seletor de arquivos~~ — feito em `MapaWidget`
- [ ] Confirmar/documentar a ferramenta externa que grava o metadado `geo_bounds` nos PNGs (script fora do app, formato deve continuar `sw_lat=X;sw_lng=Y;ne_lat=X;ne_lng=Y`)
- [ ] Considerar suporte a overlay com rotação (hoje só retângulo alinhado aos eixos, sem rotação)

### Qualidade de Código

- [ ] Testes unitários para serviços (`MbtilesService`, `GeotiffService`, `GeoPngHelper`, `PontosService`)
- [ ] Testes de integração para fluxos de viagem e rastreamento
- [ ] Migrar `desiredAccuracy`/`timeLimit` depreciados em `dashboard_screen.dart` para a nova API do `geolocator`
- [ ] Repositórios locais (`producao`, `embarcacao`, `mapa`, `viagem`, `cartas`, `rotas`) hoje acessam `DatabaseHelper` direto das telas — poderia se padronizar com um repository dedicado por entidade, como já é feito para `dispositivo`/`localizacao`/`recomendacao`

---

*Documentação atualizada em Agosto de 2026 — Atlas Blue Ocean v1.0.0*
