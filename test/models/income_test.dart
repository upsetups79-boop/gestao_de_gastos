import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_gastos/models/income.dart';

void main() {
  group('Income Model', () {
    test('should create Income from map', () {
      final map = {
        'id': 1,
        'value': 3500.0,
        'source': 'Salário',
        'description': 'Salário mensal',
        'date': '2024-01-01T00:00:00.000',
      };

      final income = Income.fromMap(map);

      expect(income.id, 1);
      expect(income.value, 3500.0);
      expect(income.source, 'Salário');
      expect(income.description, 'Salário mensal');
      expect(income.date, DateTime.parse('2024-01-01T00:00:00.000'));
    });

    test('should convert Income to map', () {
      final income = Income(
        id: 1,
        value: 3500.0,
        source: 'Salário',
        description: 'Salário mensal',
        date: DateTime(2024, 1, 1),
      );

      final map = income.toMap();

      expect(map['id'], 1);
      expect(map['value'], 3500.0);
      expect(map['source'], 'Salário');
      expect(map['description'], 'Salário mensal');
      expect(map['date'], '2024-01-01T00:00:00.000');
    });

    test('should handle null description', () {
      final income = Income(
        id: 1,
        value: 3500.0,
        source: 'Salário',
        date: DateTime(2024, 1, 1),
      );

      final map = income.toMap();

      expect(map['description'], isNull);
    });
  });
}
