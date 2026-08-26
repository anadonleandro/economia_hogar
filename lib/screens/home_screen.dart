import 'package:flutter/material.dart';

import '../constants/month_names.dart';
import '../models/resumen_mensual.dart';
import '../utils/monto_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.summary, required this.period});

  final ResumenMensual summary;
  final DateTime period;

  String _formatCurrency(int amountInCents) {
    final sign = amountInCents < 0 ? '- ' : '';

    return '$sign\$ ${formatMontoEnCentavos(amountInCents.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final periodName = '${monthNames[period.month - 1]} ${period.year}';
    final balanceColor = summary.saldoEnCentavos < 0
        ? Colors.red
        : Colors.green;
    final movementCountText = summary.cantidadMovimientos == 1
        ? '1 movimiento en el mes'
        : '${summary.cantidadMovimientos} movimientos en el mes';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(periodName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.green),
            title: const Text('Ingresos'),
            trailing: Text(
              _formatCurrency(summary.ingresosEnCentavos),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: const Text('Gastos'),
            trailing: Text(
              _formatCurrency(summary.gastosEnCentavos),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet, color: balanceColor),
            title: const Text('Saldo'),
            trailing: Text(
              _formatCurrency(summary.saldoEnCentavos),
              style: TextStyle(
                color: balanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(movementCountText),
        if (summary.cantidadMovimientos == 0) ...[
          const SizedBox(height: 24),
          const Center(child: Text('Todavía no hay movimientos.')),
        ],
      ],
    );
  }
}
