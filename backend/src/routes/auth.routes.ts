import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { query } from '../db/connection';
import { authenticateToken } from '../middleware/auth';
import { validateBody } from '../middleware/validate';

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || 'siteledger_super_secure_jwt_secret_key_ethiopia_2026_construction';

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

// POST /api/auth/login
router.post('/login', validateBody(loginSchema), async (req: Request, res: Response) => {
  const { email, password } = req.body;

  const users = await query<any>(`
    SELECT u.id, u.email, u.password_hash, u.full_name, u.phone, u.job_title,
           m.role, m.organization_id, o.name as org_name, o.currency
    FROM users u
    JOIN memberships m ON m.user_id = u.id
    JOIN organizations o ON o.id = m.organization_id
    WHERE LOWER(u.email) = LOWER($1) AND u.is_active = TRUE
    LIMIT 1;
  `, [email]);

  if (!users.length) {
    res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password.' } });
    return;
  }

  const user = users[0];
  const isMatch = await bcrypt.compare(password, user.password_hash);
  if (!isMatch) {
    res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password.' } });
    return;
  }

  const token = jwt.sign(
    { userId: user.id, organizationId: user.organization_id, role: user.role },
    JWT_SECRET,
    { expiresIn: '30d' }
  );

  res.json({
    token,
    user: {
      id: user.id,
      email: user.email,
      fullName: user.full_name,
      phone: user.phone,
      jobTitle: user.job_title,
      role: user.role,
    },
    organization: {
      id: user.organization_id,
      name: user.org_name,
      currency: user.currency,
    }
  });
});

// GET /api/auth/me
router.get('/me', authenticateToken, (req: Request, res: Response) => {
  res.json({ user: req.user });
});

// GET /api/auth/demo-accounts (convenience for evaluation and quick role switching)
router.get('/demo-accounts', async (req: Request, res: Response) => {
  const accounts = await query<any>(`
    SELECT u.email, u.full_name, u.job_title, m.role, o.name as org_name
    FROM users u
    JOIN memberships m ON m.user_id = u.id
    JOIN organizations o ON o.id = m.organization_id
    ORDER BY 
      CASE m.role
        WHEN 'PROJECT_MANAGER' THEN 1
        WHEN 'STOREKEEPER' THEN 2
        WHEN 'PROCUREMENT_OFFICER' THEN 3
        WHEN 'SUPPLIER' THEN 4
        ELSE 5
      END;
  `);

  res.json({
    accounts: accounts.map(a => ({
      email: a.email,
      fullName: a.full_name,
      role: a.role,
      jobTitle: a.job_title,
      organization: a.org_name,
      defaultPassword: 'Password123!'
    }))
  });
});

export default router;
