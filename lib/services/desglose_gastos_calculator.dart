import '../models/categoria_movimiento.dart';
import '../models/movimiento.dart';
import '../models/resumen_categoria.dart';
import '../models/tipo_movimiento.dart';

class DesgloseGastosCalculator {
  const DesgloseGastosCalculator();

  List<ResumenCategoria> calcular({
    required Iterable<Movimiento> movimientos,
    required int anio,
    required int mes,
  }) {
    if (mes < 1 || mes > 12) {
      throw RangeError.range(mes, 1, 12, 'mes');
    }

    final totals = <CategoriaMovimiento, int>{};
    final counts = <CategoriaMovimiento, int>{};

    for (final movimiento in movimientos) {
      final belongsToPeriod =
          movimiento.fecha.year == anio && movimiento.fecha.month == mes;

      if (!belongsToPeriod || movimiento.tipo != TipoMovimiento.gasto) {
        continue;
      }

      totals.update(
        movimiento.categoria,
        (total) => total + movimiento.montoEnCentavos,
        ifAbsent: () => movimiento.montoEnCentavos,
      );
      counts.update(
        movimiento.categoria,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final totalExpenses = totals.values.fold<int>(
      0,
      (sum, total) => sum + total,
    );

    if (totalExpenses == 0) {
      return const [];
    }

    final breakdown = totals.entries.map((entry) {
      return ResumenCategoria(
        categoria: entry.key,
        totalEnCentavos: entry.value,
        cantidadMovimientos: counts[entry.key]!,
        porcentaje: entry.value * 100 / totalExpenses,
      );
    }).toList();

    breakdown.sort(
      (first, second) =>
          second.totalEnCentavos.compareTo(first.totalEnCentavos),
    );

    return List.unmodifiable(breakdown);
  }
}
