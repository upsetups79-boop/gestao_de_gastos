import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_gastos/models/expense.dart';

void main() {
  group('Expense Model', () {
    test('should create Expense from map', () {
      final map = {
        'id': 1,
        'value': 50.0,
        'category': 'Alimentação',
        'description': 'Almoço',
        'date': '2024-01-15T12:00:00.000',
      };

      final expense = Expense.fromMap(map);

      expect(expense.id, 1);
      expect(expense.value, 50.0);
      expect(expense.category, 'Alimentação');
      expect(expense.description, 'Almoço');
      expect(expense.date, DateTime.parse('2024-01-15T12:00:00.000'));
    });

    test('should convert Expense to map', () {
      final expense = Expense(
        id: 1,
        value: 50.0,
        category: 'Alimentação',
        description: 'Almoço',
        date: DateTime(2024, 1, 15, 12, 0, 0),
      );

      final map = expense.toMap();

      expect(map['id'], 1);
      expect(map['value'], 50.0);
      expect(map['category'], 'Alimentação');
      expect(map['description'], 'Almoço');
      expect(map['date'], '2024-01-15T12:00:00.000');
    });

    test('should handle null description', () {
      final expense = Expense(
        id: 1,
        value: 50.0,
        category: 'Alimentação',
        date: DateTime(2024, 1, 15, 12, 0, 0),
      );

      final map = expense.toMap();

      expect(map['description'], isNull);
    });
  });
}
