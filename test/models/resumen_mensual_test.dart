import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/models/resumen_mensual.dart';

void main() {
  test('calcula el saldo como ingresos menos gastos', () {
    const resumen = ResumenMensual(
      ingresosEnCentavos: 120000000,
      gastosEnCentavos: 77465000,
      cantidadMovimientos: 15,
    );

    expect(resumen.saldoEnCentavos, 42535000);
    expect(resumen.cantidadMovimientos, 15);
  });
}
