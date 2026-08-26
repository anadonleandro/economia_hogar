import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:economia_hogar/data/app_database.dart';
import 'package:economia_hogar/data/movimiento_repository.dart';
import 'package:economia_hogar/dev/test_data_seeder.dart';

void main() {
  late Database database;
  late MovimientoRepository repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.databaseVersion,
        onCreate: AppDatabase.createSchema,
      ),
    );
    repository = MovimientoRepository.withDatabase(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('carga 40 movimientos distribuidos entre 2025 y 2026', () async {
    final insertedCount = await TestDataSeeder(repository).seed();
    final movements = await repository.obtenerTodos();

    expect(insertedCount, 40);
    expect(movements, hasLength(40));
    expect(
      movements.where((movement) => movement.fecha.year == 2025),
      hasLength(24),
    );
    expect(
      movements.where((movement) => movement.fecha.year == 2026),
      hasLength(16),
    );
  });

  test('no duplica los datos si se ejecuta más de una vez', () async {
    await TestDataSeeder(repository).seed();

    final secondInsertedCount = await TestDataSeeder(repository).seed();
    final movements = await repository.obtenerTodos();

    expect(secondInsertedCount, 0);
    expect(movements, hasLength(40));
  });
}
