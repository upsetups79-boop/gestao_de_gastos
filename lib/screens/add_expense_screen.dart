import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/database_helper.dart';
import '../utils/currency_formatter.dart';

  class AddExpenseScreen extends StatefulWidget {
    final VoidCallback onExpenseAdded;

    const AddExpenseScreen({super.key, required this.onExpenseAdded});

    @override
    State<AddExpenseScreen> createState() => _AddExpenseScreenState();
  }

  class _AddExpenseScreenState extends State<AddExpenseScreen> {
    final _formKey = GlobalKey<FormState>();
    final _valueController = TextEditingController();
    String? _category;
    String _description = '';
    DateTime _date = DateTime.now();
    List<Category> _categories = [];
    bool _isLoadingCategories = true;

    @override
    void initState() {
      super.initState();
      _loadCategories();
    }

    Future<void> _loadCategories() async {
      final categories = await DatabaseHelper.instance.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        if (categories.isNotEmpty) {
          _category = categories.first.name;
        }
      });
    }

    @override
    void dispose() {
      _valueController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Novo Gasto')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    labelText: 'Valor (R\$)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 50,00',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o valor';
                    }
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null) {
                      return 'Valor inválido. Use números e vírgula';
                    }
                    if (parsed <= 0) {
                      return 'O valor deve ser maior que zero';
                    }
                    if (parsed > 999999) {
                      return 'Valor muito alto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _isLoadingCategories
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        value: _category,
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                value: c.name,
                                child: Text(c.name)))
                            .toList(),
                        onChanged: (value) => setState(() => _category = value!),
                      ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _description = value,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Colors.green),
                  title: Text('Data: ${CurrencyFormatter.formatDate(_date)}'),
                  trailing: TextButton(
                    child: const Text('Alterar'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) setState(() => _date = date);
                    },
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SALVAR',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _saveExpense() async {
      if (_formKey.currentState!.validate()) {
        final value = double.parse(_valueController.text.replaceAll(',', '.'));
        final expense = Expense(
          value: value,
          category: _category,
          description: _description,
          date: _date,
        );
        await DatabaseHelper.instance.insertExpense(expense);
        widget.onExpenseAdded();
        if (mounted) Navigator.pop(context);
      }
    }
  }
