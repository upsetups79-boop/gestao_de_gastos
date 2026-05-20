import 'package:flutter/material.dart';

class AppStyles {
  static const Map<String, (IconData, Color)> defaultCategories = {
    'alimentação': (Icons.restaurant, Colors.orange),
    'transporte': (Icons.directions_car, Colors.blue),
    'contas': (Icons.receipt, Colors.red),
    'lazer': (Icons.movie, Colors.purple),
    'outros': (Icons.category, Colors.grey),
    'moradia': (Icons.home, Colors.green),
    'saúde': (Icons.local_hospital, Colors.pink),
    'educação': (Icons.school, Colors.indigo),
    'roupas': (Icons.checkroom, Colors.brown),
  };

  static IconData getIcon(String category) {
    final lowerCategory = category.toLowerCase();
    if (defaultCategories.containsKey(lowerCategory)) {
      return defaultCategories[lowerCategory]!.$1;
    }
    return _getIconFromName(category);
  }

  static Color getColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (defaultCategories.containsKey(lowerCategory)) {
      return defaultCategories[lowerCategory]!.$2;
    }
    return Colors.grey;
  }

  static IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'checkroom':
        return Icons.checkroom;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'movie':
        return Icons.movie;
      case 'music_note':
        return Icons.music_note;
      case 'flight':
        return Icons.flight;
      case 'pets':
        return Icons.pets;
      case 'child_care':
        return Icons.child_care;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  static Color getColorFromHex(String hexColor) {
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}