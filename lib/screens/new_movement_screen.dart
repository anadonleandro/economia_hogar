import 'package:flutter/material.dart';

import '../models/tipo_movimiento.dart';

class NewMovementScreen extends StatefulWidget {
  const NewMovementScreen({super.key});

  @override
  State<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends State<NewMovementScreen> {
  TipoMovimiento _selectedType = TipoMovimiento.gasto;

  void _selectType(Set<TipoMovimiento> selection) {
    setState(() {
      _selectedType = selection.first;
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
          ],
        ),
      ),
    );
  }
}
