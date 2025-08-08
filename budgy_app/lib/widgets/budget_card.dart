import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import 'package:intl/intl.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(budget.date);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Salary: ₱${budget.salary.toStringAsFixed(2)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: budget.allocation.entries.map((e) {
            return Text('${e.key}: ₱${e.value.toStringAsFixed(2)}');
          }).toList()
          ..add(Text('Date: $dateStr')),
        ),
      ),
    );
  }
}
