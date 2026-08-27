import 'package:flutter/material.dart';

class SelectionOption<T> {
  const SelectionOption({
    required this.value,
    required this.label,
    required this.key,
    this.icon,
  });

  final T value;
  final String label;
  final String key;
  final IconData? icon;
}

class SelectionFilterMenu<T> extends StatelessWidget {
  const SelectionFilterMenu({
    super.key,
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
  final List<SelectionOption<T>> options;
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
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(option.label),
              ],
            ),
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
