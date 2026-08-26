import 'package:flutter/material.dart';

import '../data/movimiento_repository.dart';
import '../models/movimiento.dart';
import '../services/resumen_mensual_calculator.dart';
import 'home_screen.dart';
import 'movements_screen.dart';
import 'new_movement_screen.dart';
import 'summary_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.movementRepository});

  final MovimientoRepository? movementRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const ResumenMensualCalculator _summaryCalculator =
      ResumenMensualCalculator();

  final List<Movimiento> _movements = [];

  int _selectedIndex = 0;

  static const List<String> _titles = ['Inicio', 'Movimientos', 'Resumen'];

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    final repository = widget.movementRepository;

    if (repository == null) {
      return;
    }

    try {
      final movements = await repository.obtenerTodos();

      if (!mounted) {
        return;
      }

      setState(() {
        _movements
          ..clear()
          ..addAll(movements);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los movimientos.')),
      );
    }
  }

  List<Widget> get _screens {
    final currentPeriod = DateTime.now();
    final summary = _summaryCalculator.calcular(
      movimientos: _movements,
      anio: currentPeriod.year,
      mes: currentPeriod.month,
    );

    return [
      HomeScreen(summary: summary, period: currentPeriod),
      MovementsScreen(
        movements: List.unmodifiable(_movements),
        onMovementTap: _editMovement,
        onDeleteMovement: _confirmDeleteMovement,
      ),
      const SummaryScreen(),
    ];
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openNewMovementForm() async {
    await _openMovementForm();
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

  Future<void> _openMovementForm({Movimiento? initialMovement}) async {
    final movement = await Navigator.of(context).push<Movimiento>(
      MaterialPageRoute(
        builder: (context) =>
            NewMovementScreen(initialMovement: initialMovement),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titles[_selectedIndex]),
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewMovementForm,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
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
