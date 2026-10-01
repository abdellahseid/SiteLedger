import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({super.key, required this.status, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status.replaceAll('_', ' ');

    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'COMPLETED':
      case 'RESOLVED':
      case 'VERIFIED':
        bg = AppColors.emeraldBg;
        fg = AppColors.emeraldSuccess;
        break;
      case 'PENDING_APPROVAL':
      case 'PARTIALLY_RECEIVED':
      case 'UNDER_REVIEW':
      case 'SUBMITTED':
      case 'OPEN':
        bg = AppColors.amberBg;
        fg = AppColors.amberWarning;
        break;
      case 'CRITICAL':
      case 'FLAGGED':
      case 'DAMAGE':
      case 'SHORTAGE':
      case 'REJECTED':
      case 'CANCELLED':
        bg = AppColors.redBg;
        fg = AppColors.redCritical;
        break;
      default:
        bg = Color(0xFFF1F5F9);
        fg = Color(0xFF475569);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
