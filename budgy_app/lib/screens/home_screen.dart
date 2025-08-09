import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/components/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/allocator_model.dart';
import '../models/budget_model.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Allocator> _allocators = [];
  final TextEditingController _salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllocators();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _loadAllocators() async {
    final list = await _storageService.loadAllocators();
    setState(() => _allocators = list);
  }

  double _amountFor(double salary, double percentage) => salary * percentage / 100;

  Future<void> _saveBudget() async {
    final salary = double.tryParse(_salaryController.text) ?? 0.0;
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            text: 'Please enter a valid salary',
            size: "medium",
            color: AppColors.red,
            isBold: true,
          ),
          backgroundColor: AppColors.white,
        ),
      );
      return;
    }

    final allocationMap = {
      for (var a in _allocators)
        a.name: {
          'percentage': a.percentage,
          'amount': _amountFor(salary, a.percentage),
        }
    };

    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      salary: salary,
      allocation: allocationMap,
      date: DateTime.now(),
    );

    await _storageService.saveBudget(budget);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          text: 'Budget saved for this month!',
          size: "medium",
          color: AppColors.purple,
          isBold: true,
        ),
        backgroundColor: AppColors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          UpperLeftCircularBlur(),
          LowerRightCircularBlur(),

          // Actual Home Screen UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // AppBar-like row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: 'Budgy',
                        size: "xxxlarge",
                        color: AppColors.white,
                        isBold: true,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, color: AppColors.white),
                            onPressed: () {
                              Navigator.pushNamed(context, '/history');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: AppColors.white),
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/settings');
                              await _loadAllocators();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Salary Input
                  TextField(
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    cursorColor: AppColors.white,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Salary',
                      labelStyle: TextStyle(color: AppColors.white),
                      prefixText: '₱',
                      prefixStyle: TextStyle(color: AppColors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Calculate Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: AppText(
                            text: 'Calculate',
                            size: "medium",
                            color: AppColors.purple,
                            isBold: true,
                            isCenter: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Allocator List
                  Expanded(
                    child: _allocators.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _allocators.length,
                            itemBuilder: (context, index) {
                              final a = _allocators[index];
                              final salary = double.tryParse(_salaryController.text) ?? 0.0;
                              final amt = _amountFor(salary, a.percentage);
                              final amount = formatter.format(amt);

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.purple.withOpacity(0.3),
                                elevation: 0,
                                child: ListTile(
                                  title: AppText(
                                    text: a.name,
                                    size: "medium",
                                    color: AppColors.white,
                                    isBold: true,
                                  ),
                                  subtitle: AppText(
                                    text: '${a.percentage.toStringAsFixed(0)}%',
                                    size: "small",
                                    color: AppColors.white,
                                  ),
                                  trailing: AppText(
                                    text: '₱${amount}',
                                    size: "large",
                                    color: AppColors.white,
                                    isBold: true,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),

                  // Save Button
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveBudget,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              foregroundColor: AppColors.white,
                            ),
                            child: AppText(
                              text: 'Save',
                              size: "large",
                              color: AppColors.white,
                              isBold: true,
                              isCenter: true,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class LowerRightCircularBlur extends StatelessWidget {
  const LowerRightCircularBlur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -100,
      bottom: -150,
      child: Container(
        width: 300,
        height: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(0, 0.9),
            radius: 1.2,
            colors: [
              AppColors.purple,
              AppColors.white,
            ],
            stops: [
              0.0,
              1.0
            ],
          ),
        ),
      ),
    );
  }
}

class UpperLeftCircularBlur extends StatelessWidget {
  const UpperLeftCircularBlur({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -100,
      top: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.8),
            radius: 1.2,
            colors: [
              AppColors.white,
              AppColors.purple,
            ],
            stops: [
              0.0,
              1.0
            ],
          ),
        ),
      ),
    );
  }
}

class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.2),
          radius: 1.9,
          colors: [
            AppColors.purple,
            AppColors.lightpurple,
          ],
          stops: [
            0.0,
            1.0
          ],
        ),
      ),
    );
  }
}
