import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { query, withTransaction } from '../db/connection';
import { authenticateToken } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { upload, StorageService } from '../services/storage.service';
import { DiscrepancyService } from '../services/discrepancy.service';
import { AuditService } from '../services/audit.service';

const router = Router();

// GET /api/receipts - list all material receipts
router.get('/', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { projectId, poId, status } = req.query;

  let sql = `
    SELECT r.*,
      p.name as project_name, p.code as project_code,
      po.po_number,
      s.name as supplier_name,
      u.full_name as storekeeper_name,
      COUNT(rl.id) as total_items,
      COALESCE(SUM(rl.accepted_quantity), 0) as total_accepted_quantity,
      COALESCE(SUM(rl.damaged_quantity), 0) as total_damaged_quantity,
      COUNT(DISTINCT d.id) as discrepancy_count,
      COUNT(DISTINCT e.id) as evidence_count
    FROM receipts r
    JOIN projects p ON p.id = r.project_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    JOIN users u ON u.id = r.storekeeper_id
    LEFT JOIN receipt_lines rl ON rl.receipt_id = r.id
    LEFT JOIN discrepancies d ON d.receipt_id = r.id
    LEFT JOIN evidence e ON e.receipt_id = r.id
    WHERE r.organization_id = $1
  `;
  const params: any[] = [orgId];

  if (projectId) {
    params.push(projectId);
    sql += ` AND r.project_id = $${params.length}`;
  }
  if (poId) {
    params.push(poId);
    sql += ` AND r.purchase_order_id = $${params.length}`;
  }
  if (status) {
    params.push(status);
    sql += ` AND r.status = $${params.length}`;
  }

  sql += ` GROUP BY r.id, p.id, po.id, s.id, u.id ORDER BY r.delivery_timestamp DESC;`;

  const receipts = await query<any>(sql, params);
  res.json({ receipts });
});

// GET /api/receipts/:id - full receipt details
router.get('/:id', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const receiptId = req.params.id;

  const receipts = await query<any>(`
    SELECT r.*,
      p.name as project_name, p.code as project_code,
      po.po_number, po.notes as po_notes,
      s.name as supplier_name, s.phone as supplier_phone,
      u.full_name as storekeeper_name, u.phone as storekeeper_phone
    FROM receipts r
    JOIN projects p ON p.id = r.project_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    JOIN users u ON u.id = r.storekeeper_id
    WHERE r.id = $1 AND r.organization_id = $2
    LIMIT 1;
  `, [receiptId, orgId]);

  if (!receipts.length) {
    res.status(404).json({ error: { code: 'RECEIPT_NOT_FOUND', message: 'Delivery receipt not found.' } });
    return;
  }

  const receipt = receipts[0];

  const lines = await query<any>(`
    SELECT rl.*, m.code as material_code, m.name as material_name, m.category,
      pol.unit_price_etb
    FROM receipt_lines rl
    JOIN materials m ON m.id = rl.material_id
    JOIN purchase_order_lines pol ON pol.id = rl.purchase_order_line_id
    WHERE rl.receipt_id = $1
    ORDER BY rl.id ASC;
  `, [receiptId]);

  const evidence = await query<any>(`
    SELECT * FROM evidence WHERE receipt_id = $1 ORDER BY captured_at ASC;
  `, [receiptId]);

  const discrepancies = await query<any>(`
    SELECT d.*, m.name as material_name, m.unit
    FROM discrepancies d
    JOIN materials m ON m.id = d.material_id
    WHERE d.receipt_id = $1
    ORDER BY d.created_at ASC;
  `, [receiptId]);

  const auditEvents = await AuditService.getHistory('RECEIPT', receiptId);

  res.json({
    receipt,
    lines,
    evidence,
    discrepancies,
    auditEvents
  });
});

const createReceiptSchema = z.object({
  projectId: z.string().uuid(),
  purchaseOrderId: z.string().uuid(),
  receiptNumber: z.string().min(3),
  waybillNumber: z.string().min(2),
  truckLicensePlate: z.string().min(2),
  driverName: z.string().min(2),
  driverPhone: z.string().optional(),
  carrierName: z.string().optional(),
  supplierRepresentativeName: z.string().optional(),
  deliveryTimestamp: z.string().optional(),
  latitude: z.number().optional(),
  longitude: z.number().optional(),
  notes: z.string().optional(),
  idempotencyKey: z.string().min(5),
  lines: z.array(z.object({
    purchaseOrderLineId: z.string().uuid(),
    materialId: z.string().uuid(),
    orderedQuantity: z.number().nonnegative(),
    deliveredQuantity: z.number().nonnegative(),
    acceptedQuantity: z.number().nonnegative(),
    damagedQuantity: z.number().nonnegative().default(0),
    rejectedQuantity: z.number().nonnegative().default(0),
    rejectionReason: z.string().optional(),
    unit: z.string(),
  })).min(1),
});

// Internal processor for single receipt creation
export async function processSingleReceipt(data: z.infer<typeof createReceiptSchema>, user: { id: string; fullName: string; role: string; organizationId: string }) {
  return await withTransaction(async (client) => {
    // 1. Idempotency Check
    const existing = await client.query(`
      SELECT resource_id FROM sync_idempotency WHERE idempotency_key = $1 LIMIT 1;
    `, [data.idempotencyKey]);

    if (existing.rows.length) {
      const existingReceipt = await client.query(`SELECT * FROM receipts WHERE id = $1`, [existing.rows[0].resource_id]);
      return { receipt: existingReceipt.rows[0], isDuplicate: true };
    }

    // 2. Fetch PO & verify status
    const poRes = await client.query(`
      SELECT * FROM purchase_orders WHERE id = $1 AND organization_id = $2 FOR UPDATE;
    `, [data.purchaseOrderId, user.organizationId]);

    if (!poRes.rows.length) {
      throw { status: 400, message: 'Invalid purchase order.' };
    }
    const po = poRes.rows[0];
    if (po.status !== 'APPROVED' && po.status !== 'PARTIALLY_RECEIVED') {
      throw { status: 400, message: `Cannot receive against purchase order in status ${po.status}. Must be APPROVED.` };
    }

    // 3. Insert Receipt Header
    const recRes = await client.query(`
      INSERT INTO receipts (
        organization_id, project_id, purchase_order_id, receipt_number,
        waybill_number, truck_license_plate, driver_name, driver_phone,
        carrier_name, storekeeper_id, delivery_timestamp, status,
        idempotency_key, latitude, longitude, notes, supplier_representative_name
      ) VALUES (
        $1, $2, $3, $4,
        $5, $6, $7, $8,
        $9, $10, COALESCE($11::timestamptz, CURRENT_TIMESTAMP), 'SUBMITTED',
        $12, $13, $14, $15, $16
      ) RETURNING *;
    `, [
      user.organizationId, data.projectId, data.purchaseOrderId, data.receiptNumber,
      data.waybillNumber, data.truckLicensePlate, data.driverName, data.driverPhone || null,
      data.carrierName || null, user.id, data.deliveryTimestamp || null,
      data.idempotencyKey, data.latitude || null, data.longitude || null,
      data.notes || null, data.supplierRepresentativeName || null
    ]);

    const receipt = recRes.rows[0];

    // Record idempotency
    await client.query(`
      INSERT INTO sync_idempotency (idempotency_key, resource_type, resource_id)
      VALUES ($1, 'RECEIPT', $2);
    `, [data.idempotencyKey, receipt.id]);

    // 4. Insert Receipt Lines and evaluate discrepancies
    const insertedLines: any[] = [];
    const allDiscrepancies: any[] = [];

    for (const line of data.lines) {
      // Get PO line info for unit price
      const polRes = await client.query(`
        SELECT pol.*, m.name as material_name
        FROM purchase_order_lines pol
        JOIN materials m ON m.id = pol.material_id
        WHERE pol.id = $1 FOR UPDATE;
      `, [line.purchaseOrderLineId]);

      const pol = polRes.rows[0];
      const unitPrice = pol ? Number(pol.unit_price_etb) : 0;
      const materialName = pol ? pol.material_name : 'Material';

      const rlRes = await client.query(`
        INSERT INTO receipt_lines (
          receipt_id, purchase_order_line_id, material_id, ordered_quantity,
          delivered_quantity, accepted_quantity, damaged_quantity, rejected_quantity,
          rejection_reason, unit
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING *;
      `, [
        receipt.id, line.purchaseOrderLineId, line.materialId, line.orderedQuantity,
        line.deliveredQuantity, line.acceptedQuantity, line.damagedQuantity, line.rejectedQuantity,
        line.rejectionReason || null, line.unit
      ]);

      const receiptLine = rlRes.rows[0];
      insertedLines.push(receiptLine);

      // Update PO line accepted quantity
      await client.query(`
        UPDATE purchase_order_lines
        SET accepted_quantity = accepted_quantity + $1
        WHERE id = $2;
      `, [line.acceptedQuantity, line.purchaseOrderLineId]);

      // Automatically evaluate & record discrepancies
      const lineDiscrepancies = await DiscrepancyService.evaluateAndFlagDiscrepancies({
        organizationId: user.organizationId,
        projectId: data.projectId,
        receiptId: receipt.id,
        receiptLineId: receiptLine.id,
        materialId: line.materialId,
        orderedQty: line.orderedQuantity,
        deliveredQty: line.deliveredQuantity,
        acceptedQty: line.acceptedQuantity,
        damagedQty: line.damagedQuantity,
        rejectedQty: line.rejectedQuantity,
        unitPriceEtb: unitPrice,
        materialName,
        unit: line.unit,
        notes: line.rejectionReason || data.notes,
        client
      });

      allDiscrepancies.push(...lineDiscrepancies);
    }

    // 5. Update Receipt status if discrepancies were flagged
    if (allDiscrepancies.length > 0) {
      await client.query(`
        UPDATE receipts SET status = 'FLAGGED' WHERE id = $1;
      `, [receipt.id]);
      receipt.status = 'FLAGGED';
    }

    // 6. Update Purchase Order overall status
    const remainingPolRes = await client.query(`
      SELECT SUM(ordered_quantity - accepted_quantity) as remaining
      FROM purchase_order_lines
      WHERE purchase_order_id = $1;
    `, [data.purchaseOrderId]);

    const remaining = Number(remainingPolRes.rows[0]?.remaining || 0);
    const newPoStatus = remaining <= 0 ? 'COMPLETED' : 'PARTIALLY_RECEIVED';

    await client.query(`
      UPDATE purchase_orders SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2;
    `, [newPoStatus, data.purchaseOrderId]);

    // 7. Audit Event
    await AuditService.log({
      organizationId: user.organizationId,
      entityType: 'RECEIPT',
      entityId: receipt.id,
      action: 'RECEIVE_DELIVERY',
      actorId: user.id,
      actorName: user.fullName,
      actorRole: user.role,
      newState: {
        receipt,
        discrepanciesCount: allDiscrepancies.length,
        linesCount: insertedLines.length
      },
      client
    });

    return {
      receipt,
      lines: insertedLines,
      discrepancies: allDiscrepancies,
      poStatus: newPoStatus,
      isDuplicate: false
    };
  });
}

// POST /api/receipts - single receipt creation
router.post('/', authenticateToken, validateBody(createReceiptSchema), async (req: Request, res: Response) => {
  const result = await processSingleReceipt(req.body, req.user!);
  res.status(result.isDuplicate ? 200 : 201).json(result);
});

// POST /api/receipts/sync - batch offline synchronization
const syncBatchSchema = z.object({
  batch: z.array(createReceiptSchema),
});

router.post('/sync', authenticateToken, validateBody(syncBatchSchema), async (req: Request, res: Response) => {
  const batch = req.body.batch as Array<z.infer<typeof createReceiptSchema>>;
  const synced: any[] = [];
  const errors: any[] = [];

  for (const item of batch) {
    try {
      const res = await processSingleReceipt(item, req.user!);
      synced.push({
        idempotencyKey: item.idempotencyKey,
        receiptId: res.receipt.id,
        receiptNumber: res.receipt.receipt_number,
        isDuplicate: res.isDuplicate,
        status: res.receipt.status,
      });
    } catch (err: any) {
      errors.push({
        idempotencyKey: item.idempotencyKey,
        receiptNumber: item.receiptNumber,
        error: err.message || 'Failed to sync receipt',
      });
    }
  }

  res.json({
    syncedCount: synced.length,
    failedCount: errors.length,
    synced,
    errors,
  });
});

// POST /api/receipts/:id/evidence - upload photo evidence
router.post('/:id/evidence', authenticateToken, upload.single('photo'), async (req: Request, res: Response) => {
  const receiptId = req.params.id;
  const { photoType, caption, receiptLineId } = req.body;
  const file = req.file;

  if (!file) {
    res.status(400).json({ error: { code: 'NO_FILE', message: 'No image file uploaded.' } });
    return;
  }

  const fileUrl = StorageService.getPublicUrl(file.filename);

  const evRes = await query<any>(`
    INSERT INTO evidence (
      receipt_id, receipt_line_id, photo_type, file_path, file_url,
      file_size_bytes, mime_type, caption
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING *;
  `, [
    receiptId,
    receiptLineId || null,
    photoType || 'MATERIAL_OVERVIEW',
    file.path,
    fileUrl,
    file.size,
    file.mimetype,
    caption || null
  ]);

  res.status(201).json({ evidence: evRes[0] });
});

export default router;
