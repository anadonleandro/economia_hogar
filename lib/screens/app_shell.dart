import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import 'home_screen.dart';
import 'movements_screen.dart';
import 'new_movement_screen.dart';
import 'summary_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<Movimiento> _movements = [];

  int _selectedIndex = 0;

  static const List<String> _titles = ['Inicio', 'Movimientos', 'Resumen'];

  List<Widget> get _screens => [
    const HomeScreen(),
    MovementsScreen(movements: List.unmodifiable(_movements)),
    const SummaryScreen(),
  ];

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

    setState(() {
      _movements.add(movement);
      _selectedIndex = 1;
    });
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
