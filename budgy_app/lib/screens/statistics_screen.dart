import 'package:budgy_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/colors.dart';
import '../components/text.dart';
import '../services/storage_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storageService = StorageService();

  Map<String, double> _totalsByAllocator = {};
  DateTime? _oldestDate;
  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadAndProcessData();
  }

  Future<void> _loadAndProcessData() async {
    final budgets = await _storageService.loadBudgets();
    if (budgets.isEmpty) {
      setState(() {
        _totalsByAllocator = {};
        _oldestDate = null;
        _grandTotal = 0;
      });
      return;
    }

    // Find oldest date
    budgets.sort((a, b) => a.date.compareTo(b.date));
    _oldestDate = budgets.first.date;

    // Sum allocations per allocator name
    final Map<String, double> totals = {};
    for (var budget in budgets) {
      budget.allocation.forEach((name, data) {
        final amount = (data['amount'] ?? 0).toDouble();
        totals[name] = (totals[name] ?? 0) + amount;
      });
    }

    // Compute grand total
    final grandTotal = totals.values.fold<double>(0, (sum, v) => sum + v);

    setState(() {
      _totalsByAllocator = totals;
      _oldestDate = _oldestDate;
      _grandTotal = grandTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar-like Top Row (matching Settings and Home)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: 'Statistics',
                        size: "xxlarge",
                        color: AppColors.white,
                        isBold: true,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Oldest date indicator
                  if (_oldestDate != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AppText(
                        text: 'Summary from ${DateFormat.yMMMMd().format(_oldestDate!)} to present',
                        size: "small",
                        color: AppColors.white,
                        isBold: true,
                      ),
                    ),

                  // Body content
                  Expanded(
                    child: _totalsByAllocator.isEmpty
                        ? Center(
                            child: AppText(
                              text: 'No data available',
                              size: "large",
                              color: AppColors.white,
                            ),
                          )
                        : ListView.separated(
                            itemCount: _totalsByAllocator.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final name = _totalsByAllocator.keys.elementAt(index);
                              final amount = _totalsByAllocator[name]!;
                              final percent = (_grandTotal == 0) ? 0.0 : (amount / _grandTotal).clamp(0.0, 1.0);

                              return _AllocatorBar(
                                name: name,
                                amount: amount,
                                percent: percent,
                                formatter: formatter,
                              );
                            },
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
}

class _AllocatorBar extends StatelessWidget {
  final String name;
  final double amount;
  final double percent;
  final NumberFormat formatter;

  const _AllocatorBar({
    required this.name,
    required this.amount,
    required this.percent,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = 60.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: name,
          size: "large",
          color: AppColors.white,
          isBold: true,
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: barHeight,
              width: MediaQuery.of(context).size.width * percent,
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: AppText(
                  text: formatter.format(amount),
                  size: "medium",
                  color: AppColors.white,
                  isBold: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../components/colors.dart';
// import '../components/text.dart';
// import '../models/budget_model.dart';
// import '../services/storage_service.dart';
// import '../screens/home_screen.dart';

// class StatisticsScreen extends StatefulWidget {
//   const StatisticsScreen({super.key});

//   @override
//   State<StatisticsScreen> createState() => _StatisticsScreenState();
// }

// class _StatisticsScreenState extends State<StatisticsScreen> {
//   final StorageService _storageService = StorageService();

//   Map<String, double> _totalsByAllocator = {};
//   Map<String, double> _adjustments = {};
//   DateTime? _oldestDate;
//   double _grandTotal = 0;

//   final _formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

//   @override
//   void initState() {
//     super.initState();
//     _loadAndProcessData();
//   }

//   Future<void> _loadAndProcessData() async {
//     final budgets = await _safeLoadBudgets();
//     if (budgets.isEmpty) {
//       _resetState();
//       return;
//     }

//     budgets.sort((a, b) => a.date.compareTo(b.date));
//     final totals = _calculateTotals(budgets);

//     final adjustments = await _storageService.loadAllocatorAdjustments();
//     adjustments.forEach((key, value) {
//       totals[key] = (totals[key] ?? 0) + value;
//     });

//     setState(() {
//       _totalsByAllocator = totals;
//       _adjustments = adjustments;
//       _oldestDate = budgets.first.date;
//       _grandTotal = totals.values.fold(0, (s, v) => s + v);
//     });
//   }

//   Future<List<Budget>> _safeLoadBudgets() async {
//     try {
//       return await _storageService.loadBudgets();
//     } catch (_) {
//       return [];
//     }
//   }

//   Map<String, double> _calculateTotals(List<Budget> budgets) {
//     final totals = <String, double>{};
//     for (var budget in budgets) {
//       budget.allocation.forEach((name, data) {
//         totals[name] = (totals[name] ?? 0) + (data['amount'] ?? 0).toDouble();
//       });
//     }
//     return totals;
//   }

//   void _resetState() {
//     setState(() {
//       _totalsByAllocator.clear();
//       _adjustments.clear();
//       _oldestDate = null;
//       _grandTotal = 0;
//     });
//   }

//   Future<void> _openAdjustDialog(String allocatorName) async {
//     final controller = TextEditingController();
//     bool isAddition = true;

//     await showDialog(
//       context: context,
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, setLocalState) {
//           final currentTotal = _totalsByAllocator[allocatorName] ?? 0;
//           // final currentAdjustment = _adjustments[allocatorName] ?? 0;

//           return AlertDialog(
//             backgroundColor: AppColors.white,
//             title: AppText(
//               text: 'Adjust "$allocatorName"',
//               size: 'medium',
//               color: AppColors.purple,
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AppText(
//                   text: 'Current total: ${_formatter.format(currentTotal)}',
//                   size: 'small',
//                   color: AppColors.darkgrey,
//                 ),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: controller,
//                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                   decoration: const InputDecoration(
//                     labelText: 'Amount',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     _adjustButton('Add', isAddition, AppColors.purple, () => setLocalState(() => isAddition = true)),
//                     const SizedBox(width: 8),
//                     _adjustButton('Deduct', !isAddition, AppColors.red, () => setLocalState(() => isAddition = false)),
//                   ],
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
//               TextButton(
//                 onPressed: () async {
//                   final value = double.tryParse(controller.text.trim()) ?? 0;
//                   if (value <= 0) {
//                     _showSnack('Enter a valid amount', AppColors.red);
//                     return;
//                   }
//                   await _applyAdjustment(allocatorName, value, isAddition);
//                   Navigator.pop(ctx);
//                 },
//                 child: const Text('Save'),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _adjustButton(String label, bool active, Color color, VoidCallback onPressed) {
//     return Expanded(
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: active ? color : AppColors.white.withOpacity(0.15),
//         ),
//         onPressed: onPressed,
//         child: AppText(text: label, size: 'small', color: AppColors.white),
//       ),
//     );
//   }

//   Future<void> _applyAdjustment(String name, double value, bool isAddition) async {
//     final delta = isAddition ? value : -value;
//     final prev = _adjustments[name] ?? 0;
//     final updatedAdjustment = prev + delta;

//     final newAdjustments = {..._adjustments, name: updatedAdjustment};
//     await _storageService.saveAllocatorAdjustments(newAdjustments);

//     setState(() {
//       _adjustments = newAdjustments;
//       final base = (_totalsByAllocator[name] ?? 0) - prev;
//       _totalsByAllocator[name] = base + updatedAdjustment;
//       _grandTotal = _totalsByAllocator.values.fold(0, (s, v) => s + v);
//     });

//     _showSnack('${isAddition ? "Added" : "Deducted"} ${_formatter.format(value)} to $name', AppColors.purple);
//   }

//   void _showSnack(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: AppText(text: message, size: 'medium', color: color, isBold: true),
//         backgroundColor: AppColors.white,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           const FuturisticBackground(),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildHeader(context),
//                   const SizedBox(height: 20),
//                   if (_oldestDate != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: AppText(
//                         text: 'Summary from ${DateFormat.yMMMMd().format(_oldestDate!)} to present',
//                         size: "small",
//                         color: AppColors.white,
//                         isBold: true,
//                       ),
//                     ),
//                   _buildGrandTotalCard(),
//                   const SizedBox(height: 16),
//                   _buildAllocatorList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const AppText(
//           text: 'Statistics',
//           size: "xxxlarge",
//           color: AppColors.white,
//           isBold: true,
//         ),
//         IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ],
//     );
//   }

//   Widget _buildGrandTotalCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//       decoration: BoxDecoration(
//         color: AppColors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           AppText(text: 'Grand total', size: 'medium', color: AppColors.white, isBold: true),
//           AppText(text: _formatter.format(_grandTotal), size: 'medium', color: AppColors.white, isBold: true),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllocatorList() {
//     if (_totalsByAllocator.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: AppText(text: 'No data available', size: "large", color: AppColors.white),
//         ),
//       );
//     }

//     return Expanded(
//       child: ListView.separated(
//         itemCount: _totalsByAllocator.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 14),
//         itemBuilder: (context, index) {
//           final name = _totalsByAllocator.keys.elementAt(index);
//           final amount = _totalsByAllocator[name]!;
//           final percent = (_grandTotal <= 0) ? 0.0 : (amount / _grandTotal).clamp(0.0, 1.0);

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildAllocatorHeader(name),
//               const SizedBox(height: 6),
//               _AllocatorBar(name: name, amount: amount, percent: percent, formatter: _formatter),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAllocatorHeader(String name) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         AppText(text: name, size: "large", color: AppColors.white, isBold: true),
//         Row(
//           children: [
//             if ((_adjustments[name] ?? 0) != 0)
//               AppText(
//                 text: '${(_adjustments[name]! >= 0 ? '+' : '')}${_formatter.format(_adjustments[name]!.abs())}',
//                 size: 'small',
//                 color: AppColors.white,
//               ),
//             IconButton(
//               icon: const Icon(Icons.edit, color: AppColors.white),
//               onPressed: () => _openAdjustDialog(name),
//               tooltip: 'Add / Deduct amount',
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _AllocatorBar extends StatelessWidget {
//   final String name;
//   final double amount;
//   final double percent;
//   final NumberFormat formatter;

//   const _AllocatorBar({
//     required this.name,
//     required this.amount,
//     required this.percent,
//     required this.formatter,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final barHeight = 60.0;
//     final width = MediaQuery.of(context).size.width;

//     return Stack(
//       children: [
//         Container(
//           height: barHeight,
//           decoration: BoxDecoration(
//             color: AppColors.white.withOpacity(0.18),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 500),
//           height: barHeight,
//           width: width * percent,
//           decoration: BoxDecoration(
//             color: AppColors.purple.withOpacity(0.85),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         Positioned.fill(
//           child: Center(
//             child: AppText(
//               text: formatter.format(amount),
//               size: "medium",
//               color: AppColors.white,
//               isBold: true,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
