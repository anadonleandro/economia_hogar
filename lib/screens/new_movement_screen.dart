import 'package:flutter/material.dart';

import '../models/categoria_movimiento.dart';
import '../models/tipo_movimiento.dart';

class NewMovementScreen extends StatefulWidget {
  const NewMovementScreen({super.key});

  @override
  State<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends State<NewMovementScreen> {
  TipoMovimiento _selectedType = TipoMovimiento.gasto;
  CategoriaMovimiento _selectedCategory = CategoriaMovimiento.alimentos;

  List<CategoriaMovimiento> get _availableCategories {
    return CategoriaMovimiento.values
        .where((category) => category.tipo == _selectedType)
        .toList();
  }

  void _selectType(Set<TipoMovimiento> selection) {
    final selectedType = selection.first;

    setState(() {
      _selectedType = selectedType;
      _selectedCategory = CategoriaMovimiento.values.firstWhere(
        (category) => category.tipo == selectedType,
      );
    });
  }

  void _selectCategory(CategoriaMovimiento? category) {
    if (category == null) {
      return;
    }

    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo movimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de movimiento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<TipoMovimiento>(
              segments: const [
                ButtonSegment(
                  value: TipoMovimiento.gasto,
                  label: Text('Gasto'),
                  icon: Icon(Icons.remove_circle_outline),
                ),
                ButtonSegment(
                  value: TipoMovimiento.ingreso,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: _selectType,
            ),
            const SizedBox(height: 24),
            DropdownMenu<CategoriaMovimiento>(
              key: ValueKey(_selectedType),
              initialSelection: _selectedCategory,
              label: const Text('Categoría'),
              dropdownMenuEntries: _availableCategories.map((category) {
                return DropdownMenuEntry(
                  value: category,
                  label: category.nombre,
                );
              }).toList(),
              onSelected: _selectCategory,
            ),
          ],
        ),
      ),
    );
  }
}
