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
  bool _showForm = false; // add this in your State class

  late Map<String, double> expensesPerCategory;
  late double totalExpenses;

  @override
  void initState() {
    super.initState();
    _calculateExpenses();
  }

  void _calculateExpenses() {
    expensesPerCategory = {};
    widget.budget.allocation.keys.forEach((category) {
      final totalDeducted = widget.budget.transactions.where((t) => t.category == category && t.type == 'deducted').fold(0.0, (sum, t) => sum + t.amount);

      final totalRefunded = widget.budget.transactions
          .where((t) => t.category == category && t.type == 'added') // adjust 'refunded' to your refund type if different
          .fold(0.0, (sum, t) => sum + t.amount);

      final netExpenses = totalDeducted - totalRefunded;

      expensesPerCategory[category] = netExpenses.clamp(0.0, double.infinity);
    });

    totalExpenses = expensesPerCategory.values.fold(0.0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    final double screenHeight = MediaQuery.of(context).size.height;

    // Recalculate expenses in case transactions have changed
    _calculateExpenses();

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
                // Toggle button to show/hide
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showForm = !_showForm;
                    });
                  },
                  icon: Icon(
                    _showForm ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                  ),
                  label: AppText(
                    text: _showForm ? "Hide Form" : "Add Transaction",
                    color: AppColors.white,
                    size: 'small',
                  ),
                ),
                // Retractable section
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
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
                              !_isAddition,
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
                                  return AppColors.darkpurple.withOpacity(0.2);
                                }
                                return AppColors.purple;
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return AppColors.darkpurple.withOpacity(0.2);
                                }
                                return AppColors.white;
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
                    ],
                  ),
                  crossFadeState: _showForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 25),

                if (widget.budget.transactions.isEmpty)
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: screenHeight * 0.40,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'icons/transaction.png',
                                fit: BoxFit.cover, // This makes the image fit the container
                              ),
                            ),
                          ),
                        ),
                        AppText(
                          text: 'Track your expenses and stay on top of your spending here',
                          size: "medium",
                          color: AppColors.white,
                          isCenter: true,
                        ),
                      ],
                    ),
                  ),

                // Transaction list with progress bars inside cards
                Expanded(
                  child: ListView(
                    children: widget.budget.allocation.entries.where((entry) {
                      final category = entry.key;
                      return widget.budget.transactions.any((t) => t.category == category);
                    }).map((entry) {
                      final category = entry.key;
                      final baseAmount = (entry.value['amount'] ?? 0).toDouble();

                      final List<TransactionEntry> transactions = widget.budget.transactions.where((t) => t.category == category).toList();

                      final totalAdded = transactions.where((t) => t.type == "added").fold(0.0, (sum, t) => sum + t.amount);
                      final totalDeducted = transactions.where((t) => t.type == "deducted").fold(0.0, (sum, t) => sum + t.amount);

                      final standingAmount = baseAmount + totalAdded - totalDeducted;

                      // Get expense for this category from expensesPerCategory
                      final expenseAmount = expensesPerCategory[category] ?? 0;

                      // Calculate percent for bar fill
                      final percent = baseAmount > 0 ? (expenseAmount / baseAmount).clamp(0.0, 1.0) : 0.0;

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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(
                                      text: category,
                                      size: "large",
                                      color: AppColors.white,
                                      isBold: true,
                                    ),
                                    AppText(
                                      text: formatter.format(baseAmount),
                                      size: "small",
                                      color: AppColors.lightpurple,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Transactions list per category
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

                                const SizedBox(height: 12),

                                // Progress Bar inside the card
                                if (expenseAmount != 0)
                                  Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 30,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: AppColors.black.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          Container(
                                            height: 30,
                                            width: MediaQuery.of(context).size.width * 0.7 * percent,
                                            decoration: BoxDecoration(
                                              color: AppColors.purple.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Center(
                                              child: AppText(
                                                text: "${formatter.format(expenseAmount)} / ${formatter.format(baseAmount)}",
                                                size: "xsmall",
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(
                                      text: "Remaining Balance",
                                      size: "small",
                                      color: AppColors.white,
                                    ),
                                    AppText(
                                      text: "${formatter.format(standingAmount)}",
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
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildTopBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppText(
            text: 'Tracker',
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

    setState(() {
      _controller.clear();
      _labelController.clear();
    });
  }

  // Widget buildExpenseBars() {
  //   if (expensesPerCategory.isEmpty) {
  //     return const Center(
  //       child: AppText(text: 'No expense data', size: 'medium', color: AppColors.white),
  //     );
  //   }
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: expensesPerCategory.entries.map((entry) {
  //       final category = entry.key;
  //       final expenseAmount = entry.value;
  //       final allocationAmount = (widget.budget.allocation[category]?['amount'] ?? 0).toDouble();

  //       // If allocationAmount is 0, avoid division by zero and just show empty bar
  //       final percent = allocationAmount > 0 ? (expenseAmount / allocationAmount).clamp(0.0, 1.0) : 0.0;

  //       return Padding(
  //         padding: const EdgeInsets.symmetric(vertical: 6),
  //         child: _AllocatorBar(
  //           name: category,
  //           amount: expenseAmount,
  //           percent: percent,
  //           allocationAmount: allocationAmount,
  //           formatter: NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }
}

// // Reuse this from your StatisticsScreen (or adjust to your needs)
// class _AllocatorBar extends StatelessWidget {
//   final String name;
//   final double amount; // expense amount
//   final double percent; // fraction of bar fill based on allocation
//   final double allocationAmount; // total allocated amount for the category
//   final NumberFormat formatter;

//   const _AllocatorBar({
//     Key? key,
//     required this.name,
//     required this.amount,
//     required this.percent,
//     required this.allocationAmount,
//     required this.formatter,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final barHeight = 24.0;
//     final barMaxWidth = MediaQuery.of(context).size.width * 0.7;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText(
//           text: name,
//           size: "large",
//           color: AppColors.white,
//           isBold: true,
//         ),
//         const SizedBox(height: 4),
//         Stack(
//           children: [
//             // Background bar representing allocation
//             Container(
//               height: barHeight,
//               width: barMaxWidth,
//               decoration: BoxDecoration(
//                 color: AppColors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             // Filled bar representing expense relative to allocation
//             Container(
//               height: barHeight,
//               width: barMaxWidth * percent,
//               decoration: BoxDecoration(
//                 color: AppColors.purple.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             Positioned.fill(
//               child: Center(
//                 child: AppText(
//                   // Show expense and allocation like "₱X / ₱Y"
//                   text: "${formatter.format(amount)} / ${formatter.format(allocationAmount)}",
//                   size: "small",
//                   color: AppColors.white,
//                   isBold: true,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
