import 'package:flutter/material.dart';

import '../models/categoria_movimiento.dart';
import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import '../utils/monto_parser.dart';

class NewMovementScreen extends StatefulWidget {
  const NewMovementScreen({super.key, this.initialMovement});

  final Movimiento? initialMovement;

  @override
  State<NewMovementScreen> createState() => _NewMovementScreenState();
}

class _NewMovementScreenState extends State<NewMovementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late TipoMovimiento _selectedType;
  late CategoriaMovimiento _selectedCategory;
  late DateTime _selectedDate;

  bool get _isEditing => widget.initialMovement != null;

  @override
  void initState() {
    super.initState();

    final movement = widget.initialMovement;
    _selectedType = movement?.tipo ?? TipoMovimiento.gasto;
    _selectedCategory = movement?.categoria ?? CategoriaMovimiento.alimentos;
    _selectedDate = movement?.fecha ?? DateTime.now();
    _amountController = TextEditingController(
      text: movement == null
          ? ''
          : _formatAmountForInput(movement.montoEnCentavos),
    );
    _descriptionController = TextEditingController(
      text: movement?.descripcion ?? '',
    );
  }

  String _formatAmountForInput(int amountInCents) {
    final pesos = amountInCents ~/ 100;
    final cents = (amountInCents % 100).toString().padLeft(2, '0');

    return '$pesos,$cents';
  }

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

  String? _validateAmount(String? value) {
    final amountText = value?.trim() ?? '';

    if (amountText.isEmpty) {
      return 'Ingresá un monto.';
    }

    final validFormat = RegExp(r'^\d+(?:[.,]\d{1,2})?$');

    if (!validFormat.hasMatch(amountText)) {
      return 'Ingresá un monto válido con hasta dos decimales.';
    }

    final amount = double.parse(amountText.replaceAll(',', '.'));

    if (amount <= 0) {
      return 'El monto debe ser mayor que cero.';
    }

    return null;
  }

  String get _formattedDate {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');

    return '$day/$month/${_selectedDate.year}';
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  void _saveMovement() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final description = _descriptionController.text.trim();
    final initialMovement = widget.initialMovement;
    final movement = Movimiento(
      id: initialMovement?.id,
      tipo: _selectedType,
      montoEnCentavos: parseMontoEnCentavos(_amountController.text),
      categoria: _selectedCategory,
      descripcion: description.isEmpty ? null : description,
      fecha: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      fechaCreacion: initialMovement?.fechaCreacion,
    );

    Navigator.of(context).pop(movement);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar movimiento' : 'Nuevo movimiento'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
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
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: _validateAmount,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixText: r'$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_formattedDate),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 200,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveMovement,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_isEditing ? 'Guardar cambios' : 'Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
