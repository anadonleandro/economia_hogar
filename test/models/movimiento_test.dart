import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';

void main() {
  group('Movimiento', () {
    test('crea un gasto válido', () {
      final fecha = DateTime(2026, 8, 25);
      final fechaCreacion = DateTime(2026, 8, 25, 10, 30);

      final movimiento = Movimiento(
        id: 15,
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 4530000,
        categoria: CategoriaMovimiento.alimentos,
        descripcion: 'Compra supermercado',
        fecha: fecha,
        fechaCreacion: fechaCreacion,
      );

      expect(movimiento.id, 15);
      expect(movimiento.tipo, TipoMovimiento.gasto);
      expect(movimiento.montoEnCentavos, 4530000);
      expect(movimiento.categoria, CategoriaMovimiento.alimentos);
      expect(movimiento.descripcion, 'Compra supermercado');
      expect(movimiento.fecha, fecha);
      expect(movimiento.fechaCreacion, fechaCreacion);
    });

    test('asigna automáticamente la fecha de creación', () {
      final antes = DateTime.now();

      final movimiento = Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 120000000,
        categoria: CategoriaMovimiento.sueldo,
        fecha: DateTime(2026, 8, 1),
      );

      final despues = DateTime.now();

      expect(movimiento.fechaCreacion.isBefore(antes), isFalse);
      expect(movimiento.fechaCreacion.isAfter(despues), isFalse);
    });

    test('rechaza un monto igual o menor que cero', () {
      expect(
        () => Movimiento(
          tipo: TipoMovimiento.gasto,
          montoEnCentavos: 0,
          categoria: CategoriaMovimiento.alimentos,
          fecha: DateTime(2026, 8, 25),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rechaza una categoría que no corresponde al tipo', () {
      expect(
        () => Movimiento(
          tipo: TipoMovimiento.ingreso,
          montoEnCentavos: 100000,
          categoria: CategoriaMovimiento.alimentos,
          fecha: DateTime(2026, 8, 25),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
