import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../services/export_service.dart';
import '../services/pdf_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/expense_card.dart';
import '../widgets/monthly_chart.dart';
import '../widgets/month_selector.dart';
import 'add_expense_screen.dart';
import 'categories_screen.dart';
import 'filter_screen.dart';
import 'incomes_screen.dart';
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
    double _totalIncome = 0;
    double _totalToday = 0;
    double _totalWeek = 0;
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

      final now = DateTime.now();
      final startOfMonth = _selectedMonth;
      final endOfMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
      final startOfLastMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
      final endOfLastMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month, 0, 23, 59, 59);
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6, 23, 59, 59);

      final allExpenses = await DatabaseHelper.instance.getExpenses();
      final currentMonthData = await DatabaseHelper.instance
          .getExpensesByDateRange(startOfMonth, endOfMonth);
      final lastMonthData = await DatabaseHelper.instance
          .getExpensesByDateRange(startOfLastMonth, endOfLastMonth);
      final currentMonthIncome = await DatabaseHelper.instance
          .getIncomesByDateRange(startOfMonth, endOfMonth);
      final todayData = await DatabaseHelper.instance
          .getExpensesByDateRange(startOfDay, endOfDay);
      final weekData = await DatabaseHelper.instance
          .getExpensesByDateRange(startOfWeekDay, endOfWeek);

      final totalCurrent =
          currentMonthData.fold(0.0, (sum, item) => sum + item.value);
      final totalLast =
          lastMonthData.fold(0.0, (sum, item) => sum + item.value);
      final totalIncome =
          currentMonthIncome.fold(0.0, (sum, item) => sum + item.value);
      final totalToday =
          todayData.fold(0.0, (sum, item) => sum + item.value);
      final totalWeek =
          weekData.fold(0.0, (sum, item) => sum + item.value);

      if (mounted) {
        setState(() {
          _allExpenses = allExpenses;
          _monthExpenses = currentMonthData;
          _totalMonth = totalCurrent;
          _totalLastMonth = totalLast;
          _totalIncome = totalIncome;
          _totalToday = totalToday;
          _totalWeek = totalWeek;
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
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtros',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FilterScreen()),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'pdf') {
                  PdfService.generateExpenseReport(
                      _monthExpenses, _totalMonth);
                } else if (value == 'csv') {
                  final incomes =
                      await DatabaseHelper.instance.getIncomes();
                  await ExportService.exportAllToCSV(
                      _monthExpenses, incomes);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('Exportar PDF'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'csv',
                  child: ListTile(
                    leading: Icon(Icons.table_chart),
                    title: Text('Exportar CSV'),
                  ),
                ),
              ],
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
                        _buildQuickStats(),
                        const SizedBox(height: 20),
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
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet), label: 'Receitas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.subscriptions), label: 'Assinaturas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.track_changes), label: 'Metas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label: 'Categorias'),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const IncomesScreen()));
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SubscriptionsScreen()));
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GoalsScreen()));
            } else if (index == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()));
            }
          },
        ),
      );
    }

    Widget _buildSummaryCard() {
      final balance = _totalIncome - _totalMonth;
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
                'Saldo em ${CurrencyFormatter.formatMonth(_selectedMonth)}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(CurrencyFormatter.format(balance),
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.white : Colors.red[200])),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Receitas',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70)),
                        Text(CurrencyFormatter.format(_totalIncome),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Despesas',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70)),
                        Text(CurrencyFormatter.format(_totalMonth),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
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

    Widget _buildQuickStats() {
      return Row(
        children: [
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text('Hoje',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(CurrencyFormatter.format(_totalToday),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700])),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.orange[700],
                            size: 20),
                        const SizedBox(width: 8),
                        Text('Semana',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(CurrencyFormatter.format(_totalWeek),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700])),
                  ],
                ),
              ),
            ),
          ),
        ],
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