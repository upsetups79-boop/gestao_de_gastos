import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class MonthSelector extends StatelessWidget {
    final DateTime selectedMonth;
    final ValueChanged<DateTime> onMonthChanged;

    const MonthSelector({
      super.key,
      required this.selectedMonth,
      required this.onMonthChanged,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onMonthChanged(
                  DateTime(selectedMonth.year, selectedMonth.month - 1, 1)),
            ),
            Text(
              CurrencyFormatter.formatMonth(selectedMonth),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onMonthChanged(
                  DateTime(selectedMonth.year, selectedMonth.month + 1, 1)),
            ),
          ],
        ),
      );
    }
  }