import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart' as p;
  import '../models/expense.dart';
  import '../models/subscription.dart';
  import '../models/goal.dart';

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
      final path = p.join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: _createDB);
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
        orderBy: 'date DESC',
      );
      return maps.map((map) => Expense.fromMap(map)).toList();
    }

    Future<int> deleteExpense(int id) async {
      final db = await instance.database;
      return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    }

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