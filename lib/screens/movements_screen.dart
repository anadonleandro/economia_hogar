import 'package:flutter/material.dart';

import '../constants/month_names.dart';
import '../models/categoria_movimiento.dart';
import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import '../utils/monto_formatter.dart';
import '../utils/categoria_movimiento_icon.dart';
import '../widgets/selection_filter_menu.dart';

enum _MovementTypeFilter { all, income, expense }

enum _MovementAction { edit, delete }

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
  static const String _allCategories = 'all';
  _MovementTypeFilter _selectedTypeFilter = _MovementTypeFilter.all;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  String _selectedCategory = _allCategories;
  final Set<String> _collapsedDateGroups = {};
  bool _filtersExpanded = false;

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
    return _selectedMonth == 0 ? 'Todos' : monthNames[_selectedMonth - 1];
  }

  String get _selectedYearLabel {
    return _selectedYear == 0 ? 'Todos' : _selectedYear.toString();
  }

  CategoriaMovimiento? get _selectedCategoryValue {
    if (_selectedCategory == _allCategories) {
      return null;
    }

    return CategoriaMovimiento.values.firstWhere(
      (category) => category.name == _selectedCategory,
    );
  }

  String get _selectedCategoryLabel {
    return _selectedCategoryValue?.nombre ?? 'Todos';
  }

  List<CategoriaMovimiento> get _availableCategories {
    final selectedType = _selectedType;

    if (selectedType == null) {
      return const [];
    }

    return CategoriaMovimiento.values
        .where((category) => category.tipo == selectedType)
        .toList(growable: false);
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
        _selectedCategory != _allCategories ||
        _selectedMonth != 0 ||
        _selectedYear != 0;
  }

  int get _activeFilterCount {
    var count = 0;

    if (_selectedTypeFilter != _MovementTypeFilter.all) count++;
    if (_selectedMonth != 0) count++;
    if (_selectedYear != 0) count++;
    if (_selectedCategory != _allCategories) count++;

    return count;
  }

  List<Movimiento> get _filteredMovements {
    final selectedType = _selectedType;
    final selectedCategory = _selectedCategoryValue;

    final movements = widget.movements.where((movement) {
      final matchesType = selectedType == null || movement.tipo == selectedType;
      final matchesMonth =
          _selectedMonth == 0 || movement.fecha.month == _selectedMonth;
      final matchesYear =
          _selectedYear == 0 || movement.fecha.year == _selectedYear;
      final matchesCategory =
          selectedCategory == null || movement.categoria == selectedCategory;

      return matchesType && matchesMonth && matchesYear && matchesCategory;
    }).toList();

    movements.sort((a, b) {
      final dateComparison = b.fecha.compareTo(a.fecha);

      return dateComparison != 0
          ? dateComparison
          : b.fechaCreacion.compareTo(a.fechaCreacion);
    });

    return movements;
  }

  void _selectType(_MovementTypeFilter filter) {
    setState(() {
      _selectedTypeFilter = filter;
      _selectedCategory = _allCategories;
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

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedTypeFilter = _MovementTypeFilter.all;
      _selectedCategory = _allCategories;
      _selectedMonth = 0;
      _selectedYear = 0;
      _filtersExpanded = false;
    });
  }

  String _dateGroupLabel(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final movementDate = DateUtils.dateOnly(date);

    if (movementDate == today) {
      return 'Hoy';
    }

    if (movementDate == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    }

    return '${date.day} de ${monthNames[date.month - 1].toLowerCase()} de ${date.year}';
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
        _buildFiltersHeader(),
        if (_filtersExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: SelectionFilterMenu<_MovementTypeFilter>(
                        label: 'Tipo',
                        tooltip: 'Filtrar por tipo',
                        selectedValue: _selectedTypeFilter,
                        selectedLabel: _selectedTypeLabel,
                        options: [
                          for (final filter in _MovementTypeFilter.values)
                            SelectionOption(
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
                      child: SelectionFilterMenu<int>(
                        label: 'Mes',
                        tooltip: 'Filtrar por mes',
                        menuConstraints: const BoxConstraints(maxHeight: 320),
                        selectedValue: _selectedMonth,
                        selectedLabel: _selectedMonthLabel,
                        options: [
                          const SelectionOption(
                            value: 0,
                            label: 'Todos',
                            key: 'movement_month_filter_0',
                          ),
                          for (var month = 1; month <= 12; month++)
                            SelectionOption(
                              value: month,
                              label: monthNames[month - 1],
                              key: 'movement_month_filter_$month',
                            ),
                        ],
                        onSelected: _selectMonth,
                      ),
                    ),
                    Expanded(
                      child: SelectionFilterMenu<int>(
                        label: 'Año',
                        tooltip: 'Filtrar por año',
                        menuConstraints: const BoxConstraints(maxHeight: 320),
                        selectedValue: _selectedYear,
                        selectedLabel: _selectedYearLabel,
                        options: [
                          const SelectionOption(
                            value: 0,
                            label: 'Todos',
                            key: 'movement_year_filter_0',
                          ),
                          for (final year in _availableYears)
                            SelectionOption(
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
                const SizedBox(height: 8),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: SelectionFilterMenu<String>(
                        label: 'Categoría',
                        tooltip: 'Filtrar por categoría',
                        menuConstraints: const BoxConstraints(maxHeight: 320),
                        selectedValue: _selectedCategory,
                        selectedLabel: _selectedCategoryLabel,
                        options: [
                          const SelectionOption(
                            value: _allCategories,
                            label: 'Todos',
                            key: 'movement_category_filter_all',
                          ),
                          for (final category in _availableCategories)
                            SelectionOption(
                              value: category.name,
                              label: category.nombre,
                              key: 'movement_category_filter_${category.name}',
                            ),
                        ],
                        onSelected: _selectCategory,
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('clear_movement_filters'),
                      onPressed: _hasActiveFilters ? _clearFilters : null,
                      child: const Text('Limpiar consulta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
          child: _buildQuerySummary(filteredMovements),
        ),
        const Divider(height: 1),
        Expanded(
          child: filteredMovements.isEmpty
              ? _buildEmptyQueryState()
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: _buildGroupedMovements(filteredMovements),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyQueryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No encontramos movimientos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Probá modificando los filtros seleccionados.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const ValueKey('empty_clear_movement_filters'),
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpiar consulta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersHeader() {
    final activeFilterCount = _activeFilterCount;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        key: const ValueKey('movement_filters_header'),
        onTap: () {
          setState(() {
            _filtersExpanded = !_filtersExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activeFilterCount == 0
                      ? 'Filtros'
                      : 'Filtros · $activeFilterCount ${activeFilterCount == 1 ? 'activo' : 'activos'}',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Icon(
                _filtersExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuerySummary(List<Movimiento> movements) {
    var incomeInCents = 0;
    var expensesInCents = 0;

    for (final movement in movements) {
      if (movement.tipo == TipoMovimiento.ingreso) {
        incomeInCents += movement.montoEnCentavos;
      } else {
        expensesInCents += movement.montoEnCentavos;
      }
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQueryMetric(
              key: const ValueKey('movement_query_count'),
              icon: Icons.receipt_long_outlined,
              text: movements.length == 1
                  ? '1 resultado'
                  : '${movements.length} resultados',
            ),
          ),
          const VerticalDivider(width: 12, indent: 8, endIndent: 8),
          Expanded(
            child: _buildQueryMetric(
              key: const ValueKey('movement_query_income'),
              icon: Icons.arrow_downward,
              color: Colors.green,
              text: '+ \$ ${formatMontoEnCentavos(incomeInCents)}',
            ),
          ),
          const VerticalDivider(width: 12, indent: 8, endIndent: 8),
          Expanded(
            child: _buildQueryMetric(
              key: const ValueKey('movement_query_expenses'),
              icon: Icons.arrow_upward,
              color: Colors.red,
              text: '- \$ ${formatMontoEnCentavos(expensesInCents)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryMetric({
    required Key key,
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedMovements(List<Movimiento> movements) {
    final widgets = <Widget>[];
    final groups = <String, List<Movimiento>>{};

    for (final movement in movements) {
      final dateKey = _dateKey(movement.fecha);
      groups.putIfAbsent(dateKey, () => []).add(movement);
    }

    for (final entry in groups.entries) {
      final dateKey = entry.key;
      final groupMovements = entry.value;
      final date = groupMovements.first.fecha;
      final isCollapsed = _collapsedDateGroups.contains(dateKey);
      final count = groupMovements.length;

      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 4));
      }

      widgets.add(
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            key: ValueKey('movement_date_header_$dateKey'),
            onTap: () {
              setState(() {
                if (isCollapsed) {
                  _collapsedDateGroups.remove(dateKey);
                } else {
                  _collapsedDateGroups.add(dateKey);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_dateGroupLabel(date)} · $count ${count == 1 ? 'movimiento' : 'movimientos'}',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (isCollapsed) {
        continue;
      }

      for (final movement in groupMovements) {
        widgets
          ..add(_buildMovementTile(movement))
          ..add(const Divider(height: 1));
      }
    }

    return widgets;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${_formatDate(date)} $hour:$minute';
  }

  Future<void> _showMovementDetails(Movimiento movement) async {
    final isIncome = movement.tipo == TipoMovimiento.ingreso;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final description = movement.descripcion?.trim();
    final shouldEdit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalle del movimiento',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withAlpha(32),
                      foregroundColor: color,
                      child: Icon(
                        categoriaMovimientoIcon(movement.categoria),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movement.categoria.nombre,
                            style: Theme.of(sheetContext).textTheme.titleMedium,
                          ),
                          Text(isIncome ? 'Ingreso' : 'Gasto'),
                        ],
                      ),
                    ),
                    Text(
                      '$sign \$ ${formatMontoEnCentavos(movement.montoEnCentavos)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context: sheetContext,
                  icon: Icons.notes_outlined,
                  label: 'Descripción',
                  value: description == null || description.isEmpty
                      ? 'Sin descripción'
                      : description,
                ),
                _buildDetailRow(
                  context: sheetContext,
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha del movimiento',
                  value: _formatDate(movement.fecha),
                ),
                _buildDetailRow(
                  context: sheetContext,
                  icon: Icons.schedule_outlined,
                  label: 'Fecha de creación',
                  value: _formatDateTime(movement.fechaCreacion),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Cerrar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldEdit == true) {
      widget.onMovementTap?.call(movement);
    }
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementTile(Movimiento movement) {
    final isIncome = movement.tipo == TipoMovimiento.ingreso;
    final description = movement.descripcion?.trim();
    final amountColor = isIncome ? Colors.green : Colors.red;
    final amountSign = isIncome ? '+' : '-';

    return ListTile(
      onTap: () => _showMovementDetails(movement),
      leading: CircleAvatar(
        backgroundColor: amountColor.withAlpha(32),
        foregroundColor: amountColor,
        child: Icon(categoriaMovimientoIcon(movement.categoria)),
      ),
      title: Text(
        description == null || description.isEmpty
            ? movement.categoria.nombre
            : description,
      ),
      subtitle: Text(movement.categoria.nombre),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$amountSign \$ ${formatMontoEnCentavos(movement.montoEnCentavos)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<_MovementAction>(
            tooltip: 'Acciones del movimiento',
            onSelected: (action) {
              switch (action) {
                case _MovementAction.edit:
                  widget.onMovementTap?.call(movement);
                case _MovementAction.delete:
                  widget.onDeleteMovement?.call(movement);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                key: ValueKey('movement_action_edit'),
                value: _MovementAction.edit,
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                key: ValueKey('movement_action_delete'),
                value: _MovementAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Eliminar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}
