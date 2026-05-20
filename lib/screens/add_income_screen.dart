import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/income.dart';
import '../services/database_helper.dart';
import '../utils/currency_formatter.dart';

class AddIncomeScreen extends StatefulWidget {
  final VoidCallback onIncomeAdded;

  const AddIncomeScreen({super.key, required this.onIncomeAdded});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSource = 'Salário';
  DateTime _selectedDate = DateTime.now();

  final List<String> _sources = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Vendas',
    'Outros',
  ];

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(
          _valueController.text.replaceAll('.', '').replaceAll(',', '.'));
      final income = Income(
        value: value,
        source: _selectedSource,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        date: _selectedDate,
      );
      await DatabaseHelper.instance.insertIncome(income);
      widget.onIncomeAdded();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Receita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: const InputDecoration(
                  labelText: 'Fonte',
                  border: OutlineInputBorder(),
                ),
                items: _sources.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSource = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar Receita',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
