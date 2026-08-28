import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';

enum TipoExportacionMovimientos { todos, gastos, ingresos }

class ArchivoExcelMovimientos {
  const ArchivoExcelMovimientos({
    required this.bytes,
    required this.nombre,
    required this.cantidadMovimientos,
  });

  final Uint8List bytes;
  final String nombre;
  final int cantidadMovimientos;
}

class MovimientosExcelExporter {
  const MovimientosExcelExporter();

  static const _sheetName = 'Movimientos';

  ArchivoExcelMovimientos generar({
    required Iterable<Movimiento> movimientos,
    required int anio,
    required int mes,
    required TipoExportacionMovimientos tipoExportacion,
  }) {
    if (mes < 1 || mes > 12) {
      throw RangeError.range(mes, 1, 12, 'mes');
    }

    final filteredMovements = movimientos.where((movement) {
      final belongsToPeriod =
          movement.fecha.year == anio && movement.fecha.month == mes;

      if (!belongsToPeriod) {
        return false;
      }

      return switch (tipoExportacion) {
        TipoExportacionMovimientos.todos => true,
        TipoExportacionMovimientos.gastos =>
          movement.tipo == TipoMovimiento.gasto,
        TipoExportacionMovimientos.ingresos =>
          movement.tipo == TipoMovimiento.ingreso,
      };
    }).toList();

    filteredMovements.sort((first, second) {
      final dateComparison = second.fecha.compareTo(first.fecha);

      if (dateComparison != 0) {
        return dateComparison;
      }

      return second.fechaCreacion.compareTo(first.fechaCreacion);
    });

    final excel = Excel.createExcel();
    excel.rename(excel.getDefaultSheet()!, _sheetName);
    final sheet = excel[_sheetName];

    sheet.appendRow([
      TextCellValue('Tipo'),
      TextCellValue('Importe'),
      TextCellValue('Categoría'),
      TextCellValue('Descripción'),
      TextCellValue('Fecha del movimiento'),
      TextCellValue('Fecha de creación'),
    ]);

    for (final movement in filteredMovements) {
      sheet.appendRow([
        TextCellValue(_movementTypeName(movement.tipo)),
        DoubleCellValue(movement.montoEnCentavos / 100),
        TextCellValue(movement.categoria.nombre),
        TextCellValue(movement.descripcion ?? ''),
        TextCellValue(_formatDate(movement.fecha)),
        TextCellValue(_formatDateTime(movement.fechaCreacion)),
      ]);
    }

    final encodedFile = excel.encode();

    if (encodedFile == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }

    return ArchivoExcelMovimientos(
      bytes: Uint8List.fromList(encodedFile),
      nombre: _fileName(anio, mes, tipoExportacion),
      cantidadMovimientos: filteredMovements.length,
    );
  }

  String _movementTypeName(TipoMovimiento type) {
    return switch (type) {
      TipoMovimiento.gasto => 'Gasto',
      TipoMovimiento.ingreso => 'Ingreso',
    };
  }

  String _fileName(int year, int month, TipoExportacionMovimientos exportType) {
    final typeName = switch (exportType) {
      TipoExportacionMovimientos.todos => 'todos',
      TipoExportacionMovimientos.gastos => 'gastos',
      TipoExportacionMovimientos.ingresos => 'ingresos',
    };
    final paddedMonth = month.toString().padLeft(2, '0');

    return 'economia_hogar_${year}_${paddedMonth}_$typeName.xlsx';
  }

  String _formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_twoDigits(date.hour)}:'
        '${_twoDigits(date.minute)}:${_twoDigits(date.second)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
