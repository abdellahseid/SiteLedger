import { Router, Request, Response } from 'express';
import { query } from '../db/connection';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// GET /api/reports/dashboard - executive metrics
router.get('/dashboard', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { projectId } = req.query;

  let projectFilterPo = '';
  let projectFilterRec = '';
  let projectFilterDisc = '';
  const params: any[] = [orgId];

  if (projectId) {
    params.push(projectId);
    projectFilterPo = ` AND po.project_id = $2`;
    projectFilterRec = ` AND r.project_id = $2`;
    projectFilterDisc = ` AND d.project_id = $2`;
  }

  // 1. KPI Counts
  const orderStats = await query<any>(`
    SELECT 
      COUNT(po.id) as total_orders,
      COALESCE(SUM(po.total_amount_etb), 0) as total_budget_committed_etb,
      COUNT(po.id) FILTER (WHERE po.status = 'APPROVED') as active_orders,
      COUNT(po.id) FILTER (WHERE po.status = 'COMPLETED') as completed_orders
    FROM purchase_orders po
    WHERE po.organization_id = $1 ${projectFilterPo};
  `, params);

  const deliveryStats = await query<any>(`
    SELECT 
      COUNT(r.id) as total_deliveries,
      COUNT(r.id) FILTER (WHERE r.status = 'FLAGGED') as flagged_deliveries,
      COALESCE(SUM(rl.accepted_quantity), 0) as total_units_accepted,
      COALESCE(SUM(rl.damaged_quantity), 0) as total_units_damaged
    FROM receipts r
    LEFT JOIN receipt_lines rl ON rl.receipt_id = r.id
    WHERE r.organization_id = $1 ${projectFilterRec};
  `, params);

  const discrepancyStats = await query<any>(`
    SELECT 
      COUNT(d.id) as total_discrepancies,
      COUNT(d.id) FILTER (WHERE d.status IN ('OPEN', 'UNDER_REVIEW')) as open_discrepancies,
      COUNT(d.id) FILTER (WHERE d.status = 'RESOLVED') as resolved_discrepancies,
      COALESCE(SUM(d.financial_impact_etb) FILTER (WHERE d.status IN ('OPEN', 'UNDER_REVIEW')), 0) as at_risk_etb
    FROM discrepancies d
    WHERE d.organization_id = $1 ${projectFilterDisc};
  `, params);

  // 2. Material fulfillment breakdown
  const materialFulfillment = await query<any>(`
    SELECT m.id, m.name, m.code, m.unit, m.category,
      COALESCE(SUM(pol.ordered_quantity), 0) as total_ordered,
      COALESCE(SUM(pol.accepted_quantity), 0) as total_accepted
    FROM purchase_orders po
    JOIN purchase_order_lines pol ON pol.purchase_order_id = po.id
    JOIN materials m ON m.id = pol.material_id
    WHERE po.organization_id = $1 ${projectFilterPo} AND po.status != 'CANCELLED'
    GROUP BY m.id, m.name, m.code, m.unit, m.category
    ORDER BY total_ordered DESC
    LIMIT 6;
  `, params);

  // 3. Top suppliers by delivery volume and discrepancy rate
  const supplierPerformance = await query<any>(`
    SELECT s.id, s.name, s.rating,
      COUNT(DISTINCT r.id) as total_deliveries,
      COUNT(DISTINCT d.id) as total_discrepancies,
      COALESCE(SUM(d.financial_impact_etb), 0) as total_discrepancy_value_etb
    FROM suppliers s
    LEFT JOIN purchase_orders po ON po.supplier_id = s.id
    LEFT JOIN receipts r ON r.purchase_order_id = po.id
    LEFT JOIN discrepancies d ON d.receipt_id = r.id
    WHERE s.organization_id = $1
    GROUP BY s.id
    ORDER BY total_deliveries DESC
    LIMIT 5;
  `, [orgId]);

  // 4. Recent delivery activity
  const recentDeliveries = await query<any>(`
    SELECT r.id, r.receipt_number, r.waybill_number, r.truck_license_plate,
      r.delivery_timestamp, r.status,
      p.name as project_name, s.name as supplier_name,
      COUNT(rl.id) as item_count
    FROM receipts r
    JOIN projects p ON p.id = r.project_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    LEFT JOIN receipt_lines rl ON rl.receipt_id = r.id
    WHERE r.organization_id = $1 ${projectFilterRec}
    GROUP BY r.id, p.name, s.name
    ORDER BY r.delivery_timestamp DESC
    LIMIT 5;
  `, params);

  res.json({
    orders: orderStats[0],
    deliveries: deliveryStats[0],
    discrepancies: discrepancyStats[0],
    materials: materialFulfillment,
    suppliers: supplierPerformance,
    recentDeliveries
  });
});

// GET /api/reports/export-csv - download CSV export of delivery receipts & discrepancies
router.get('/export-csv', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;

  const rows = await query<any>(`
    SELECT 
      r.receipt_number,
      r.waybill_number,
      r.truck_license_plate,
      r.driver_name,
      r.carrier_name,
      p.code as project_code,
      p.name as project_name,
      po.po_number,
      s.name as supplier_name,
      m.code as material_code,
      m.name as material_name,
      rl.ordered_quantity,
      rl.delivered_quantity,
      rl.accepted_quantity,
      rl.damaged_quantity,
      rl.rejected_quantity,
      rl.unit,
      pol.unit_price_etb,
      r.status as receipt_status,
      r.delivery_timestamp
    FROM receipts r
    JOIN projects p ON p.id = r.project_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    JOIN receipt_lines rl ON rl.receipt_id = r.id
    JOIN materials m ON m.id = rl.material_id
    JOIN purchase_order_lines pol ON pol.id = rl.purchase_order_line_id
    WHERE r.organization_id = $1
    ORDER BY r.delivery_timestamp DESC;
  `, [orgId]);

  const headers = [
    'Receipt Number', 'Waybill Number', 'Truck Plate', 'Driver Name', 'Carrier',
    'Project Code', 'Project Name', 'PO Number', 'Supplier',
    'Material Code', 'Material Name', 'Ordered Qty', 'Delivered Qty',
    'Accepted Qty', 'Damaged Qty', 'Rejected Qty', 'Unit', 'Unit Price (ETB)',
    'Status', 'Delivery Date'
  ];

  const csvRows = [headers.join(',')];
  for (const r of rows) {
    const row = [
      `"${r.receipt_number}"`,
      `"${r.waybill_number}"`,
      `"${r.truck_license_plate}"`,
      `"${r.driver_name}"`,
      `"${r.carrier_name || ''}"`,
      `"${r.project_code}"`,
      `"${r.project_name.replace(/"/g, '""')}"`,
      `"${r.po_number}"`,
      `"${r.supplier_name.replace(/"/g, '""')}"`,
      `"${r.material_code}"`,
      `"${r.material_name.replace(/"/g, '""')}"`,
      r.ordered_quantity,
      r.delivered_quantity,
      r.accepted_quantity,
      r.damaged_quantity,
      r.rejected_quantity,
      `"${r.unit}"`,
      r.unit_price_etb,
      `"${r.receipt_status}"`,
      `"${new Date(r.delivery_timestamp).toISOString()}"`
    ];
    csvRows.push(row.join(','));
  }

  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename="siteledger-deliveries-report.csv"');
  res.send(csvRows.join('\r\n'));
});

export default router;
