
  class Subscription {                                                                                                      final int? id;
    final String name;                                                                                                      final double value;
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