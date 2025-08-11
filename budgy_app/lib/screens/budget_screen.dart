import 'package:budgy_app/models/budget_transaction_model.dart';
import 'package:budgy_app/screens/calculation_screen.dart';
import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/text.dart';
import '../models/budget_model.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  final Budget budget;
  const BudgetScreen({super.key, required this.budget});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final StorageService _storageService = StorageService();
  final _controller = TextEditingController();
  final _labelController = TextEditingController();
  String? _selectedAllocator;
  bool _isAddition = true;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedAllocator,
                    items: widget.budget.allocation.keys
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: AppText(
                                text: name,
                                color: AppColors.white,
                                size: 'small',
                              ),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedAllocator = value),
                    decoration: const InputDecoration(
                      labelText: "Select Category",
                      labelStyle: TextStyle(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: "Label",
                      labelStyle: TextStyle(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      labelStyle: TextStyle(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ToggleButtons(
                        isSelected: [
                          _isAddition,
                          !_isAddition
                        ],
                        onPressed: (index) {
                          setState(() {
                            _isAddition = index == 0;
                          });
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: AppText(
                              text: "Add",
                              color: AppColors.white,
                              size: 'small',
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: AppText(
                              text: "Deduct",
                              color: AppColors.white,
                              size: 'small',
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _selectedAllocator == null || _controller.text.isEmpty || _labelController.text.isEmpty ? null : _adjustAmount,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return AppColors.darkpurple.withOpacity(0.2); // disabled background color (dark grey)
                            }
                            return AppColors.purple; // enabled background color (use your brand color)
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return AppColors.darkpurple.withOpacity(0.2); // disabled background color (dark grey)
                            }
                            return AppColors.white; // enabled text color (white)
                          }),
                        ),
                        child: const AppText(
                          text: "Confirm",
                          color: AppColors.white,
                          size: 'small',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AppText(text: 'Transactions', size: 'medium', color: AppColors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: widget.budget.allocation.entries.where((entry) {
                        final category = entry.key;
                        // Check if there are transactions for this category
                        return widget.budget.transactions.any((t) => t.category == category);
                      }).map((entry) {
                        final category = entry.key;
                        final baseAmount = entry.value['amount'] ?? 0;

                        // Filter transactions by category
                        final List<TransactionEntry> transactions = widget.budget.transactions.where((t) => t.category == category).toList();

                        final totalAdded = transactions.where((t) => t.type == "added").fold(0.0, (sum, t) => sum + t.amount);

                        final totalDeducted = transactions.where((t) => t.type == "deducted").fold(0.0, (sum, t) => sum + t.amount);

                        final standingAmount = baseAmount + totalAdded - totalDeducted;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: AppColors.white.withOpacity(0.1),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AppText(
                                        text: category,
                                        size: "large",
                                        color: AppColors.white,
                                        isBold: true,
                                      ),
                                      const SizedBox(width: 10),
                                      AppText(
                                        text: formatter.format(baseAmount),
                                        size: "small",
                                        color: AppColors.lightpurple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    children: transactions.map((t) {
                                      final isAdd = t.type == "added";
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText(
                                              text: t.label,
                                              size: "xsmall",
                                              color: isAdd ? AppColors.green : AppColors.red,
                                            ),
                                            AppText(
                                              text: "${isAdd ? '+' : '-'} ${formatter.format(t.amount)}",
                                              size: "small",
                                              color: isAdd ? AppColors.green : AppColors.red,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                        text: "Balance",
                                        size: "small",
                                        color: AppColors.white,
                                      ),
                                      AppText(
                                        text: "= ${formatter.format(standingAmount)}",
                                        size: "small",
                                        color: AppColors.white,
                                        isBold: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
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
            text: 'Budget',
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

  Future<void> _adjustAmount() async {
    final double value = double.tryParse(_controller.text) ?? 0;
    if (value <= 0 || _selectedAllocator == null) return;

    final category = _selectedAllocator!;
    final label = _labelController.text.trim();

    final transaction = TransactionEntry(
      id: UniqueKey().toString(),
      category: category,
      amount: value,
      label: label.isEmpty ? 'No label' : label,
      date: DateTime.now(),
      type: _isAddition ? 'added' : 'deducted',
    );

    // Add to in-memory model as well
    widget.budget.addTransaction(transaction);

    await _storageService.updateBudget(
      widget.budget,
      category,
      _isAddition ? value : -value,
      label: label,
      transactionEntry: transaction,
    );

    setState(() {});
    _controller.clear();
    _labelController.clear();
  }
}
