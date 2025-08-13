import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/widgets/allocator_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import '../models/allocator_model.dart';
import '../models/wallet_model.dart';
import '../services/storage_service.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
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

  double _amountFor(double salary, double value) => salary * value / 100;

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
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  Future<void> _saveWallet() async {
    final salary = _parseSalary();
    if (salary == null) {
      _showSnackBar('Please enter a valid salary', AppColors.red);
      return;
    }

    final allocationMap = {
      for (var a in _allocators)
        a.name: {
          'value': a.value,
          'amount': _amountFor(salary, a.value),
        }
    };

    final wallet = Wallet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      salary: salary,
      allocation: allocationMap,
      date: DateTime.now(),
    );

    await _storageService.saveWallet(wallet);

    _showSnackBar('Wallet saved!', AppColors.purple);

    _salaryController.clear();
    setState(() {});
    Navigator.pushReplacementNamed(context, '/wallet');
  }

  void _onAmountChange() {
    final salary = _parseSalary();
    if (salary == null) {
      _showSnackBar('Please enter a valid salary', AppColors.red);
      return;
    }
    setState(() {});
  }

  String _formattedAmount(double salary, Allocator allocator) {
    final amt = _amountFor(salary, allocator.value);
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  AppText(text: "Set your total amount and allocate by percentages.\nBudget adjust automatically when your amount changes." "", size: 'xsmall', color: AppColors.secondaryLight),
                  const SizedBox(height: 20),
                  _buildSalaryInput(),
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

  Widget _buildTopBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute horizontally

              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
                AppText(
                  text: 'Percentage Wallet',
                  size: "xlarge",
                  color: AppColors.primaryLight,
                  isBold: true,
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primaryLight),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/allocations');
                    await _loadAllocators();
                  },
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildSalaryInput() => TextField(
        controller: _salaryController,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _onAmountChange();
        },
        inputFormatters: [
          CurrencyInputFormatter(
            leadingSymbol: '₱',
            useSymbolPadding: true,
            thousandSeparator: ThousandSeparator.Comma,
            mantissaLength: 0, // no decimal places for salary
          ),
        ],
        cursorColor: AppColors.primaryLight,
        style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 25),
        decoration: InputDecoration(
          labelText: 'Input Amount',
          labelStyle: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryLight, width: 3),
          ),
        ),
      );

  Widget _buildSaveButton() => Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveWallet,
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: AppColors.purple,
                  foregroundColor: AppColors.primaryLight,
                ),
                child: AppText(
                  text: 'Create',
                  size: "large",
                  color: AppColors.textButton,
                  isBold: true,
                  isCenter: true,
                ),
              ),
            ),
          ),
        ],
      );
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
            AppColors.primaryDark,
            // AppColors.darkpurple
          ],
          stops: [
            0.0,
            // 1.0
          ],
        ),
      ),
    );
  }
}
