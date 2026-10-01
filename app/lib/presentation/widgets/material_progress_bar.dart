import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MaterialProgressBar extends StatelessWidget {
  final double ordered;
  final double accepted;
  final String unit;

  const MaterialProgressBar({
    super.key,
    required this.ordered,
    required this.accepted,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = ordered > 0 ? (accepted / ordered).clamp(0.0, 1.0) : 0.0;
    final int percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${accepted.toInt()} of ${ordered.toInt()} $unit',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: ratio >= 1.0 ? AppColors.emeraldSuccess : AppColors.electricBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio >= 1.0 ? AppColors.emeraldSuccess : AppColors.electricBlue,
            ),
          ),
        ),
      ],
    );
  }
}
