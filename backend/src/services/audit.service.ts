import { PoolClient } from 'pg';
import { pool, query } from '../db/connection';

export interface AuditParams {
  organizationId: string;
  entityType: string;
  entityId: string;
  action: string;
  actorId?: string;
  actorName?: string;
  actorRole?: string;
  previousState?: any;
  newState?: any;
  changesDiff?: any;
  ipAddress?: string;
  client?: PoolClient;
}

export class AuditService {
  static async log(params: AuditParams): Promise<void> {
    const sql = `
      INSERT INTO audit_events (
        organization_id, entity_type, entity_id, action,
        actor_id, actor_name, actor_role, ip_address,
        previous_state, new_state, changes_diff
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11);
    `;
    const values = [
      params.organizationId,
      params.entityType,
      params.entityId,
      params.action,
      params.actorId || null,
      params.actorName || 'System',
      params.actorRole || 'SYSTEM',
      params.ipAddress || null,
      params.previousState ? JSON.stringify(params.previousState) : null,
      params.newState ? JSON.stringify(params.newState) : null,
      params.changesDiff ? JSON.stringify(params.changesDiff) : null,
    ];

    if (params.client) {
      await params.client.query(sql, values);
    } else {
      await query(sql, values);
    }
  }

  static async getHistory(entityType: string, entityId: string): Promise<any[]> {
    return query(
      `SELECT * FROM audit_events WHERE entity_type = $1 AND entity_id = $2 ORDER BY timestamp DESC`,
      [entityType, entityId]
    );
  }
}
