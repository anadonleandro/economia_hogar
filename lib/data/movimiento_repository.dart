import 'package:sqflite/sqflite.dart';

import '../models/categoria_movimiento.dart';
import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import 'app_database.dart';

class MovimientoRepository {
  MovimientoRepository({AppDatabase? appDatabase})
    : _database = (appDatabase ?? AppDatabase.instance).database;

  MovimientoRepository.withDatabase(Database database)
    : _database = Future.value(database);

  final Future<Database> _database;

  Future<int> insertar(Movimiento movimiento) async {
    final database = await _database;

    return database.insert(AppDatabase.movementsTable, _toMap(movimiento));
  }

  Future<List<Movimiento>> obtenerTodos() async {
    final database = await _database;
    final rows = await database.query(
      AppDatabase.movementsTable,
      orderBy: 'fecha DESC, id DESC',
    );

    return rows.map(_fromMap).toList(growable: false);
  }

  Map<String, Object?> _toMap(Movimiento movimiento) {
    return {
      'tipo': movimiento.tipo.name,
      'monto_centavos': movimiento.montoEnCentavos,
      'categoria': movimiento.categoria.name,
      'descripcion': movimiento.descripcion,
      'fecha': movimiento.fecha.toIso8601String(),
      'fecha_creacion': movimiento.fechaCreacion.toIso8601String(),
    };
  }

  Movimiento _fromMap(Map<String, Object?> row) {
    return Movimiento(
      id: row['id'] as int,
      tipo: TipoMovimiento.values.byName(row['tipo'] as String),
      montoEnCentavos: row['monto_centavos'] as int,
      categoria: CategoriaMovimiento.values.byName(row['categoria'] as String),
      descripcion: row['descripcion'] as String?,
      fecha: DateTime.parse(row['fecha'] as String),
      fechaCreacion: DateTime.parse(row['fecha_creacion'] as String),
    );
  }
}
