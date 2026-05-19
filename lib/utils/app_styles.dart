 import 'package:flutter/material.dart';

  class AppStyles {
    static const Map<String, (IconData, Color)> categories = {
      'alimentação': (Icons.restaurant, Colors.orange),
      'transporte': (Icons.directions_car, Colors.blue),
      'contas': (Icons.receipt, Colors.red),
      'lazer': (Icons.movie, Colors.purple),
      'outros': (Icons.category, Colors.grey),
    };

    static IconData getIcon(String category) =>
        categories[category.toLowerCase()]?.$1 ?? Icons.help_outline;

    static Color getColor(String category) =>
        categories[category.toLowerCase()]?.$2 ?? Colors.grey;
  }