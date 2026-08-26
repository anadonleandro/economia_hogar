import '../data/movimiento_repository.dart';
import '../models/categoria_movimiento.dart';
import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';

class TestDataSeeder {
  const TestDataSeeder(this._repository);

  static const String descriptionPrefix = '[DATOS DE PRUEBA]';

  final MovimientoRepository _repository;

  Future<int> seed() async {
    final existingMovements = await _repository.obtenerTodos();
    final alreadySeeded = existingMovements.any(
      (movement) =>
          movement.descripcion?.startsWith(descriptionPrefix) ?? false,
    );

    if (alreadySeeded) {
      return 0;
    }

    final movements = _buildMovements();

    for (final movement in movements) {
      await _repository.insertar(movement);
    }

    return movements.length;
  }

  List<Movimiento> _buildMovements() {
    const expenseCategories = [
      CategoriaMovimiento.alimentos,
      CategoriaMovimiento.servicios,
      CategoriaMovimiento.transporte,
      CategoriaMovimiento.vivienda,
      CategoriaMovimiento.salud,
      CategoriaMovimiento.educacion,
      CategoriaMovimiento.ocio,
      CategoriaMovimiento.ropa,
    ];
    const incomeCategories = [
      CategoriaMovimiento.sueldo,
      CategoriaMovimiento.trabajoExtra,
      CategoriaMovimiento.venta,
      CategoriaMovimiento.inversion,
    ];
    final movements = <Movimiento>[];

    void addYear(int year, int lastMonth) {
      for (var month = 1; month <= lastMonth; month++) {
        movements.add(
          Movimiento(
            tipo: TipoMovimiento.ingreso,
            montoEnCentavos: 100000000 + (month * 2500000),
            categoria: incomeCategories[(month - 1) % incomeCategories.length],
            descripcion: '$descriptionPrefix Ingreso $month/$year',
            fecha: DateTime(year, month, 5),
          ),
        );
        movements.add(
          Movimiento(
            tipo: TipoMovimiento.gasto,
            montoEnCentavos: 8000000 + (month * 1250000),
            categoria:
                expenseCategories[(month - 1) % expenseCategories.length],
            descripcion: '$descriptionPrefix Gasto $month/$year',
            fecha: DateTime(year, month, 18),
          ),
        );
      }
    }

    addYear(2025, 12);
    addYear(2026, 8);

    return movements;
  }
}
