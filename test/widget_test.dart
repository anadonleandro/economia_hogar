import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/main.dart';
import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';

void main() {
  testWidgets('Muestra la pantalla inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Todavía no hay movimientos.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Nuevo movimiento'), findsOneWidget);
  });

  testWidgets('Permite navegar entre las secciones', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Movimientos'));
    await tester.pumpAndSettle();

    expect(
      find.text('Todavía no hay movimientos registrados.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Resumen'));
    await tester.pumpAndSettle();

    expect(find.text('El resumen mensual aparecerá aquí.'), findsOneWidget);
  });

  testWidgets('Abre y cierra la pantalla de nuevo movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    expect(find.text('Tipo de movimiento'), findsOneWidget);
    expect(find.byType(SegmentedButton<TipoMovimiento>), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Todavía no hay movimientos.'), findsOneWidget);
  });

  testWidgets('Permite seleccionar el tipo de movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    var selector = tester.widget<SegmentedButton<TipoMovimiento>>(
      find.byType(SegmentedButton<TipoMovimiento>),
    );

    expect(selector.selected, {TipoMovimiento.gasto});

    await tester.tap(find.text('Ingreso'));
    await tester.pumpAndSettle();

    selector = tester.widget<SegmentedButton<TipoMovimiento>>(
      find.byType(SegmentedButton<TipoMovimiento>),
    );

    expect(selector.selected, {TipoMovimiento.ingreso});
  });

  testWidgets('Filtra las categorías según el tipo de movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    var categoryMenu = tester.widget<DropdownMenu<CategoriaMovimiento>>(
      find.byType(DropdownMenu<CategoriaMovimiento>),
    );

    expect(categoryMenu.initialSelection, CategoriaMovimiento.alimentos);
    expect(categoryMenu.dropdownMenuEntries, hasLength(9));
    expect(
      categoryMenu.dropdownMenuEntries.every(
        (entry) => entry.value.tipo == TipoMovimiento.gasto,
      ),
      isTrue,
    );

    await tester.tap(find.text('Ingreso'));
    await tester.pumpAndSettle();

    categoryMenu = tester.widget<DropdownMenu<CategoriaMovimiento>>(
      find.byType(DropdownMenu<CategoriaMovimiento>),
    );

    expect(categoryMenu.initialSelection, CategoriaMovimiento.sueldo);
    expect(categoryMenu.dropdownMenuEntries, hasLength(5));
    expect(
      categoryMenu.dropdownMenuEntries.every(
        (entry) => entry.value.tipo == TipoMovimiento.ingreso,
      ),
      isTrue,
    );

    await tester.tap(find.byType(DropdownMenu<CategoriaMovimiento>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trabajo extra').last);
    await tester.pumpAndSettle();

    categoryMenu = tester.widget<DropdownMenu<CategoriaMovimiento>>(
      find.byType(DropdownMenu<CategoriaMovimiento>),
    );

    expect(categoryMenu.initialSelection, CategoriaMovimiento.trabajoExtra);
  });
}
