String formatMontoEnCentavos(int amountInCents) {
  final absoluteAmount = amountInCents.abs();
  final integerPart = (absoluteAmount ~/ 100).toString();
  final decimalPart = (absoluteAmount % 100).toString().padLeft(2, '0');
  final firstGroupLength = integerPart.length % 3 == 0
      ? 3
      : integerPart.length % 3;
  final groups = <String>[integerPart.substring(0, firstGroupLength)];

  for (var index = firstGroupLength; index < integerPart.length; index += 3) {
    groups.add(integerPart.substring(index, index + 3));
  }

  final sign = amountInCents < 0 ? '-' : '';

  return "$sign${groups.join('.')},$decimalPart";
}
