
  import 'package:flutter/material.dart';
  import '../models/expense.dart';                                                                                        import '../utils/app_styles.dart';
  import '../utils/currency_formatter.dart';                                                                            
  class ExpenseCard extends StatelessWidget {
    final Expense expense;
    final VoidCallback onDelete;

    const ExpenseCard({super.key, required this.expense, required this.onDelete});

    @override
    Widget build(BuildContext context) {
      final color = AppStyles.getColor(expense.category);
      final icon = AppStyles.getIcon(expense.category);

      return Dismissible(
        key: Key(expense.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => onDelete(),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description?.isNotEmpty == true
                            ? expense.description!
                            : expense.category[0].toUpperCase() +
                                expense.category.substring(1),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatDate(expense.date),
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(expense.value),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }