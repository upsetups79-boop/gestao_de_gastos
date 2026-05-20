import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';
import '../utils/currency_formatter.dart';
import '../widgets/empty_state.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

    @override
    State<GoalsScreen> createState() => _GoalsScreenState();
  }

  class _GoalsScreenState extends State<GoalsScreen> {
    List<Goal> _goals = [];

    @override
    void initState() {
      super.initState();
      _loadGoals();
    }

    Future<void> _loadGoals() async {
      final goals = await DatabaseHelper.instance.getGoals();
      if (mounted) setState(() => _goals = goals);
    }

    void _deleteGoal(int id) async {
      await DatabaseHelper.instance.deleteGoal(id);
      _loadGoals();
    }

    void _showAddGoalDialog() {
      final nameC = TextEditingController();
      final targetC = TextEditingController();
      final currentC = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nova Meta'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetC,
                  decoration: const InputDecoration(
                    labelText: 'Meta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: currentC,
                  decoration: const InputDecoration(
                    labelText: 'Atual',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.isNotEmpty) {
                  DatabaseHelper.instance.insertGoal(Goal(
                    name: nameC.text,
                    targetValue: double.tryParse(targetC.text) ?? 0,
                    currentValue: double.tryParse(currentC.text) ?? 0,
                  ));
                  Navigator.pop(ctx);
                  _loadGoals();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Metas Financeiras')),
        body: _goals.isEmpty
            ? const EmptyState(
                icon: Icons.track_changes,
                title: 'Sem metas',
                subtitle: 'Crie metas para acompanhar seu progresso financeiro',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final progress = goal.targetValue == 0
                      ? 0.0
                      : goal.currentValue / goal.targetValue;
                  final percent = (progress * 100).clamp(0, 999);
                  final texto = CurrencyFormatter.format(goal.currentValue) +
                      ' de ' +
                      CurrencyFormatter.format(goal.targetValue) +
                      ' (' +
                      percent.toStringAsFixed(0) +
                      '%)';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(goal.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () => _deleteGoal(goal.id!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 10,
                              color: Colors.green,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            texto,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddGoalDialog,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
  }