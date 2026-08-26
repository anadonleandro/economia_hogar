import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import '../utils/monto_formatter.dart';

enum _MovementTypeFilter { all, income, expense }

const List<String> _monthNames = [
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

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({
    super.key,
    required this.movements,
    this.onMovementTap,
    this.onDeleteMovement,
  });

  final List<Movimiento> movements;
  final ValueChanged<Movimiento>? onMovementTap;
  final ValueChanged<Movimiento>? onDeleteMovement;

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  _MovementTypeFilter _selectedTypeFilter = _MovementTypeFilter.all;
  int _selectedMonth = 0;
  int _selectedYear = 0;

  TipoMovimiento? get _selectedType {
    return switch (_selectedTypeFilter) {
      _MovementTypeFilter.all => null,
      _MovementTypeFilter.income => TipoMovimiento.ingreso,
      _MovementTypeFilter.expense => TipoMovimiento.gasto,
    };
  }

  String get _selectedTypeLabel {
    return switch (_selectedTypeFilter) {
      _MovementTypeFilter.all => 'Todos',
      _MovementTypeFilter.income => 'Ingresos',
      _MovementTypeFilter.expense => 'Gastos',
    };
  }

  String get _selectedMonthLabel {
    return _selectedMonth == 0 ? 'Todos' : _monthNames[_selectedMonth - 1];
  }

  String get _selectedYearLabel {
    return _selectedYear == 0 ? 'Todos' : _selectedYear.toString();
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

  bool get _hasActiveFilters {
    return _selectedTypeFilter != _MovementTypeFilter.all ||
        _selectedMonth != 0 ||
        _selectedYear != 0;
  }

  List<Movimiento> get _filteredMovements {
    final selectedType = _selectedType;

    return widget.movements
        .where((movement) {
          final matchesType =
              selectedType == null || movement.tipo == selectedType;
          final matchesMonth =
              _selectedMonth == 0 || movement.fecha.month == _selectedMonth;
          final matchesYear =
              _selectedYear == 0 || movement.fecha.year == _selectedYear;

          return matchesType && matchesMonth && matchesYear;
        })
        .toList(growable: false);
  }

  void _selectType(_MovementTypeFilter filter) {
    setState(() {
      _selectedTypeFilter = filter;
    });
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

  void _clearFilters() {
    setState(() {
      _selectedTypeFilter = _MovementTypeFilter.all;
      _selectedMonth = 0;
      _selectedYear = 0;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movements.isEmpty) {
      return const Center(
        child: Text('Todavía no hay movimientos registrados.'),
      );
    }

    final filteredMovements = _filteredMovements;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: _FilterMenu<_MovementTypeFilter>(
                      label: 'Tipo',
                      tooltip: 'Filtrar por tipo',
                      selectedValue: _selectedTypeFilter,
                      selectedLabel: _selectedTypeLabel,
                      options: [
                        for (final filter in _MovementTypeFilter.values)
                          _FilterOption(
                            value: filter,
                            label: switch (filter) {
                              _MovementTypeFilter.all => 'Todos',
                              _MovementTypeFilter.income => 'Ingresos',
                              _MovementTypeFilter.expense => 'Gastos',
                            },
                            key: 'movement_type_filter_${filter.name}',
                          ),
                      ],
                      onSelected: _selectType,
                    ),
                  ),
                  Expanded(
                    child: _FilterMenu<int>(
                      label: 'Mes',
                      tooltip: 'Filtrar por mes',
                      menuConstraints: const BoxConstraints(maxHeight: 320),
                      selectedValue: _selectedMonth,
                      selectedLabel: _selectedMonthLabel,
                      options: [
                        const _FilterOption(
                          value: 0,
                          label: 'Todos',
                          key: 'movement_month_filter_0',
                        ),
                        for (var month = 1; month <= 12; month++)
                          _FilterOption(
                            value: month,
                            label: _monthNames[month - 1],
                            key: 'movement_month_filter_$month',
                          ),
                      ],
                      onSelected: _selectMonth,
                    ),
                  ),
                  Expanded(
                    child: _FilterMenu<int>(
                      label: 'Año',
                      tooltip: 'Filtrar por año',
                      menuConstraints: const BoxConstraints(maxHeight: 320),
                      selectedValue: _selectedYear,
                      selectedLabel: _selectedYearLabel,
                      options: [
                        const _FilterOption(
                          value: 0,
                          label: 'Todos',
                          key: 'movement_year_filter_0',
                        ),
                        for (final year in _availableYears)
                          _FilterOption(
                            value: year,
                            label: year.toString(),
                            key: 'movement_year_filter_$year',
                          ),
                      ],
                      onSelected: _selectYear,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const ValueKey('clear_movement_filters'),
                  onPressed: _hasActiveFilters ? _clearFilters : null,
                  child: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredMovements.isEmpty
              ? const Center(
                  child: Text('No hay movimientos para este filtro.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredMovements.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _buildMovementTile(filteredMovements[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildMovementTile(Movimiento movement) {
    final isIncome = movement.tipo == TipoMovimiento.ingreso;
    final description = movement.descripcion?.trim();
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountSign = isIncome ? '+' : '-';

    return ListTile(
      onTap: () => widget.onMovementTap?.call(movement),
      leading: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: amountColor,
      ),
      title: Text(
        description == null || description.isEmpty
            ? movement.categoria.nombre
            : description,
      ),
      subtitle: Text(
        '${movement.categoria.nombre} · ${_formatDate(movement.fecha)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$amountSign \$ ${formatMontoEnCentavos(movement.montoEnCentavos)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => widget.onDeleteMovement?.call(movement),
            tooltip: 'Eliminar movimiento',
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _FilterOption<T> {
  const _FilterOption({
    required this.value,
    required this.label,
    required this.key,
  });

  final T value;
  final String label;
  final String key;
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.tooltip,
    required this.selectedValue,
    required this.selectedLabel,
    required this.options,
    required this.onSelected,
    this.menuConstraints,
  });

  final String label;
  final String tooltip;
  final T selectedValue;
  final String selectedLabel;
  final List<_FilterOption<T>> options;
  final ValueChanged<T> onSelected;
  final BoxConstraints? menuConstraints;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: selectedValue,
      tooltip: tooltip,
      constraints: menuConstraints,
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((option) {
          return CheckedPopupMenuItem<T>(
            key: ValueKey(option.key),
            value: option.value,
            checked: option.value == selectedValue,
            child: Text(option.label),
          );
        }).toList();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
