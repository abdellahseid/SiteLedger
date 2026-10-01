import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { query, withTransaction } from '../db/connection';
import { authenticateToken, requireRoles } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { GeminiService } from '../services/gemini.service';
import { AuditService } from '../services/audit.service';

const router = Router();

// GET /api/discrepancies - list discrepancies
router.get('/', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { projectId, status, severity, type } = req.query;

  let sql = `
    SELECT d.*,
      p.name as project_name, p.code as project_code,
      m.name as material_name, m.unit as material_unit, m.code as material_code,
      r.receipt_number, r.waybill_number, r.truck_license_plate,
      po.po_number,
      s.name as supplier_name,
      u1.full_name as assigned_to_name,
      u2.full_name as resolved_by_name
    FROM discrepancies d
    JOIN projects p ON p.id = d.project_id
    JOIN materials m ON m.id = d.material_id
    JOIN receipts r ON r.id = d.receipt_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    LEFT JOIN users u1 ON u1.id = d.assigned_to
    LEFT JOIN users u2 ON u2.id = d.resolved_by
    WHERE d.organization_id = $1
  `;
  const params: any[] = [orgId];

  if (projectId) {
    params.push(projectId);
    sql += ` AND d.project_id = $${params.length}`;
  }
  if (status) {
    params.push(status);
    sql += ` AND d.status = $${params.length}`;
  }
  if (severity) {
    params.push(severity);
    sql += ` AND d.severity = $${params.length}`;
  }
  if (type) {
    params.push(type);
    sql += ` AND d.type = $${params.length}`;
  }

  sql += ` ORDER BY 
    CASE d.severity
      WHEN 'CRITICAL' THEN 1
      WHEN 'HIGH' THEN 2
      WHEN 'MEDIUM' THEN 3
      ELSE 4
    END, d.created_at DESC;`;

  const discrepancies = await query<any>(sql, params);
  res.json({ discrepancies });
});

// GET /api/discrepancies/:id - detail with AI explanation
router.get('/:id', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const discrepancyId = req.params.id;

  const rows = await query<any>(`
    SELECT d.*,
      p.name as project_name, p.code as project_code,
      m.name as material_name, m.unit as material_unit, m.code as material_code,
      r.receipt_number, r.waybill_number, r.truck_license_plate, r.notes as receipt_notes,
      po.po_number,
      s.name as supplier_name, s.phone as supplier_phone, s.contact_person as supplier_contact,
      u1.full_name as assigned_to_name,
      u2.full_name as resolved_by_name
    FROM discrepancies d
    JOIN projects p ON p.id = d.project_id
    JOIN materials m ON m.id = d.material_id
    JOIN receipts r ON r.id = d.receipt_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    LEFT JOIN users u1 ON u1.id = d.assigned_to
    LEFT JOIN users u2 ON u2.id = d.resolved_by
    WHERE d.id = $1 AND d.organization_id = $2
    LIMIT 1;
  `, [discrepancyId, orgId]);

  if (!rows.length) {
    res.status(404).json({ error: { code: 'DISCREPANCY_NOT_FOUND', message: 'Discrepancy record not found.' } });
    return;
  }

  const discrepancy = rows[0];

  // Evidence photos attached to this receipt/line
  const evidence = await query<any>(`
    SELECT * FROM evidence 
    WHERE receipt_id = $1 AND (receipt_line_id = $2 OR photo_type IN ('DAMAGE_DETAIL', 'WAYBILL'))
    ORDER BY captured_at ASC;
  `, [discrepancy.receipt_id, discrepancy.receipt_line_id]);

  // Generate or fetch AI Discrepancy Insight
  const unitPrice = discrepancy.actual_quantity !== 0 
    ? Math.abs(Number(discrepancy.financial_impact_etb) / Number(discrepancy.variance_quantity || 1))
    : 1000;

  const aiInsight = await GeminiService.explainDiscrepancy({
    materialName: discrepancy.material_name,
    expectedQuantity: Number(discrepancy.expected_quantity),
    actualQuantity: Number(discrepancy.actual_quantity),
    varianceQuantity: Number(discrepancy.variance_quantity),
    unit: discrepancy.material_unit,
    type: discrepancy.type,
    severity: discrepancy.severity,
    unitPriceEtb: unitPrice,
    financialImpactEtb: Number(discrepancy.financial_impact_etb),
    notes: discrepancy.description,
    supplierName: discrepancy.supplier_name,
    projectName: discrepancy.project_name,
  });

  const auditEvents = await AuditService.getHistory('DISCREPANCY', discrepancyId);

  res.json({
    discrepancy,
    evidence,
    aiInsight,
    auditEvents
  });
});

const assignSchema = z.object({
  assignedToUserId: z.string().uuid(),
});

// PATCH /api/discrepancies/:id/assign
router.patch('/:id/assign', authenticateToken, requireRoles('ADMIN', 'PROJECT_MANAGER', 'PROCUREMENT_OFFICER'), validateBody(assignSchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const discrepancyId = req.params.id;
  const { assignedToUserId } = req.body;

  const result = await withTransaction(async (client) => {
    const updated = await client.query(`
      UPDATE discrepancies
      SET assigned_to = $1, status = 'UNDER_REVIEW', updated_at = CURRENT_TIMESTAMP
      WHERE id = $2 AND organization_id = $3
      RETURNING *;
    `, [assignedToUserId, discrepancyId, orgId]);

    if (!updated.rows.length) {
      throw { status: 404, message: 'Discrepancy not found.' };
    }

    await AuditService.log({
      organizationId: orgId,
      entityType: 'DISCREPANCY',
      entityId: discrepancyId,
      action: 'ASSIGN',
      actorId: req.user!.id,
      actorName: req.user!.fullName,
      actorRole: req.user!.role,
      newState: updated.rows[0],
      client
    });

    return updated.rows[0];
  });

  res.json({ discrepancy: result, message: 'Discrepancy assigned successfully.' });
});

const resolveSchema = z.object({
  resolutionType: z.enum(['SUPPLIER_REPLACEMENT', 'CREDIT_NOTE', 'ACCEPTED_WITH_CONCESSION', 'REJECTED_RETURNED', 'CLAIM_FILED']),
  resolutionNotes: z.string().min(5),
});

// PATCH /api/discrepancies/:id/resolve
router.patch('/:id/resolve', authenticateToken, requireRoles('ADMIN', 'PROJECT_MANAGER', 'PROCUREMENT_OFFICER'), validateBody(resolveSchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const discrepancyId = req.params.id;
  const { resolutionType, resolutionNotes } = req.body;

  const result = await withTransaction(async (client) => {
    const current = await client.query(`
      SELECT * FROM discrepancies WHERE id = $1 AND organization_id = $2 FOR UPDATE;
    `, [discrepancyId, orgId]);

    if (!current.rows.length) {
      throw { status: 404, message: 'Discrepancy not found.' };
    }

    const updated = await client.query(`
      UPDATE discrepancies
      SET status = 'RESOLVED',
          resolution_type = $1,
          resolution_notes = $2,
          resolved_by = $3,
          resolved_at = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $4
      RETURNING *;
    `, [resolutionType, resolutionNotes, req.user!.id, discrepancyId]);

    await AuditService.log({
      organizationId: orgId,
      entityType: 'DISCREPANCY',
      entityId: discrepancyId,
      action: 'RESOLVE',
      actorId: req.user!.id,
      actorName: req.user!.fullName,
      actorRole: req.user!.role,
      previousState: { status: current.rows[0].status },
      newState: updated.rows[0],
      client
    });

    return updated.rows[0];
  });

  res.json({ discrepancy: result, message: 'Discrepancy resolved successfully.' });
});

export default router;
