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

  testWidgets('Permite ingresar el monto del movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    final amountField = find.widgetWithText(TextFormField, 'Monto');

    expect(amountField, findsOneWidget);

    await tester.enterText(amountField, '45300,50');

    expect(find.text('45300,50'), findsOneWidget);
  });

  testWidgets('Valida el monto del movimiento', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    final amountField = find.widgetWithText(TextFormField, 'Monto');

    await tester.enterText(amountField, '1');
    await tester.enterText(amountField, '');
    await tester.pump();

    expect(find.text('Ingresá un monto.'), findsOneWidget);

    await tester.enterText(amountField, '0');
    await tester.pump();

    expect(find.text('El monto debe ser mayor que cero.'), findsOneWidget);

    await tester.enterText(amountField, '10,999');
    await tester.pump();

    expect(
      find.text('Ingresá un monto válido con hasta dos decimales.'),
      findsOneWidget,
    );

    await tester.enterText(amountField, '45300,50');
    await tester.pump();

    expect(find.text('Ingresá un monto.'), findsNothing);
    expect(find.text('El monto debe ser mayor que cero.'), findsNothing);
    expect(
      find.text('Ingresá un monto válido con hasta dos decimales.'),
      findsNothing,
    );
  });

  testWidgets('Permite ingresar una descripción opcional', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    final descriptionFinder = find.widgetWithText(
      TextFormField,
      'Descripción (opcional)',
    );
    final editableText = tester.widget<EditableText>(
      find.descendant(
        of: descriptionFinder,
        matching: find.byType(EditableText),
      ),
    );

    expect(editableText.maxLines, 3);

    final longDescription = List.filled(201, 'a').join();

    await tester.enterText(descriptionFinder, longDescription);

    expect(editableText.controller.text, hasLength(200));

    await tester.enterText(descriptionFinder, 'Compra semanal');

    expect(find.text('Compra semanal'), findsOneWidget);
  });

  testWidgets('Muestra la fecha actual y abre el calendario', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final formattedToday = [
      today.day.toString().padLeft(2, '0'),
      today.month.toString().padLeft(2, '0'),
      today.year.toString(),
    ].join('/');

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    expect(find.text(formattedToday), findsOneWidget);

    await tester.tap(find.text(formattedToday));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('Valida y guarda el formulario de movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Nuevo movimiento'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Guardar');

    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Ingresá un monto.'), findsOneWidget);
    expect(find.text('Nuevo movimiento'), findsOneWidget);

    final amountField = find.widgetWithText(TextFormField, 'Monto');
    final descriptionField = find.widgetWithText(
      TextFormField,
      'Descripción (opcional)',
    );

    await tester.enterText(amountField, '45300,50');
    await tester.enterText(descriptionField, 'Compra supermercado');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Compra supermercado'), findsOneWidget);
    expect(find.textContaining('Alimentos ·'), findsOneWidget);
    expect(find.text(r'- $ 45.300,50'), findsOneWidget);
    expect(find.text('Nuevo movimiento'), findsOneWidget);
  });
}
