 import 'package:flutter/material.dart';
  import '../models/subscription.dart';                                                                                   import '../services/database_helper.dart';
  import '../utils/currency_formatter.dart';                                                                              import '../widgets/empty_state.dart';

  class SubscriptionsScreen extends StatefulWidget {
    const SubscriptionsScreen({super.key});

    @override
    State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
  }

  class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
    List<Subscription> _subscriptions = [];

    @override
    void initState() {
      super.initState();
      _loadSubscriptions();
    }

    Future<void> _loadSubscriptions() async {
      final subs = await DatabaseHelper.instance.getSubscriptions();
      if (mounted) setState(() => _subscriptions = subs);
    }

    void _deleteSubscription(int id) async {
      await DatabaseHelper.instance.deleteSubscription(id);
      _loadSubscriptions();
    }

    void _showAddSubscriptionDialog() {
      final nameC = TextEditingController();
      final valueC = TextEditingController();
      DateTime selectedDate = DateTime.now();

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Nova Assinatura'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueC,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.green),
                    title: Text(
                        'Vence dia ${CurrencyFormatter.formatDate(selectedDate)}'),
                    trailing: TextButton(
                      child: const Text('Alterar'),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setDialogState(() => selectedDate = d);
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  if (nameC.text.isNotEmpty && valueC.text.isNotEmpty) {
                    DatabaseHelper.instance.insertSubscription(Subscription(
                      name: nameC.text,
                      value: double.parse(valueC.text.replaceAll(',', '.')),
                      billDate: selectedDate,
                    ));
                    Navigator.pop(ctx);
                    _loadSubscriptions();
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assinaturas')),
        body: _subscriptions.isEmpty
            ? const EmptyState(
                icon: Icons.subscriptions,
                title: 'Sem assinaturas',
                subtitle: 'Adicione suas assinaturas recorrentes',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _subscriptions.length,
                itemBuilder: (context, index) {
                  final s = _subscriptions[index];
                  final days = s.daysUntilNextBill();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.subscriptions,
                            color: Colors.green),
                      ),
                      title: Text(s.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${CurrencyFormatter.format(s.value)} • Vence em $days dias'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSubscription(s.id!),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddSubscriptionDialog,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
  }