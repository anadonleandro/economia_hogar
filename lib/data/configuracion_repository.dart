import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class ConfiguracionRepository {
  ConfiguracionRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance,
      _database = null;

  ConfiguracionRepository.withDatabase(this._database)
    : _appDatabase = AppDatabase.instance;

  static const String _darkModeKey = 'modo_oscuro';

  final AppDatabase _appDatabase;
  final Database? _database;

  Future<Database> get _databaseInstance async {
    return _database ?? await _appDatabase.database;
  }

  Future<bool> obtenerModoOscuro() async {
    final database = await _databaseInstance;
    final rows = await database.query(
      AppDatabase.settingsTable,
      columns: ['valor'],
      where: 'clave = ?',
      whereArgs: [_darkModeKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return false;
    }

    return rows.single['valor'] == '1';
  }

  Future<void> guardarModoOscuro(bool enabled) async {
    final database = await _databaseInstance;

    await database.insert(AppDatabase.settingsTable, {
      'clave': _darkModeKey,
      'valor': enabled ? '1' : '0',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
