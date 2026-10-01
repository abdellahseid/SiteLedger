import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { query } from '../db/connection';
import { authenticateToken, requireRoles } from '../middleware/auth';
import { validateBody } from '../middleware/validate';

const router = Router();

// GET /api/projects - list projects for user's organization
router.get('/', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;

  const projects = await query<any>(`
    SELECT p.*,
      COUNT(DISTINCT po.id) as total_orders,
      COUNT(DISTINCT r.id) as total_receipts,
      COUNT(DISTINCT d.id) FILTER (WHERE d.status IN ('OPEN', 'UNDER_REVIEW')) as open_discrepancies,
      COALESCE(SUM(d.financial_impact_etb) FILTER (WHERE d.status IN ('OPEN', 'UNDER_REVIEW')), 0) as discrepancy_impact_etb
    FROM projects p
    LEFT JOIN purchase_orders po ON po.project_id = p.id
    LEFT JOIN receipts r ON r.project_id = p.id
    LEFT JOIN discrepancies d ON d.project_id = p.id
    WHERE p.organization_id = $1
    GROUP BY p.id
    ORDER BY p.created_at ASC;
  `, [orgId]);

  res.json({ projects });
});

// GET /api/projects/:id - detailed project stats
router.get('/:id', authenticateToken, async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const projectId = req.params.id;

  const projectRows = await query<any>(`
    SELECT p.*,
      COUNT(DISTINCT po.id) as total_orders,
      COUNT(DISTINCT r.id) as total_receipts,
      COUNT(DISTINCT d.id) FILTER (WHERE d.status IN ('OPEN', 'UNDER_REVIEW')) as open_discrepancies,
      COALESCE(SUM(d.financial_impact_etb) FILTER (WHERE d.status IN ('OPEN', 'UNDER_REVIEW')), 0) as discrepancy_impact_etb
    FROM projects p
    LEFT JOIN purchase_orders po ON po.project_id = p.id
    LEFT JOIN receipts r ON r.project_id = p.id
    LEFT JOIN discrepancies d ON d.project_id = p.id
    WHERE p.id = $1 AND p.organization_id = $2
    GROUP BY p.id;
  `, [projectId, orgId]);

  if (!projectRows.length) {
    res.status(404).json({ error: { code: 'PROJECT_NOT_FOUND', message: 'Project not found.' } });
    return;
  }

  // Material summary for this project
  const materialSummary = await query<any>(`
    SELECT m.id, m.code, m.name, m.unit, m.category,
      COALESCE(SUM(pol.ordered_quantity), 0) as total_ordered,
      COALESCE(SUM(pol.accepted_quantity), 0) as total_accepted
    FROM purchase_orders po
    JOIN purchase_order_lines pol ON pol.purchase_order_id = po.id
    JOIN materials m ON m.id = pol.material_id
    WHERE po.project_id = $1 AND po.status != 'CANCELLED'
    GROUP BY m.id, m.code, m.name, m.unit, m.category
    ORDER BY m.name ASC;
  `, [projectId]);

  res.json({
    project: projectRows[0],
    materialSummary
  });
});

const createProjectSchema = z.object({
  code: z.string().min(2).max(50),
  name: z.string().min(3).max(255),
  location: z.string().min(2).max(255),
  description: z.string().optional(),
  budgetEtb: z.number().nonnegative().optional(),
  startDate: z.string().optional(),
  targetCompletion: z.string().optional(),
});

// POST /api/projects
router.post('/', authenticateToken, requireRoles('ADMIN', 'PROJECT_MANAGER'), validateBody(createProjectSchema), async (req: Request, res: Response) => {
  const orgId = req.user!.organizationId;
  const { code, name, location, description, budgetEtb, startDate, targetCompletion } = req.body;

  const newProj = await query<any>(`
    INSERT INTO projects (
      organization_id, code, name, location, description, budget_etb, start_date, target_completion
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING *;
  `, [orgId, code.toUpperCase(), name, location, description || null, budgetEtb || 0, startDate || null, targetCompletion || null]);

  res.status(201).json({ project: newProj[0] });
});

export default router;
