class Income {
  final int? id;
  final double value;
  final String source;
  final String? description;
  final DateTime date;

  Income({
    this.id,
    required this.value,
    required this.source,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'source': source,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  static Income fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      value: (map['value'] as num).toDouble(),
      source: map['source'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
