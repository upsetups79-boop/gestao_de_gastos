
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
