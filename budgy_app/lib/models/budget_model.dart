class Budget {
  final String id;
  final double salary;
  final Map<String, Map<String, double>> allocation; // { "Savings": { "percentage": 50, "amount": 2500 } }
  final DateTime date;

  Budget({
    required this.id,
    required this.salary,
    required this.allocation,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'salary': salary,
        'allocation': allocation,
        'date': date.toIso8601String(),
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
      );
}
