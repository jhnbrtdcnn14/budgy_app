import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/budget_model.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveBudget(Budget budget) async {
    final allData = await getBudgets();
    allData.add(budget);
    await _storage.write(key: 'budgets', value: jsonEncode(allData.map((b) => b.toJson()).toList()));
  }

  Future<List<Budget>> getBudgets() async {
    final data = await _storage.read(key: 'budgets');
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Budget.fromJson(e)).toList();
  }
}
