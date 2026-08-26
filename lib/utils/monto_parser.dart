int parseMontoEnCentavos(String value) {
  final normalizedValue = value.trim().replaceAll(',', '.');
  final parts = normalizedValue.split('.');
  final integerPart = int.parse(parts.first);
  final decimalPart = parts.length == 2 ? parts.last.padRight(2, '0') : '00';

  return integerPart * 100 + int.parse(decimalPart);
}
