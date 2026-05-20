import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/expense.dart';
import '../models/income.dart';
import '../models/category.dart';
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
      return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
    }

    Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE incomes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL NOT NULL,
            source TEXT NOT NULL,
            description TEXT,
            date TEXT NOT NULL
          )
        ''');
      }
      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL
          )
        ''');
        await _insertDefaultCategories(db);
      }
    }

    Future _insertDefaultCategories(Database db) async {
      final defaultCategories = [
        {'name': 'Alimentação', 'icon': 'restaurant', 'color': 'FF5722'},
        {'name': 'Transporte', 'icon': 'directions_car', 'color': '2196F3'},
        {'name': 'Moradia', 'icon': 'home', 'color': '4CAF50'},
        {'name': 'Saúde', 'icon': 'local_hospital', 'color': 'E91E63'},
        {'name': 'Educação', 'icon': 'school', 'color': '9C27B0'},
        {'name': 'Lazer', 'icon': 'sports_esports', 'color': 'FF9800'},
        {'name': 'Roupas', 'icon': 'checkroom', 'color': '795548'},
        {'name': 'Outros', 'icon': 'more_horiz', 'color': '607D8B'},
      ];
      for (final category in defaultCategories) {
        await db.insert('categories', category);
      }
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
        CREATE TABLE incomes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          value REAL NOT NULL,
          source TEXT NOT NULL,
          description TEXT,
          date TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT NOT NULL,
          color TEXT NOT NULL
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
      await _insertDefaultCategories(db);
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

    Future<int> insertIncome(Income income) async {
      final db = await instance.database;
      return await db.insert('incomes', income.toMap());
    }

    Future<List<Income>> getIncomes() async {
      final db = await instance.database;
      final maps = await db.query('incomes', orderBy: 'date DESC');
      return maps.map((map) => Income.fromMap(map)).toList();
    }

    Future<List<Income>> getIncomesByDateRange(DateTime start, DateTime end) async {
      final db = await instance.database;
      final maps = await db.query(
        'incomes',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
      return maps.map((map) => Income.fromMap(map)).toList();
    }

    Future<int> deleteIncome(int id) async {
      final db = await instance.database;
      return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
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

    Future<int> insertCategory(Category category) async {
      final db = await instance.database;
      return await db.insert('categories', category.toMap());
    }

    Future<List<Category>> getCategories() async {
      final db = await instance.database;
      final maps = await db.query('categories', orderBy: 'name ASC');
      return maps.map((map) => Category.fromMap(map)).toList();
    }

    Future<int> updateCategory(Category category) async {
      final db = await instance.database;
      return await db.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    }

    Future<int> deleteCategory(int id) async {
      final db = await instance.database;
      return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    }
  }