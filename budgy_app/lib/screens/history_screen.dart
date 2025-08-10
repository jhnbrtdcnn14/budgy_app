import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/screens/adjust_allocator_screen.dart';
import 'package:budgy_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/colors.dart';
import '../models/budget_model.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<Budget> _budgets = [];
  final NumberFormat _currencyFormatter = NumberFormat('#,##0.00');
  final DateFormat _dateFormatter = DateFormat.yMMMMd();

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await _storageService.loadBudgets();
    budgets.sort((a, b) => b.date.compareTo(a.date));
    setState(() => _budgets = budgets);
  }

  Future<void> _deleteBudget(String id) async {
    await _storageService.deleteBudget(id);
    await _loadBudgets();
  }

  Future<bool?> _showConfirmDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const AppText(
          text: 'Delete Budget',
          size: 'medium',
          color: AppColors.purple,
          isBold: true,
        ),
        content: const AppText(
          text: 'Are you sure you want to delete this entry?',
          size: 'medium',
          color: AppColors.darkgrey,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
  }

  TableRow _buildAllocationRow(String category, Map<String, dynamic> values) {
    final percentage = (values['percentage'] as double).toStringAsFixed(0);
    final amount = _currencyFormatter.format(values['amount']);
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: category, size: 'small', color: AppColors.lightpurple),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: '$percentage%', size: 'small', color: AppColors.lightpurple),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: '₱$amount', size: 'small', color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final formattedDate = _dateFormatter.format(budget.date);
    final formattedSalary = _currencyFormatter.format(budget.salary);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white.withOpacity(0.2),
      elevation: 0,
      child: ListTile(
        title: AppText(
          text: '₱$formattedSalary',
          size: "large",
          color: AppColors.white,
          isBold: true,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $formattedDate',
              style: const TextStyle(fontSize: 12, color: AppColors.lightpurple),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(flex: 1),
                1: FixedColumnWidth(60),
                2: IntrinsicColumnWidth(flex: 1),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: budget.allocation.entries.map((entry) => _buildAllocationRow(entry.key, entry.value)).toList(),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdjustAllocatorScreen(
                      budget: budget, // Pass the budget to the adjust screen
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.white),
              onPressed: () async {
                final confirm = await _showConfirmDeleteDialog();
                if (confirm == true) {
                  _deleteBudget(budget.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _budgets.isEmpty
                        ? const Center(
                            child: AppText(
                              text: 'No history yet',
                              size: "large",
                              color: AppColors.white,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _budgets.length,
                            itemBuilder: (_, index) => _buildBudgetCard(_budgets[index]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppText(
            text: 'History',
            size: "xxxlarge",
            color: AppColors.white,
            isBold: true,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
}
