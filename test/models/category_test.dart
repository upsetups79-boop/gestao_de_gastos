import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_de_gastos/models/category.dart';

void main() {
  group('Category Model', () {
    test('should create Category from map', () {
      final map = {
        'id': 1,
        'name': 'Alimentação',
        'icon': 'restaurant',
        'color': 'FF5722',
      };

      final category = Category.fromMap(map);

      expect(category.id, 1);
      expect(category.name, 'Alimentação');
      expect(category.icon, 'restaurant');
      expect(category.color, 'FF5722');
    });

    test('should convert Category to map', () {
      final category = Category(
        id: 1,
        name: 'Alimentação',
        icon: 'restaurant',
        color: 'FF5722',
      );

      final map = category.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Alimentação');
      expect(map['icon'], 'restaurant');
      expect(map['color'], 'FF5722');
    });
  });
}
