import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/material_progress_bar.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isApproving = false;

  void _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Purchase Order'),
        content: const Text('Are you sure you want to approve this purchase order? This authorizes site storekeepers to accept incoming material shipments at the gate.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldSuccess),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isApproving = true);
      try {
        await ref.read(orderRepoProvider).approveOrder(widget.orderId);
        ref.invalidate(ordersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.emeraldSuccess,
              content: Text('✅ Purchase order approved and storekeepers authorized!'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve order: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isApproving = false);
      }
    }
  }

  void _showQrDialog(String poNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(poNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 190, color: AppColors.navyDark),
            ),
            const SizedBox(height: 14),
            const Text(
              'Present this QR code or PO number at site scale gate for rapid material intake.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderFuture = ref.watch(orderRepoProvider).getOrderDetails(widget.orderId);
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_rounded),
            tooltip: 'View QR Code',
            onPressed: () {
              orderFuture.then((po) {
                if (mounted) _showQrDialog(po.poNumber);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading order: ${snapshot.error}'));
          }

          final po = snapshot.data!;
          final canApprove = (user?.isProjectManager == true) && po.status == 'PENDING_APPROVAL';

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
                                  po.poNumber,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  po.projectName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.electricBlue),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(status: po.status),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Order Pipeline Progress Bar
                      _buildPipelineStep(po.status),

                      const Divider(height: 28),
                      _detailRow('Supplier', po.supplierName, isDark),
                      if (po.supplierPhone != null) _detailRow('Supplier Contact', po.supplierPhone!, isDark),
                      _detailRow('Total Commitment', Formatters.currency(po.totalAmountEtb), isDark),
                      _detailRow('Created By', po.createdByName ?? 'Dawit Tadesse (Procurement)', isDark),
                      if (po.approvedByName != null) _detailRow('Approved By', po.approvedByName!, isDark),
                      _detailRow('Date Created', Formatters.date(po.createdAt), isDark),
                      if (po.notes != null) _detailRow('Notes', po.notes!, isDark),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        onPressed: () => _showQrDialog(po.poNumber),
                        icon: const Icon(Icons.qr_code_rounded, size: 18),
                        label: const Text('Display Gate Intake QR Code'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              if (canApprove) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isApproving ? null : _handleApprove,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: _isApproving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Approve Purchase Order (Sign-off)'),
                ),
                const SizedBox(height: 12),
              ],

              if (po.canReceive) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => context.push('/receive', extra: po),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: const Text('Receive Material Against This Order'),
                ),
                const SizedBox(height: 16),
              ],

              // Line Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Authorized Line Items',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${po.lines.length} material${po.lines.length > 1 ? "s" : ""}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...po.lines.map((line) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                line.materialName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.navyDark,
                                ),
                              ),
                            ),
                            Text(
                              Formatters.currency(line.totalPriceEtb),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.electricBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unit Price: ${Formatters.currency(line.unitPriceEtb)} / ${line.unit}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        MaterialProgressBar(
                          ordered: line.orderedQuantity,
                          accepted: line.acceptedQuantity,
                          unit: line.unit,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPipelineStep(String status) {
    int currentStep = 1;
    if (status == 'APPROVED') currentStep = 2;
    if (status == 'PARTIALLY_RECEIVED') currentStep = 3;
    if (status == 'COMPLETED') currentStep = 4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepNode('Drafted', 1, currentStep >= 1),
          _stepLine(currentStep >= 2),
          _stepNode('PM Signoff', 2, currentStep >= 2),
          _stepLine(currentStep >= 3),
          _stepNode('Offload Intake', 3, currentStep >= 3),
          _stepLine(currentStep >= 4),
          _stepNode('Completed', 4, currentStep >= 4),
        ],
      ),
    );
  }

  Widget _stepNode(String label, int step, bool isDone) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone ? AppColors.electricBlue : AppColors.borderSubtle,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isDone ? Icons.check_rounded : Icons.circle,
              size: isDone ? 14 : 6,
              color: isDone ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
            color: isDone ? AppColors.navyDark : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? AppColors.electricBlue : AppColors.borderSubtle,
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
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
}

