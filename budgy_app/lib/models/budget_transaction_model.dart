class TransactionEntry {
  final String id; // Unique transaction ID
  final String category; // e.g. "Savings", "Wants"
  final double amount; // positive for add or deduct (always positive)
  final String label; // e.g. "Bonus", "Bought shoes"
  final DateTime date;
  final String type; // "added" or "deducted"

  TransactionEntry({
    required this.id,
    required String category,
    required this.amount,
    required String label,
    required this.date,
    required this.type,
  })  : category = _capitalize(category),
        label = _capitalize(label);

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'amount': amount,
        'label': label,
        'date': date.toIso8601String(),
        'type': type,
      };

  factory TransactionEntry.fromJson(Map<String, dynamic> json) => TransactionEntry(
        id: json['id'],
        category: json['category'],
        amount: (json['amount'] as num).toDouble(),
        label: json['label'],
        date: DateTime.parse(json['date']),
        type: json['type'],
      );
}
