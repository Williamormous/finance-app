class BudgetCategory {
  String name;
  double allocatedAmount;

  BudgetCategory({
    required this.name,
    required this.allocatedAmount,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'allocatedAmount': allocatedAmount,
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        name: json['name'] ?? '',
        allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 0.0,
      );
}

class Budget {
  final String id;
  String name;
  double totalAmount;
  List<BudgetCategory> categories;

  Budget({
    required this.id,
    required this.name,
    required this.totalAmount,
    List<BudgetCategory>? categories,
  }) : categories = categories ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalAmount': totalAmount,
        'categories': categories.map((c) => c.toJson()).toList(),
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        categories: (json['categories'] as List<dynamic>?)
                ?.map((c) => BudgetCategory.fromJson(c))
                .toList() ??
            [],
      );
}
