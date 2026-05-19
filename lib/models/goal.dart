
  class Goal {
    final int? id;                                                                                                          final String name;
    final double targetValue;                                                                                               final double currentValue;

    Goal({
      this.id,
      required this.name,
      required this.targetValue,
      required this.currentValue,
    });

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'name': name,
        'target_value': targetValue,
        'current_value': currentValue,
      };
    }

    static Goal fromMap(Map<String, dynamic> map) {
      return Goal(
        id: map['id'],
        name: map['name'],
        targetValue: (map['target_value'] as num).toDouble(),
        currentValue: (map['current_value'] as num).toDouble(),
      );
    }
  }