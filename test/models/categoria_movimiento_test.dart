import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';

void main() {
  group('CategoriaMovimiento', () {
    test('define nueve categorías de gasto', () {
      final categorias = CategoriaMovimiento.values
          .where((categoria) => categoria.tipo == TipoMovimiento.gasto)
          .toList();

      expect(categorias, hasLength(9));
      expect(categorias, contains(CategoriaMovimiento.alimentos));
      expect(categorias, contains(CategoriaMovimiento.otrosGastos));
    });

    test('define cinco categorías de ingreso', () {
      final categorias = CategoriaMovimiento.values
          .where((categoria) => categoria.tipo == TipoMovimiento.ingreso)
          .toList();

      expect(categorias, hasLength(5));
      expect(categorias, contains(CategoriaMovimiento.sueldo));
      expect(categorias, contains(CategoriaMovimiento.otrosIngresos));
    });

    test('distingue las categorías Otros por tipo', () {
      expect(CategoriaMovimiento.otrosGastos.nombre, 'Otros');
      expect(CategoriaMovimiento.otrosIngresos.nombre, 'Otros');
      expect(CategoriaMovimiento.otrosGastos.tipo, TipoMovimiento.gasto);
      expect(CategoriaMovimiento.otrosIngresos.tipo, TipoMovimiento.ingreso);
    });
  });
}
