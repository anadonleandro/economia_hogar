import 'categoria_movimiento.dart';

class ResumenCategoria {
  const ResumenCategoria({
    required this.categoria,
    required this.totalEnCentavos,
    required this.cantidadMovimientos,
    required this.porcentaje,
  });

  final CategoriaMovimiento categoria;
  final int totalEnCentavos;
  final int cantidadMovimientos;
  final double porcentaje;
}
