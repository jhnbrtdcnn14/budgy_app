import 'package:budgy_app/models/allocator_model.dart';
import 'package:budgy_app/models/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:intl/intl.dart';
import '../components/colors.dart';
import '../components/text.dart';
import 'create_wallet_screen.dart'; // for FuturisticBackground
import '../services/storage_service.dart';

class CustomWalletAmountScreen extends StatefulWidget {
  const CustomWalletAmountScreen({super.key});

  @override
  State<CustomWalletAmountScreen> createState() => _CustomWalletAmountScreenState();
}

class _CustomWalletAmountScreenState extends State<CustomWalletAmountScreen> {
  final StorageService _storageService = StorageService();
  List<Allocator> _allocators = [];
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _amountControllers = [];
  final NumberFormat _formatter = NumberFormat('#,##0.00');

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllocators();
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _amountControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAllocators() async {
    final list = await _storageService.loadCustomAllocators();
    setState(() {
      _allocators = list;
      _nameControllers.clear();
      _amountControllers.clear();

      for (final alloc in _allocators) {
        _nameControllers.add(TextEditingController(text: alloc.name));
        _amountControllers.add(TextEditingController(text: _formatter.format(alloc.value)));
      }

      _loading = false; // ✅ Stop showing loading spinner
    });
  }

  void _addAllocator() {
    setState(() {
      final newAlloc = Allocator(name: 'New', value: 0);
      _allocators.add(newAlloc);
      _nameControllers.add(TextEditingController(text: newAlloc.name));
      _amountControllers.add(TextEditingController(text: "0"));
    });
  }

  void _removeAllocator(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _amountControllers[index].dispose();
      _nameControllers.removeAt(index);
      _amountControllers.removeAt(index);
      _allocators.removeAt(index);
    });
  }

  Future<void> _saveCustomWallet() async {
    // Build allocation map from entered values
    final allocationMap = <String, double>{};

    for (var i = 0; i < _allocators.length; i++) {
      final name = _nameControllers[i].text.trim();

      // Clean text: remove ₱, commas, and spaces
      final cleanedText = _amountControllers[i].text.replaceAll(RegExp(r'[₱,\s]'), '');

      final amount = double.tryParse(cleanedText) ?? 0.0;

      allocationMap[name] = amount;
    }

    final wallet = Wallet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      salary: null, // no salary for custom wallet
      allocation: allocationMap,
      date: DateTime.now(),
      isCustom: true,
    );

    await _storageService.saveWallet(wallet);

    _showSnackBar('Custom Wallet saved!', AppColors.purple);

    Navigator.pushReplacementNamed(context, '/wallet');
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

  Widget _buildAllocatorRow(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.tertiaryLight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameControllers[index],
                style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  labelText: 'Name',
                  labelStyle: TextStyle(color: AppColors.primaryLight),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _amountControllers[index],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: AppColors.primaryLight),
                  prefixText: '₱',
                  prefixStyle: TextStyle(color: AppColors.primaryLight),
                ),
                inputFormatters: [
                  CurrencyInputFormatter(
                    useSymbolPadding: true,
                    thousandSeparator: ThousandSeparator.Comma,
                    mantissaLength: 0, // no decimal places for salary
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.red),
              onPressed: () => _removeAllocator(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppColors.primaryLight),
                        onPressed: () => Navigator.pop(context),
                      ),
                      AppText(
                        text: 'Custom Wallet',
                        size: "xlarge",
                        color: AppColors.primaryLight,
                        isBold: true,
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: AppColors.primaryLight),
                        onPressed: _addAllocator,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppText(text: "Manually set categories and fixed amounts.\nPerfect for exact monthly budgets.", size: 'xsmall', color: AppColors.secondaryLight),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allocators.length,
                      itemBuilder: (context, i) => _buildAllocatorRow(i),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveCustomWallet,
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
