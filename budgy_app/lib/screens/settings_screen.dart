// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
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
    // Sync values from controllers into model list
    for (int i = 0; i < _allocators.length; i++) {
      final name = _nameControllers[i].text.trim();
      final pct = double.tryParse(_percentControllers[i].text) ?? 0;
      _allocators[i] = _allocators[i].copyWith(name: name.isEmpty ? 'Unnamed' : name, percentage: pct);
    }

    final total = _allocators.fold<double>(0, (s, a) => s + a.percentage);

    if (total != 100.0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Total is not 100%'),
          content: Text('Current total is ${total.toStringAsFixed(1)}%. Do you want to save anyway?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save anyway')),
          ],
        ),
      );

      if (proceed != true) return;
    }

    await _storageService.saveAllocators(_allocators);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Allocators saved')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final total = _allocators.fold<double>(0, (s, a) => s + a.percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addAllocator),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAllocators),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: total > 100 ? Colors.red.shade700 : Colors.transparent,
            padding: const EdgeInsets.all(8),
            child: Text('Total: ${total.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allocators.length,
              itemBuilder: (context, i) {
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _nameControllers[i],
                            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Name'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _percentControllers[i],
                            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Percentage', suffixText: '%'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removeAllocator(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}