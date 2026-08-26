import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:economia_hogar/main.dart';
import 'package:economia_hogar/constants/month_names.dart';
import 'package:economia_hogar/models/categoria_movimiento.dart';
import 'package:economia_hogar/models/movimiento.dart';
import 'package:economia_hogar/models/tipo_movimiento.dart';
import 'package:economia_hogar/screens/new_movement_screen.dart';
import 'package:economia_hogar/screens/movements_screen.dart';
import 'package:economia_hogar/screens/app_shell.dart';
import 'package:economia_hogar/screens/summary_screen.dart';

Future<void> _openNewMovementForm(WidgetTester tester) async {
  await tester.tap(find.text('Movimientos'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Nuevo movimiento'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Muestra la pantalla inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Movimientos del día'), findsOneWidget);
    expect(
      find.text('No hay movimientos registrados este día.'),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Nuevo movimiento'), findsNothing);

    await tester.tap(find.text('Movimientos'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo movimiento'), findsOneWidget);
  });

  testWidgets('muestra el estado de carga inicial', (
    WidgetTester tester,
  ) async {
    final completer = Completer<List<Movimiento>>();

    await tester.pumpWidget(
      MaterialApp(home: AppShell(movementsLoader: () => completer.future)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando movimientos...'), findsOneWidget);
    expect(find.text('0 movimientos en el mes'), findsNothing);

    completer.complete([]);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('0 movimientos en el mes'), findsOneWidget);
  });

  testWidgets('muestra un error de carga y permite reintentar', (
    WidgetTester tester,
  ) async {
    var loadAttempts = 0;

    Future<List<Movimiento>> loadMovements() async {
      loadAttempts++;

      if (loadAttempts == 1) {
        throw Exception('Error de prueba');
      }

      return [];
    }

    await tester.pumpWidget(
      MaterialApp(home: AppShell(movementsLoader: loadMovements)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar los movimientos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(loadAttempts, 2);
    expect(find.text('0 movimientos en el mes'), findsOneWidget);
  });

  testWidgets('abre altas rápidas de ingreso y gasto desde Inicio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Agregar ingreso'));
    await tester.pumpAndSettle();

    var selector = tester.widget<SegmentedButton<TipoMovimiento>>(
      find.byType(SegmentedButton<TipoMovimiento>),
    );
    var categoryMenu = tester.widget<DropdownMenu<CategoriaMovimiento>>(
      find.byType(DropdownMenu<CategoriaMovimiento>),
    );

    expect(selector.selected, {TipoMovimiento.ingreso});
    expect(categoryMenu.initialSelection, CategoriaMovimiento.sueldo);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Agregar gasto'));
    await tester.pumpAndSettle();

    selector = tester.widget<SegmentedButton<TipoMovimiento>>(
      find.byType(SegmentedButton<TipoMovimiento>),
    );
    categoryMenu = tester.widget<DropdownMenu<CategoriaMovimiento>>(
      find.byType(DropdownMenu<CategoriaMovimiento>),
    );

    expect(selector.selected, {TipoMovimiento.gasto});
    expect(categoryMenu.initialSelection, CategoriaMovimiento.alimentos);
  });

  testWidgets('abre Acerca de desde el menú principal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Acerca de'), findsOneWidget);

    await tester.tap(find.text('Acerca de'));
    await tester.pumpAndSettle();

    expect(find.text('Economía del Hogar'), findsOneWidget);
    expect(find.text('Objetivo'), findsOneWidget);
    expect(find.text('Privacidad'), findsOneWidget);
    expect(
      find.textContaining('guarda la información localmente'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsWidgets);
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

    final currentPeriod = DateTime.now();
    const monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    expect(
      find.text(
        'Resumen de ${monthNames[currentPeriod.month - 1]} ${currentPeriod.year}',
      ),
      findsOneWidget,
    );
    expect(find.text('Ingresos del período'), findsOneWidget);
    expect(find.text('Gastos del período'), findsOneWidget);
    expect(find.text('Saldo del período'), findsOneWidget);
    expect(find.text('0 movimientos en el período'), findsOneWidget);
    expect(find.text('Sin movimientos en este período.'), findsOneWidget);
  });

  testWidgets('Abre y cierra la pantalla de nuevo movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await _openNewMovementForm(tester);

    expect(find.text('Tipo de movimiento'), findsOneWidget);
    expect(find.byType(SegmentedButton<TipoMovimiento>), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(
      find.text('Todavía no hay movimientos registrados.'),
      findsOneWidget,
    );
  });

  testWidgets('Permite seleccionar el tipo de movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await _openNewMovementForm(tester);

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

    await _openNewMovementForm(tester);

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

    await _openNewMovementForm(tester);

    final amountField = find.widgetWithText(TextFormField, 'Monto');

    expect(amountField, findsOneWidget);

    await tester.enterText(amountField, '45300,50');

    expect(find.text('45300,50'), findsOneWidget);
  });

  testWidgets('Valida el monto del movimiento', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await _openNewMovementForm(tester);

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

    await _openNewMovementForm(tester);

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

    await _openNewMovementForm(tester);

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

    await _openNewMovementForm(tester);

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

  testWidgets('Actualiza el resumen mensual de Inicio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0 movimientos en el mes'), findsOneWidget);

    await _openNewMovementForm(tester);

    final amountField = find.widgetWithText(TextFormField, 'Monto');
    final saveButton = find.text('Guardar');

    await tester.enterText(amountField, '1000');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();

    expect(find.text(r'$ 0,00'), findsOneWidget);
    expect(find.text(r'$ 1.000,00'), findsOneWidget);
    expect(find.text(r'- $ 1.000,00'), findsNWidgets(2));
    expect(find.text('1 movimiento en el mes'), findsOneWidget);
    expect(find.text('0 ingresos en el mes'), findsOneWidget);
    expect(find.text('1 gasto en el mes'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text(r'- $ 1.000,00'), findsNWidgets(2));
    expect(find.text('Movimientos del día'), findsOneWidget);
  });

  testWidgets('muestra los movimientos de hoy ordenados en Inicio', (
    WidgetTester tester,
  ) async {
    final currentPeriod = DateTime.now();
    final movements = [
      for (var day = 1; day <= 4; day++)
        Movimiento(
          id: day,
          tipo: TipoMovimiento.gasto,
          montoEnCentavos: day * 10000,
          categoria: CategoriaMovimiento.alimentos,
          descripcion: 'Movimiento $day',
          fecha: DateTime(
            currentPeriod.year,
            currentPeriod.month,
            currentPeriod.day,
          ),
          fechaCreacion: DateTime(
            currentPeriod.year,
            currentPeriod.month,
            currentPeriod.day,
            day,
          ),
        ),
      Movimiento(
        id: 99,
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 50000,
        categoria: CategoriaMovimiento.sueldo,
        descripcion: 'Movimiento de ayer',
        fecha: currentPeriod.subtract(const Duration(days: 1)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(home: AppShell(movementsLoader: () async => movements)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Movimientos del día'), findsOneWidget);
    expect(find.textContaining('· 4 movimientos'), findsOneWidget);
    expect(find.text('Movimiento 4'), findsOneWidget);
    expect(find.text('Movimiento 3'), findsOneWidget);
    expect(find.text('Movimiento de ayer'), findsNothing);
    expect(find.byType(Scrollbar), findsOneWidget);

    final nextDayButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(nextDayButton.onPressed, isNull);

    await tester.tap(find.byTooltip('Día anterior'));
    await tester.pumpAndSettle();

    expect(find.text('Movimiento de ayer'), findsOneWidget);
    expect(find.text('Movimiento 4'), findsNothing);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right),
          )
          .onPressed,
      isNotNull,
    );

    for (var day = currentPeriod.day - 1; day > 1; day--) {
      await tester.tap(find.byTooltip('Día anterior'));
      await tester.pump();
    }

    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_left),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();

    expect(
      find.text('${monthNames[currentPeriod.month - 1]} ${currentPeriod.year}'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right),
          )
          .onPressed,
      isNull,
    );

    await tester.ensureVisible(find.text('Movimiento 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Movimiento 4'));
    await tester.pumpAndSettle();

    expect(find.text('Editar movimiento'), findsOneWidget);
  });

  testWidgets('Carga los datos de un movimiento para editarlo', (
    WidgetTester tester,
  ) async {
    final creationDate = DateTime(2026, 8, 20, 10, 30);
    final movement = Movimiento(
      id: 7,
      tipo: TipoMovimiento.ingreso,
      montoEnCentavos: 123456,
      categoria: CategoriaMovimiento.trabajoExtra,
      descripcion: 'Trabajo del fin de semana',
      fecha: DateTime(2026, 8, 19),
      fechaCreacion: creationDate,
    );

    await tester.pumpWidget(
      MaterialApp(home: NewMovementScreen(initialMovement: movement)),
    );

    expect(find.text('Editar movimiento'), findsOneWidget);
    expect(find.text('1234,56'), findsOneWidget);
    expect(find.text('Trabajo del fin de semana'), findsOneWidget);
    expect(find.text('19/08/2026'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);

    final selector = tester.widget<SegmentedButton<TipoMovimiento>>(
      find.byType(SegmentedButton<TipoMovimiento>),
    );
    expect(selector.selected, {TipoMovimiento.ingreso});

    final categoryMenu = tester.widget<DropdownMenu<CategoriaMovimiento>>(
      find.byType(DropdownMenu<CategoriaMovimiento>),
    );
    expect(categoryMenu.initialSelection, CategoriaMovimiento.trabajoExtra);
  });

  testWidgets('confirma antes de eliminar un movimiento', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await _openNewMovementForm(tester);

    final amountField = find.widgetWithText(TextFormField, 'Monto');
    final descriptionField = find.widgetWithText(
      TextFormField,
      'Descripción (opcional)',
    );
    final saveButton = find.text('Guardar');

    await tester.enterText(amountField, '500');
    await tester.enterText(descriptionField, 'Movimiento para eliminar');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Eliminar movimiento'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text(
        '¿Querés eliminar este movimiento? Esta acción no se puede deshacer.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Movimiento para eliminar'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar movimiento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Movimiento para eliminar'), findsNothing);
    expect(
      find.text('Todavía no hay movimientos registrados.'),
      findsOneWidget,
    );
  });

  testWidgets('filtra el listado por tipo de movimiento', (
    WidgetTester tester,
  ) async {
    final movements = [
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 200000,
        categoria: CategoriaMovimiento.sueldo,
        descripcion: 'Ingreso visible',
        fecha: DateTime(2026, 8, 5),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 50000,
        categoria: CategoriaMovimiento.alimentos,
        descripcion: 'Gasto visible',
        fecha: DateTime(2026, 8, 10),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 30000,
        categoria: CategoriaMovimiento.transporte,
        descripcion: 'Gasto anterior',
        fecha: DateTime(2025, 7, 10),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MovementsScreen(movements: movements)),
      ),
    );

    expect(find.text('Ingreso visible'), findsOneWidget);
    expect(find.text('Gasto visible'), findsOneWidget);
    expect(find.text('Gasto anterior'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar por tipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('movement_type_filter_income')));
    await tester.pumpAndSettle();

    expect(find.text('Ingreso visible'), findsOneWidget);
    expect(find.text('Gasto visible'), findsNothing);
    expect(find.text('Gasto anterior'), findsNothing);
    expect(find.text('Ingresos'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar por tipo'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('movement_type_filter_expense')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ingreso visible'), findsNothing);
    expect(find.text('Gasto visible'), findsOneWidget);
    expect(find.text('Gasto anterior'), findsOneWidget);
    expect(find.text('Gastos'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar por tipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('movement_type_filter_all')));
    await tester.pumpAndSettle();

    expect(find.text('Ingreso visible'), findsOneWidget);
    expect(find.text('Gasto visible'), findsOneWidget);
    expect(find.text('Gasto anterior'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar por mes'));
    await tester.pumpAndSettle();
    final julyOption = find.byKey(const ValueKey('movement_month_filter_7'));
    await tester.ensureVisible(julyOption);
    await tester.pumpAndSettle();
    await tester.tap(julyOption);
    await tester.pumpAndSettle();

    expect(find.text('Ingreso visible'), findsNothing);
    expect(find.text('Gasto visible'), findsNothing);
    expect(find.text('Gasto anterior'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar por año'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('movement_year_filter_2025')));
    await tester.pumpAndSettle();

    expect(find.text('Gasto anterior'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('clear_movement_filters')));
    await tester.pumpAndSettle();

    expect(find.text('Ingreso visible'), findsOneWidget);
    expect(find.text('Gasto visible'), findsOneWidget);
    expect(find.text('Gasto anterior'), findsOneWidget);
    expect(find.text('Todos'), findsNWidgets(3));
  });

  testWidgets('selecciona el período del resumen mensual', (
    WidgetTester tester,
  ) async {
    final currentPeriod = DateTime.now();
    final previousYear = currentPeriod.year - 1;
    final movements = [
      Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoEnCentavos: 123456,
        categoria: CategoriaMovimiento.sueldo,
        fecha: DateTime(previousYear, 1, 5),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 50000,
        categoria: CategoriaMovimiento.alimentos,
        fecha: DateTime(currentPeriod.year, currentPeriod.month, 10),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SummaryScreen(movements: movements)),
      ),
    );

    await tester.tap(find.byTooltip('Seleccionar mes del resumen'));
    await tester.pumpAndSettle();
    final januaryOption = find.byKey(const ValueKey('summary_month_1'));
    await tester.ensureVisible(januaryOption);
    await tester.pumpAndSettle();
    await tester.tap(januaryOption);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Seleccionar año del resumen'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('summary_year_$previousYear')));
    await tester.pumpAndSettle();

    expect(find.text('Resumen de Enero $previousYear'), findsOneWidget);
    expect(find.text(r'$ 1.234,56'), findsNWidgets(2));
    expect(find.text(r'$ 0,00'), findsOneWidget);
    expect(find.text('1 movimiento en el período'), findsOneWidget);
    expect(find.text('Sin gastos en este período.'), findsOneWidget);
  });

  testWidgets('muestra el desglose de gastos por categoría', (
    WidgetTester tester,
  ) async {
    final currentPeriod = DateTime.now();
    final movements = [
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 60000,
        categoria: CategoriaMovimiento.alimentos,
        fecha: DateTime(currentPeriod.year, currentPeriod.month, 5),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 20000,
        categoria: CategoriaMovimiento.alimentos,
        fecha: DateTime(currentPeriod.year, currentPeriod.month, 12),
      ),
      Movimiento(
        tipo: TipoMovimiento.gasto,
        montoEnCentavos: 20000,
        categoria: CategoriaMovimiento.transporte,
        fecha: DateTime(currentPeriod.year, currentPeriod.month, 18),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SummaryScreen(movements: movements)),
      ),
    );

    expect(find.text('Gastos por categoría'), findsOneWidget);
    expect(find.text('Alimentos'), findsOneWidget);
    expect(find.text(r'$ 800,00'), findsOneWidget);
    expect(find.text('2 movimientos · 80,0 %'), findsOneWidget);
    expect(find.text('Transporte'), findsOneWidget);
    expect(find.text(r'$ 200,00'), findsOneWidget);
    expect(find.text('1 movimiento · 20,0 %'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });
}
