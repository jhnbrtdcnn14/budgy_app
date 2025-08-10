class Budget {
  final String id;
  final double salary;
  final Map<String, Map<String, double>> allocation;
  final DateTime date;
  final Map<String, double> added;    // e.g. { "Savings": 200 }
  final Map<String, double> deducted; // e.g. { "Wants": 150 }

  Budget({
    required this.id,
    required this.salary,
    required this.allocation,
    required this.date,
    Map<String, double>? added,
    Map<String, double>? deducted,
  })  : added = added ?? {},
        deducted = deducted ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'salary': salary,
        'allocation': allocation,
        'date': date.toIso8601String(),
        'added': added,
        'deducted': deducted,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'],
        salary: (json['salary'] as num).toDouble(),
        allocation: (json['allocation'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            {
              'percentage': (value['percentage'] as num).toDouble(),
              'amount': (value['amount'] as num).toDouble(),
            },
          ),
        ),
        date: DateTime.parse(json['date']),
        added: (json['added'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
            {},
        deducted: (json['deducted'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
            {},
      );
}
