import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../utils/currency_formatter.dart';
import '../widgets/expense_card.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<Category> _categories = [];
  List<Expense> _filteredExpenses = [];
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  double _minValue = 0;
  double _maxValue = 10000;
  bool _isLoading = true;
  bool _isFiltered = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    List<Expense> expenses = await DatabaseHelper.instance.getExpenses();

    if (_selectedCategory != null) {
      expenses =
          expenses.where((e) => e.category == _selectedCategory).toList();
    }

    if (_startDate != null) {
      expenses =
          expenses.where((e) => e.date.isAfter(_startDate!)).toList();
    }

    if (_endDate != null) {
      final endOfDay =
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      expenses =
          expenses.where((e) => e.date.isBefore(endOfDay)).toList();
    }

    expenses = expenses
        .where((e) => e.value >= _minValue && e.value <= _maxValue)
        .toList();

    setState(() {
      _filteredExpenses = expenses;
      _isLoading = false;
      _isFiltered = true;
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _minValue = 0;
      _maxValue = 10000;
      _isFiltered = false;
      _filteredExpenses = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
        actions: [
          if (_isFiltered)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildDateFilter(),
                  const SizedBox(height: 16),
                  _buildValueFilter(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Aplicar Filtros',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  if (_isFiltered) ...[
                    const SizedBox(height: 24),
                    _buildResults(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Categoria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = null);
                  },
                  selectedColor: Colors.green[100],
                  checkmarkColor: Colors.green[700],
                ),
                ..._categories.map((category) => FilterChip(
                      label: Text(category.name),
                      selected: _selectedCategory == category.name,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory =
                              selected ? category.name : null;
                        });
                      },
                      selectedColor: Colors.green[100],
                      checkmarkColor: Colors.green[700],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Período',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('De'),
                    subtitle: Text(_startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Selecione'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectStartDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListTile(
                    title: const Text('Até'),
                    subtitle: Text(_endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Selecione'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectEndDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Valor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(_minValue, _maxValue),
              min: 0,
              max: 10000,
              divisions: 100,
              labels: RangeLabels(
                CurrencyFormatter.format(_minValue),
                CurrencyFormatter.format(_maxValue),
              ),
              onChanged: (values) {
                setState(() {
                  _minValue = values.start;
                  _maxValue = values.end;
                });
              },
              activeColor: Colors.green,
              inactiveColor: Colors.green[100],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(CurrencyFormatter.format(_minValue),
                    style: const TextStyle(fontSize: 12)),
                Text(CurrencyFormatter.format(_maxValue),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final total =
        _filteredExpenses.fold(0.0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Resultados: ${_filteredExpenses.length}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(CurrencyFormatter.format(total),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700])),
          ],
        ),
        const SizedBox(height: 12),
        if (_filteredExpenses.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Nenhum gasto encontrado',
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = _filteredExpenses[index];
              return ExpenseCard(
                expense: expense,
                onDelete: () {},
              );
            },
          ),
      ],
    );
  }
}
