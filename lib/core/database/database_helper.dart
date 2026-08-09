import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'blue_ocean.db');

    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela Embarcação
    await db.execute('''
  CREATE TABLE embarcacao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    dono TEXT,
    quantidade_urnas INTEGER NOT NULL DEFAULT 1,
    registro TEXT,
    data_cadastro TEXT NOT NULL,
    ativo INTEGER NOT NULL DEFAULT 1,
    capacidade_gelo_kg REAL,
    capacidade_diesel_litros REAL,
    numero_tripulantes INTEGER,
    mestre_id TEXT,
    motor_usado TEXT,
    foto TEXT
  )
''');

    // Tabela Localização
    await db.execute('''
    CREATE TABLE localizacao_historico (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_hora TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      velocidade REAL,
      precisao REAL,
      altitude REAL,
      direcao INTEGER,
      bateria_nivel INTEGER,
      viagem_id INTEGER,
      sincronizado INTEGER NOT NULL DEFAULT 0
    )
  ''');

    // Tabela de Viagens
    await db.execute('''
    CREATE TABLE viagem (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT,
      data_inicio TEXT NOT NULL,
      data_termino TEXT,
      embarcacao_id TEXT,
      status TEXT NOT NULL
    )
  ''');

    // Tabela de Cartas Náuticas
    await db.execute('''
      CREATE TABLE carta_nautica (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT UNIQUE NOT NULL,
        nome TEXT NOT NULL,
        url_s3 TEXT NOT NULL,
        caminho_local TEXT,
        data_publicacao TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL,
        esta_baixada INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de Registro de Produção
    await db.execute('''
      CREATE TABLE producao_registro (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        embarcacao_id TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        especie TEXT NOT NULL,
        quantidade_kg REAL NOT NULL,
        latitude REAL,
        longitude REAL,
        carta_codigo TEXT,
        observacao TEXT,
        sincronizado INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _criarTabelaPontoMarcado(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _criarTabelaPontoMarcado(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE localizacao_historico ADD COLUMN altitude REAL');
      await db.execute('ALTER TABLE localizacao_historico ADD COLUMN direcao INTEGER');
      await db.execute(
          'ALTER TABLE localizacao_historico ADD COLUMN bateria_nivel INTEGER');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE embarcacao ADD COLUMN capacidade_gelo_kg REAL');
      await db.execute('ALTER TABLE embarcacao ADD COLUMN capacidade_diesel_litros REAL');
      await db.execute('ALTER TABLE embarcacao ADD COLUMN numero_tripulantes INTEGER');
      await db.execute('ALTER TABLE embarcacao ADD COLUMN mestre_id TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE embarcacao ADD COLUMN motor_usado TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE embarcacao ADD COLUMN foto TEXT');
    }
  }

  Future<void> _criarTabelaPontoMarcado(Database db) async {
    // Tabela de Pontos Marcados manualmente no mapa
    await db.execute('''
      CREATE TABLE ponto_marcado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        data_criacao TEXT NOT NULL
      )
    ''');
  }

  // Métodos genéricos
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> delete(String table, {required int id}) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    required String where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(String table, Map<String, dynamic> data,
      {required int id}) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }
}
