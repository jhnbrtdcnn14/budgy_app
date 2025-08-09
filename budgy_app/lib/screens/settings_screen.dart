import 'dart:ui';

import 'package:flutter/material.dart';
import '../components/colors.dart';
import '../components/text.dart';
import '../screens/home_screen.dart'; // for FuturisticBackground
import '../models/allocator_model.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    for (final c in _nameControllers) c.dispose();
    for (final c in _percentControllers) c.dispose();
    super.dispose();
  }

  Future<void> _loadAllocators() async {
    final data = await _storageService.loadAllocators();
    _allocators = data;
    _nameControllers.clear();
    _percentControllers.clear();
    for (final a in _allocators) {
      _nameControllers.add(TextEditingController(text: a.name));
      _percentControllers.add(TextEditingController(text: a.percentage.toString()));
    }
    setState(() => _loading = false);
  }

  void _addAllocator() {
    setState(() {
      final newAlloc = Allocator(name: 'New', percentage: 0);
      _allocators.add(newAlloc);
      _nameControllers.add(TextEditingController(text: newAlloc.name));
      _percentControllers.add(TextEditingController(text: newAlloc.percentage.toString()));
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
        percentage: pct,
      );
    }

    final total = _allocators.fold<double>(0, (s, a) => s + a.percentage);

    if (total != 100.0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.white,
          title: AppText(text: 'Total is not 100%', size: 'medium', color: AppColors.red),
          content: AppText(
            text: 'Current total is ${total.toStringAsFixed(1)}%.',
            size: 'small',
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ],
        ),
      );

      if (proceed != true) return;
    }

    await _storageService.saveAllocators(_allocators);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: AppText(
          text: 'Allocators saved!',
          size: "medium",
          color: AppColors.purple,
          isBold: true,
        ),
        backgroundColor: AppColors.white,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final total = _allocators.fold<double>(0, (s, a) => s + a.percentage);

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
                      AppText(
                        text: 'Settings',
                        size: "xxxlarge",
                        color: AppColors.white,
                        isBold: true,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.white),
                            onPressed: _addAllocator,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Total percentage
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: total != 100 ? AppColors.red : AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: AppText(
                      text: 'Total: ${total.toStringAsFixed(0)}%',
                      size: "medium",
                      color: AppColors.white,
                      isBold: true,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // List of allocators
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allocators.length,
                      itemBuilder: (context, i) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: AppColors.white,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    style: const TextStyle(color: AppColors.darkgrey, fontWeight: FontWeight.bold),
                                    controller: _nameControllers[i],
                                    decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none), labelText: 'Name', labelStyle: TextStyle(color: AppColors.darkgrey)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    selectionHeightStyle: BoxHeightStyle.max,
                                    style: const TextStyle(color: AppColors.darkgrey, fontWeight: FontWeight.bold),
                                    controller: _percentControllers[i],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(borderSide: BorderSide.none),
                                      labelText: 'Percentage',
                                      labelStyle: TextStyle(color: AppColors.darkgrey),
                                      suffixText: '%',
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.red),
                                  onPressed: () => _removeAllocator(i),
                                ),
                              ],
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
                            onPressed: _saveAllocators,
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
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
