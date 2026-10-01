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
    Color dotColor;
    String label = status.replaceAll('_', ' ');

    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'COMPLETED':
      case 'RESOLVED':
      case 'VERIFIED':
        bg = AppColors.emeraldBg;
        fg = AppColors.emeraldDark;
        dotColor = AppColors.emeraldSuccess;
        break;
      case 'PENDING_APPROVAL':
      case 'PARTIALLY_RECEIVED':
      case 'UNDER_REVIEW':
      case 'SUBMITTED':
      case 'OPEN':
        bg = AppColors.amberBg;
        fg = AppColors.amberDark;
        dotColor = AppColors.amberWarning;
        break;
      case 'CRITICAL':
      case 'FLAGGED':
      case 'DAMAGE':
      case 'SHORTAGE':
      case 'REJECTED':
      case 'CANCELLED':
        bg = AppColors.redBg;
        fg = AppColors.redDark;
        dotColor = AppColors.redCritical;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        dotColor = const Color(0xFF64748B);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.18), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 5 : 6,
            height: isSmall ? 5 : 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: isSmall ? 10.5 : 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

