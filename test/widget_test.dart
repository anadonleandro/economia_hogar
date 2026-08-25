import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/main.dart';

void main() {
  testWidgets('Muestra la pantalla inicial sin movimientos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Economía del Hogar'), findsOneWidget);
    expect(find.text('Todavía no hay movimientos.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
