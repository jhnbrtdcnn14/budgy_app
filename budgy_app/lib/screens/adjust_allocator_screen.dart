import 'package:budgy_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/text.dart';
import '../models/budget_model.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class AdjustAllocatorScreen extends StatefulWidget {
  final Budget budget;
  const AdjustAllocatorScreen({super.key, required this.budget});

  @override
  State<AdjustAllocatorScreen> createState() => _AdjustAllocatorScreenState();
}

class _AdjustAllocatorScreenState extends State<AdjustAllocatorScreen> {
  final StorageService _storageService = StorageService();
  final _controller = TextEditingController();
  String? _selectedAllocator;
  bool _isAddition = true;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

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
                  DropdownButtonFormField<String>(
                    value: _selectedAllocator,
                    items: widget.budget.allocation.keys
                        .map((name) => DropdownMenuItem(
                            value: name,
                            child: AppText(
                              text: name,
                              color: AppColors.white,
                              size: 'small',
                            )))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedAllocator = value),
                    decoration: const InputDecoration(labelText: "Select Allocator", labelStyle: TextStyle(color: AppColors.white)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount", labelStyle: TextStyle(color: AppColors.white)),
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    isSelected: [
                      _isAddition,
                      !_isAddition
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
                          )),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: AppText(
                            text: "Deduct",
                            color: AppColors.white,
                            size: 'small',
                          )),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedAllocator == null || _controller.text.isEmpty ? null : _adjustAmount,
                    child: AppText(
                      text: "Confirm",
                      color: AppColors.white,
                      size: 'small',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: widget.budget.allocation.entries.map((entry) {
                        final category = entry.key;
                        final baseAmount = entry.value['amount'] ?? 0;
                        final added = widget.budget.added[category] ?? 0;
                        final deducted = widget.budget.deducted[category] ?? 0;
                        final standingAmount = baseAmount + added - deducted;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: AppColors.white.withOpacity(0.1),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AppText(
                                        text: category,
                                        size: "large",
                                        color: AppColors.white,
                                        isBold: true,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      AppText(
                                        text: "${formatter.format(baseAmount)}",
                                        size: "small",
                                        color: AppColors.lightpurple,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  if (added != 0)
                                    AppText(
                                      text: "+ ${formatter.format(added)}",
                                      size: "small",
                                      color: AppColors.green,
                                    ),
                                  if (deducted != 0)
                                    AppText(
                                      text: "- ${formatter.format(deducted)}",
                                      size: "small",
                                      color: AppColors.red,
                                    ),
                                  if (added != 0 || deducted != 0)
                                    AppText(
                                      text: "= ${formatter.format(standingAmount)}",
                                      size: "small",
                                      color: AppColors.white,
                                      isBold: true,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildTopBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppText(
            text: 'Budget',
            size: "xxxlarge",
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
    if (_isAddition) {
      widget.budget.added[category] = (widget.budget.added[category] ?? 0) + value;
    } else {
      widget.budget.deducted[category] = (widget.budget.deducted[category] ?? 0) + value;
    }

    await _storageService.updateBudget(
      widget.budget,
      category,
      _isAddition ? value : -value,
    );

    setState(() {});
    _controller.clear();
  }
}
