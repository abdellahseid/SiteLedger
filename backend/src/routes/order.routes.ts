import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { query, withTransaction } from '../db/connection';
import { authenticateToken, requireRoles } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { AuditService } from '../services/audit.service';

const router = Router();

// GET /api/orders - list purchase orders
router.get('/', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { projectId, status, supplierId } = req.query;

  let sql = `
    SELECT po.*,
      p.name as project_name, p.code as project_code,
      s.name as supplier_name,
      u1.full_name as created_by_name,
      u2.full_name as approved_by_name,
      COUNT(pol.id) as total_line_items,
      COALESCE(SUM(pol.accepted_quantity), 0) as total_accepted_quantity,
      COALESCE(SUM(pol.ordered_quantity), 0) as total_ordered_quantity
    FROM purchase_orders po
    JOIN projects p ON p.id = po.project_id
    JOIN suppliers s ON s.id = po.supplier_id
    LEFT JOIN users u1 ON u1.id = po.created_by
    LEFT JOIN users u2 ON u2.id = po.approved_by
    LEFT JOIN purchase_order_lines pol ON pol.purchase_order_id = po.id
    WHERE po.organization_id = $1
  `;
  const params: any[] = [orgId];

  if (projectId) {
    params.push(projectId);
    sql += ` AND po.project_id = $${params.length}`;
  }
  if (status) {
    params.push(status);
    sql += ` AND po.status = $${params.length}`;
  }
  if (supplierId) {
    params.push(supplierId);
    sql += ` AND po.supplier_id = $${params.length}`;
  }

  sql += ` GROUP BY po.id, p.id, s.id, u1.id, u2.id ORDER BY po.created_at DESC;`;

  const orders = await query<any>(sql, params);
  res.json({ orders });
});

// GET /api/orders/by-number/:poNumber (QR Code and Barcode Site Lookup)
router.get('/by-number/:poNumber', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const poNumber = req.params.poNumber.trim();

  const orders = await query<any>(`
    SELECT po.*,
      p.name as project_name, p.code as project_code,
      s.name as supplier_name, s.phone as supplier_phone,
      u.full_name as created_by_name
    FROM purchase_orders po
    JOIN projects p ON p.id = po.project_id
    JOIN suppliers s ON s.id = po.supplier_id
    LEFT JOIN users u ON u.id = po.created_by
    WHERE po.organization_id = $1 AND LOWER(po.po_number) = LOWER($2)
    LIMIT 1;
  `, [orgId, poNumber]);

  if (!orders.length) {
    res.status(404).json({ error: { code: 'PO_NOT_FOUND', message: `No purchase order found for QR: ${poNumber}` } });
    return;
  }

  const order = orders[0];
  const lines = await query<any>(`
    SELECT pol.*, m.code as material_code, m.name as material_name, m.unit, m.category
    FROM purchase_order_lines pol
    JOIN materials m ON m.id = pol.material_id
    WHERE pol.purchase_order_id = $1;
  `, [order.id]);

  res.json({ order, lines });
});

// GET /api/orders/:id - detail with line items & delivery progress
router.get('/:id', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const orderId = req.params.id;

  const orders = await query<any>(`
    SELECT po.*,
      p.name as project_name, p.code as project_code,
      s.name as supplier_name, s.phone as supplier_phone, s.contact_person as supplier_contact,
      u1.full_name as created_by_name,
      u2.full_name as approved_by_name
    FROM purchase_orders po
    JOIN projects p ON p.id = po.project_id
    JOIN suppliers s ON s.id = po.supplier_id
    LEFT JOIN users u1 ON u1.id = po.created_by
    LEFT JOIN users u2 ON u2.id = po.approved_by
    WHERE po.id = $1 AND po.organization_id = $2
    LIMIT 1;
  `, [orderId, orgId]);

  if (!orders.length) {
    res.status(404).json({ error: { code: 'PO_NOT_FOUND', message: 'Purchase order not found.' } });
    return;
  }

  const order = orders[0];

  const lines = await query<any>(`
    SELECT pol.*, m.code as material_code, m.name as material_name, m.unit, m.category,
      (pol.ordered_quantity - pol.accepted_quantity) as remaining_quantity
    FROM purchase_order_lines pol
    JOIN materials m ON m.id = pol.material_id
    WHERE pol.purchase_order_id = $1
    ORDER BY pol.id ASC;
  `, [orderId]);

  const receipts = await query<any>(`
    SELECT r.*, u.full_name as storekeeper_name,
      COUNT(rl.id) as line_count,
      COALESCE(SUM(rl.accepted_quantity), 0) as total_accepted,
      COALESCE(SUM(rl.damaged_quantity), 0) as total_damaged
    FROM receipts r
    JOIN users u ON u.id = r.storekeeper_id
    LEFT JOIN receipt_lines rl ON rl.receipt_id = r.id
    WHERE r.purchase_order_id = $1
    GROUP BY r.id, u.id
    ORDER BY r.delivery_timestamp DESC;
  `, [orderId]);

  const history = await query<any>(`
    SELECT h.*, u.full_name as changed_by_name
    FROM purchase_order_history h
    LEFT JOIN users u ON u.id = h.changed_by
    WHERE h.purchase_order_id = $1
    ORDER BY h.created_at DESC;
  `, [orderId]);

  res.json({ order, lines, receipts, history });
});

const createOrderSchema = z.object({
  projectId: z.string().uuid(),
  supplierId: z.string().uuid(),
  poNumber: z.string().min(3),
  notes: z.string().optional(),
  expectedDeliveryDate: z.string().optional(),
  lines: z.array(z.object({
    materialId: z.string().uuid(),
    orderedQuantity: z.number().positive(),
    unitPriceEtb: z.number().positive(),
    notes: z.string().optional(),
  })).min(1),
});

// POST /api/orders - create purchase order with lines
router.post('/', authenticateToken, requireRoles('ADMIN', 'PROJECT_MANAGER', 'PROCUREMENT_OFFICER'), validateBody(createOrderSchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const userId = req.user!.id;
  const { projectId, supplierId, poNumber, notes, expectedDeliveryDate, lines } = req.body;

  const totalAmount = lines.reduce((acc, l) => acc + (l.orderedQuantity * l.unitPriceEtb), 0);

  const result = await withTransaction(async (client) => {
    const poRes = await client.query(`
      INSERT INTO purchase_orders (
        organization_id, project_id, supplier_id, po_number, version, status,
        total_amount_etb, notes, created_by, expected_delivery_date
      ) VALUES ($1, $2, $3, $4, 1, 'PENDING_APPROVAL', $5, $6, $7, $8)
      RETURNING *;
    `, [orgId, projectId, supplierId, poNumber.trim(), totalAmount, notes || null, userId, expectedDeliveryDate || null]);
    
    const newPo = poRes.rows[0];

    const insertedLines: any[] = [];
    for (const line of lines) {
      const lineTotal = line.orderedQuantity * line.unitPriceEtb;
      const lRes = await client.query(`
        INSERT INTO purchase_order_lines (
          purchase_order_id, material_id, ordered_quantity, accepted_quantity,
          unit_price_etb, total_price_etb, notes
        ) VALUES ($1, $2, $3, 0.00, $4, $5, $6)
        RETURNING *;
      `, [newPo.id, line.materialId, line.orderedQuantity, line.unitPriceEtb, lineTotal, line.notes || null]);
      insertedLines.push(lRes.rows[0]);
    }

    // Save snapshot history
    await client.query(`
      INSERT INTO purchase_order_history (
        purchase_order_id, version, changed_by, action, snapshot_json
      ) VALUES ($1, 1, $2, 'CREATED', $3);
    `, [newPo.id, userId, JSON.stringify({ po: newPo, lines: insertedLines })]);

    await AuditService.log({
      organizationId: orgId,
      entityType: 'PURCHASE_ORDER',
      entityId: newPo.id,
      action: 'CREATE',
      actorId: userId,
      actorName: req.user!.fullName,
      actorRole: req.user!.role,
      newState: newPo,
      client
    });

    return { order: newPo, lines: insertedLines };
  });

  res.status(201).json(result);
});

// PATCH /api/orders/:id/approve - PM signs off
router.patch('/:id/approve', authenticateToken, requireRoles('ADMIN', 'PROJECT_MANAGER'), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const userId = req.user!.id;
  const orderId = req.params.id;

  const result = await withTransaction(async (client) => {
    const poRes = await client.query(`
      SELECT * FROM purchase_orders WHERE id = $1 AND organization_id = $2 FOR UPDATE;
    `, [orderId, orgId]);

    if (!poRes.rows.length) {
      throw { status: 404, message: 'Purchase order not found.' };
    }

    const currentPo = poRes.rows[0];
    if (currentPo.status === 'APPROVED' || currentPo.status === 'PARTIALLY_RECEIVED') {
      return currentPo;
    }

    const updateRes = await client.query(`
      UPDATE purchase_orders
      SET status = 'APPROVED', approved_by = $1, approved_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING *;
    `, [userId, orderId]);

    const updatedPo = updateRes.rows[0];

    // History record
    await client.query(`
      INSERT INTO purchase_order_history (purchase_order_id, version, changed_by, action, snapshot_json)
      VALUES ($1, $2, $3, 'APPROVED', $4);
    `, [orderId, updatedPo.version, userId, JSON.stringify(updatedPo)]);

    await AuditService.log({
      organizationId: orgId,
      entityType: 'PURCHASE_ORDER',
      entityId: orderId,
      action: 'APPROVE',
      actorId: userId,
      actorName: req.user!.fullName,
      actorRole: req.user!.role,
      previousState: { status: currentPo.status },
      newState: { status: 'APPROVED' },
      client
    });

    return updatedPo;
  });

  res.json({ order: result, message: 'Purchase order approved successfully.' });
});

export default router;
