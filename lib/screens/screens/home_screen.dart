
  import 'package:flutter/material.dart';
  import '../models/expense.dart';
  import '../services/database_helper.dart';
  import '../services/pdf_service.dart';
  import '../utils/currency_formatter.dart';
  import '../widgets/expense_card.dart';
  import '../widgets/monthly_chart.dart';
  import '../widgets/month_selector.dart';
  import 'add_expense_screen.dart';
  import 'subscriptions_screen.dart';
  import 'goals_screen.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    List<Expense> _allExpenses = [];
    List<Expense> _monthExpenses = [];
    double _totalMonth = 0;
    double _totalLastMonth = 0;
    bool _isLoading = true;
    DateTime _selectedMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);

    @override
    void initState() {
      super.initState();
      _loadData();
    }

    Future<void> _loadData() async {
      setState(() => _isLoading = true);

      final startOfMonth = _selectedMonth;
      final endOfMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
      final startOfLastMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      final endOfLastMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month, 0, 23, 59, 59);

      final allExpenses = await DatabaseHelper.instance.getExpenses();
      final currentMonthData = await DatabaseHelper.instance
          .getExpensesByDateRange(startOfMonth, endOfMonth);
      final lastMonthData = await DatabaseHelper.instance
          .getExpensesByDateRange(startOfLastMonth, endOfLastMonth);

      final totalCurrent =
          currentMonthData.fold(0.0, (sum, item) => sum + item.value);
      final totalLast =
          lastMonthData.fold(0.0, (sum, item) => sum + item.value);

      if (mounted) {
        setState(() {
          _allExpenses = allExpenses;
          _monthExpenses = currentMonthData;
          _totalMonth = totalCurrent;
          _totalLastMonth = totalLast;
          _isLoading = false;
        });
      }
    }

    void _onMonthChanged(DateTime newMonth) {
      setState(() => _selectedMonth = newMonth);
      _loadData();
    }

    void _deleteExpense(int id) async {
      await DatabaseHelper.instance.deleteExpense(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gasto removido')));
      }
    }

    @override
    Widget build(BuildContext context) {
      final now = DateTime.now();
      final isCurrentMonth =
          _selectedMonth.year == now.year && _selectedMonth.month == now.month;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Gestão de Gastos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Exportar PDF',
              onPressed: () =>
                  PdfService.generateExpenseReport(_monthExpenses, _totalMonth),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonthSelector(
                        selectedMonth: _selectedMonth,
                        onMonthChanged: _onMonthChanged,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(),
                      const SizedBox(height: 20),
                      if (isCurrentMonth) ...[
                        _buildComparisonCard(),
                        const SizedBox(height: 20),
                      ],
                      MonthlyChartWidget(expenses: _monthExpenses),
                      const SizedBox(height: 20),
                      _buildRecentExpenses(),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddExpenseScreen(onExpenseAdded: _loadData)),
          ),
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.subscriptions), label: 'Assinaturas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.track_changes), label: 'Metas'),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SubscriptionsScreen()));
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GoalsScreen()));
            }
          },
        ),
      );
    }

    Widget _buildSummaryCard() {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total em ${CurrencyFormatter.formatMonth(_selectedMonth)}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(CurrencyFormatter.format(_totalMonth),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              if (_totalLastMonth > 0 && _totalMonth > _totalLastMonth * 1.2)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.yellowAccent, size: 20),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Alerta: 20% acima do mês passado!',
                          style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget _buildComparisonCard() {
      final difference = _totalMonth - _totalLastMonth;
      final percentage =
          _totalLastMonth > 0 ? (difference / _totalLastMonth * 100) : 100.0;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vs Mês Anterior',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(CurrencyFormatter.format(difference.abs()),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  difference > 0 ? Colors.red : Colors.green)),
                      const SizedBox(width: 8),
                      Text(
                          '${difference > 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                              color:
                                  difference > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Icon(
                  difference > 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: difference > 0 ? Colors.red : Colors.green,
                  size: 40),
            ],
          ),
        ),
      );
    }

    Widget _buildRecentExpenses() {
      if (_monthExpenses.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Nenhum gasto neste mês',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gastos do Mês',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${_monthExpenses.length} itens',
                  style: TextStyle(color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _monthExpenses.length,
            itemBuilder: (context, index) {
              final expense = _monthExpenses[index];
              return ExpenseCard(
                  expense: expense,
                  onDelete: () => _deleteExpense(expense.id!));
            },
          ),
        ],
      );
    }
  }
