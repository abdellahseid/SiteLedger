import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { query } from '../db/connection';
import { authenticateToken } from '../middleware/auth';
import { validateBody } from '../middleware/validate';
import { GeminiService } from '../services/gemini.service';

const router = Router();

// POST /api/ai/explain-discrepancy - explain discrepancy by ID
const explainSchema = z.object({
  discrepancyId: z.string().uuid(),
});

router.post('/explain-discrepancy', authenticateToken, validateBody(explainSchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { discrepancyId } = req.body;

  const rows = await query<any>(`
    SELECT d.*,
      p.name as project_name,
      m.name as material_name, m.unit as material_unit,
      s.name as supplier_name,
      r.notes as receipt_notes
    FROM discrepancies d
    JOIN projects p ON p.id = d.project_id
    JOIN materials m ON m.id = d.material_id
    JOIN receipts r ON r.id = d.receipt_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    WHERE d.id = $1 AND d.organization_id = $2
    LIMIT 1;
  `, [discrepancyId, orgId]);

  if (!rows.length) {
    res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Discrepancy record not found.' } });
    return;
  }

  const d = rows[0];
  const unitPrice = d.actual_quantity !== 0
    ? Math.abs(Number(d.financial_impact_etb) / Number(d.variance_quantity || 1))
    : 1000;

  const result = await GeminiService.explainDiscrepancy({
    materialName: d.material_name,
    expectedQuantity: Number(d.expected_quantity),
    actualQuantity: Number(d.actual_quantity),
    varianceQuantity: Number(d.variance_quantity),
    unit: d.material_unit,
    type: d.type,
    severity: d.severity,
    unitPriceEtb: unitPrice,
    financialImpactEtb: Number(d.financial_impact_etb),
    notes: d.description,
    supplierName: d.supplier_name,
    projectName: d.project_name,
  });

  res.json({
    discrepancyId,
    materialName: d.material_name,
    ...result
  });
});

// POST /api/ai/project-summary - generates executive delivery briefing
const summarySchema = z.object({
  projectId: z.string().uuid(),
});

router.post('/project-summary', authenticateToken, validateBody(summarySchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { projectId } = req.body;

  const proj = await query<any>(`SELECT name FROM projects WHERE id = $1 AND organization_id = $2;`, [projectId, orgId]);
  if (!proj.length) {
    res.status(404).json({ error: { code: 'PROJECT_NOT_FOUND', message: 'Project not found.' } });
    return;
  }

  const orderStats = await query<any>(`
    SELECT COUNT(id) as total_orders, COALESCE(SUM(total_amount_etb), 0) as total_spent
    FROM purchase_orders WHERE project_id = $1;
  `, [projectId]);

  const deliveryStats = await query<any>(`
    SELECT COUNT(id) as total_deliveries FROM receipts WHERE project_id = $1;
  `, [projectId]);

  const discStats = await query<any>(`
    SELECT COUNT(id) as open_count, COALESCE(SUM(financial_impact_etb), 0) as impact
    FROM discrepancies WHERE project_id = $1 AND status IN ('OPEN', 'UNDER_REVIEW');
  `, [projectId]);

  const materials = await query<any>(`
    SELECT m.name, m.unit,
      COALESCE(SUM(pol.accepted_quantity), 0) as received,
      COALESCE(SUM(pol.ordered_quantity), 0) as ordered
    FROM purchase_orders po
    JOIN purchase_order_lines pol ON pol.purchase_order_id = po.id
    JOIN materials m ON m.id = pol.material_id
    WHERE po.project_id = $1
    GROUP BY m.name, m.unit
    LIMIT 5;
  `, [projectId]);

  const summary = await GeminiService.generateProjectSummary({
    projectName: proj[0].name,
    totalOrders: Number(orderStats[0]?.total_orders || 0),
    totalDeliveries: Number(deliveryStats[0]?.total_deliveries || 0),
    totalSpentEtb: Number(orderStats[0]?.total_spent || 0),
    openDiscrepancies: Number(discStats[0]?.open_count || 0),
    discrepancyValueEtb: Number(discStats[0]?.impact || 0),
    criticalMaterials: materials.map(m => ({
      name: m.name,
      received: Number(m.received),
      ordered: Number(m.ordered),
      unit: m.unit,
    }))
  });

  res.json({
    projectName: proj[0].name,
    ...summary
  });
});

// POST /api/ai/query-report - natural language query over authorized project data
const querySchema = z.object({
  projectId: z.string().uuid().optional(),
  query: z.string().min(3),
});

router.post('/query-report', authenticateToken, validateBody(querySchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { projectId, query: userQuery } = req.body;

  // Gather context data for the query
  const discrepancies = await query<any>(`
    SELECT d.type, d.severity, d.financial_impact_etb, d.description, m.name as material_name, s.name as supplier_name
    FROM discrepancies d
    JOIN materials m ON m.id = d.material_id
    JOIN receipts r ON r.id = d.receipt_id
    JOIN purchase_orders po ON po.id = r.purchase_order_id
    JOIN suppliers s ON s.id = po.supplier_id
    WHERE d.organization_id = $1 ${projectId ? 'AND d.project_id = $2' : ''}
    LIMIT 20;
  `, projectId ? [orgId, projectId] : [orgId]);

  const orders = await query<any>(`
    SELECT po.po_number, po.status, po.total_amount_etb, s.name as supplier_name
    FROM purchase_orders po
    JOIN suppliers s ON s.id = po.supplier_id
    WHERE po.organization_id = $1 ${projectId ? 'AND po.project_id = $2' : ''}
    LIMIT 20;
  `, projectId ? [orgId, projectId] : [orgId]);

  const contextData = {
    userRole: req.user!.role,
    totalDiscrepancies: discrepancies.length,
    discrepancies,
    orders,
  };

  const answer = await GeminiService.queryProjectReports(userQuery, contextData);

  res.json({
    query: userQuery,
    ...answer
  });
});

// POST /api/ai/parse-delivery-note - extract items from OCR / note text
const parseNoteSchema = z.object({
  documentText: z.string().min(5),
});

router.post('/parse-delivery-note', authenticateToken, validateBody(parseNoteSchema), async (req: Request, res: Response) => {
  const { documentText } = req.body;
  const result = await GeminiService.extractFromDeliveryNote(documentText);
  res.json(result);
});

export default router;
