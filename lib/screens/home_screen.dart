import 'package:flutter/material.dart';

import '../constants/month_names.dart';
import '../models/movimiento.dart';
import '../models/resumen_mensual.dart';
import '../models/tipo_movimiento.dart';
import '../utils/monto_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.summary,
    required this.period,
    required this.selectedDate,
    required this.selectedDayMovements,
    required this.canSelectPreviousDay,
    required this.canSelectNextDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onMovementTap,
  });

  final ResumenMensual summary;
  final DateTime period;
  final DateTime selectedDate;
  final List<Movimiento> selectedDayMovements;
  final bool canSelectPreviousDay;
  final bool canSelectNextDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final ValueChanged<Movimiento> onMovementTap;

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
    final selectedDateText =
        '${selectedDate.day} de ${monthNames[selectedDate.month - 1].toLowerCase()} de ${selectedDate.year}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(periodName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _buildBalanceCard(
          amount: summary.saldoEnCentavos,
          color: balanceColor,
          footerText: _countLabel(
            summary.cantidadMovimientos,
            singular: 'movimiento en el mes',
            plural: 'movimientos en el mes',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.savings_outlined,
                label: 'Ingresos',
                amount: summary.ingresosEnCentavos,
                color: Colors.green,
                addTooltip: 'Agregar ingreso',
                onAdd: onAddIncome,
                footerText: _countLabel(
                  summary.cantidadIngresos,
                  singular: 'ingreso en el mes',
                  plural: 'ingresos en el mes',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.shopping_bag_outlined,
                label: 'Gastos',
                amount: summary.gastosEnCentavos,
                color: Colors.red,
                addTooltip: 'Agregar gasto',
                onAdd: onAddExpense,
                footerText: _countLabel(
                  summary.cantidadGastos,
                  singular: 'gasto en el mes',
                  plural: 'gastos en el mes',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Movimientos del día',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.outlined(
                  onPressed: canSelectPreviousDay ? onPreviousDay : null,
                  tooltip: 'Día anterior',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_left),
                ),
                const SizedBox(width: 4),
                IconButton.outlined(
                  onPressed: canSelectNextDay ? onNextDay : null,
                  tooltip: 'Día siguiente',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TodayMovementsCard(
          movements: selectedDayMovements,
          selectedDateText: selectedDateText,
          onMovementTap: onMovementTap,
        ),
      ],
    );
  }

  String _countLabel(
    int count, {
    required String singular,
    required String plural,
  }) {
    return '$count ${count == 1 ? singular : plural}';
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required int amount,
    required Color color,
    required String addTooltip,
    required VoidCallback onAdd,
    required String footerText,
  }) {
    return SizedBox(
      height: 148,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withAlpha(32),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 30),
                        ),
                        IconButton.filled(
                          onPressed: onAdd,
                          tooltip: addTooltip,
                          style: IconButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                          ),
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(label),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCardFooter(footerText),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard({
    required int amount,
    required Color color,
    required String footerText,
  }) {
    return SizedBox(
      height: 148,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withAlpha(32),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: color,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saldo'),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(amount),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCardFooter(footerText),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFooter(String text) {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _TodayMovementsCard extends StatefulWidget {
  const _TodayMovementsCard({
    required this.movements,
    required this.selectedDateText,
    required this.onMovementTap,
  });

  final List<Movimiento> movements;
  final String selectedDateText;
  final ValueChanged<Movimiento> onMovementTap;

  @override
  State<_TodayMovementsCard> createState() => _TodayMovementsCardState();
}

class _TodayMovementsCardState extends State<_TodayMovementsCard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: widget.movements.isEmpty
                  ? const Center(
                      child: Text('No hay movimientos registrados este día.'),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: widget.movements.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _buildMovementTile(widget.movements[index]),
                      ),
                    ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 39,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.movements.length == 1
                            ? '${widget.selectedDateText} · 1 movimiento'
                            : '${widget.selectedDateText} · ${widget.movements.length} movimientos',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementTile(Movimiento movement) {
    final isIncome = movement.tipo == TipoMovimiento.ingreso;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final description = movement.descripcion?.trim();
    final date = movement.fecha;
    final formattedDate = [
      date.day.toString().padLeft(2, '0'),
      date.month.toString().padLeft(2, '0'),
      date.year.toString(),
    ].join('/');

    return SizedBox(
      height: 58,
      child: ListTile(
        dense: true,
        onTap: () => widget.onMovementTap(movement),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(32),
          foregroundColor: color,
          child: Icon(isIncome ? Icons.south_west : Icons.north_east),
        ),
        title: Text(
          description == null || description.isEmpty
              ? movement.categoria.nombre
              : description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${movement.categoria.nombre} · $formattedDate'),
        trailing: Text(
          '$sign \$ ${formatMontoEnCentavos(movement.montoEnCentavos)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
