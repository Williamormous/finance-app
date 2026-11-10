class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final bool isGain; // true = gain, false = spend
  final DateTime date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.isGain,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isGain': isGain,
        'date': date.toIso8601String(),
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        isGain: json['isGain'] ?? true,
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      );
}
