import '../models/movimiento.dart';
import '../models/resumen_mensual.dart';
import '../models/tipo_movimiento.dart';

class ResumenMensualCalculator {
  const ResumenMensualCalculator();

  ResumenMensual calcular({
    required Iterable<Movimiento> movimientos,
    required int anio,
    required int mes,
  }) {
    if (mes < 1 || mes > 12) {
      throw RangeError.range(mes, 1, 12, 'mes');
    }

    var ingresosEnCentavos = 0;
    var gastosEnCentavos = 0;
    var cantidadMovimientos = 0;

    for (final movimiento in movimientos) {
      final perteneceAlPeriodo =
          movimiento.fecha.year == anio && movimiento.fecha.month == mes;

      if (!perteneceAlPeriodo) {
        continue;
      }

      cantidadMovimientos++;

      if (movimiento.tipo == TipoMovimiento.ingreso) {
        ingresosEnCentavos += movimiento.montoEnCentavos;
      } else {
        gastosEnCentavos += movimiento.montoEnCentavos;
      }
    }

    return ResumenMensual(
      ingresosEnCentavos: ingresosEnCentavos,
      gastosEnCentavos: gastosEnCentavos,
      cantidadMovimientos: cantidadMovimientos,
    );
  }
}
