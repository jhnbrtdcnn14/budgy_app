import 'package:budgy_app/components/colors.dart';
import 'package:budgy_app/components/text.dart';
import 'package:budgy_app/models/allocator_model.dart';
import 'package:flutter/material.dart';

class AllocatorCard extends StatelessWidget {
  final Allocator allocator;
  final String formattedAmount;
  const AllocatorCard({
    required this.allocator,
    required this.formattedAmount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.tertiaryLight,
      child: ListTile(
        title: AppText(
          text: allocator.name,
          size: "medium",
          color: AppColors.primaryLight,
          isBold: true,
        ),
        subtitle: AppText(
          text: '${allocator.value.toStringAsFixed(0)}%',
          size: "small",
          color: AppColors.secondaryLight,
        ),
        trailing: AppText(
          text: '₱$formattedAmount',
          size: "large",
          color: AppColors.primaryLight,
          isBold: true,
        ),
      ),
    );
  }
}
