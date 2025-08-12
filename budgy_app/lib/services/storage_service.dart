import 'dart:convert';
import 'package:budgy_app/models/budget_model.dart';
import 'package:budgy_app/models/budget_transaction_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/allocator_model.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();
  final _key = 'allocators';
  static const _budgetsKey = 'budgets';

  Future<void> saveAllocators(List<Allocator> allocators) async {
    final jsonStr = jsonEncode(allocators.map((a) => a.toJson()).toList());
    await _storage.write(key: _key, value: jsonStr);
  }

  Future<List<Allocator>> loadAllocators() async {
    final jsonStr = await _storage.read(key: _key);
    if (jsonStr == null) {
      return [
        Allocator(name: 'Savings', percentage: 50),
        Allocator(name: 'Needs', percentage: 30),
        Allocator(name: 'Wants', percentage: 15),
        Allocator(name: 'Investment', percentage: 5),
      ];
    }
    final List decoded = jsonDecode(jsonStr) as List;
    return decoded
        .map((e) => Allocator.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearAllocators() async {
    await _storage.delete(key: _key);
  }

  Future<void> saveBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_budgetsKey);
    final List budgets = data != null ? jsonDecode(data) : [];
    budgets.add(budget.toJson());
    prefs.setString(_budgetsKey, jsonEncode(budgets));
  }

  Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_budgetsKey);
    if (data == null) return [];
    final list = (jsonDecode(data) as List)
        .map((item) => Budget.fromJson(item))
        .toList();
    return list;
  }

  Future<void> deleteBudget(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_budgetsKey);
    if (data == null) return;
    final List decoded = jsonDecode(data);
    decoded.removeWhere((item) => item['id'] == id);
    prefs.setString(_budgetsKey, jsonEncode(decoded));
  }

  Future<void> saveTransaction(
  Budget budget,
  String category,
  double change, {
  String? label,
  TransactionEntry? transactionEntry,  // <-- optionally pass the new transaction entry here
}) async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(_budgetsKey);
  if (data == null) return;

  final List decoded = jsonDecode(data);
  final index = decoded.indexWhere((item) => item['id'] == budget.id);
  if (index != -1) {
    final budgetMap = Map<String, dynamic>.from(decoded[index]);

    // Existing added/deducted maps
    final added = (budgetMap['added'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num).toDouble()));
    final deducted = (budgetMap['deducted'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num).toDouble()));

    final addedLabels =
        (budgetMap['addedLabels'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v.toString()));
    final deductedLabels =
        (budgetMap['deductedLabels'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v.toString()));

    // Update added/deducted totals and labels
    added.putIfAbsent(category, () => 0);
    deducted.putIfAbsent(category, () => 0);

    if (change >= 0) {
      added[category] = added[category]! + change;
      if (label != null && label.isNotEmpty) {
        addedLabels[category] = label;
      }
    } else {
      deducted[category] = deducted[category]! + (-change);
      if (label != null && label.isNotEmpty) {
        deductedLabels[category] = label;
      }
    }

    budgetMap['added'] = added;
    budgetMap['deducted'] = deducted;
    budgetMap['addedLabels'] = addedLabels;
    budgetMap['deductedLabels'] = deductedLabels;

    // --- Handle transactions list ---

    List existingTransactions = budgetMap['transactions'] ?? [];

    if (transactionEntry != null) {
      existingTransactions.add(transactionEntry.toJson());
    }

    budgetMap['transactions'] = existingTransactions;

    // Save updated budget back
    decoded[index] = budgetMap;
    await prefs.setString(_budgetsKey, jsonEncode(decoded));
  }
}

}
