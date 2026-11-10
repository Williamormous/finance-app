import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction_item.dart';
import '../utils/currency_utils.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;
  final String currency;
  final VoidCallback onAccountUpdated;
  final VoidCallback onAccountDeleted;

  const AccountDetailScreen({
    super.key,
    required this.account,
    required this.currency,
    required this.onAccountUpdated,
    required this.onAccountDeleted,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  void _addTransaction(bool isGain) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGain ? 'Add Gain (Income)' : 'Add Spend (Expense)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Description / Title',
                hintText: 'e.g. Salary, Grocery, Coffee',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 45.50',
                prefixText: getCurrencyPrefix(widget.currency),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final amountText = amountController.text.trim();
              if (title.isNotEmpty && amountText.isNotEmpty) {
                final amount = double.tryParse(amountText) ?? 0.0;
                if (amount > 0) {
                  setState(() {
                    widget.account.transactions.insert(
                      0,
                      TransactionItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        amount: amount,
                        isGain: isGain,
                        date: DateTime.now(),
                      ),
                    );
                    if (isGain) {
                      widget.account.balance += amount;
                    } else {
                      widget.account.balance -= amount;
                    }
                  });
                  widget.onAccountUpdated();
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isGain ? Colors.teal : Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(isGain ? 'Add Gain' : 'Record Spend'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(TransactionItem tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${tx.title}"?\nThis will reverse its effect of ${formatCurrency(widget.currency, tx.amount)} on your balance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.account.transactions.removeWhere((item) => item.id == tx.id);
                if (tx.isGain) {
                  widget.account.balance -= tx.amount;
                } else {
                  widget.account.balance += tx.amount;
                }
              });
              widget.onAccountUpdated();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editAccountName() {
    final nameController = TextEditingController(text: widget.account.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Account Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Account Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  widget.account.name = newName;
                });
                widget.onAccountUpdated();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${widget.account.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              widget.onAccountDeleted();
              Navigator.pop(context); // return to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editAccountName,
            tooltip: 'Edit Account Name',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
            tooltip: 'Delete Account',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Balance Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Account Balance',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(widget.currency, widget.account.balance),
                    style: TextStyle(
                      color: widget.account.balance >= 0
                          ? Colors.teal.shade700
                          : Colors.red.shade700,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _addTransaction(false),
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('Spend'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _addTransaction(true),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Gain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.account.transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions yet.\nClick Spend or Gain to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.account.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = widget.account.transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tx.isGain
                                  ? Colors.teal.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              child: Icon(
                                tx.isGain ? Icons.arrow_downward : Icons.arrow_upward,
                                color: tx.isGain ? Colors.teal : Colors.redAccent,
                              ),
                            ),
                            title: Text(tx.title),
                            subtitle: Text(
                              tx.date.toLocal().toString().split(' ')[0],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatSignedCurrency(widget.currency, tx.amount, tx.isGain),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: tx.isGain ? Colors.teal.shade700 : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                  onPressed: () => _deleteTransaction(tx),
                                  tooltip: 'Delete Transaction',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
