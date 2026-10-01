import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { query } from '../db/connection';

export interface AuthenticatedUser {
  id: string;
  email: string;
  fullName: string;
  role: 'ADMIN' | 'PROJECT_MANAGER' | 'PROCUREMENT_OFFICER' | 'STOREKEEPER' | 'SUPPLIER';
  organizationId: string;
  organizationName: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'siteledger_super_secure_jwt_secret_key_ethiopia_2026_construction';

export async function authenticateToken(req: Request, res: Response, next: NextFunction): Promise<void> {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    res.status(401).json({
      error: { code: 'UNAUTHORIZED', message: 'Authentication token required.' }
    });
    return;
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as any;
    
    // Fetch user and primary membership details
    const users = await query<any>(`
      SELECT u.id, u.email, u.full_name, m.role, m.organization_id, o.name as org_name
      FROM users u
      JOIN memberships m ON m.user_id = u.id
      JOIN organizations o ON o.id = m.organization_id
      WHERE u.id = $1 AND u.is_active = TRUE
      LIMIT 1;
    `, [payload.userId]);

    if (!users.length) {
      res.status(401).json({
        error: { code: 'USER_NOT_FOUND', message: 'User session invalid or deactivated.' }
      });
      return;
    }

    const row = users[0];
    req.user = {
      id: row.id,
      email: row.email,
      fullName: row.full_name,
      role: row.role,
      organizationId: row.organization_id,
      organizationName: row.org_name
    };

    next();
  } catch (err) {
    res.status(403).json({
      error: { code: 'FORBIDDEN', message: 'Invalid or expired authentication token.' }
    });
  }
}

export function requireRoles(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Authentication required.' } });
      return;
    }
    if (!allowedRoles.includes(req.user.role) && req.user.role !== 'ADMIN') {
      res.status(403).json({
        error: { code: 'INSUFFICIENT_PERMISSIONS', message: `Action requires one of: ${allowedRoles.join(', ')}` }
      });
      return;
    }
    next();
  };
}
