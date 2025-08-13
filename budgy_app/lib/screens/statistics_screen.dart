import 'package:budgy_app/screens/create_wallet_screen.dart';
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

  // Percentage wallets
  Map<String, double> _totalsByAllocator = {};
  double _grandTotal = 0;

  // Custom wallets
  Map<String, double> _customTotalsByAllocator = {};
  double _customGrandTotal = 0;

  DateTime? _oldestDate;

  @override
  void initState() {
    super.initState();
    _loadAndProcessData();
  }

  Future<void> _loadAndProcessData() async {
    final wallets = await _storageService.loadWallets();
    if (wallets.isEmpty) {
      setState(() {
        _totalsByAllocator = {};
        _customTotalsByAllocator = {};
        _oldestDate = null;
        _grandTotal = 0;
        _customGrandTotal = 0;
      });
      return;
    }

    // Find oldest date
    wallets.sort((a, b) => a.date.compareTo(b.date));
    _oldestDate = wallets.first.date;

    // Separate totals
    final Map<String, double> percentTotals = {};
    final Map<String, double> customTotals = {};

    for (var wallet in wallets) {
      wallet.allocation.forEach((name, value) {
        final amount = value is Map ? (value['amount'] ?? 0).toDouble() : (value ?? 0).toDouble();

        if (wallet.isCustom) {
          customTotals[name] = (customTotals[name] ?? 0) + amount;
        } else {
          percentTotals[name] = (percentTotals[name] ?? 0) + amount;
        }
      });
    }

    final percentGrandTotal = percentTotals.values.fold<double>(0, (sum, v) => sum + v);
    final customGrandTotal = customTotals.values.fold<double>(0, (sum, v) => sum + v);

    setState(() {
      _totalsByAllocator = percentTotals;
      _customTotalsByAllocator = customTotals;
      _grandTotal = percentGrandTotal;
      _customGrandTotal = customGrandTotal;
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
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_rounded, color: AppColors.primaryLight),
                            onPressed: () {
                              Navigator.pop(context, '/wallet');
                            },
                          ),
                        ],
                      ),
                      AppText(
                        text: 'Statistics',
                        size: "xxlarge",
                        color: AppColors.primaryLight,
                        isBold: true,
                      ),
                      SizedBox.square(
                        dimension: 30,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Oldest date indicator
                  if (_oldestDate != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AppText(
                        text: 'Summary from ${DateFormat.yMMMMd().format(_oldestDate!)} to present',
                        size: "xsmall",
                        color: AppColors.primaryLight,
                      ),
                    ),

                  // Body content
                  Expanded(
                    child: ListView(
                      children: [
                        if (_totalsByAllocator.isNotEmpty) ...[
                          AppText(
                            text: "Percentage Wallets",
                            size: "large",
                            color: AppColors.primaryLight,
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          ..._totalsByAllocator.entries.map((entry) {
                            final percent = (_grandTotal == 0) ? 0.0 : (entry.value / _grandTotal).clamp(0.0, 1.0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _AllocatorBar(
                                name: entry.key,
                                amount: entry.value,
                                percent: percent,
                                formatter: formatter,
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                        ],
                        if (_customTotalsByAllocator.isNotEmpty) ...[
                          Divider(
                            color: AppColors.tertiaryLight,
                          ),
                          const SizedBox(height: 20),
                          AppText(
                            text: "Custom Wallets",
                            size: "large",
                            color: AppColors.primaryLight,
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          ..._customTotalsByAllocator.entries.map((entry) {
                            final percent = (_customGrandTotal == 0) ? 0.0 : (entry.value / _customGrandTotal).clamp(0.0, 1.0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _AllocatorBar(
                                name: entry.key,
                                amount: entry.value,
                                percent: percent,
                                formatter: formatter,
                              ),
                            );
                          }),
                        ],
                      ],
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
          size: "small",
          color: AppColors.secondaryLight,
          isBold: true,
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.tertiaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: barHeight,
              width: MediaQuery.of(context).size.width * percent,
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: AppText(
                  text: formatter.format(amount),
                  size: "medium",
                  color: AppColors.primaryLight,
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
