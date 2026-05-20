import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/subscription.dart';
import '../models/goal.dart';
import '../models/category.dart';
import 'database_helper.dart';

class BackupService {
  static Future<String> createBackup() async {
    final expenses = await DatabaseHelper.instance.getExpenses();
    final incomes = await DatabaseHelper.instance.getIncomes();
    final subscriptions = await DatabaseHelper.instance.getSubscriptions();
    final goals = await DatabaseHelper.instance.getGoals();
    final categories = await DatabaseHelper.instance.getCategories();

    final backup = {
      'version': 1,
      'date': DateTime.now().toIso8601String(),
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'incomes': incomes.map((i) => i.toMap()).toList(),
      'subscriptions': subscriptions.map((s) => s.toMap()).toList(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'categories': categories.map((c) => c.toMap()).toList(),
    };

    final json = jsonEncode(backup);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/backup_financeiro.json');
    await file.writeAsString(json);
    return file.path;
  }

  static Future<void> shareBackup() async {
    final path = await createBackup();
    await Share.shareXFiles([path], subject: 'Backup Financeiro');
  }

  static Future<void> restoreBackup(String jsonContent) async {
    final backup = jsonDecode(jsonContent);

    // Clear existing data
    final db = await DatabaseHelper.instance.database;
    await db.delete('expenses');
    await db.delete('incomes');
    await db.delete('subscriptions');
    await db.delete('goals');
    await db.delete('categories');

    // Restore expenses
    for (final expenseMap in backup['expenses']) {
      final expense = Expense.fromMap(expenseMap);
      await DatabaseHelper.instance.insertExpense(expense);
    }

    // Restore incomes
    for (final incomeMap in backup['incomes']) {
      final income = Income.fromMap(incomeMap);
      await DatabaseHelper.instance.insertIncome(income);
    }

    // Restore subscriptions
    for (final subscriptionMap in backup['subscriptions']) {
      final subscription = Subscription.fromMap(subscriptionMap);
      await DatabaseHelper.instance.insertSubscription(subscription);
    }

    // Restore goals
    for (final goalMap in backup['goals']) {
      final goal = Goal.fromMap(goalMap);
      await DatabaseHelper.instance.insertGoal(goal);
    }

    // Restore categories
    for (final categoryMap in backup['categories']) {
      final category = Category.fromMap(categoryMap);
      await DatabaseHelper.instance.insertCategory(category);
    }
  }
}
