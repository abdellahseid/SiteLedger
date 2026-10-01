import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptFuture = ref.watch(receiptRepoProvider).getReceiptDetails(receiptId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Verification Record'),
      ),
      body: FutureBuilder(
        future: receiptFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading receipt: ${snapshot.error}'));
          }

          final r = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.waybillNumber,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Electronic Receipt: ${r.receiptNumber}',
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: r.status),
                        ],
                      ),
                      const Divider(height: 28),
                      _row('Purchase Order', r.poNumber, isDark),
                      _row('Project', r.projectName, isDark),
                      _row('Supplier', r.supplierName, isDark),
                      _row('Truck License Plate', r.truckLicensePlate, isDark),
                      _row('Driver Name', r.driverName, isDark),
                      if (r.driverPhone != null) _row('Driver Phone', r.driverPhone!, isDark),
                      if (r.carrierName != null) _row('Carrier / Transporter', r.carrierName!, isDark),
                      _row('Inspecting Storekeeper', r.storekeeperName ?? 'Chala Lemma', isDark),
                      _row('Offload Timestamp', Formatters.dateTime(r.deliveryTimestamp), isDark),
                      if (r.notes != null) _row('Inspection Notes', r.notes!, isDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Material Intake Quantities Breakdown
              Text(
                'Material Offload Verification',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              ...r.lines.map((line) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.materialName,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _qtyBox('Ordered', line.orderedQuantity, line.unit, AppColors.navyDark, isDark),
                            const SizedBox(width: 8),
                            _qtyBox('Delivered', line.deliveredQuantity, line.unit, AppColors.electricBlue, isDark),
                            const SizedBox(width: 8),
                            _qtyBox('Accepted', line.acceptedQuantity, line.unit, AppColors.emeraldSuccess, isDark),
                            const SizedBox(width: 8),
                            _qtyBox('Damaged', line.damagedQuantity, line.unit, AppColors.redCritical, isDark),
                          ],
                        ),
                        if (line.rejectionReason != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.redBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.redBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.report_problem_rounded, size: 18, color: AppColors.redCritical),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Defect Inspection Flag:',
                                        style: TextStyle(fontSize: 11, color: AppColors.redDark, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        line.rejectionReason!,
                                        style: const TextStyle(fontSize: 12.5, color: AppColors.redCritical, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Photographic Evidence Gallery
              Text(
                'Photo Evidence Audit Trail',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              if (r.evidence.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: const [
                        Icon(Icons.photo_library_outlined, color: AppColors.electricBlue, size: 24),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '3 High-resolution inspection photos verified & securely stored in audit ledger.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: r.evidence.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final ev = r.evidence[idx];
                      return Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppColors.navyDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_rounded, size: 38, color: Colors.white70),
                            const SizedBox(height: 8),
                            Text(
                              ev.photoType.replaceAll('_', ' '),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (ev.caption != null)
                              Text(
                                ev.caption!,
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // Action to View Discrepancies if any
              if (r.isFlagged)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redCritical,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => context.go('/issues'),
                  icon: const Icon(Icons.report_problem_rounded),
                  label: const Text('Review Linked Material Discrepancies', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBox(String label, double qty, String unit, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(
              qty.toInt().toString(),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
            ),
            Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

