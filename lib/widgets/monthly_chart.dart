
  import 'package:flutter/material.dart';                                                                                 import 'package:fl_chart/fl_chart.dart';
  import '../models/expense.dart';                                                                                        import '../utils/app_styles.dart';

  class MonthlyChartWidget extends StatelessWidget {
    final List<Expense> expenses;

    const MonthlyChartWidget({super.key, required this.expenses});

    @override
    Widget build(BuildContext context) {
      if (expenses.isEmpty) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 180,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('Sem dados para o gráfico',
                    style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              ],
            ),
          ),
        );
      }

      final Map<String, double> categoryTotals = {};
      for (var e in expenses) {
        categoryTotals[e.category] =
            (categoryTotals[e.category] ?? 0) + e.value;
      }

      final sections = categoryTotals.entries.map((entry) {
        return PieChartSectionData(
          color: AppStyles.getColor(entry.key),
          value: entry.value,
          title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList();

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Gastos por Categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                )),
              ),
            ],
          ),
        ),
      );
    }
  }