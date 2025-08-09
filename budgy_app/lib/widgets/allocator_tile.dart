import 'package:flutter/material.dart';
import '../models/allocator_model.dart';

class AllocatorTile extends StatelessWidget {
  final Allocator allocator;
  final Function(double) onChanged;

  const AllocatorTile({super.key, required this.allocator, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: allocator.percentage.toString());
    return ListTile(
      title: Text(allocator.name),
      trailing: SizedBox(
        width: 80,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: '%'),
          onChanged: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null) {
              onChanged(parsed);
            }
          },
        ),
      ),
    );
  }
}
