import 'package:flutter/material.dart';
import '../models/income.dart';
import '../services/database_helper.dart';
import '../utils/currency_formatter.dart';
import 'add_income_screen.dart';

class IncomesScreen extends StatefulWidget {
  const IncomesScreen({super.key});

  @override
  State<IncomesScreen> createState() => _IncomesScreenState();
}

class _IncomesScreenState extends State<IncomesScreen> {
  List<Income> _incomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    setState(() => _isLoading = true);
    final incomes = await DatabaseHelper.instance.getIncomes();
    setState(() {
      _incomes = incomes;
      _isLoading = false;
    });
  }

  Future<void> _deleteIncome(int id) async {
    await DatabaseHelper.instance.deleteIncome(id);
    _loadIncomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _incomes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma receita registrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicione sua primeira receita',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _incomes.length,
                  itemBuilder: (context, index) {
                    final income = _incomes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Icon(
                            _getIconForSource(income.source),
                            color: Colors.green[700],
                          ),
                        ),
                        title: Text(
                          income.source,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          income.description ?? 'Sem descrição',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(income.value),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${income.date.day}/${income.date.month}/${income.date.year}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onLongPress: () => _showDeleteDialog(income),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddIncomeScreen(
                onIncomeAdded: _loadIncomes,
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIconForSource(String source) {
    switch (source) {
      case 'Salário':
        return Icons.work;
      case 'Freelance':
        return Icons.computer;
      case 'Investimentos':
        return Icons.trending_up;
      case 'Vendas':
        return Icons.shopping_cart;
      default:
        return Icons.attach_money;
    }
  }

  void _showDeleteDialog(Income income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text('Deseja excluir a receita de ${income.source}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIncome(income.id!);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
