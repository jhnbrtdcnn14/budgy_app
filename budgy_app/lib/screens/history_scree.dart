import 'package:budgy_app/components/text.dart';
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

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final list = await _storageService.loadBudgets();
    list.sort((a, b) => b.date.compareTo(a.date)); // newest first
    setState(() => _budgets = list);
  }

  Future<void> _deleteBudget(String id) async {
    await _storageService.deleteBudget(id);
    await _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          // UpperLeftCircularBlur(),
          // LowerRightCircularBlur(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
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
                  ),
                  const SizedBox(height: 20),

                  // History List
                  Expanded(
                    child: _budgets.isEmpty
                        ? Center(
                            child: AppText(
                              text: 'No history yet',
                              size: "large",
                              color: AppColors.white,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _budgets.length,
                            itemBuilder: (context, index) {
                              final b = _budgets[index];
                              final dateStr = DateFormat.yMMMMd().format(b.date);
                              final amount = formatter.format(b.salary);
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: AppColors.white, // Transparent
                                elevation: 0,
                                child: ListTile(
                                  title: AppText(
                                    text: '₱${amount}',
                                    size: "large",
                                    color: AppColors.darkgrey,
                                    isBold: true,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date: $dateStr',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.lightergrey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Table(
                                        columnWidths: const {
                                          0: IntrinsicColumnWidth(flex: 1), // Category column
                                          1: FixedColumnWidth(60), // Percentage column
                                          2: IntrinsicColumnWidth(flex: 1), // Amount column
                                        },
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        children: b.allocation.entries.map((e) {
                                          final percentage = e.value['percentage']!.toStringAsFixed(0); // no .0
                                          final amount = formatter.format(e.value['amount']);
                                          return TableRow(
                                            children: [
                                              Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: AppText(text: e.key, size: 'small', color: AppColors.lightergrey)),
                                              Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: AppText(text: '$percentage%', size: 'small', color: AppColors.lightergrey)),
                                              Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: AppText(
                                                    text: '₱$amount',
                                                    size: 'small',
                                                    color: AppColors.lightergrey,
                                                  )),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.white),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: AppColors.white,
                                          title: AppText(text: 'Delete Budget', size: 'medium', color: AppColors.purple),
                                          content: AppText(text: 'Are you sure you want to delete this entry?', size: 'medium', color: AppColors.darkgrey),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        _deleteBudget(b.id);
                                      }
                                    },
                                  ),
                                ),
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
