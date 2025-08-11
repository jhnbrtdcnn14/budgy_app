import 'package:budgy_app/screens/calculation_screen.dart';
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
    final double screenHeight = MediaQuery.of(context).size.height;

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
                                        'icons/statistics.png',
                                        fit: BoxFit.cover, // This makes the image fit the container
                                      ),
                                    ),
                                  ),
                                ),
                                AppText(
                                  text: 'Here’s where you can view all your accumulated amounts by allocation.',
                                  size: "medium",
                                  color: AppColors.white,
                                  isCenter: true,
                                ),
                              ],
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
