import express from 'express';
import cors from 'cors';
import path from 'path';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import { openApiSpec } from './swagger/swagger';
import { errorHandler } from './middleware/errorHandler';

import authRoutes from './routes/auth.routes';
import projectRoutes from './routes/project.routes';
import materialRoutes from './routes/material.routes';
import orderRoutes from './routes/order.routes';
import receiptRoutes from './routes/receipt.routes';
import discrepancyRoutes from './routes/discrepancy.routes';
import reportRoutes from './routes/report.routes';
import aiRoutes from './routes/ai.routes';

dotenv.config();

export const app = express();
const PORT = process.env.PORT || 4000;

// Enable CORS for mobile and web clients
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Idempotency-Key']
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static file serving for uploads (evidence photos, waybills)
const uploadDir = path.resolve(process.cwd(), process.env.UPLOAD_DIR || './uploads');
app.use('/uploads', express.static(uploadDir));

// OpenAPI / Swagger Documentation
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(openApiSpec));
app.get('/api/openapi.json', (req, res) => {
  res.json(openApiSpec);
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/projects', projectRoutes);
app.use('/api/materials', materialRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/receipts', receiptRoutes);
app.use('/api/discrepancies', discrepancyRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/ai', aiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'SiteLedger Delivery Intelligence API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptimeSeconds: process.uptime(),
  });
});

// Global Error Handler
app.use(errorHandler);

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`🚀 SiteLedger API Server running on port ${PORT}`);
    console.log(`📚 OpenAPI Docs available at: http://localhost:${PORT}/api/docs`);
    console.log(`🏥 Health check at: http://localhost:${PORT}/health`);
    console.log(`====================================================`);
  });
}

export default app;
