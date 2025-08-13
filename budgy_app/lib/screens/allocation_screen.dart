import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/text.dart';
import 'create_wallet_screen.dart'; // for FuturisticBackground
import '../models/allocator_model.dart';
import '../services/storage_service.dart';

class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  final StorageService _storageService = StorageService();
  List<Allocator> _allocators = [];
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _percentControllers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllocators();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _percentControllers) {
      c.dispose();
    }
    _nameControllers.clear();
    _percentControllers.clear();
  }

  void _createControllersFromAllocators() {
    _disposeControllers();
    for (final alloc in _allocators) {
      _nameControllers.add(TextEditingController(text: alloc.name));
      _percentControllers.add(TextEditingController(text: alloc.value.toString()));
    }
  }

  Future<void> _loadAllocators() async {
    final loaded = await _storageService.loadAllocators();
    setState(() {
      _allocators = loaded;
      _createControllersFromAllocators();
      _loading = false;
    });
  }

  void _addAllocator() {
    setState(() {
      final newAlloc = Allocator(name: 'New', value: 0);
      _allocators.add(newAlloc);
      _nameControllers.add(TextEditingController(text: newAlloc.name));
      _percentControllers.add(TextEditingController(text: newAlloc.value.toString()));
    });
  }

  void _removeAllocator(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _percentControllers[index].dispose();
      _nameControllers.removeAt(index);
      _percentControllers.removeAt(index);
      _allocators.removeAt(index);
    });
  }

  Future<void> _saveAllocators() async {
    for (int i = 0; i < _allocators.length; i++) {
      final name = _nameControllers[i].text.trim();
      final pct = double.tryParse(_percentControllers[i].text) ?? 0;
      _allocators[i] = _allocators[i].copyWith(
        name: name.isEmpty ? 'Unnamed' : name,
        value: pct,
      );
    }

    final total = _allocators.fold<double>(0, (sum, a) => sum + a.value);

    if (total != 100.0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.primaryLight,
          title: AppText(
            text: 'Total is not 100%',
            size: 'medium',
            color: AppColors.red,
            isBold: true,
          ),
          content: AppText(
            text: 'Current total is ${total.toStringAsFixed(1)}%.',
            size: 'small',
            color: AppColors.primaryDark,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    await _storageService.saveAllocators(_allocators);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(
      content: AppText(
        text: 'Allocations saved!',
        size: "medium",
        color: AppColors.purple,
        isBold: true,
      ),
      backgroundColor: AppColors.primaryLight,
    ));
    Navigator.pop(context);
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
                style:  TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
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
                controller: _percentControllers[index],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  labelText: 'value',
                  labelStyle: TextStyle(color: AppColors.primaryLight),
                  suffixText: '%',
                  suffixStyle: TextStyle(color: AppColors.primaryLight),
                ),
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

  Widget _buildTotalDisplay(double total) {
    final isValid = total == 100;
    final fillColor = isValid ? AppColors.primaryLight.withOpacity(0.1) : AppColors.red;
    final backgroundColor = AppColors.tertiaryLight;

    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Filled portion
          FractionallySizedBox(
            widthFactor: (total.clamp(0, 100)) / 100,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Text centered on top
          Center(
            child: AppText(
              text: 'Total: ${total.toStringAsFixed(0)}%',
              size: "medium",
              color: AppColors.primaryLight,
              isBold: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final total = _allocators.fold<double>(0, (sum, a) => sum + a.value);

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon:  Icon(Icons.arrow_back, color: AppColors.primaryLight),
                              onPressed: () => Navigator.pop(context),
                            ),
                            AppText(
                              text: 'Allocations',
                              size: "xxlarge",
                              color: AppColors.primaryLight,
                              isBold: true,
                            ),
                            IconButton(icon:  Icon(Icons.add, color: AppColors.primaryLight), onPressed: _addAllocator),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  _buildTotalDisplay(total),
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
                            onPressed: _saveAllocators,
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: AppColors.purple,
                              foregroundColor: AppColors.primaryLight,
                            ),
                            child: AppText(
                              text: 'Save',
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
