import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/storage_service.dart';
import '../widgets/budget_card.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  final _salaryController = TextEditingController();
  final _uuid = const Uuid();

  double savings = 0.5;
  double needs = 0.3;
  double wants = 0.2;

  List<Budget> budgets = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() async {
    final data = await _storageService.getBudgets();
    setState(() {
      budgets = data;
    });
  }

  void _saveBudget() async {
    final salary = double.tryParse(_salaryController.text);
    if (salary == null) return;

    final allocation = {
      'Savings': salary * savings,
      'Needs': salary * needs,
      'Wants': salary * wants,
    };

    final budget = Budget(
      id: _uuid.v4(),
      salary: salary,
      allocation: allocation,
      date: DateTime.now(),
    );

    await _storageService.saveBudget(budget);
    _salaryController.clear();
    _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter Salary'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Save Budget'),
            ),
            const SizedBox(height: 20),
            const Text('Past Budgets:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final b = budgets[index];
                  return BudgetCard(budget: b);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
