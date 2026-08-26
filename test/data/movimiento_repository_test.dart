import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:economia_hogar/data/app_database.dart';
import 'package:economia_hogar/data/movimiento_repository.dart';
import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';

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

  test('inserta y recupera un movimiento con todos sus datos', () async {
    final creationDate = DateTime(2026, 8, 26, 15, 30);
    final movement = Movimiento(
      tipo: TipoMovimiento.gasto,
      montoEnCentavos: 123456,
      categoria: CategoriaMovimiento.alimentos,
      descripcion: 'Prueba SQLite',
      fecha: DateTime(2026, 8, 25),
      fechaCreacion: creationDate,
    );

    final id = await repository.insertar(movement);
    final savedMovements = await repository.obtenerTodos();

    expect(id, greaterThan(0));
    expect(savedMovements, hasLength(1));

    final savedMovement = savedMovements.single;
    expect(savedMovement.id, id);
    expect(savedMovement.tipo, movement.tipo);
    expect(savedMovement.montoEnCentavos, movement.montoEnCentavos);
    expect(savedMovement.categoria, movement.categoria);
    expect(savedMovement.descripcion, movement.descripcion);
    expect(savedMovement.fecha, movement.fecha);
    expect(savedMovement.fechaCreacion, creationDate);
  });

  test('recupera primero los movimientos de fecha más reciente', () async {
    final olderMovement = Movimiento(
      tipo: TipoMovimiento.gasto,
      montoEnCentavos: 50000,
      categoria: CategoriaMovimiento.servicios,
      fecha: DateTime(2026, 7, 10),
    );
    final newerMovement = Movimiento(
      tipo: TipoMovimiento.ingreso,
      montoEnCentavos: 200000,
      categoria: CategoriaMovimiento.sueldo,
      fecha: DateTime(2026, 8, 10),
    );

    await repository.insertar(olderMovement);
    await repository.insertar(newerMovement);

    final savedMovements = await repository.obtenerTodos();

    expect(savedMovements, hasLength(2));
    expect(savedMovements.first.tipo, TipoMovimiento.ingreso);
    expect(savedMovements.last.tipo, TipoMovimiento.gasto);
  });
}
