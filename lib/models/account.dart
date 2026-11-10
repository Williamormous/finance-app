import 'transaction_item.dart';

class Account {
  final String id;
  String name;
  double balance;
  final List<TransactionItem> transactions;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    List<TransactionItem>? transactions,
  }) : transactions = transactions ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        transactions: (json['transactions'] as List<dynamic>?)
                ?.map((t) => TransactionItem.fromJson(t))
                .toList() ??
            [],
      );
}
