import { PoolClient } from 'pg';
import { query } from '../db/connection';

export interface ProcessReceiptLineParams {
  organizationId: string;
  projectId: string;
  receiptId: string;
  receiptLineId: string;
  materialId: string;
  orderedQty: number;
  deliveredQty: number;
  acceptedQty: number;
  damagedQty: number;
  rejectedQty: number;
  unitPriceEtb: number;
  materialName: string;
  unit: string;
  notes?: string;
  assignedToUserId?: string;
  client: PoolClient;
}

export class DiscrepancyService {
  static async evaluateAndFlagDiscrepancies(params: ProcessReceiptLineParams): Promise<any[]> {
    const createdDiscrepancies: any[] = [];
    const client = params.client;

    // 1. Shortage Check: deliveredQty < orderedQty
    if (params.deliveredQty < params.orderedQty) {
      const shortageQty = params.orderedQty - params.deliveredQty;
      const financialImpact = shortageQty * params.unitPriceEtb;
      const severity = financialImpact > 100000 ? 'CRITICAL' : financialImpact > 30000 ? 'HIGH' : 'MEDIUM';

      const res = await client.query(`
        INSERT INTO discrepancies (
          organization_id, project_id, receipt_id, receipt_line_id, material_id,
          type, severity, status, expected_quantity, actual_quantity, variance_quantity,
          financial_impact_etb, description, assigned_to
        ) VALUES (
          $1, $2, $3, $4, $5,
          'SHORTAGE', $6, 'OPEN', $7, $8, $9,
          $10, $11, $12
        ) RETURNING *;
      `, [
        params.organizationId,
        params.projectId,
        params.receiptId,
        params.receiptLineId,
        params.materialId,
        severity,
        params.orderedQty,
        params.deliveredQty,
        -shortageQty,
        financialImpact,
        `Physical offload count revealed ${params.deliveredQty} ${params.unit} vs ${params.orderedQty} ${params.unit} ordered. Shortage deficit of ${shortageQty} ${params.unit} (Value: ETB ${financialImpact.toLocaleString()}).`,
        params.assignedToUserId || null,
      ]);
      createdDiscrepancies.push(res.rows[0]);
    }

    // 2. Excess Check: deliveredQty > orderedQty
    if (params.deliveredQty > params.orderedQty) {
      const excessQty = params.deliveredQty - params.orderedQty;
      const financialImpact = excessQty * params.unitPriceEtb;

      const res = await client.query(`
        INSERT INTO discrepancies (
          organization_id, project_id, receipt_id, receipt_line_id, material_id,
          type, severity, status, expected_quantity, actual_quantity, variance_quantity,
          financial_impact_etb, description, assigned_to
        ) VALUES (
          $1, $2, $3, $4, $5,
          'EXCESS', 'LOW', 'OPEN', $6, $7, $8,
          $9, $10, $11
        ) RETURNING *;
      `, [
        params.organizationId,
        params.projectId,
        params.receiptId,
        params.receiptLineId,
        params.materialId,
        params.orderedQty,
        params.deliveredQty,
        excessQty,
        financialImpact,
        `Supplier dispatched ${params.deliveredQty} ${params.unit}, exceeding authorized purchase order quantity of ${params.orderedQty} ${params.unit} by +${excessQty} ${params.unit}.`,
        params.assignedToUserId || null,
      ]);
      createdDiscrepancies.push(res.rows[0]);
    }

    // 3. Damage / Quality Rejection Check: damagedQty > 0
    if (params.damagedQty > 0) {
      const financialImpact = params.damagedQty * params.unitPriceEtb;
      const severity = financialImpact > 50000 ? 'HIGH' : 'MEDIUM';

      const res = await client.query(`
        INSERT INTO discrepancies (
          organization_id, project_id, receipt_id, receipt_line_id, material_id,
          type, severity, status, expected_quantity, actual_quantity, variance_quantity,
          financial_impact_etb, description, assigned_to
        ) VALUES (
          $1, $2, $3, $4, $5,
          'DAMAGE', $6, 'OPEN', $7, $8, $9,
          $10, $11, $12
        ) RETURNING *;
      `, [
        params.organizationId,
        params.projectId,
        params.receiptId,
        params.receiptLineId,
        params.materialId,
        severity,
        params.deliveredQty,
        params.acceptedQty,
        -params.damagedQty,
        financialImpact,
        `${params.damagedQty} ${params.unit} rejected on site due to damage or non-conformance. Value: ETB ${financialImpact.toLocaleString()}. Site notes: "${params.notes || 'Damage on delivery'}".`,
        params.assignedToUserId || null,
      ]);
      createdDiscrepancies.push(res.rows[0]);
    }

    return createdDiscrepancies;
  }
}
