import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';
import 'package:economia_hogar/services/movimientos_excel_exporter.dart';

void main() {
  const exporter = MovimientosExcelExporter();

  test('exporta todos los movimientos del período en una sola hoja', () {
    final movements = [
      Movimiento(
        id: 1,
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 125050,
        categoria: CategoriaMovimiento.alimentos,
        descripcion: 'Compra mensual',
        fecha: DateTime(2026, 8, 5),
        fechaCreacion: DateTime(2026, 8, 5, 10, 30),
      ),
      Movimiento(
        id: 2,
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 250000,
        categoria: CategoriaMovimiento.venta,
        descripcion: 'Venta de escritorio',
        fecha: DateTime(2026, 8, 20),
        fechaCreacion: DateTime(2026, 8, 20, 18, 45),
      ),
      Movimiento(
        id: 3,
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 50000,
        categoria: CategoriaMovimiento.salud,
        fecha: DateTime(2026, 7, 20),
      ),
    ];

    final file = exporter.generar(
      movimientos: movements,
      anio: 2026,
      mes: 8,
      tipoExportacion: TipoExportacionMovimientos.todos,
    );
    final excel = Excel.decodeBytes(file.bytes);
    final sheet = excel.tables['Movimientos']!;

    expect(excel.tables.keys, ['Movimientos']);
    expect(file.nombre, 'economia_hogar_2026_08_todos.xlsx');
    expect(file.cantidadMovimientos, 2);
    expect(sheet.maxRows, 3);
    expect(sheet.rows.first.map((cell) => cell?.value.toString()).toList(), [
      'Tipo',
      'Importe',
      'Categoría',
      'Descripción',
      'Fecha del movimiento',
      'Fecha de creación',
    ]);
    expect(sheet.rows[1][0]?.value.toString(), 'Ingreso');
    expect(sheet.rows[1][3]?.value.toString(), 'Venta de escritorio');
    expect(sheet.rows[1][4]?.value.toString(), '20/08/2026');
    expect(sheet.rows[1][5]?.value.toString(), '20/08/2026 18:45:00');
    expect(sheet.rows[2][0]?.value.toString(), 'Gasto');
  });

  test('filtra gastos e ingresos en sus exportaciones', () {
    final movements = [
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 10000,
        categoria: CategoriaMovimiento.servicios,
        fecha: DateTime(2026, 8, 1),
      ),
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 20000,
        categoria: CategoriaMovimiento.sueldo,
        fecha: DateTime(2026, 8, 2),
      ),
    ];

    final expenses = exporter.generar(
      movimientos: movements,
      anio: 2026,
      mes: 8,
      tipoExportacion: TipoExportacionMovimientos.gastos,
    );
    final income = exporter.generar(
      movimientos: movements,
      anio: 2026,
      mes: 8,
      tipoExportacion: TipoExportacionMovimientos.ingresos,
    );

    expect(expenses.cantidadMovimientos, 1);
    expect(income.cantidadMovimientos, 1);
    expect(
      Excel.decodeBytes(expenses.bytes).tables['Movimientos']!.rows[1][0]?.value
          .toString(),
      'Gasto',
    );
    expect(
      Excel.decodeBytes(income.bytes).tables['Movimientos']!.rows[1][0]?.value
          .toString(),
      'Ingreso',
    );
  });
}
