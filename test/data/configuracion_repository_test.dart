import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:economia_hogar/data/app_database.dart';
import 'package:economia_hogar/data/configuracion_repository.dart';

void main() {
  late Database database;
  late ConfiguracionRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.databaseVersion,
        onCreate: AppDatabase.createSchema,
      ),
    );
    repository = ConfiguracionRepository.withDatabase(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('usa modo claro cuando todavía no existe una configuración', () async {
    expect(await repository.obtenerModoOscuro(), isFalse);
  });

  test('guarda y recupera la preferencia de modo oscuro', () async {
    await repository.guardarModoOscuro(true);
    expect(await repository.obtenerModoOscuro(), isTrue);

    await repository.guardarModoOscuro(false);
    expect(await repository.obtenerModoOscuro(), isFalse);
  });
}
