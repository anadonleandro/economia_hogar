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
      MovementsScreen(movements: List.unmodifiable(_movements)),
      const SummaryScreen(),
    ];
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openNewMovementForm() async {
    final movement = await Navigator.of(context).push<Movimiento>(
      MaterialPageRoute(builder: (context) => const NewMovementScreen()),
    );

    if (movement == null || !mounted) {
      return;
    }

    final repository = widget.movementRepository;

    if (repository == null) {
      setState(() {
        _movements.add(movement);
        _selectedIndex = 1;
      });
      return;
    }

    try {
      await repository.insertar(movement);
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
