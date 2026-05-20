import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_helper.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _addCategory() async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
    if (result != null) {
      await DatabaseHelper.instance.insertCategory(result);
      _loadCategories();
    }
  }

  Future<void> _editCategory(Category category) async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => AddCategoryDialog(category: category),
    );
    if (result != null) {
      await DatabaseHelper.instance.updateCategory(result);
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir a categoria "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteCategory(category.id!);
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma categoria',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            int.parse('FF${category.color}', radix: 16),
                          ),
                          child: Icon(
                            _getIconData(category.icon),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editCategory(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
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
      case 'more_horiz':
        return Icons.more_horiz;
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
      default:
        return Icons.category;
    }
  }
}

class AddCategoryDialog extends StatefulWidget {
  final Category? category;

  const AddCategoryDialog({super.key, this.category});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'more_horiz';
  String _selectedColor = '607D8B';

  final List<String> _icons = [
    'restaurant',
    'directions_car',
    'home',
    'local_hospital',
    'school',
    'sports_esports',
    'checkroom',
    'shopping_cart',
    'fitness_center',
    'movie',
    'music_note',
    'flight',
    'pets',
    'child_care',
    'more_horiz',
  ];

  final List<String> _colors = [
    'FF5722',
    '2196F3',
    '4CAF50',
    'E91E63',
    '9C27B0',
    'FF9800',
    '795548',
    '607D8B',
    'F44336',
    '3F51B5',
    '009688',
    'FFC107',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category != null ? 'Editar Categoria' : 'Nova Categoria'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ícone'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                    ),
                    child: Icon(
                      _getIconData(icon),
                      color: isSelected ? Colors.green[700] : Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Cor'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF$color', radix: 16)),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final category = Category(
                id: widget.category?.id,
                name: _nameController.text,
                icon: _selectedIcon,
                color: _selectedColor,
              );
              Navigator.pop(context, category);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
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
      case 'more_horiz':
        return Icons.more_horiz;
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
      default:
        return Icons.category;
    }
  }
}
