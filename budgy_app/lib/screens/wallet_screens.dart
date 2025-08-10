import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/screens/budget_screen.dart';
import 'package:budgy_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/colors.dart';
import '../models/budget_model.dart';
import '../services/storage_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
          text: 'Delete Wallet',
          size: 'medium',
          color: AppColors.purple,
          isBold: true,
        ),
        content: const AppText(
          text: 'Are you sure you want to delete this wallet?',
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

  Widget _buildWalletCard(Budget budget) {
    final formattedDate = _dateFormatter.format(budget.date);
    final formattedSalary = _currencyFormatter.format(budget.salary);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: EdgeInsets.zero, // Remove default padding to match Card layout
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetScreen(
              budget: budget, // Pass the budget to the adjust screen
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                              text: 'No wallet yet',
                              size: "large",
                              color: AppColors.white,
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (_, __) => const SizedBox(height: 10), // space between items,
                            itemCount: _budgets.length,
                            itemBuilder: (_, index) => _buildWalletCard(_budgets[index]),
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
            text: 'Wallet',
            size: "xxlarge",
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
