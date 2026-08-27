import 'package:flutter/material.dart';

import '../data/movimiento_repository.dart';
import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import '../services/resumen_mensual_calculator.dart';
import 'about_screen.dart';
import 'home_screen.dart';
import 'movements_screen.dart';
import 'new_movement_screen.dart';
import 'summary_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.movementRepository,
    this.movementsLoader,
    this.darkModeEnabled = false,
    this.onDarkModeChanged,
  });

  final MovimientoRepository? movementRepository;
  final Future<List<Movimiento>> Function()? movementsLoader;
  final bool darkModeEnabled;
  final ValueChanged<bool>? onDarkModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const ResumenMensualCalculator _summaryCalculator =
      ResumenMensualCalculator();

  final List<Movimiento> _movements = [];

  int _selectedIndex = 0;
  int _homeResetVersion = 0;
  DateTime _selectedHomeDate = DateUtils.dateOnly(DateTime.now());
  bool _isLoadingMovements = false;
  String? _loadErrorMessage;

  static const List<String> _titles = ['Inicio', 'Movimientos', 'Resumen'];

  @override
  void initState() {
    super.initState();
    _isLoadingMovements =
        widget.movementRepository != null || widget.movementsLoader != null;
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    final repository = widget.movementRepository;
    final loader = widget.movementsLoader ?? repository?.obtenerTodos;

    if (loader == null) {
      return;
    }

    setState(() {
      _isLoadingMovements = true;
      _loadErrorMessage = null;
    });

    try {
      final movements = await loader();

      if (!mounted) {
        return;
      }

      setState(() {
        _movements
          ..clear()
          ..addAll(movements);
        _isLoadingMovements = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMovements = false;
        _loadErrorMessage = 'No se pudieron cargar los movimientos.';
      });
    }
  }

  Widget _buildBody() {
    if (_isLoadingMovements) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando movimientos...'),
          ],
        ),
      );
    }

    final loadErrorMessage = _loadErrorMessage;

    if (loadErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(loadErrorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadMovements,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return _screens[_selectedIndex];
  }

  List<Widget> get _screens {
    final currentPeriod = DateTime.now();
    final selectedDayMovements =
        _movements
            .where(
              (movement) =>
                  movement.fecha.year == _selectedHomeDate.year &&
                  movement.fecha.month == _selectedHomeDate.month &&
                  movement.fecha.day == _selectedHomeDate.day,
            )
            .toList()
          ..sort((a, b) {
            final dateComparison = b.fecha.compareTo(a.fecha);

            return dateComparison != 0
                ? dateComparison
                : b.fechaCreacion.compareTo(a.fechaCreacion);
          });
    final summary = _summaryCalculator.calcular(
      movimientos: _movements,
      anio: currentPeriod.year,
      mes: currentPeriod.month,
    );

    return [
      HomeScreen(
        key: ValueKey(_homeResetVersion),
        summary: summary,
        period: currentPeriod,
        selectedDate: _selectedHomeDate,
        selectedDayMovements: selectedDayMovements,
        canSelectPreviousDay: _selectedHomeDate.day > 1,
        canSelectNextDay: !_isToday(_selectedHomeDate),
        onPreviousDay: _selectPreviousHomeDay,
        onNextDay: _selectNextHomeDay,
        onAddIncome: () =>
            _openNewMovementForm(initialType: TipoMovimiento.ingreso),
        onAddExpense: () =>
            _openNewMovementForm(initialType: TipoMovimiento.gasto),
        onMovementTap: _editMovement,
      ),
      MovementsScreen(
        movements: List.unmodifiable(_movements),
        onMovementTap: _editMovement,
        onDeleteMovement: _confirmDeleteMovement,
      ),
      SummaryScreen(movements: List.unmodifiable(_movements)),
    ];
  }

  bool _isToday(DateTime date) {
    return DateUtils.isSameDay(date, DateTime.now());
  }

  void _selectPreviousHomeDay() {
    if (_selectedHomeDate.day == 1) {
      return;
    }

    setState(() {
      _selectedHomeDate = _selectedHomeDate.subtract(const Duration(days: 1));
    });
  }

  void _selectNextHomeDay() {
    if (_isToday(_selectedHomeDate)) {
      return;
    }

    setState(() {
      _selectedHomeDate = _selectedHomeDate.add(const Duration(days: 1));
    });
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        _selectedHomeDate = DateUtils.dateOnly(DateTime.now());
        _homeResetVersion++;
      }
    });
  }

  Future<void> _openAboutScreen() async {
    Navigator.of(context).pop();
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (context) => const AboutScreen()));
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Economía del Hogar',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Cerrar menú',
                      icon: const Icon(Icons.menu),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Modo nocturno'),
              value: widget.darkModeEnabled,
              onChanged: widget.onDarkModeChanged,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: _openAboutScreen,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNewMovementForm({TipoMovimiento? initialType}) async {
    await _openMovementForm(initialType: initialType);
  }

  Future<void> _editMovement(Movimiento movement) async {
    await _openMovementForm(initialMovement: movement);
  }

  Future<void> _confirmDeleteMovement(Movimiento movement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar movimiento'),
          content: const Text(
            '¿Querés eliminar este movimiento? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final repository = widget.movementRepository;

    if (repository == null) {
      setState(() {
        _movements.remove(movement);
      });
      return;
    }

    final id = movement.id;

    if (id == null) {
      _showMessage('No se pudo identificar el movimiento.');
      return;
    }

    try {
      final affectedRows = await repository.eliminar(id);

      if (affectedRows != 1) {
        throw StateError('No se encontró el movimiento para eliminar.');
      }

      final movements = await repository.obtenerTodos();

      if (!mounted) {
        return;
      }

      setState(() {
        _movements
          ..clear()
          ..addAll(movements);
      });
      _showMessage('Movimiento eliminado.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('No se pudo eliminar el movimiento.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openMovementForm({
    Movimiento? initialMovement,
    TipoMovimiento? initialType,
  }) async {
    final movement = await Navigator.of(context).push<Movimiento>(
      MaterialPageRoute(
        builder: (context) => NewMovementScreen(
          initialMovement: initialMovement,
          initialType: initialType,
        ),
      ),
    );

    if (movement == null || !mounted) {
      return;
    }

    final repository = widget.movementRepository;

    if (repository == null) {
      setState(() {
        final index = _movements.indexWhere((item) => item.id == movement.id);

        if (movement.id != null && index != -1) {
          _movements[index] = movement;
        } else {
          _movements.add(movement);
        }
        _selectedIndex = 1;
      });
      return;
    }

    try {
      if (movement.id == null) {
        await repository.insertar(movement);
      } else {
        await repository.actualizar(movement);
      }
      final movements = await repository.obtenerTodos();

      if (!mounted) {
        return;
      }

      setState(() {
        _movements
          ..clear()
          ..addAll(movements);
        _selectedIndex = 1;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el movimiento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 1)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filled(
                onPressed: () => _openNewMovementForm(),
                tooltip: 'Nuevo movimiento',
                icon: const Icon(Icons.add),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Movimientos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Resumen',
          ),
        ],
      ),
    );
  }
}
