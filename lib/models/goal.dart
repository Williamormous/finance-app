class Goal {
  final String id;
  String title;
  double targetAmount;
  double savedAmount;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      );
}
