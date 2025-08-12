import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/screens/budget_screen.dart';
import 'package:budgy_app/screens/calculation_screen.dart';
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
        backgroundColor: AppColors.primaryLight,
        title: AppText(
          text: 'Delete Wallet',
          size: 'medium',
          color: AppColors.purple,
          isBold: true,
        ),
        content: AppText(
          text: 'Are you sure you want to delete this wallet?',
          size: 'medium',
          color: AppColors.primaryDark,
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
          child: AppText(text: category, size: 'small', color: AppColors.secondaryLight),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: '$percentage%', size: 'small', color: AppColors.secondaryLight),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: '₱$amount', size: 'small', color: AppColors.secondaryLight),
        ),
      ],
    );
  }

  Widget _buildWalletCard(Budget budget) {
    final formattedDate = _dateFormatter.format(budget.date);
    final formattedSalary = _currencyFormatter.format(budget.salary);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight.withOpacity(0.1),
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
            color: AppColors.primaryLight,
            isBold: true,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedDate',
                style:  TextStyle(fontSize: 12, color: AppColors.secondaryLight),
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
                icon:  Icon(Icons.delete, color: AppColors.primaryLight),
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
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 20),
                  if (!_budgets.isEmpty)
                    Column(
                      children: [
                        AppText(text: 'Wallet', size: 'medium', color: AppColors.primaryLight),
                        const SizedBox(height: 20),
                      ],
                    ),
                  Expanded(
                    child: _budgets.isEmpty
                        ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox.square(
                                  dimension: screenHeight * 0.30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.asset(
                                        'icons/wallet.png',
                                        fit: BoxFit.cover, // This makes the image fit the container
                                      ),
                                    ),
                                  ),
                                ),
                                AppText(
                                  text: 'Hit the add button and create your wallet today!',
                                  size: "medium",
                                  color: AppColors.primaryLight,
                                  isCenter: true,
                                ),
                                SizedBox(
                                  height: 200,
                                )
                              ],
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
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/calculation');
              },
              backgroundColor: AppColors.purple,
              child: Icon(
                Icons.add,
                color: AppColors.textButton,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: 'Budgy',
            size: "xxxlarge",
            color: AppColors.primaryLight,
            isBold: true,
          ),
          Row(
            children: [
              IconButton(
                icon:  Icon(Icons.bar_chart_rounded, color: AppColors.primaryLight),
                onPressed: () {
                  Navigator.pushNamed(context, '/statistic');
                },
              ),
               IconButton(
                icon:  Icon(Icons.settings_rounded, color: AppColors.primaryLight),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ],
      );
}
