import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; // Mudei aqui para evitar conflito
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

// ==========================================
// MODELOS
// ==========================================
class Expense {
  final int? id;
  final double value;
  final String category;
  final String? description;
  final DateTime date;

  Expense({
    this.id,
    required this.value,
    required this.category,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      value: (map['value'] as num).toDouble(),
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}

class Subscription {
  final int? id;
  final String name;
  final double value;
  final DateTime billDate;

  Subscription({
    this.id,
    required this.name,
    required this.value,
    required this.billDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'bill_date': billDate.toIso8601String(),
    };
  }

  static Subscription fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      value: (map['value'] as num).toDouble(),
      billDate: DateTime.parse(map['bill_date']),
    );
  }

  String nextBillDate() {
    return '${billDate.day.toString().padLeft(2, '0')}/${billDate.month.toString().padLeft(2, '0')}/${billDate.year}';
  }

  int daysUntilNextBill() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime nextBill = DateTime(today.year, today.month, billDate.day);
    
    if (nextBill.isBefore(today)) {
      nextBill = DateTime(today.year, today.month + 1, billDate.day);
    }
    
    return nextBill.difference(today).inDays;
  }
}

class Goal {
  final int? id;
  final String name;
  final double targetValue;
  final double currentValue;

  Goal({
    this.id,
    required this.name,
    required this.targetValue,
    required this.currentValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_value': targetValue,
      'current_value': currentValue,
    };
  }

  static Goal fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      targetValue: (map['target_value'] as num).toDouble(),
      currentValue: (map['current_value'] as num).toDouble(),
    );
  }
}

// ==========================================
// BANCO DE DADOS
// ==========================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_app_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    // Correção do conflito: usando p.join em vez de join direto
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        value REAL NOT NULL,
        bill_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_value REAL NOT NULL,
        current_value REAL NOT NULL
      )
    ''');
  }

  // CRUD Expenses
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Subscriptions
  Future<int> insertSubscription(Subscription subscription) async {
    final db = await instance.database;
    return await db.insert('subscriptions', subscription.toMap());
  }

  Future<List<Subscription>> getSubscriptions() async {
    final db = await instance.database;
    final maps = await db.query('subscriptions');
    return maps.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<int> deleteSubscription(int id) async {
    final db = await instance.database;
    return await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Goals
  Future<int> insertGoal(Goal goal) async {
    final db = await instance.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoals() async {
    final db = await instance.database;
    final maps = await db.query('goals');
    return maps.map((map) => Goal.fromMap(map)).toList();
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}

// ==========================================
// WIDGETS E TELAS
// ==========================================

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return "";
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  ExpenseCard({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: EdgeInsets.only(bottom: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(expense.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: _getCategoryColor(expense.category),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description != null && expense.description!.isNotEmpty 
                          ? expense.description! 
                          : expense.category.capitalize(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${expense.date.day.toString().padLeft(2,'0')}/${expense.date.month.toString().padLeft(2,'0')}/${expense.date.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                'R\$ ${expense.value.toStringAsFixed(2)}',
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação': return Icons.restaurant;
      case 'transporte': return Icons.directions_car;
      case 'contas': return Icons.receipt;
      case 'lazer': return Icons.movie;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação': return Colors.orange;
      case 'transporte': return Colors.blue;
      case 'contas': return Colors.red;
      case 'lazer': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class MonthlyChartWidget extends StatelessWidget {
  final List<Expense> expenses;

  MonthlyChartWidget({required this.expenses});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação': return Colors.orange;
      case 'transporte': return Colors.blue;
      case 'contas': return Colors.red;
      case 'lazer': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text("Sem dados para o gráfico", style: TextStyle(color: Colors.grey)),
      );
    }

    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.value;
    }

    final List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${entry.key.capitalize()}\n${entry.value.toStringAsFixed(0)}',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Gastos por Categoria", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _allExpenses = [];
  List<Expense> _monthExpenses = [];
  double _totalMonth = 0;
  double _totalLastMonth = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    final allExpenses = await DatabaseHelper.instance.getExpenses();
    final currentMonthData = await DatabaseHelper.instance.getExpensesByDateRange(startOfMonth, endOfMonth);
    final lastMonthData = await DatabaseHelper.instance.getExpensesByDateRange(startOfLastMonth, endOfLastMonth);

    final totalCurrent = currentMonthData.fold(0.0, (sum, item) => sum + item.value);
    final totalLast = lastMonthData.fold(0.0, (sum, item) => sum + item.value);

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

  void _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gasto removido')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestão de Gastos'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    SizedBox(height: 20),
                    _buildComparisonCard(),
                    SizedBox(height: 20),
                    MonthlyChartWidget(expenses: _monthExpenses),
                    SizedBox(height: 20),
                    _buildRecentExpenses(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddExpenseScreen(onExpenseAdded: _loadData)),
        ),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: 'Assinaturas'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Metas'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GoalsScreen()));
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
        padding: EdgeInsets.all(20),
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
            Text('Total Gasto este Mês', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 8),
            Text('R\$ ${_totalMonth.toStringAsFixed(2)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            if (_totalLastMonth > 0 && _totalMonth > _totalLastMonth * 1.2)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.yellowAccent, size: 20),
                    SizedBox(width: 5),
                    Expanded(child: Text('Alerta: 20% acima do mês passado!', style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.w500))),
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
    final percentage = _totalLastMonth > 0 ? (difference / _totalLastMonth * 100) : 100.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vs Mês Anterior', style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('R\$ ${difference.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: difference > 0 ? Colors.red : Colors.green)),
                    SizedBox(width: 8),
                    Text('${difference > 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%', style: TextStyle(color: difference > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Icon(difference > 0 ? Icons.trending_up : Icons.trending_down, color: difference > 0 ? Colors.red : Colors.green, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Histórico Recente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _allExpenses.length > 5 ? 5 : _allExpenses.length,
          itemBuilder: (context, index) {
            final expense = _allExpenses[index];
            return ExpenseCard(expense: expense, onDelete: () => _deleteExpense(expense.id!));
          },
        ),
      ],
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  final Function onExpenseAdded;
  AddExpenseScreen({required this.onExpenseAdded});
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  String _category = 'alimentação';
  String _description = '';
  DateTime _date = DateTime.now();
  final List<String> _categories = ['alimentação', 'transporte', 'contas', 'lazer', 'outros'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Novo Gasto')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Valor (R\$)', prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
                value: _category,
                items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category.capitalize()))).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descrição (opcional)', prefixIcon: Icon(Icons.description), border: OutlineInputBorder()),
                onChanged: (value) => _description = value,
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today, color: Colors.green),
                title: Text('Data: ${_date.day.toString().padLeft(2,'0')}/${_date.month.toString().padLeft(2,'0')}/${_date.year}'),
                trailing: TextButton(
                  child: Text("Alterar"),
                  onPressed: () async {
                    final date = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (date != null) setState(() => _date = date);
                  },
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('SALVAR'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final valueString = _valueController.text.replaceAll(',', '.');
      final value = double.parse(valueString);
      final expense = Expense(value: value, category: _category, description: _description, date: _date);
      await DatabaseHelper.instance.insertExpense(expense);
      widget.onExpenseAdded();
      if (mounted) Navigator.pop(context);
    }
  }
}

class SubscriptionsScreen extends StatefulWidget {
  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> _subscriptions = [];
  
  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() async {
    final subscriptions = await DatabaseHelper.instance.getSubscriptions();
    if(mounted) setState(() => _subscriptions = subscriptions);
  }

  void _addSubscription(Subscription s) async {
    await DatabaseHelper.instance.insertSubscription(s);
    _loadSubscriptions();
  }

  void _deleteSubscription(int id) async {
    await DatabaseHelper.instance.deleteSubscription(id);
    _loadSubscriptions();
  }

  void _showAddSubscriptionDialog() {
    final nameC = TextEditingController();
    final valueC = TextEditingController();
    DateTime? selectedDate;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nova Assinatura'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: InputDecoration(labelText: 'Nome')),
              TextField(controller: valueC, decoration: InputDecoration(labelText: 'Valor'), keyboardType: TextInputType.number),
              ElevatedButton(
                child: Text(selectedDate == null ? "Escolher Data" : "${selectedDate!.day}/${selectedDate!.month}"),
                onPressed: () async {
                  final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if(d!=null) setState(() => selectedDate = d); // Nota: Em dialog simples o setState pode não atualizar a UI do dialog, mas salva a variavel
                }
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          TextButton(onPressed: () {
            if(nameC.text.isNotEmpty && valueC.text.isNotEmpty) {
              _addSubscription(Subscription(
                name: nameC.text, 
                value: double.parse(valueC.text.replaceAll(',', '.')),
                billDate: selectedDate ?? DateTime.now()
              ));
              Navigator.pop(ctx);
            }
          }, child: Text("Salvar"))
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assinaturas')),
      body: _subscriptions.isEmpty ? Center(child: Text("Sem assinaturas")) : ListView.builder(
        itemCount: _subscriptions.length,
        itemBuilder: (context, index) {
          final s = _subscriptions[index];
          return ListTile(
            title: Text(s.name),
            subtitle: Text("R\$ ${s.value} - Vence dia ${s.billDate.day}"),
            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSubscription(s.id!)),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: _showAddSubscriptionDialog),
    );
  }
}

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> _goals = [];
  
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    final goals = await DatabaseHelper.instance.getGoals();
    if(mounted) setState(() => _goals = goals);
  }

  void _addGoal(Goal g) async {
    await DatabaseHelper.instance.insertGoal(g);
    _loadGoals();
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
        title: Text("Nova Meta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: InputDecoration(labelText: "Nome")),
            TextField(controller: targetC, decoration: InputDecoration(labelText: "Meta (R\$)"), keyboardType: TextInputType.number),
            TextField(controller: currentC, decoration: InputDecoration(labelText: "Atual (R\$)"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancelar")),
          TextButton(onPressed: () {
            if(nameC.text.isNotEmpty) {
              _addGoal(Goal(
                name: nameC.text, 
                targetValue: double.tryParse(targetC.text) ?? 0, 
                currentValue: double.tryParse(currentC.text) ?? 0
              ));
              Navigator.pop(ctx);
            }
          }, child: Text("Salvar"))
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Metas Financeiras")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          final progress = goal.targetValue == 0 ? 0.0 : goal.currentValue / goal.targetValue;
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                     Text(goal.name, style: TextStyle(fontWeight: FontWeight.bold)),
                     IconButton(icon: Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteGoal(goal.id!))
                   ]),
                   LinearProgressIndicator(value: progress.clamp(0.0, 1.0), color: Colors.green, backgroundColor: Colors.grey[200]),
                   SizedBox(height: 5),
                   Text("R\$ ${goal.currentValue} de R\$ ${goal.targetValue} (${(progress*100).toStringAsFixed(0)}%)")
                ],
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: _showAddGoalDialog),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white)
        ),
      ),
      home: HomeScreen(),
    );
  }
}