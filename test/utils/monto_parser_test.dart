import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/utils/monto_parser.dart';

void main() {
  group('parseMontoEnCentavos', () {
    test('convierte un monto entero', () {
      expect(parseMontoEnCentavos('1200000'), 120000000);
    });

    test('convierte decimales separados por coma', () {
      expect(parseMontoEnCentavos('45300,50'), 4530050);
    });

    test('convierte un decimal separado por punto', () {
      expect(parseMontoEnCentavos('10.5'), 1050);
    });
  });
}
