import 'package:flutter/material.dart';

import '../models/categoria_movimiento.dart';
import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import '../utils/categoria_movimiento_icon.dart';
import '../utils/monto_parser.dart';

enum _UnsavedChangesAction { keepEditing, discard, save }

class NewMovementScreen extends StatefulWidget {
  const NewMovementScreen({super.key, this.initialMovement, this.initialType})
    : assert(initialMovement == null || initialType == null);

  final Movimiento? initialMovement;
  final TipoMovimiento? initialType;

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
  late final TipoMovimiento _initialType;
  late final CategoriaMovimiento _initialCategory;
  late final DateTime _initialDate;
  late final String _initialAmountText;
  late final String _initialDescriptionText;
  bool _canLeave = false;

  bool get _isEditing => widget.initialMovement != null;
  bool get _isTypeLocked => widget.initialType != null && !_isEditing;

  @override
  void initState() {
    super.initState();

    final movement = widget.initialMovement;
    _selectedType =
        movement?.tipo ?? widget.initialType ?? TipoMovimiento.gasto;
    _selectedCategory =
        movement?.categoria ??
        CategoriaMovimiento.values.firstWhere(
          (category) => category.tipo == _selectedType,
        );
    _selectedDate = movement?.fecha ?? DateTime.now();
    _amountController = TextEditingController(
      text: movement == null
          ? ''
          : _formatAmountForInput(movement.montoEnCentavos),
    );
    _descriptionController = TextEditingController(
      text: movement?.descripcion ?? '',
    );
    _amountController.addListener(_handleTextChanged);
    _descriptionController.addListener(_handleTextChanged);
    _initialType = _selectedType;
    _initialCategory = _selectedCategory;
    _initialDate = DateUtils.dateOnly(_selectedDate);
    _initialAmountText = _amountController.text;
    _initialDescriptionText = _descriptionController.text;
  }

  bool get _hasUnsavedChanges {
    return _selectedType != _initialType ||
        _selectedCategory != _initialCategory ||
        !DateUtils.isSameDay(_selectedDate, _initialDate) ||
        _amountController.text != _initialAmountText ||
        _descriptionController.text != _initialDescriptionText;
  }

  void _handleTextChanged() {
    setState(() {});
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

  void _selectType(TipoMovimiento selectedType) {
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

    _leaveScreen(movement);
  }

  void _leaveScreen([Movimiento? movement]) {
    setState(() {
      _canLeave = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop(movement);
      }
    });
  }

  Future<void> _handlePopAttempt(bool didPop) async {
    if (didPop || !_hasUnsavedChanges) {
      return;
    }

    final action = await showDialog<_UnsavedChangesAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text(
            'Realizaste cambios en el movimiento. ¿Qué querés hacer?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(_UnsavedChangesAction.keepEditing),
              child: const Text('Seguir editando'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(_UnsavedChangesAction.discard),
              child: const Text('Salir sin guardar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_UnsavedChangesAction.save),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case _UnsavedChangesAction.discard:
        _leaveScreen();
        return;
      case _UnsavedChangesAction.save:
        _saveMovement();
        return;
      case _UnsavedChangesAction.keepEditing:
      case null:
        return;
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_handleTextChanged);
    _descriptionController.removeListener(_handleTextChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movementColor = _selectedType == TipoMovimiento.gasto
        ? Colors.red
        : Colors.green;

    return PopScope<Movimiento>(
      canPop: _canLeave || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) => _handlePopAttempt(didPop),
      child: Scaffold(
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
                  Row(
                    children: [
                      _buildTypeButton(
                        type: TipoMovimiento.gasto,
                        label: 'Gasto',
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 12),
                      _buildTypeButton(
                        type: TipoMovimiento.ingreso,
                        label: 'Ingreso',
                        icon: Icons.savings_outlined,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _amountController,
                    style: Theme.of(context).textTheme.titleLarge,
                    cursorColor: movementColor,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: _validateAmount,
                    decoration: InputDecoration(
                      labelText: 'Importe',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(color: movementColor),
                      prefixIcon: Center(
                        widthFactor: 1,
                        child: Text(
                          r'$',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: movementColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      filled: true,
                      fillColor: movementColor.withAlpha(12),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: movementColor.withAlpha(140),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: movementColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownMenu<CategoriaMovimiento>(
                    key: ValueKey(_selectedType),
                    expandedInsets: EdgeInsets.zero,
                    initialSelection: _selectedCategory,
                    label: const Text('Categoría'),
                    dropdownMenuEntries: _availableCategories.map((category) {
                      return DropdownMenuEntry(
                        value: category,
                        label: category.nombre,
                        leadingIcon: Icon(categoriaMovimientoIcon(category)),
                      );
                    }).toList(),
                    onSelected: _selectCategory,
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
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                key: const ValueKey('save_movement_button'),
                onPressed: _saveMovement,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isEditing ? 'Guardar cambios' : 'Guardar'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required TipoMovimiento type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    final isEnabled = !_isTypeLocked || isSelected;

    return Expanded(
      child: SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          key: ValueKey('movement_type_${type.name}'),
          onPressed: isEnabled ? () => _selectType(type) : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            disabledForegroundColor: color.withAlpha(96),
            backgroundColor: isSelected ? color.withAlpha(24) : null,
            side: BorderSide(color: color, width: isSelected ? 2 : 1),
          ),
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}
