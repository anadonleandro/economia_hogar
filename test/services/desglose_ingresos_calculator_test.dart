import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';
import 'package:economia_hogar/services/desglose_ingresos_calculator.dart';

void main() {
  const calculator = DesgloseIngresosCalculator();

  test('agrupa ingresos por categoría y calcula sus porcentajes', () {
    final movements = [
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 60000,
        categoria: CategoriaMovimiento.sueldo,
        fecha: DateTime(2026, 8, 5),
      ),
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 20000,
        categoria: CategoriaMovimiento.sueldo,
        fecha: DateTime(2026, 8, 12),
      ),
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 20000,
        categoria: CategoriaMovimiento.venta,
        fecha: DateTime(2026, 8, 18),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 50000,
        categoria: CategoriaMovimiento.alimentos,
        fecha: DateTime(2026, 8, 1),
      ),
    ];

    final breakdown = calculator.calcular(
      movimientos: movements,
      anio: 2026,
      mes: 8,
    );

    expect(breakdown, hasLength(2));
    expect(breakdown.first.categoria, CategoriaMovimiento.sueldo);
    expect(breakdown.first.totalEnCentavos, 80000);
    expect(breakdown.first.cantidadMovimientos, 2);
    expect(breakdown.first.porcentaje, closeTo(80, 0.001));
    expect(breakdown.last.categoria, CategoriaMovimiento.venta);
    expect(breakdown.last.totalEnCentavos, 20000);
    expect(breakdown.last.cantidadMovimientos, 1);
    expect(breakdown.last.porcentaje, closeTo(20, 0.001));
  });

  test('devuelve una lista vacía cuando el período no tiene ingresos', () {
    final breakdown = calculator.calcular(
      movimientos: const [],
      anio: 2026,
      mes: 8,
    );

    expect(breakdown, isEmpty);
  });

  test('rechaza un mes fuera del rango válido', () {
    expect(
      () => calculator.calcular(movimientos: const [], anio: 2026, mes: 0),
      throwsRangeError,
    );
  });
}
