import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/widgets/allocator_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
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
  final NumberFormat _formatter = NumberFormat('#,##0.00');

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

  double? _parseSalary() {
    String rawText = _salaryController.text;
    // Remove ₱ and commas
    rawText = rawText.replaceAll('₱', '').replaceAll(',', '').trim();
    final salary = double.tryParse(rawText);
    if (salary == null || salary <= 0) return null;
    return salary;
  }

  void _showSnackBar(String message, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          text: message,
          size: "medium",
          color: textColor,
          isBold: true,
        ),
        backgroundColor: AppColors.white,
      ),
    );
  }

  Future<void> _saveBudget() async {
    final salary = _parseSalary();
    if (salary == null) {
      _showSnackBar('Please enter a valid salary', AppColors.red);
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

    _showSnackBar('Budget saved to budget!', AppColors.purple);

    _salaryController.clear();
    setState(() {});
  }

  void _onCalculatePressed() {
    final salary = _parseSalary();
    if (salary == null) {
      _showSnackBar('Please enter a valid salary', AppColors.red);
      return;
    }
    setState(() {});
  }

  String _formattedAmount(double salary, Allocator allocator) {
    final amt = _amountFor(salary, allocator.percentage);
    return _formatter.format(amt);
  }

  @override
  Widget build(BuildContext context) {
    final salary = _parseSalary() ?? 0.0;

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 20),
                  _buildSalaryInput(),
                  const SizedBox(height: 12),
                  _buildCalculateButton(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _allocators.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _allocators.length,
                            itemBuilder: (context, index) {
                              final allocator = _allocators[index];
                              final formattedAmount = _formattedAmount(salary, allocator);
                              return AllocatorCard(
                                allocator: allocator,
                                formattedAmount: formattedAmount,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppText(
            text: 'Budgy',
            size: "xxxlarge",
            color: AppColors.white,
            isBold: true,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: AppColors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/statistic');
                },
              ),
              IconButton(
                icon: const Icon(Icons.percent_rounded, color: AppColors.white),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/settings');
                  await _loadAllocators();
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/wallet');
                },
              ),
            ],
          ),
        ],
      );

  Widget _buildSalaryInput() => TextField(
        controller: _salaryController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          CurrencyInputFormatter(
            leadingSymbol: '₱',
            useSymbolPadding: true,
            thousandSeparator: ThousandSeparator.Comma,
            mantissaLength: 0, // no decimal places for salary
          ),
        ],
        cursorColor: AppColors.white,
        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 25),
        decoration: const InputDecoration(
          labelText: 'Input Salary',
          labelStyle: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.white, width: 3),
          ),
        ),
      );

  Widget _buildCalculateButton() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.white,
              ),
              onPressed: _onCalculatePressed,
              child: const AppText(
                text: 'Calculate',
                size: "medium",
                color: AppColors.lightergrey,
                isBold: true,
                isCenter: true,
              ),
            ),
          ),
        ],
      );

  Widget _buildSaveButton() => Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: AppColors.purple,
                  foregroundColor: AppColors.white,
                ),
                child: const AppText(
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
      );
}

class LowerRightCircularBlur extends StatelessWidget {
  const LowerRightCircularBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -100,
      bottom: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(0.5, 0.9),
            radius: 1.2,
            colors: [
              AppColors.black,
              AppColors.darkpurple,
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
  const UpperLeftCircularBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -100,
      top: -150,
      child: Container(
        width: 300,
        height: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.8),
            radius: 1.2,
            colors: [
              AppColors.black,
              AppColors.darkpurple,
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
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.2),
          radius: 1.9,
          colors: [
            AppColors.black,
            AppColors.darkpurple
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
