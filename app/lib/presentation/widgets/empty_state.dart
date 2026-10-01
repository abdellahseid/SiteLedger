import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.electricBlue),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonLabel!),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

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
              '$accepted of $ordered $unit',
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
