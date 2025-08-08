class Budget {
  final String id;
  final double salary;
  final Map<String, double> allocation;
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
    salary: json['salary'],
    allocation: Map<String, double>.from(json['allocation']),
    date: DateTime.parse(json['date']),
  );
}
