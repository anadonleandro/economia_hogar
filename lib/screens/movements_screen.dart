import 'package:flutter/material.dart';

import '../models/movimiento.dart';
import '../models/tipo_movimiento.dart';
import '../utils/monto_formatter.dart';

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key, required this.movements});

  final List<Movimiento> movements;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const Center(
        child: Text('Todavía no hay movimientos registrados.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: movements.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final movement = movements[index];
        final isIncome = movement.tipo == TipoMovimiento.ingreso;
        final description = movement.descripcion?.trim();
        final amountColor = isIncome ? Colors.green : Colors.red;
        final amountSign = isIncome ? '+' : '-';

        return ListTile(
          leading: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: amountColor,
          ),
          title: Text(
            description == null || description.isEmpty
                ? movement.categoria.nombre
                : description,
          ),
          subtitle: Text(
            '${movement.categoria.nombre} · ${_formatDate(movement.fecha)}',
          ),
          trailing: Text(
            '$amountSign \$ ${formatMontoEnCentavos(movement.montoEnCentavos)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
