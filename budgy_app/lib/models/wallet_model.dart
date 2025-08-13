import 'package:budgy_app/models/budget_transaction_model.dart';

class Wallet {
  final String id;
  final double? salary; // Nullable for custom wallets
  final Map<String, dynamic> allocation; // Can hold amount-only for custom
  final DateTime date;
  final bool isCustom; // New field

  final Map<String, double> added;
  final Map<String, double> deducted;
  final Map<String, String> addedLabels;
  final Map<String, String> deductedLabels;
  final List<TransactionEntry> transactions;

  Wallet({
    required this.id,
    this.salary,
    required this.allocation,
    required this.date,
    this.isCustom = false,
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
        'isCustom': isCustom,
        'added': added,
        'deducted': deducted,
        'addedLabels': addedLabels,
        'deductedLabels': deductedLabels,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'],
        salary: (json['salary'] as num?)?.toDouble(),
        allocation: Map<String, dynamic>.from(json['allocation']),
        date: DateTime.parse(json['date']),
        isCustom: json['isCustom'] ?? false,
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
