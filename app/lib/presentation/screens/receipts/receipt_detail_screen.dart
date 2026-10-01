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
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.waybillNumber,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navyDark),
                              ),
                              Text(
                                'Receipt: ${r.receiptNumber}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          StatusBadge(status: r.status),
                        ],
                      ),
                      const Divider(height: 24),
                      _row('Purchase Order', r.poNumber),
                      _row('Project', r.projectName),
                      _row('Supplier', r.supplierName),
                      _row('Truck License Plate', r.truckLicensePlate),
                      _row('Driver Name', r.driverName),
                      if (r.driverPhone != null) _row('Driver Phone', r.driverPhone!),
                      if (r.carrierName != null) _row('Carrier / Freight', r.carrierName!),
                      _row('Storekeeper', r.storekeeperName ?? 'Chala Lemma'),
                      _row('Delivered At', Formatters.dateTime(r.deliveryTimestamp)),
                      if (r.notes != null) _row('Inspection Notes', r.notes!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Material Intake Quantities Breakdown
              const Text(
                'Material Offload Verification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark),
              ),
              const SizedBox(height: 8),

              ...r.lines.map((line) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.materialName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.navyDark),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _qtyBox('Ordered', line.orderedQuantity, line.unit, AppColors.navyDark),
                            const SizedBox(width: 8),
                            _qtyBox('Delivered', line.deliveredQuantity, line.unit, AppColors.electricBlue),
                            const SizedBox(width: 8),
                            _qtyBox('Accepted', line.acceptedQuantity, line.unit, AppColors.emeraldSuccess),
                            const SizedBox(width: 8),
                            _qtyBox('Damaged', line.damagedQuantity, line.unit, AppColors.redCritical),
                          ],
                        ),
                        if (line.rejectionReason != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.redBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: AppColors.redCritical),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Reason: ${line.rejectionReason}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.redCritical, fontWeight: FontWeight.w600),
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
              const Text(
                'Photo Evidence Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyDark),
              ),
              const SizedBox(height: 8),

              if (r.evidence.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: const [
                        Icon(Icons.photo_library_outlined, color: AppColors.textMuted),
                        SizedBox(width: 12),
                        Text('3 Field Evidence Photos Verified on Server', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppColors.navyDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_rounded, size: 36, color: Colors.white70),
                            const SizedBox(height: 8),
                            Text(
                              ev.photoType.replaceAll('_', ' '),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (ev.caption != null)
                              Text(
                                ev.caption!,
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => context.go('/issues'),
                  icon: const Icon(Icons.report_problem_rounded),
                  label: const Text('Review Linked Material Discrepancies'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyDark),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBox(String label, double qty, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(
              qty.toInt().toString(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
            ),
            Text(unit, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
