import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';

class OfflineSyncBanner extends ConsumerWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingSyncCountProvider);
    final count = pendingCountAsync.value ?? 0;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.amberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amberWarning.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.amberWarning.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 18, color: AppColors.amberWarning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count offline delivery queued',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.navyDark),
                ),
                const Text(
                  'Saved in Drift SQLite outbox',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/sync'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.amberWarning,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Sync Center', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}
