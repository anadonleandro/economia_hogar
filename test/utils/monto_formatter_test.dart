import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/utils/monto_formatter.dart';

void main() {
  group('formatMontoEnCentavos', () {
    test('formatea pesos y centavos', () {
      expect(formatMontoEnCentavos(4530050), '45.300,50');
    });

    test('agrega separadores de miles', () {
      expect(formatMontoEnCentavos(120000000), '1.200.000,00');
    });

    test('formatea valores menores a un peso', () {
      expect(formatMontoEnCentavos(50), '0,50');
    });
  });
}
