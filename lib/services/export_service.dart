import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../utils/currency_formatter.dart';

class ExportService {
  static Future<void> exportExpensesToCSV(List<Expense> expenses) async {
    final buffer = StringBuffer();
    buffer.writeln('Data,Categoria,Descrição,Valor');
    for (final expense in expenses) {
      final date = CurrencyFormatter.formatDate(expense.date);
      final category = expense.category;
      final description = expense.description ?? '';
      final value = expense.value.toStringAsFixed(2);
      buffer.writeln('$date,$category,$description,$value');
    }

    await _saveAndShare(buffer.toString(), 'gastos.csv');
  }

  static Future<void> exportIncomesToCSV(List<Income> incomes) async {
    final buffer = StringBuffer();
    buffer.writeln('Data,Fonte,Descrição,Valor');
    for (final income in incomes) {
      final date = CurrencyFormatter.formatDate(income.date);
      final source = income.source;
      final description = income.description ?? '';
      final value = income.value.toStringAsFixed(2);
      buffer.writeln('$date,$source,$description,$value');
    }

    await _saveAndShare(buffer.toString(), 'receitas.csv');
  }

  static Future<void> exportAllToCSV(
      List<Expense> expenses, List<Income> incomes) async {
    final buffer = StringBuffer();
    buffer.writeln('Tipo,Data,Categoria/Fonte,Descrição,Valor');

    for (final expense in expenses) {
      final date = CurrencyFormatter.formatDate(expense.date);
      final category = expense.category;
      final description = expense.description ?? '';
      final value = expense.value.toStringAsFixed(2);
      buffer.writeln('Gasto,$date,$category,$description,$value');
    }

    for (final income in incomes) {
      final date = CurrencyFormatter.formatDate(income.date);
      final source = income.source;
      final description = income.description ?? '';
      final value = income.value.toStringAsFixed(2);
      buffer.writeln('Receita,$date,$source,$description,$value');
    }

    await _saveAndShare(buffer.toString(), 'financeiro.csv');
  }

  static Future<void> _saveAndShare(String content, String filename) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    final xFile = XFile(file.path);
    await Share.shareXFiles([xFile], subject: 'Exportação Financeira');
  }
}
