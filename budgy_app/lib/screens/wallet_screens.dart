import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/screens/budget_screen.dart';
import 'package:budgy_app/screens/create_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/colors.dart';
import '../models/wallet_model.dart';
import '../services/storage_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final StorageService _storageService = StorageService();
  List<Wallet> _wallets = [];

  final NumberFormat _currencyFormatter = NumberFormat('#,##0.00');
  final DateFormat _dateFormatter = DateFormat.yMMMMd();

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final wallets = await _storageService.loadWallets();
    wallets.sort((a, b) => b.date.compareTo(a.date));
    setState(() => _wallets = wallets);
  }

  Future<void> _deleteBudget(String id) async {
    await _storageService.deleteBudget(id);
    await _loadWallets();
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

  TableRow _buildAllocationRow(String category, dynamic values, {bool isCustom = false}) {
    final double amountValue = isCustom ? (values ?? 0.0) as double : (values['amount'] ?? 0.0) as double;

    final amount = _currencyFormatter.format(amountValue);

    final percentageText = isCustom ? '-' : '${((values['value'] ?? 0.0) as double).toStringAsFixed(0)}%';
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: category, size: 'small', color: AppColors.secondaryLight),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: percentageText, size: 'small', color: AppColors.secondaryLight),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: AppText(text: '₱$amount', size: 'small', color: AppColors.secondaryLight),
        ),
      ],
    );
  }

  Widget _buildWalletCard(Wallet budget) {
    final formattedDate = _dateFormatter.format(budget.date);
    final formattedSalary = budget.salary != null ? _currencyFormatter.format(budget.salary) : 'Custom Wallet'; // label for custom wallet

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetScreen(budget: budget),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: AppText(
            text: budget.salary != null ? '₱$formattedSalary' : formattedSalary,
            size: "large",
            color: AppColors.primaryLight,
            isBold: true,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedDate',
                style: TextStyle(fontSize: 12, color: AppColors.secondaryLight),
              ),
              const SizedBox(height: 8),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(flex: 1),
                  1: FixedColumnWidth(60),
                  2: IntrinsicColumnWidth(flex: 1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: budget.allocation.entries
                    .map((entry) => _buildAllocationRow(
                          entry.key,
                          entry.value,
                          isCustom: budget.isCustom,
                        ))
                    .toList(),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: AppColors.primaryLight),
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
                  if (!_wallets.isEmpty)
                    Column(
                      children: [
                        AppText(text: 'Wallet', size: 'medium', color: AppColors.primaryLight),
                        const SizedBox(height: 20),
                      ],
                    ),
                  Expanded(
                    child: _wallets.isEmpty
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
                            itemCount: _wallets.length,
                            itemBuilder: (_, index) => _buildWalletCard(_wallets[index]),
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
              onPressed: () => _showWalletTypeSelector(context),
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
                icon: Icon(Icons.bar_chart_rounded, color: AppColors.primaryLight),
                onPressed: () {
                  Navigator.pushNamed(context, '/statistic');
                },
              ),
              IconButton(
                icon: Icon(Icons.settings_rounded, color: AppColors.primaryLight),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ],
      );

  void _showWalletTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryDark.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: "Choose Wallet Type",
                size: "large",
                isBold: true,
                color: AppColors.primaryLight,
              ),
              const SizedBox(height: 16),

              // Percentage Wallet Card
              _WalletTypeCard(
                title: "Percentage Wallet",
                description: "Set your total amount and allocate by percentages.\nBudgets adjust automatically when your amount changes.",
                preview: {
                  "Bills": "50%",
                  "Savings": "30%",
                  "Leisure": "20%",
                },
                onTap: () {
                  Navigator.pushNamed(context, '/create_wallet');
                },
              ),
              const SizedBox(height: 12),

              // Custom Wallet Card
              _WalletTypeCard(
                title: "Custom Wallet",
                description: "Manually set categories and fixed amounts.\nPerfect for exact monthly budgets.",
                preview: {
                  "Rent": "₱6,000",
                  "Food": "₱5,000",
                },
                onTap: () {
                  Navigator.pushNamed(context, '/custom_wallet');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalletTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final Map<String, String> preview;
  final VoidCallback onTap;

  const _WalletTypeCard({
    required this.title,
    required this.description,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              size: "medium",
              color: AppColors.primaryLight,
              isBold: true,
            ),
            const SizedBox(height: 6),
            AppText(
              text: description,
              size: "xsmall",
              color: AppColors.secondaryLight,
            ),
            const SizedBox(height: 10),

            // Preview Row
            Column(
              children: preview.entries
                  .map((e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            text: e.key,
                            size: "xsmall",
                            color: AppColors.primaryLight,
                          ),
                          AppText(
                            text: e.value,
                            size: "xsmall",
                            color: AppColors.primaryLight,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
