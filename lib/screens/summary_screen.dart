import 'package:flutter/material.dart';

import '../constants/month_names.dart';
import '../models/movimiento.dart';
import '../models/resumen_categoria.dart';
import '../services/desglose_gastos_calculator.dart';
import '../services/resumen_mensual_calculator.dart';
import '../utils/monto_formatter.dart';
import '../widgets/selection_filter_menu.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.movements});

  final List<Movimiento> movements;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  static const ResumenMensualCalculator _calculator =
      ResumenMensualCalculator();
  static const DesgloseGastosCalculator _expenseBreakdownCalculator =
      DesgloseGastosCalculator();

  late int _selectedMonth;
  late int _selectedYear;

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
    final periodName = '${monthNames[_selectedMonth - 1]} $_selectedYear';
    final balanceColor = summary.saldoEnCentavos < 0
        ? Colors.red
        : Colors.green;
    final movementCountText = summary.cantidadMovimientos == 1
        ? '1 movimiento en el período'
        : '${summary.cantidadMovimientos} movimientos en el período';

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
        Text(
          'Resumen de $periodName',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.green),
            title: const Text('Ingresos del período'),
            trailing: Text(
              _formatCurrency(summary.ingresosEnCentavos),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: const Text('Gastos del período'),
            trailing: Text(
              _formatCurrency(summary.gastosEnCentavos),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet, color: balanceColor),
            title: const Text('Saldo del período'),
            trailing: Text(
              _formatCurrency(summary.saldoEnCentavos),
              style: TextStyle(
                color: balanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(movementCountText),
        if (summary.cantidadMovimientos == 0) ...[
          const SizedBox(height: 24),
          const Center(child: Text('Sin movimientos en este período.')),
        ],
        const SizedBox(height: 28),
        Text(
          'Gastos por categoría',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (expenseBreakdown.isEmpty)
          const Center(child: Text('Sin gastos en este período.'))
        else
          ...expenseBreakdown.map(_buildCategorySummary),
      ],
    );
  }

  Widget _buildCategorySummary(ResumenCategoria summary) {
    final movementCountText = summary.cantidadMovimientos == 1
        ? '1 movimiento'
        : '${summary.cantidadMovimientos} movimientos';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    summary.categoria.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  _formatCurrency(summary.totalEnCentavos),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$movementCountText · ${_formatPercentage(summary.porcentaje)}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: summary.porcentaje / 100),
          ],
        ),
      ),
    );
  }
}
