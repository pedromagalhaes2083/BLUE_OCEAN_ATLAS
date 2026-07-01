# Atlas Blue Ocean — Documentação Técnica

> Versão: 1.0.0+1 · Flutter ≥ 3.6.0 · Última atualização: Julho 2026

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Configuração do Ambiente](#2-configuração-do-ambiente)
3. [Arquitetura do Projeto](#3-arquitetura-do-projeto)
4. [Estrutura de Pastas](#4-estrutura-de-pastas)
5. [Dependências](#5-dependências)
6. [Banco de Dados SQLite](#6-banco-de-dados-sqlite)
7. [Serviços Principais](#7-serviços-principais)
8. [Features — Telas e Funcionalidades](#8-features--telas-e-funcionalidades)
9. [Modelos de Dados](#9-modelos-de-dados)
10. [Armazenamento Local (Hive)](#10-armazenamento-local-hive)
11. [Assets](#11-assets)
12. [Fluxos Principais](#12-fluxos-principais)
13. [Permissões Android/iOS](#13-permissões-androidios)
14. [Convenções e Padrões](#14-convenções-e-padrões)
15. [Próximos Passos](#15-próximos-passos)

---

## 1. Visão Geral

**Atlas Blue Ocean** é um aplicativo móvel multiplataforma desenvolvido em Flutter para **embarcações pesqueiras**. Ele centraliza as operações de navegação, rastreamento de posição, registro de produção (capturas) e consulta de dados meteorológicos, funcionando **predominantemente offline**.

### Funcionalidades principais

| Área | O que faz |
|------|-----------|
| **Mapa Offline** | Exibe cartas náuticas em formato MBTiles ou GeoTIFF sem internet |
| **Rastreamento GPS** | Registra a posição da embarcação a cada 5 min (foreground) e 15 min (background) |
| **Meteorologia** | Consulta dados de vento, correntes e clorofila a partir de arquivos JSON locais |
| **Produção** | Registra capturas de pesca (espécie, quantidade, posição GPS) |
| **Cartas Náuticas** | Gerencia e visualiza PDFs de cartas náuticas |
| **Teste de API** | Ferramenta interna para testar endpoints HTTP com interpolação de coordenadas GPS |

### Stack Tecnológica

- **Frontend:** Flutter (Dart)
- **Banco de dados relacional:** SQLite via `sqflite`
- **Banco de dados NoSQL:** Hive via `hive_flutter`
- **Mapas:** `flutter_map` com tiles MBTiles + overlay GeoTIFF
- **GPS:** `geolocator`
- **Background tasks:** `workmanager`
- **Armazenamento seguro:** `flutter_secure_storage`

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

### Credenciais de acesso (ambiente de desenvolvimento)

```
Usuário: mestre
Senha:   1234
```

> ⚠️ Essas credenciais são fixas no `AuthService` e devem ser substituídas por uma integração real com backend antes do deploy em produção.

---

## 3. Arquitetura do Projeto

O projeto segue uma arquitetura **Feature-First** com separação em camadas dentro de cada feature:

```
feature/
├── domain/
│   └── models/        ← Modelos de dados (entidades)
└── presentation/      ← Telas (Widgets / Screens)
```

A camada `core/` contém tudo que é compartilhado entre features:

```
core/
├── auth/              ← Autenticação
├── background/        ← Tarefa de rastreamento em background
├── database/          ← Acesso ao SQLite
├── services/          ← Lógica de negócio reutilizável
└── storage/           ← Armazenamento NoSQL (Hive)
```

### Padrões utilizados

| Padrão | Onde é usado |
|--------|-------------|
| **Singleton** | `AuthService`, `LocationTrackingService`, `LocationService`, `DatabaseHelper` |
| **Repository (simplificado)** | `DatabaseHelper` como camada de acesso a dados |
| **Abstract Base Class** | `BaseMeteorologyCard` para os cards de meteorologia |
| **Isolates (compute)** | `GeotiffService` para não bloquear a UI ao processar imagens |

---

## 4. Estrutura de Pastas

```
atlas/
├── assets/
│   ├── cartas/                        # Carta náutica PDF e arquivo MBTiles bundled
│   │   ├── Carta_Navegacao_Nordeste.pdf
│   │   └── OUTPUT_FILE.mbtiles        # Mapa base offline (sempre carregado)
│   ├── icons/                         # Ícones customizados
│   └── json/
│       ├── vento.json                 # Dados de vento (modelo GFS)
│       ├── correntes.json             # Dados de correntes (modelo HYCOM)
│       ├── clorofila.json             # Dados de clorofila (NOAA)
│       └── posicoes/
│           └── Routing3.json          # Pontos de rota com dados meteorológicos
│
├── lib/
│   ├── main.dart                      # Ponto de entrada do app
│   │
│   ├── core/
│   │   ├── auth/
│   │   │   └── auth_service.dart
│   │   ├── background/
│   │   │   └── location_worker.dart
│   │   ├── database/
│   │   │   └── database_helper.dart
│   │   ├── services/
│   │   │   ├── mbtiles_service.dart
│   │   │   ├── geotiff_service.dart
│   │   │   ├── pontos_service.dart
│   │   │   ├── location_tracking_service.dart
│   │   │   └── location_service.dart
│   │   └── storage/
│   │       └── api_storage_service.dart
│   │
│   └── features/
│       ├── auth/presentation/
│       │   └── login_screen.dart
│       ├── dashboard/presentation/
│       │   └── dashboard_screen.dart
│       ├── cartas/
│       │   ├── domain/models/carta_nautica.dart
│       │   └── presentation/
│       │       ├── cartas_screen.dart
│       │       ├── pdf_viewer_screen.dart
│       │       └── solicitar_cartas_screen.dart
│       ├── embarcacao/
│       │   ├── domain/models/embarcacao.dart
│       │   └── presentation/
│       │       ├── embarcacao_screen.dart
│       │       └── cadastrar_embarcaao_screen.dart
│       ├── viagem/
│       │   ├── domain/models/
│       │   │   ├── viagem.dart
│       │   │   └── tripulante.dart
│       │   └── presentation/
│       │       ├── nova_viagem_screen.dart
│       │       ├── historico_localizacoes_screen.dart
│       │       └── nova_tripulacao.dart
│       ├── mapa/
│       │   ├── presentation/mapa_screen.dart
│       │   └── widgets/
│       │       ├── mbtiles_tile_provider.dart
│       │       └── meteorologia_sheet.dart
│       ├── metereologia/presentation/
│       │   └── gribs_screen.dart
│       ├── producao/
│       │   ├── domain/models/producao_registro.dart
│       │   └── presentation/producao_screen.dart
│       ├── api_tester/presentation/
│       │   └── api_tester_screen.dart
│       └── widgets/
│           ├── position_card.dart
│           ├── base_meteorology_card.dart
│           ├── info_column.dart
│           └── meteorology_widgets/
│               ├── wind_card.dart
│               ├── current_card.dart
│               └── chlorophyll_card.dart
│
└── pubspec.yaml
```

---

## 5. Dependências

### Principais

| Pacote | Versão | Finalidade |
|--------|--------|-----------|
| `http` | ^1.2.2 | Requisições HTTP |
| `sqflite` | ^2.3.3 | Banco de dados SQLite local |
| `path_provider` | ^2.1.5 | Diretórios do dispositivo |
| `path` | ^1.9.0 | Manipulação de caminhos |
| `pdfrx` | ^1.0.0 | Visualizador de PDF |
| `geolocator` | ^13.0.0 | GPS e geolocalização |
| `workmanager` | 0.9.0+3 | Tarefas em background |
| `permission_handler` | ^12.0.0 | Gerenciamento de permissões |
| `flutter_map` | ^7.0.2 | Mapa interativo offline |
| `latlong2` | ^0.9.1 | Operações com coordenadas |
| `file_picker` | ^8.1.6 | Seletor de arquivos do dispositivo |
| `image` | ^4.5.0 | Processamento de GeoTIFF |
| `hive_flutter` | ^1.1.0 | Armazenamento NoSQL local |
| `intl` | ^0.19.0 | Formatação de datas/números |
| `flutter_secure_storage` | ^9.2.0 | Armazenamento seguro de credenciais |

---

## 6. Banco de Dados SQLite

**Arquivo:** `blue_ocean.db` (em `ApplicationDocumentsDirectory`)  
**Gerenciado por:** `lib/core/database/database_helper.dart` (Singleton)

O `DatabaseHelper` expõe métodos genéricos CRUD: `query`, `insert`, `update`, `delete`.

### Tabelas

#### `embarcacao`
Armazena os dados das embarcações cadastradas.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | Chave primária auto-incrementada |
| `nome` | TEXT | Nome da embarcação |
| `dono` | TEXT | Nome do proprietário |
| `quantidade_urnas` | INTEGER | Nº de compartimentos/urnas (default 1) |
| `registro` | TEXT | Código/placa (ex: PE-1234) |
| `data_cadastro` | TEXT | ISO 8601 |
| `ativo` | INTEGER | 1=ativo, 0=inativo |

---

#### `viagem`
Representa cada saída de pesca.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `nome` | TEXT | Nome opcional da viagem |
| `data_inicio` | TEXT | ISO 8601 |
| `data_termino` | TEXT | ISO 8601 (nullable) |
| `embarcacao_id` | TEXT | ID da embarcação |
| `status` | TEXT | `'em_andamento'` ou `'finalizada'` |

---

#### `localizacao_historico`
Histórico de posições rastreadas durante as viagens.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `data_hora` | TEXT | ISO 8601 |
| `latitude` | REAL | Graus decimais |
| `longitude` | REAL | Graus decimais |
| `velocidade` | REAL | m/s (pode ser nulo) |
| `precisao` | REAL | Metros (pode ser nulo) |
| `viagem_id` | INTEGER | FK para `viagem.id` |
| `sincronizado` | INTEGER | 0=pendente, 1=enviado ao servidor |

---

#### `carta_nautica`
Metadados de cartas náuticas disponíveis.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `codigo` | TEXT UNIQUE | Código identificador da carta |
| `nome` | TEXT | Nome descritivo |
| `url_s3` | TEXT | URL para download no S3 |
| `caminho_local` | TEXT | Caminho local após download (nullable) |
| `data_publicacao` | TEXT | ISO 8601 |
| `data_atualizacao` | TEXT | ISO 8601 |
| `esta_baixada` | INTEGER | 0=não baixada, 1=baixada |

---

#### `producao_registro`
Registros de captura de pesca.

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | INTEGER PK | — |
| `embarcacao_id` | TEXT | ID da embarcação |
| `data_hora` | TEXT | ISO 8601 |
| `especie` | TEXT | Nome da espécie capturada |
| `quantidade_kg` | REAL | Peso em quilogramas |
| `latitude` | REAL | Posição da captura (nullable) |
| `longitude` | REAL | Posição da captura (nullable) |
| `carta_codigo` | TEXT | Referência da carta usada (nullable) |
| `observacao` | TEXT | Obs. livre (nullable) |
| `sincronizado` | INTEGER | 0=pendente, 1=enviado ao servidor |

---

## 7. Serviços Principais

### 7.1 AuthService
**Localização:** `lib/core/auth/auth_service.dart`  
**Padrão:** Singleton

Gerencia autenticação com armazenamento seguro via `flutter_secure_storage`.

```dart
AuthService.instance.login(usuario, senha)   // → bool
AuthService.instance.isLoggedIn()            // → bool
AuthService.instance.logout()                // limpa tudo
AuthService.instance.getMestreNome()         // → String?
AuthService.instance.getEmbarcacaoId()       // → String?
```

**Chaves salvas no secure storage:**
- `user_logged` → `"true"`
- `mestre_nome` → `"Mestre João"` (fixo por enquanto)
- `embarcacao_id` → `"PE-1234"` (fixo por enquanto)

---

### 7.2 LocationTrackingService
**Localização:** `lib/core/services/location_tracking_service.dart`  
**Padrão:** Singleton

Rastreamento de posição em dois modos simultâneos:

| Modo | Frequência | Tecnologia |
|------|-----------|-----------|
| **Foreground** | A cada 5 minutos | `Timer.periodic` |
| **Background** | A cada 15 minutos | `WorkManager` |

```dart
final svc = LocationTrackingService();

await svc.startBackgroundTracking(viagemId: id);   // inicia WorkManager
await svc.startForegroundTracking(viagemId: id);   // inicia Timer
await svc.stopAllTracking();                        // para tudo

List<Map> historico = await svc.getHistory(viagemId: id);
bool ativo = svc.isTracking;
```

Cada posição é salva em `localizacao_historico` com `sincronizado = 0`.

O callback de background fica em `lib/core/background/location_worker.dart` e deve ser registrado como `@pragma('vm:entry-point')`.

---

### 7.3 MbtilesService
**Localização:** `lib/core/services/mbtiles_service.dart`

Lê arquivos MBTiles (SQLite) para servir tiles de mapa ao `flutter_map`.

```dart
// Carrega arquivo bundled nos assets (copia para disco na primeira vez)
await _mbtiles.openFromAsset('assets/cartas/OUTPUT_FILE.mbtiles');

// Ou abre um arquivo externo
await _mbtiles.open('/caminho/para/arquivo.mbtiles');

// Obtém tile para coordenadas z/x/y
Uint8List? bytes = await _mbtiles.getTileBytes(z, x, y);

// Lê metadados (name, bounds, center, minzoom, maxzoom, scheme)
Map<String, String> meta = await _mbtiles.getMetadata();
```

**Detalhe importante:** MBTiles pode usar convenção TMS (eixo Y invertido) ou XYZ. O serviço auto-detecta na primeira requisição de tile e cacheia o resultado em `_isTms`.

---

### 7.4 GeotiffService
**Localização:** `lib/core/services/geotiff_service.dart`

Processa arquivos GeoTIFF georeferenciados, extraindo bounds e decodificando a imagem.

```dart
GeotiffResult result = await _geotiffService.load('/caminho/arquivo.tif');

result.north   // limite norte
result.south   // limite sul
result.east    // limite leste
result.west    // limite oeste
result.imageBytes  // PNG em memória (Uint8List)
```

O decode da imagem roda em isolate (`compute()`) para não travar a UI. Imagens maiores que 4096px são redimensionadas automaticamente.

**Tags GeoTIFF suportadas:** 33550 (ModelPixelScale), 33922 (ModelTiepoint), 34264 (ModelTransformation).

---

### 7.5 PontosService
**Localização:** `lib/core/services/pontos_service.dart`

Carrega pontos de rota a partir de arquivos JSON nos assets.

```dart
List<PontoMapa> pontos = await _pontosService.loadFromAsset(
  'assets/json/posicoes/Routing3.json'
);
```

Suporta JSON como objeto único ou lista de objetos. Cada ponto pode ter dados meteorológicos completos no campo `meteorologia`.

---

### 7.6 LocationService
**Localização:** `lib/core/services/location_service.dart`  
**Padrão:** Singleton

Utilitários de geolocalização.

```dart
Position? pos = await LocationService().getCurrentPosition();

// Converte decimal para DMS: "23° 33' 1.8" S"
String dms = LocationService().decimalToDMS(-23.5505, true);
```

---

### 7.7 ApiStorageService
**Localização:** `lib/core/storage/api_storage_service.dart`  
**Storage:** Hive — box `api_responses`

Persiste respostas HTTP da tela de Teste de API.

```dart
final storage = ApiStorageService();

storage.save(ApiEntry(...));       // salva
List<ApiEntry> all = storage.getAll(); // mais recente primeiro
storage.clear();                   // apaga tudo
int n = storage.count;
```

---

## 8. Features — Telas e Funcionalidades

### 8.1 Login (`auth/`)

**Tela:** `LoginScreen`

- Formulário simples com usuário e senha
- Chama `AuthService.login()` → navega para `DashboardScreen` em caso de sucesso
- Credenciais fixas para desenvolvimento: `mestre` / `1234`

---

### 8.2 Dashboard (`dashboard/`)

**Tela:** `DashboardScreen`

Tela inicial do app (aba 0 do BottomNavigationBar).

**O que exibe:**
- Nome da embarcação atual
- `PositionCard` com coordenadas GPS ao vivo
- Card da viagem em andamento (dias em mar)
- Estatísticas: total de cartas baixadas, total de registros de produção
- Banner de rastreamento ativo (quando em viagem)
- Botões de ações rápidas:
  - Mapa de Navegação
  - Mapa Offline (MBTiles)
  - Solicitar Carta
  - Teste de API

**Lógica de rastreamento:**  
Se houver uma viagem ativa ao abrir o dashboard, o `LocationTrackingService` é iniciado automaticamente (foreground + background).

---

### 8.3 Cartas Náuticas (`cartas/`)

**Telas:** `CartasScreen` → `PdfViewerScreen`

- Lista cartas do banco SQLite com busca em tempo real
- Abre PDFs com zoom/pan usando o pacote `pdfrx`
- Suporte a cartas do asset bundled e cartas baixadas

---

### 8.4 Embarcação (`embarcacao/`)

**Telas:** `EmbarcacaoScreen`, `CadastrarEmbarcacaoScreen`

- Lista embarcações cadastradas no banco
- Formulário de cadastro: nome, dono, nº de urnas, placa/registro
- A placa é sempre convertida para maiúsculas

---

### 8.5 Viagem (`viagem/`)

**Telas:** `NovaViagemScreen`, `HistoricoLocalizacoesScreen`

- Inicia nova viagem com nome opcional e datas
- Histórico de localizações exibe timeline de posições registradas, com coordenadas em formato DMS

---

### 8.6 Mapa Offline (`mapa/`)

**Tela:** `MapaScreen`

A tela mais complexa do app. Suporta três modos:

| Modo | Como ativar |
|------|------------|
| **MBTiles bundled** | Carregado automaticamente ao abrir (`OUTPUT_FILE.mbtiles`) |
| **MBTiles externo** | Botão da pasta na AppBar → file picker |
| **GeoTIFF** | Botão da pasta na AppBar → selecionar `.tif/.tiff` |

**Camadas do mapa (ordem de renderização):**
1. `TileLayer` com `MbtilesTileProvider` (se modo MBTiles)
2. `OverlayImageLayer` com a imagem GeoTIFF (se modo GeoTIFF)
3. `MarkerLayer` — pontos do JSON (círculo laranja preciso na coordenada)
4. `MarkerLayer` — labels dos pontos (flutuam à direita do círculo)
5. `MarkerLayer` — posição GPS atual (ícone de barco azul)

**Toque no label de um ponto → abre `MeteorologiaSheet`**  
(bottom sheet draggável com dados de vento, movimento, atmosfera e ondas)

**GPS:** Usa estratégia de duas fases:
1. `getLastKnownPosition()` → exibe imediatamente (cache do sistema)
2. `getCurrentPosition()` → atualiza com fix fresco em segundo plano

**MbtilesTileProvider:**  
Widget em `mapa/widgets/mbtiles_tile_provider.dart`. Implementa `TileProvider` do `flutter_map`. Retorna tile transparente 1x1 quando o tile não existe no banco.

---

### 8.7 Meteorologia (`metereologia/`)

**Tela:** `GribProcessorScreen`

Exibe dados meteorológicos carregados de três JSONs dos assets:
- `vento.json` → `WindCard`
- `correntes.json` → `CurrentCard`
- `clorofila.json` → `ChlorophyllCard`

Os dados são **filtrados por proximidade** da posição atual usando a fórmula de Haversine (raio ≈ 80 milhas náuticas) e **ordenados do mais próximo para o mais distante**.

---

### 8.8 Produção (`producao/`)

**Tela:** `ProducaoScreen`

Registro de capturas de pesca:
- Espécie (obrigatório)
- Quantidade em kg (obrigatório, decimal)
- Observação (opcional)
- Posição GPS capturada automaticamente
- Data/hora registrada automaticamente
- Salvo com `sincronizado = 0` (pendente de envio ao servidor)

---

### 8.9 Teste de API (`api_tester/`)

**Tela:** `ApiTesterScreen`

Ferramenta interna para desenvolvedores testarem endpoints HTTP.

**Aba "Testar":**
- Card de GPS com coordenadas atuais
- Seletor de método: GET / POST / PUT / PATCH / DELETE
- Campo de URL com suporte a placeholders: `{latitude}` e `{longitude}`
- Campo de body JSON (POST/PUT/PATCH) também com placeholders
- Botão Enviar → substitui placeholders → dispara requisição → exibe resposta formatada → **salva no Hive**

**Aba "Histórico":**
- Lista expansível de todas as respostas salvas
- Exibe: status code, método, URL, tempo de resposta, timestamp, coordenadas
- Corpo da resposta formatado (monospace dark)
- Botão "Limpar tudo"

**Exemplo de uso dos placeholders:**
```
URL: https://api.exemplo.com/dados?lat={latitude}&lon={longitude}
Body: { "latitude": {latitude}, "longitude": {longitude} }
```

---

### 8.10 Widgets Compartilhados (`features/widgets/`)

| Widget | Descrição |
|--------|-----------|
| `PositionCard` | Card com coordenadas GPS, estado de loading e erros |
| `BaseMeteorologyCard` | Classe abstrata base para cards de meteorologia |
| `InfoColumn` | Coluna com ícone + label + valor (usado em cards de met.) |
| `WindCard` | Velocidade, direção, temperatura do vento |
| `CurrentCard` | Velocidade, direção, temperatura e salinidade de correntes |
| `ChlorophyllCard` | Concentração de clorofila em mg/m³ |
| `MeteorologiaSheet` | Bottom sheet draggável com dados completos do `PontoMapa` |

---

## 9. Modelos de Dados

### Embarcacao
```dart
class Embarcacao {
  final int? id;
  final String nome;
  final String? dono;
  final int quantidadeUrnas;  // default: 1
  final String? registro;     // ex: "PE-1234"
  final DateTime dataCadastro;
  final bool ativo;
}
```

### Viagem
```dart
class Viagem {
  final int id;
  final String? nome;
  final DateTime dataInicio;
  final DateTime? dataTermino;
  final String embarcacaoId;
  final String status;  // 'em_andamento' | 'finalizada'
  
  bool get isFinalizada => status == 'finalizada';
}
```

### CartaNautica
```dart
class CartaNautica {
  final int id;
  final String codigo;
  final String nome;
  final String urlS3;
  final String? caminhoLocal;
  final DateTime dataPublicacao;
  final DateTime dataAtualizacao;
  final bool estaBaixada;
}
```

### ProducaoRegistro
```dart
class ProducaoRegistro {
  final int id;
  final String embarcacaoId;
  final DateTime dataHora;
  final String especie;
  final double quantidadeKg;
  final double? latitude;
  final double? longitude;
  final String? cartaCodigo;
  final String? observacao;
  final bool sincronizado;
}
```

### PontoMapa + Meteorologia
```dart
class PontoMapa {
  final double latitude;
  final double longitude;
  final String? embarcacao;    // nome da embarcação
  final String? instante;      // ISO 8601
  final Meteorologia? meteorologia;
  
  String get label  // ex: "3.76°S, 32.35°W"
}

class Meteorologia {
  // Vento
  final double? twsKts;    // True Wind Speed (nós)
  final double? twdDeg;    // True Wind Direction (graus)
  final double? twaDeg;    // True Wind Angle
  final double? awsKts;    // Apparent Wind Speed
  final double? awaDeg;    // Apparent Wind Angle
  final double? gustsKts;  // Rajadas

  // Movimento da embarcação
  final double? sogKts;    // Speed Over Ground
  final double? cogDeg;    // Course Over Ground
  final double? stwKts;    // Speed Through Water
  final double? ctwDeg;    // Course Through Water

  // Atmosfera
  final double? airtempC;    // Temperatura (°C)
  final double? pressureHpa; // Pressão (hPa)
  final double? cloudsPct;   // Cobertura de nuvens (%)
  final double? rainMmH;     // Chuva (mm/h)

  // Ondas
  final double? combWavesHeightM;  // Altura de ondas combinadas (m)
  final double? windWavesHeightM;  // Altura de ondas de vento (m)
  final double? windWavesDirDeg;   // Direção de ondas de vento
  final double? windWavesPeriodS;  // Período (s)
  final double? swellHeightM;      // Altura do swell (m)
  final double? swellDirDeg;       // Direção do swell
  final double? swellPeriodS;      // Período do swell (s)
}
```

### ApiEntry (Hive)
```dart
class ApiEntry {
  final String url;
  final String method;        // 'GET', 'POST', etc.
  final int statusCode;
  final int elapsedMs;
  final String responseBody;  // JSON formatado
  final double? latitude;     // posição no momento da chamada
  final double? longitude;
  final DateTime savedAt;
  
  Map<String, dynamic>? get parsedBody  // tenta deserializar o body
}
```

### GeotiffResult
```dart
class GeotiffResult {
  final double north, south, east, west;  // bounds geográficos
  final Uint8List imageBytes;             // PNG decodificado em memória
}
```

---

## 10. Armazenamento Local (Hive)

O Hive é inicializado em `main.dart` antes do `runApp`:

```dart
await Hive.initFlutter();
await Hive.openBox('api_responses');
```

**Boxes abertas:**

| Box | Conteúdo | Gerenciado por |
|-----|----------|---------------|
| `api_responses` | Respostas HTTP do API Tester | `ApiStorageService` |

Os dados são armazenados como `Map` (sem TypeAdapters, sem geração de código), garantindo simplicidade. O body da resposta é salvo como String JSON formatada.

---

## 11. Assets

### `assets/cartas/`
- `OUTPUT_FILE.mbtiles` — mapa base offline bundled no app. Carregado automaticamente ao abrir a tela de Mapa. Na primeira execução, é copiado do bundle para o diretório de documentos do dispositivo.
- `Carta_Navegacao_Nordeste.pdf` — carta de exemplo para a feature de Cartas.

### `assets/json/`

**`vento.json`** — Dados de vento (modelo GFS, 0.25° de resolução)
```json
{
  "model": "GFS",
  "dados": [
    {
      "latitude": -9.50, "longitude": -44.75,
      "u10": 2.4,         // componente leste-oeste (m/s)
      "v10": -2.1,        // componente norte-sul (m/s)
      "velocidade": 3.2,  // nós
      "direcao": 231,     // graus
      "tmp2m": 298.1,     // temperatura 2m (Kelvin)
      "rh2m": 79          // umidade relativa (%)
    }
  ]
}
```

**`correntes.json`** — Dados de correntes marinhas (modelo HYCOM)
```json
{
  "modelo": "HYCOM",
  "dados": [
    {
      "latitude": -2.55, "longitude": -39.55,
      "velocidade": 1.01,        // nós
      "direcao": 100,            // graus
      "temperatura_agua": 28.4,  // °C
      "salinidade": 35.1         // PSU
    }
  ]
}
```

**`clorofila.json`** — Concentração de clorofila (NOAA CoastWatch VIIRS)
```json
{
  "fonte": "NOAA CoastWatch VIIRS NPP",
  "dados": [
    {
      "latitude": -3.25, "longitude": -39.45,
      "chlor_a": 1.85  // mg/m³
    }
  ]
}
```

**`posicoes/Routing3.json`** — Pontos de rota com dados meteorológicos completos. Segue o formato do modelo `PontoMapa` (com campos `empresa`, `embarcacao`, `dispositivo`, `instante`, `latitude`, `longitude`, `meteorologia`).

---

## 12. Fluxos Principais

### Inicialização do App

```
main()
 ├─ WidgetsFlutterBinding.ensureInitialized()
 ├─ DatabaseHelper.instance          → abre blue_ocean.db
 ├─ Hive.initFlutter()
 ├─ Hive.openBox('api_responses')
 └─ runApp(AtlasBlueOceanApp)
     └─ MaterialApp
         ├─ BottomNavigationBar (3 abas)
         └─ [Tab 0] DashboardScreen
             [Tab 1] CartasScreen
             [Tab 2] ProducaoScreen
```

### Fluxo de Autenticação

```
LoginScreen
 └─ AuthService.login('mestre', '1234')
     ├─ OK  → FlutterSecureStorage.write(user_logged: true)
     │        → Navigator.pushReplacement(DashboardScreen)
     └─ FAIL → SnackBar com mensagem de erro

[Em qualquer tela]
 └─ AuthService.logout()
     └─ FlutterSecureStorage.deleteAll()
         └─ Navigator.pushReplacement(LoginScreen)
```

### Fluxo de Rastreamento

```
DashboardScreen.initState()
 └─ _carregarDados()
     └─ se viagem em andamento:
         └─ _iniciarRastreamentoAutomatico()
             ├─ LocationTrackingService.startBackgroundTracking(viagemId)
             │   └─ WorkManager.registerPeriodicTask(freq: 15min)
             │       └─ location_worker.dart → salva posição no SQLite
             │
             └─ LocationTrackingService.startForegroundTracking(viagemId)
                 └─ Timer.periodic(5min)
                     └─ Geolocator.getCurrentPosition()
                         └─ INSERT localizacao_historico (sincronizado=0)
```

### Fluxo do Mapa

```
MapaScreen.initState()
 ├─ _loadGpsPosition()
 │   ├─ getLastKnownPosition() → exibe imediatamente
 │   └─ getCurrentPosition()   → atualiza (até 30s)
 │
 ├─ _loadBundledChart()
 │   ├─ MbtilesService.openFromAsset('assets/cartas/OUTPUT_FILE.mbtiles')
 │   │   └─ Copia para DocumentsDirectory (se primeira vez)
 │   └─ _applyMetadata() → define center/zoom/min-max zoom
 │
 └─ _loadPontos()
     └─ PontosService.loadFromAsset('assets/json/posicoes/Routing3.json')
         └─ renderiza MarkerLayer com círculos + labels clicáveis

[Toque no label] → MeteorologiaSheet.show(context, ponto)
                    └─ DraggableScrollableSheet com 4 seções:
                        Vento | Movimento | Atmosfera | Ondas
```

---

## 13. Permissões Android/iOS

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

Para o WorkManager funcionar corretamente em background, o serviço deve estar declarado no manifest.

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necessário para rastrear a posição da embarcação.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Necessário para rastrear em segundo plano.</string>
```

---

## 14. Convenções e Padrões

### Nomenclatura de Arquivos

- Telas: `nome_screen.dart`
- Widgets reutilizáveis: `nome_card.dart`, `nome_widget.dart`, `nome_sheet.dart`
- Serviços: `nome_service.dart`
- Modelos: `nome_modelo.dart` (snake_case)

### Coordenadas

O app usa **graus decimais** internamente em todos os modelos e banco de dados. A conversão para DMS (graus/minutos/segundos) é feita apenas na camada de apresentação via `LocationService.decimalToDMS()`.

### Sincronização

Todos os dados gerados offline (localizações, produção) são salvos com `sincronizado = 0`. A coluna existe para futura implementação de sync com backend quando houver conectividade.

### Boas práticas adotadas

- GPS usa estratégia de duas fases: **last known** (instantâneo) → **current position** (atualizado)
- Imagens GeoTIFF são processadas em **isolate** para não travar a UI
- Tiles MBTiles ausentes retornam pixel transparente em vez de erro
- Hive armazena sem TypeAdapters (sem `build_runner`)
- Imports de assets `assets/json/posicoes/` devem estar **explícitos** no `pubspec.yaml` (Flutter não inclui subdiretórios automaticamente)

---

## 15. Próximos Passos

### Integração com Backend

- [ ] Substituir credenciais hardcoded por API de autenticação real
- [ ] Implementar sincronização de `localizacao_historico` (campo `sincronizado`)
- [ ] Implementar sincronização de `producao_registro`
- [ ] Download de cartas náuticas a partir de S3

### Melhorias de Produto

- [ ] Splash screen
- [ ] Gerenciamento de múltiplas viagens (listar, encerrar, ver histórico)
- [ ] Exportar dados de produção em CSV/PDF
- [ ] Integração com APIs de previsão meteorológica em tempo real (NOAA, ECMWF)
- [ ] Modo de visualização de histórico de rota no mapa

### Qualidade de Código

- [ ] Testes unitários para serviços (`MbtilesService`, `GeotiffService`, `PontosService`)
- [ ] Testes de integração para fluxos de viagem e rastreamento
- [ ] Substituir `print()` por logger estruturado
- [ ] Tratar erro de typo no arquivo `cadastrar_embarcaao_screen.dart` (falta o `ç`)
- [ ] Migrar `desiredAccuracy`/`timeLimit` depreciados em `dashboard_screen.dart` para nova API do `geolocator`

---

*Documentação gerada em Julho de 2026 — Atlas Blue Ocean v1.0.0*
