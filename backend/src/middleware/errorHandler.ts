import { Request, Response, NextFunction } from 'express';

export function errorHandler(err: any, req: Request, res: Response, next: NextFunction): void {
  console.error('[API-ERROR]', {
    message: err.message,
    stack: process.env.NODE_ENV !== 'production' ? err.stack : undefined,
    path: req.originalUrl,
    method: req.method,
  });

  if (err.code === '23505') {
    // Postgres Unique Violation
    res.status(409).json({
      error: {
        code: 'DUPLICATE_RESOURCE',
        message: 'A resource with these unique identifiers already exists.',
        detail: err.detail
      }
    });
    return;
  }

  if (err.code === '23503') {
    // Postgres Foreign Key Violation
    res.status(400).json({
      error: {
        code: 'FOREIGN_KEY_VIOLATION',
        message: 'Referenced entity does not exist.',
        detail: err.detail
      }
    });
    return;
  }

  res.status(err.status || 500).json({
    error: {
      code: err.code || 'INTERNAL_SERVER_ERROR',
      message: err.message || 'An unexpected server error occurred.',
    }
  });
}
