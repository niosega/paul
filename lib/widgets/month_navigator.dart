import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthNavigator({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(
            DateTime(selectedMonth.year, selectedMonth.month - 1),
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(selectedMonth),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: isCurrentMonth
              ? null
              : () => onChanged(
                    DateTime(selectedMonth.year, selectedMonth.month + 1),
                  ),
        ),
      ],
    );
  }
}
