
import 'package:budgy_app/models/budget_transaction_model.dart';

class Budget {
  final String id;
  final double salary;
  final Map<String, Map<String, double>> allocation;
  final DateTime date;
  final Map<String, double> added;
  final Map<String, double> deducted;
  final Map<String, String> addedLabels;
  final Map<String, String> deductedLabels;
  final List<TransactionEntry> transactions;

  Budget({
    required this.id,
    required this.salary,
    required this.allocation,
    required this.date,
    Map<String, double>? added,
    Map<String, double>? deducted,
    Map<String, String>? addedLabels,
    Map<String, String>? deductedLabels,
    List<TransactionEntry>? transactions,
  })  : added = added ?? {},
        deducted = deducted ?? {},
        addedLabels = addedLabels ?? {},
        deductedLabels = deductedLabels ?? {},
        transactions = transactions ?? [];

  /// Adds a transaction and updates added/deducted maps and labels accordingly.
  void addTransaction(TransactionEntry transaction) {
    transactions.add(transaction);

    if (transaction.type == "added") {
      added[transaction.category] =
          (added[transaction.category] ?? 0) + transaction.amount;
      addedLabels[transaction.category] = transaction.label;
    } else if (transaction.type == "deducted") {
      deducted[transaction.category] =
          (deducted[transaction.category] ?? 0) + transaction.amount;
      deductedLabels[transaction.category] = transaction.label;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'salary': salary,
        'allocation': allocation,
        'date': date.toIso8601String(),
        'added': added,
        'deducted': deducted,
        'addedLabels': addedLabels,
        'deductedLabels': deductedLabels,
        'transactions': transactions.map((t) => t.toJson()).toList(),
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
        addedLabels: (json['addedLabels'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {},
        deductedLabels: (json['deductedLabels'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {},
        transactions: (json['transactions'] as List<dynamic>?)
                ?.map((t) => TransactionEntry.fromJson(t))
                .toList() ??
            [],
      );
}
