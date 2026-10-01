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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amberBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.amberWarning.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.amberWarning.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 18, color: AppColors.amberDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count offline delivery item${count > 1 ? "s" : ""} queued',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.navyDark),
                ),
                const Text(
                  'Encrypted in local SQLite outbox',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/sync'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberWarning,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Sync Outbox', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
          ),
        ],
      ),
    );
  }
}

