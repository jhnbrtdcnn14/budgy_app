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
                    color: AppColors.primaryLight,
                  ),
                  label: AppText(
                    text: _showForm ? "Hide Form" : "Add Transaction",
                    color: AppColors.primaryLight,
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
                                    color: AppColors.primaryLight,
                                    size: 'small',
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedAllocator = value),
                        decoration:  InputDecoration(
                          labelText: "Select Category",
                          labelStyle: TextStyle(color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _labelController,
                        decoration:  InputDecoration(
                          labelText: "Label",
                          labelStyle: TextStyle(color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration:  InputDecoration(
                          labelText: "Amount",
                          labelStyle: TextStyle(color: AppColors.primaryLight),
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
                            children:  [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: AppText(
                                  text: "Add",
                                  color: AppColors.primaryLight,
                                  size: 'small',
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: AppText(
                                  text: "Deduct",
                                  color: AppColors.primaryLight,
                                  size: 'small',
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _selectedAllocator == null || _controller.text.isEmpty || _labelController.text.isEmpty ? null : _saveTransaction,
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
                                return AppColors.primaryDark;
                              }),
                            ),
                            child: AppText(
                              text: "Confirm",
                              color: AppColors.primaryLight,
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
                  Column(
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
                              'icons/transaction.png',
                              fit: BoxFit.cover, // This makes the image fit the container
                            ),
                          ),
                        ),
                      ),
                      AppText(
                        text: 'Track your expenses and stay on top of your spending here',
                        size: "small",
                        color: AppColors.primaryLight,
                        isCenter: true,
                      ),
                    ],
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
                          color: AppColors.primaryLight.withOpacity(0.1),
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
                                      color: AppColors.primaryLight,
                                      isBold: true,
                                    ),
                                    AppText(
                                      text: formatter.format(baseAmount),
                                      size: "small",
                                      color: AppColors.primaryLight,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Transactions list per category
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(1), // left
                                    1: FlexColumnWidth(1), // center
                                    2: FlexColumnWidth(1), // right
                                  },
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  children: transactions.map((t) {
                                    final isAdd = t.type == "added";
                                    return TableRow(
                                      children: [
                                        // LEFT - Align left
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: AppText(
                                            text: DateFormat('MMM d, yyyy').format(t.date),
                                            size: "small",
                                            color: isAdd ? AppColors.green : AppColors.red,
                                          ),
                                        ),
                                        // CENTER - Align right
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AppText(
                                            text: t.label,
                                            size: "xsmall",
                                            color: isAdd ? AppColors.green : AppColors.red,
                                          ),
                                        ),
                                        // RIGHT - Align right
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: AppText(
                                            text: "${isAdd ? '+' : '-'} ${formatter.format(t.amount)}",
                                            size: "small",
                                            color: isAdd ? AppColors.green : AppColors.red,
                                          ),
                                        ),
                                      ],
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
                                              color: AppColors.tertiaryLight,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Container(
                                                height: 30,
                                                width: constraints.maxWidth * percent,
                                                decoration: BoxDecoration(
                                                  color: expenseAmount > baseAmount ? AppColors.red : AppColors.purple.withOpacity(0.8),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              );
                                            },
                                          ),
                                          Positioned.fill(
                                            child: Center(
                                              child: AppText(
                                                text: "${formatter.format(expenseAmount)} / ${formatter.format(baseAmount)}",
                                                size: "xsmall",
                                                color: AppColors.primaryLight,
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
                                      text: expenseAmount > baseAmount ? "You have overspent" : "Remaining Balance",
                                      size: "small",
                                      color: AppColors.primaryLight,
                                    ),
                                    AppText(
                                      text: "${formatter.format(standingAmount.abs())}",
                                      size: "small",
                                      color: AppColors.primaryLight,
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
           IconButton(
            icon:  Icon(Icons.arrow_back, color: AppColors.primaryLight),
            onPressed: () => Navigator.pop(context),
          ),
          AppText(
            text: 'Tracker',
            size: "xxlarge",
            color: AppColors.primaryLight,
            isBold: true,
          ),
         
           SizedBox.square(
                        dimension: 30,
                      )
        ],
      );

  Future<void> _saveTransaction() async {
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

    await _storageService.saveTransaction(
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
  //       child: AppText(text: 'No expense data', size: 'medium', color: AppColors.primaryLight),
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
//           color: AppColors.primaryLight,
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
//                 color: AppColors.primaryLight.withOpacity(0.2),
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
//                   color: AppColors.primaryLight,
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
