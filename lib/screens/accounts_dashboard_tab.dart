import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction_item.dart';
import '../utils/currency_utils.dart';
import 'account_detail_screen.dart';

class AccountsDashboardTab extends StatefulWidget {
  final List<Account> accounts;
  final String currency;
  final VoidCallback onAccountsChanged;

  const AccountsDashboardTab({
    super.key,
    required this.accounts,
    required this.currency,
    required this.onAccountsChanged,
  });

  @override
  State<AccountsDashboardTab> createState() => _AccountsDashboardTabState();
}

class _AccountsDashboardTabState extends State<AccountsDashboardTab> {
  double get _totalBalance {
    return widget.accounts.fold(0.0, (sum, acc) => sum + acc.balance);
  }

  void _createAccount() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. Cash, Emergency Fund',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Starting Balance',
                hintText: 'e.g. 500.00',
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
              final name = nameController.text.trim();
              final balanceText = balanceController.text.trim();
              if (name.isNotEmpty) {
                final startingBalance = double.tryParse(balanceText) ?? 0.0;
                setState(() {
                  widget.accounts.add(
                    Account(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      balance: startingBalance,
                      transactions: startingBalance != 0
                          ? [
                              TransactionItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: 'Starting Balance',
                                amount: startingBalance.abs(),
                                isGain: startingBalance >= 0,
                                date: DateTime.now(),
                              ),
                            ]
                          : [],
                    ),
                  );
                });
                widget.onAccountsChanged();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.accounts.removeWhere((acc) => acc.id == account.id);
              });
              widget.onAccountsChanged();
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

  void _openAccountDetail(Account account) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailScreen(
          account: account,
          currency: widget.currency,
          onAccountUpdated: () {
            setState(() {});
            widget.onAccountsChanged();
          },
          onAccountDeleted: () {
            setState(() {
              widget.accounts.removeWhere((acc) => acc.id == account.id);
            });
            widget.onAccountsChanged();
          },
        ),
      ),
    );
    setState(() {});
    widget.onAccountsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accounts'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth / Total Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade800, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(widget.currency, _totalBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.accounts.length} active account${widget.accounts.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.accounts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No accounts yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _createAccount,
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first account'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: widget.accounts.length,
                      itemBuilder: (context, index) {
                        final account = widget.accounts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.teal,
                              ),
                            ),
                            title: Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${account.transactions.length} transaction${account.transactions.length == 1 ? '' : 's'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatCurrency(widget.currency, account.balance),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: account.balance >= 0
                                        ? Colors.teal.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () => _deleteAccount(account),
                                  tooltip: 'Delete Account',
                                ),
                              ],
                            ),
                            onTap: () => _openAccountDetail(account),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAccount,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }
}
