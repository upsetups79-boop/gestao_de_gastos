
  import 'package:flutter/material.dart';                                                                                 import 'package:flutter/services.dart';
  import '../models/expense.dart';                                                                                        import '../services/database_helper.dart';
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
    String _category = 'alimentação';
    String _description = '';
    DateTime _date = DateTime.now();
    final List<String> _categories = [
      'alimentação',
      'transporte',
      'contas',
      'lazer',
      'outros'
    ];

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
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o valor';
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return 'Valor inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  value: _category,
                  items: _categories
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c[0].toUpperCase() + c.substring(1))))
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
