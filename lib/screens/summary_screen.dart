import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/month_names.dart';
import '../models/movimiento.dart';
import '../models/resumen_categoria.dart';
import '../models/resumen_mensual.dart';
import '../services/archivo_excel_sharer.dart';
import '../services/desglose_gastos_calculator.dart';
import '../services/desglose_ingresos_calculator.dart';
import '../services/movimientos_excel_exporter.dart';
import '../services/resumen_mensual_calculator.dart';
import '../utils/categoria_movimiento_icon.dart';
import '../utils/monto_formatter.dart';
import '../widgets/selection_filter_menu.dart';

enum _SummarySection { balance, expenses, income }

enum _ExportOption { all, expenses, income }

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.movements});

  final List<Movimiento> movements;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  static const List<Color> _categoryColors = [
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF8E24AA),
    Color(0xFF3949AB),
    Color(0xFF00897B),
    Color(0xFF6D4C41),
    Color(0xFFD81B60),
    Color(0xFF546E7A),
  ];
  static const List<Color> _incomeCategoryColors = [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
    Color(0xFF00897B),
    Color(0xFF7CB342),
    Color(0xFF00ACC1),
  ];
  static const ResumenMensualCalculator _calculator =
      ResumenMensualCalculator();
  static const DesgloseGastosCalculator _expenseBreakdownCalculator =
      DesgloseGastosCalculator();
  static const DesgloseIngresosCalculator _incomeBreakdownCalculator =
      DesgloseIngresosCalculator();
  static const MovimientosExcelExporter _excelExporter =
      MovimientosExcelExporter();
  static const ArchivoExcelSharer _excelSharer = ArchivoExcelSharer();

  late int _selectedMonth;
  late int _selectedYear;
  _SummarySection _selectedSection = _SummarySection.balance;

  @override
  void initState() {
    super.initState();
    final currentPeriod = DateTime.now();
    _selectedMonth = currentPeriod.month;
    _selectedYear = currentPeriod.year;
  }

  String _formatCurrency(int amountInCents) {
    final sign = amountInCents < 0 ? '- ' : '';

    return '$sign\$ ${formatMontoEnCentavos(amountInCents.abs())}';
  }

  String _formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1).replaceAll('.', ',')} %';
  }

  List<int> get _availableYears {
    var firstYear = DateTime.now().year;

    for (final movement in widget.movements) {
      if (movement.fecha.year < firstYear) {
        firstYear = movement.fecha.year;
      }
    }

    final currentYear = DateTime.now().year;

    return [for (var year = currentYear; year >= firstYear; year--) year];
  }

  void _selectMonth(int month) {
    setState(() {
      _selectedMonth = month;
    });
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
    });
  }

  void _selectSection(Set<_SummarySection> sections) {
    setState(() {
      _selectedSection = sections.first;
    });
  }

  Future<void> _exportMovements(_ExportOption option) async {
    final exportType = switch (option) {
      _ExportOption.all => TipoExportacionMovimientos.todos,
      _ExportOption.expenses => TipoExportacionMovimientos.gastos,
      _ExportOption.income => TipoExportacionMovimientos.ingresos,
    };
    final file = _excelExporter.generar(
      movimientos: widget.movements,
      anio: _selectedYear,
      mes: _selectedMonth,
      tipoExportacion: exportType,
    );

    if (file.cantidadMovimientos == 0) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay movimientos para exportar en este período.'),
        ),
      );
      return;
    }

    try {
      await _excelSharer.compartir(file);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo compartir el archivo Excel.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _calculator.calcular(
      movimientos: widget.movements,
      anio: _selectedYear,
      mes: _selectedMonth,
    );
    final expenseBreakdown = _expenseBreakdownCalculator.calcular(
      movimientos: widget.movements,
      anio: _selectedYear,
      mes: _selectedMonth,
    );
    final incomeBreakdown = _incomeBreakdownCalculator.calcular(
      movimientos: widget.movements,
      anio: _selectedYear,
      mes: _selectedMonth,
    );
    final previousPeriod = DateTime(_selectedYear, _selectedMonth - 1);
    final previousSummary = _calculator.calcular(
      movimientos: widget.movements,
      anio: previousPeriod.year,
      mes: previousPeriod.month,
    );
    final periodName = '${monthNames[_selectedMonth - 1]} $_selectedYear';
    final previousPeriodName =
        '${monthNames[previousPeriod.month - 1]} ${previousPeriod.year}';
    final balanceColor = summary.saldoEnCentavos < 0
        ? Colors.red
        : Colors.green;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: SelectionFilterMenu<int>(
                label: 'Mes',
                tooltip: 'Seleccionar mes del resumen',
                selectedValue: _selectedMonth,
                selectedLabel: monthNames[_selectedMonth - 1],
                menuConstraints: const BoxConstraints(maxHeight: 320),
                options: [
                  for (var month = 1; month <= 12; month++)
                    SelectionOption(
                      value: month,
                      label: monthNames[month - 1],
                      key: 'summary_month_$month',
                    ),
                ],
                onSelected: _selectMonth,
              ),
            ),
            Expanded(
              child: SelectionFilterMenu<int>(
                label: 'Año',
                tooltip: 'Seleccionar año del resumen',
                selectedValue: _selectedYear,
                selectedLabel: _selectedYear.toString(),
                menuConstraints: const BoxConstraints(maxHeight: 320),
                options: [
                  for (final year in _availableYears)
                    SelectionOption(
                      value: year,
                      label: year.toString(),
                      key: 'summary_year_$year',
                    ),
                ],
                onSelected: _selectYear,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Resumen de $periodName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            PopupMenuButton<_ExportOption>(
              key: const ValueKey('summary_export_menu'),
              tooltip: 'Opciones de exportación',
              icon: const Icon(Icons.more_vert),
              onSelected: _exportMovements,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ExportOption.all,
                  child: ListTile(
                    leading: Icon(Icons.table_view_outlined),
                    title: Text('Exportar todo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _ExportOption.expenses,
                  child: ListTile(
                    leading: Icon(Icons.shopping_bag_outlined),
                    title: Text('Exportar Gastos'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _ExportOption.income,
                  child: ListTile(
                    leading: Icon(Icons.savings_outlined),
                    title: Text('Exportar Ingresos'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SegmentedButton<_SummarySection>(
          key: const ValueKey('summary_section_tabs'),
          expandedInsets: EdgeInsets.zero,
          segments: const [
            ButtonSegment(
              value: _SummarySection.balance,
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: Text('Saldos'),
            ),
            ButtonSegment(
              value: _SummarySection.expenses,
              icon: Icon(Icons.shopping_bag_outlined),
              label: Text('Gastos'),
            ),
            ButtonSegment(
              value: _SummarySection.income,
              icon: Icon(Icons.savings_outlined),
              label: Text('Ingresos'),
            ),
          ],
          selected: {_selectedSection},
          onSelectionChanged: _selectSection,
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (_selectedSection) {
            _SummarySection.balance => _buildBalanceContent(
              summary,
              balanceColor,
              previousSummary,
              previousPeriodName,
            ),
            _SummarySection.expenses => Column(
              key: const ValueKey('summary_expenses_content'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionOverview(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Gastos del período',
                  amount: summary.gastosEnCentavos,
                  color: Colors.red,
                  countText: _countLabel(
                    summary.cantidadGastos,
                    singular: 'gasto en el período',
                    plural: 'gastos en el período',
                  ),
                ),
                const SizedBox(height: 12),
                if (expenseBreakdown.isEmpty)
                  const Center(child: Text('Sin gastos en este período.'))
                else ...[
                  _buildExpensePie(expenseBreakdown, summary.gastosEnCentavos),
                ],
              ],
            ),
            _SummarySection.income => Column(
              key: const ValueKey('summary_income_content'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionOverview(
                  icon: Icons.savings_outlined,
                  title: 'Ingresos del período',
                  amount: summary.ingresosEnCentavos,
                  color: Colors.green,
                  countText: _countLabel(
                    summary.cantidadIngresos,
                    singular: 'ingreso en el período',
                    plural: 'ingresos en el período',
                  ),
                ),
                const SizedBox(height: 12),
                if (incomeBreakdown.isEmpty)
                  const Center(child: Text('Sin ingresos en este período.'))
                else
                  _buildIncomePie(incomeBreakdown, summary.ingresosEnCentavos),
              ],
            ),
          },
        ),
      ],
    );
  }

  Widget _buildSectionOverview({
    Key? key,
    required IconData icon,
    required String title,
    required int amount,
    required Color color,
    required String countText,
  }) {
    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(32),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(countText, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceContent(
    ResumenMensual summary,
    Color balanceColor,
    ResumenMensual previousSummary,
    String previousPeriodName,
  ) {
    final greatestTotal = summary.ingresosEnCentavos > summary.gastosEnCentavos
        ? summary.ingresosEnCentavos
        : summary.gastosEnCentavos;
    final incomeProgress = greatestTotal == 0
        ? 0.0
        : summary.ingresosEnCentavos / greatestTotal;
    final expenseProgress = greatestTotal == 0
        ? 0.0
        : summary.gastosEnCentavos / greatestTotal;

    return Column(
      key: const ValueKey('summary_balance_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionOverview(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Saldo del período',
          amount: summary.saldoEnCentavos,
          color: balanceColor,
          countText: _countLabel(
            summary.cantidadMovimientos,
            singular: 'movimiento en el período',
            plural: 'movimientos en el período',
          ),
        ),
        const SizedBox(height: 12),
        Card(
          key: const ValueKey('summary_balance_comparison'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildComparisonColumn(
                      key: const ValueKey('summary_income_bar'),
                      fillKey: const ValueKey('summary_income_bar_fill'),
                      icon: Icons.savings_outlined,
                      label: 'Ingresos',
                      amount: summary.ingresosEnCentavos,
                      count: summary.cantidadIngresos,
                      progress: incomeProgress,
                      color: Colors.green,
                    ),
                  ),
                  const VerticalDivider(width: 24),
                  Expanded(
                    child: _buildComparisonColumn(
                      key: const ValueKey('summary_expense_bar'),
                      fillKey: const ValueKey('summary_expense_bar_fill'),
                      icon: Icons.shopping_bag_outlined,
                      label: 'Gastos',
                      amount: summary.gastosEnCentavos,
                      count: summary.cantidadGastos,
                      progress: expenseProgress,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          key: const ValueKey('summary_balance_result'),
          child: ListTile(
            leading: Icon(Icons.balance_outlined, color: balanceColor),
            title: const Text('Resultado del período'),
            subtitle: Text(_balanceResultText(summary)),
          ),
        ),
        const SizedBox(height: 12),
        _buildMonthlyComparison(summary, previousSummary, previousPeriodName),
      ],
    );
  }

  Widget _buildComparisonColumn({
    required Key key,
    required Key fillKey,
    required IconData icon,
    required String label,
    required int amount,
    required int count,
    required double progress,
    required Color color,
  }) {
    return Column(
      key: key,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatCurrency(amount),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  key: fillKey,
                  width: 64,
                  height: constraints.maxHeight * progress,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(
          '$count ${count == 1 ? 'movimiento' : 'movimientos'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMonthlyComparison(
    ResumenMensual currentSummary,
    ResumenMensual previousSummary,
    String previousPeriodName,
  ) {
    final difference =
        currentSummary.saldoEnCentavos - previousSummary.saldoEnCentavos;
    final differenceColor = difference > 0
        ? Colors.green
        : difference < 0
        ? Colors.red
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final differenceIcon = difference > 0
        ? Icons.trending_up
        : difference < 0
        ? Icons.trending_down
        : Icons.trending_flat;

    return Card(
      key: const ValueKey('summary_monthly_comparison'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparado con $previousPeriodName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Expanded(child: Text('Saldo anterior')),
                Text(
                  _formatCurrency(previousSummary.saldoEnCentavos),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(differenceIcon, color: differenceColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _monthlyComparisonText(
                      difference: difference,
                      previousSummary: previousSummary,
                      previousPeriodName: previousPeriodName,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthlyComparisonText({
    required int difference,
    required ResumenMensual previousSummary,
    required String previousPeriodName,
  }) {
    if (previousSummary.cantidadMovimientos == 0) {
      return 'No hay movimientos en $previousPeriodName para comparar.';
    }

    if (difference == 0) {
      return 'El saldo no cambió respecto de $previousPeriodName.';
    }

    final direction = difference > 0 ? 'aumentó' : 'disminuyó';
    final amountText = _formatCurrency(difference.abs());
    final previousBalance = previousSummary.saldoEnCentavos;

    if (previousBalance == 0) {
      return 'El saldo $direction en $amountText. No se puede calcular un porcentaje porque el saldo anterior fue cero.';
    }

    final percentage = difference.abs() * 100 / previousBalance.abs();

    return 'El saldo $direction en $amountText (${_formatPercentage(percentage)}) respecto de $previousPeriodName.';
  }

  String _balanceResultText(ResumenMensual summary) {
    if (summary.cantidadMovimientos == 0) {
      return 'No hay movimientos para analizar en este período.';
    }

    if (summary.saldoEnCentavos > 0) {
      return 'Los ingresos superaron a los gastos por ${_formatCurrency(summary.saldoEnCentavos)}.';
    }

    if (summary.saldoEnCentavos < 0) {
      return 'Los gastos superaron a los ingresos por ${_formatCurrency(summary.saldoEnCentavos.abs())}.';
    }

    return 'Los ingresos y los gastos fueron iguales.';
  }

  Widget _buildExpensePie(List<ResumenCategoria> breakdown, int totalExpenses) {
    final colors = [
      for (var index = 0; index < breakdown.length; index++)
        _categoryColors[index % _categoryColors.length],
    ];

    return SizedBox(
      width: double.infinity,
      child: Card(
        key: const ValueKey('summary_expense_pie_card'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Distribución por categoría',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Total ${_formatCurrency(totalExpenses)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Gráfico de gastos por categoría',
                child: SizedBox(
                  key: const ValueKey('summary_expense_pie'),
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      percentages: [
                        for (final item in breakdown) item.porcentaje,
                      ],
                      colors: colors,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < breakdown.length; index++) ...[
                if (index > 0) const Divider(height: 20),
                _buildCategoryLegend(breakdown[index], colors[index]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLegend(ResumenCategoria summary, Color color) {
    final movementCountText = summary.cantidadMovimientos == 1
        ? '1 movimiento'
        : '${summary.cantidadMovimientos} movimientos';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(32),
            shape: BoxShape.circle,
          ),
          child: Icon(
            categoriaMovimientoIcon(summary.categoria),
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.categoria.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                '$movementCountText · ${_formatPercentage(summary.porcentaje)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatCurrency(summary.totalEnCentavos),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildIncomePie(List<ResumenCategoria> breakdown, int totalIncome) {
    final colors = [
      for (var index = 0; index < breakdown.length; index++)
        _incomeCategoryColors[index % _incomeCategoryColors.length],
    ];

    return SizedBox(
      width: double.infinity,
      child: Card(
        key: const ValueKey('summary_income_pie_card'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Distribución por categoría',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Total ${_formatCurrency(totalIncome)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Gráfico de ingresos por categoría',
                child: SizedBox(
                  key: const ValueKey('summary_income_pie'),
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      percentages: [
                        for (final item in breakdown) item.porcentaje,
                      ],
                      colors: colors,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < breakdown.length; index++) ...[
                if (index > 0) const Divider(height: 20),
                _buildCategoryLegend(breakdown[index], colors[index]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _countLabel(
    int count, {
    required String singular,
    required String plural,
  }) {
    return '$count ${count == 1 ? singular : plural}';
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({required this.percentages, required this.colors});

  final List<double> percentages;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    for (var index = 0; index < percentages.length; index++) {
      final sweepAngle = percentages[index] / 100 * math.pi * 2;
      const gapAngle = 0.012;
      final paint = Paint()
        ..color = colors[index]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        rect,
        startAngle + gapAngle / 2,
        math.max(0, sweepAngle - gapAngle),
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.percentages != percentages ||
        oldDelegate.colors != colors;
  }
}
