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
    final isDone = ratio >= 1.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${accepted.toInt()} of ${ordered.toInt()} $unit',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.emeraldBg
                    : (isDark ? const Color(0xFF1E293B) : AppColors.blueLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? AppColors.emeraldSuccess.withOpacity(0.3)
                      : AppColors.electricBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDone ? AppColors.emeraldDark : AppColors.electricBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Stack(
          children: [
            Container(
              height: 9,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 9,
                decoration: BoxDecoration(
                  gradient: isDone ? AppGradients.emeraldGradient : AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (isDone ? AppColors.emeraldSuccess : AppColors.electricBlue).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

