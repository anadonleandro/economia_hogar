import 'categoria_movimiento.dart';
import 'tipo_movimiento.dart';

class Movimiento {
  Movimiento({
    this.id,
    required this.tipo,
    required this.montoEnCentavos,
    required this.categoria,
    this.descripcion,
    required this.fecha,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now() {
    if (montoEnCentavos <= 0) {
      throw ArgumentError.value(
        montoEnCentavos,
        'montoEnCentavos',
        'El monto debe ser mayor que cero.',
      );
    }

    if (categoria.tipo != tipo) {
      throw ArgumentError(
        'La categoría seleccionada no corresponde al tipo de movimiento.',
      );
    }
  }

  final int? id;
  final TipoMovimiento tipo;
  final int montoEnCentavos;
  final CategoriaMovimiento categoria;
  final String? descripcion;
  final DateTime fecha;
  final DateTime fechaCreacion;
}
