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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela Localização
    await db.execute('''
    CREATE TABLE localizacao_historico (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      data_hora TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      velocidade REAL,
      precisao REAL,
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
}
