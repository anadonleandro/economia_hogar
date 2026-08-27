import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String databaseName = 'economia_hogar.db';
  static const int databaseVersion = 2;
  static const String movementsTable = 'movimientos';
  static const String settingsTable = 'configuraciones';

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = p.join(databasesPath, databaseName);

    return openDatabase(
      databasePath,
      version: databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: createSchema,
      onUpgrade: upgradeSchema,
    );
  }

  static Future<void> createSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $movementsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL CHECK (tipo IN ('ingreso', 'gasto')),
        monto_centavos INTEGER NOT NULL CHECK (monto_centavos > 0),
        categoria TEXT NOT NULL,
        descripcion TEXT,
        fecha TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL
      )
    ''');
    await _createSettingsTable(database);
  }

  static Future<void> upgradeSchema(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createSettingsTable(database);
    }
  }

  static Future<void> _createSettingsTable(Database database) async {
    await database.execute('''
      CREATE TABLE $settingsTable (
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final database = _database;

    if (database == null) {
      return;
    }

    await database.close();
    _database = null;
  }
}
