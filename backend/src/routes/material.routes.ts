import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { query } from '../db/connection';
import { authenticateToken, requireRoles } from '../middleware/auth';
import { validateBody } from '../middleware/validate';

const router = Router();

// GET /api/materials - catalog
router.get('/', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const materials = await query<any>(`
    SELECT * FROM materials
    WHERE organization_id = $1
    ORDER BY category ASC, name ASC;
  `, [orgId]);

  res.json({ materials });
});

// GET /api/suppliers
router.get('/suppliers', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const suppliers = await query<any>(`
    SELECT s.*,
      COUNT(DISTINCT po.id) as total_orders,
      COUNT(DISTINCT r.id) as total_deliveries,
      COUNT(DISTINCT d.id) as total_discrepancies
    FROM suppliers s
    LEFT JOIN purchase_orders po ON po.supplier_id = s.id
    LEFT JOIN receipts r ON r.purchase_order_id = po.id
    LEFT JOIN discrepancies d ON d.receipt_id = r.id
    WHERE s.organization_id = $1
    GROUP BY s.id
    ORDER BY s.rating DESC, s.name ASC;
  `, [orgId]);

  res.json({ suppliers });
});

const createMaterialSchema = z.object({
  code: z.string().min(2),
  name: z.string().min(2),
  category: z.string().min(2),
  unit: z.string().min(1),
  standardSpecification: z.string().optional(),
  defaultUnitCostEtb: z.number().nonnegative().optional(),
});

// POST /api/materials
router.post('/', authenticateToken, requireRoles('ADMIN', 'PROCUREMENT_OFFICER'), validateBody(createMaterialSchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { code, name, category, unit, standardSpecification, defaultUnitCostEtb } = req.body;

  const mat = await query<any>(`
    INSERT INTO materials (
      organization_id, code, name, category, unit, standard_specification, default_unit_cost_etb
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *;
  `, [orgId, code.toUpperCase(), name, category, unit, standardSpecification || null, defaultUnitCostEtb || 0]);

  res.status(201).json({ material: mat[0] });
});

export default router;
