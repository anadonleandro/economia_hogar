import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';
import 'package:economia_hogar/services/resumen_mensual_calculator.dart';

void main() {
  const calculator = ResumenMensualCalculator();

  test('calcula totales del mes solicitado', () {
    final movimientos = [
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 120000000,
        categoria: CategoriaMovimiento.sueldo,
        fecha: DateTime(2026, 8, 1),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 77465000,
        categoria: CategoriaMovimiento.alimentos,
        fecha: DateTime(2026, 8, 25),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 100000,
        categoria: CategoriaMovimiento.servicios,
        fecha: DateTime(2026, 9, 1),
      ),
    ];

    final resumen = calculator.calcular(
      movimientos: movimientos,
      anio: 2026,
      mes: 8,
    );

    expect(resumen.ingresosEnCentavos, 120000000);
    expect(resumen.gastosEnCentavos, 77465000);
    expect(resumen.saldoEnCentavos, 42535000);
    expect(resumen.cantidadMovimientos, 2);
    expect(resumen.cantidadIngresos, 1);
    expect(resumen.cantidadGastos, 1);
  });

  test('devuelve totales en cero para un mes sin movimientos', () {
    final resumen = calculator.calcular(
      movimientos: const [],
      anio: 2026,
      mes: 8,
    );

    expect(resumen.ingresosEnCentavos, 0);
    expect(resumen.gastosEnCentavos, 0);
    expect(resumen.saldoEnCentavos, 0);
    expect(resumen.cantidadMovimientos, 0);
    expect(resumen.cantidadIngresos, 0);
    expect(resumen.cantidadGastos, 0);
  });

  test('rechaza un mes fuera del rango válido', () {
    expect(
      () => calculator.calcular(movimientos: const [], anio: 2026, mes: 13),
      throwsRangeError,
    );
  });
}
