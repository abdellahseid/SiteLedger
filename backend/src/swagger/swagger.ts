export const openApiSpec = {
  openapi: '3.0.0',
  info: {
    title: 'SiteLedger Construction Delivery Intelligence API',
    version: '1.0.0',
    description: 'Production REST API for offline-first construction materials delivery verification in Ethiopia. Powered by Node.js, TypeScript, PostgreSQL, and Google Gemini AI.',
    contact: {
      name: 'SiteLedger Engineering Team',
      email: 'engineering@siteledger.et'
    }
  },
  servers: [
    { url: 'http://localhost:4000', description: 'Local Development Server' }
  ],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT'
      }
    }
  },
  security: [{ bearerAuth: [] }],
  paths: {
    '/api/auth/login': {
      post: {
        summary: 'Authenticate user with email and password',
        tags: ['Authentication'],
        security: [],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                  email: { type: 'string', example: 'storekeeper@siteledger.et' },
                  password: { type: 'string', example: 'Password123!' }
                }
              }
            }
          }
        },
        responses: {
          200: { description: 'Authentication successful with JWT token and user profile' }
        }
      }
    },
    '/api/auth/demo-accounts': {
      get: {
        summary: 'List available seed demo accounts for instant role-switching',
        tags: ['Authentication'],
        security: [],
        responses: { 200: { description: 'List of pre-configured demo user accounts' } }
      }
    },
    '/api/projects': {
      get: {
        summary: 'List all construction projects in organization with delivery stats',
        tags: ['Projects'],
        responses: { 200: { description: 'Array of projects' } }
      }
    },
    '/api/orders': {
      get: {
        summary: 'List purchase orders with fulfillment progress',
        tags: ['Purchase Orders'],
        parameters: [
          { name: 'projectId', in: 'query', schema: { type: 'string' } },
          { name: 'status', in: 'query', schema: { type: 'string' } }
        ],
        responses: { 200: { description: 'Array of purchase orders' } }
      },
      post: {
        summary: 'Create a new purchase order with line items',
        tags: ['Purchase Orders'],
        responses: { 201: { description: 'Purchase order created' } }
      }
    },
    '/api/orders/by-number/{poNumber}': {
      get: {
        summary: 'Site QR code / barcode lookup for instantaneous material receiving',
        tags: ['Purchase Orders'],
        parameters: [
          { name: 'poNumber', in: 'path', required: true, schema: { type: 'string' } }
        ],
        responses: { 200: { description: 'Matching purchase order and lines' } }
      }
    },
    '/api/orders/{id}/approve': {
      patch: {
        summary: 'Project Manager signs off on purchase order',
        tags: ['Purchase Orders'],
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string' } }],
        responses: { 200: { description: 'Purchase order approved' } }
      }
    },
    '/api/receipts': {
      get: {
        summary: 'List material receipts with delivery metrics',
        tags: ['Delivery Receipts'],
        responses: { 200: { description: 'Array of receipts' } }
      },
      post: {
        summary: 'Process delivery arrival, check shortages/damages, update PO progress',
        tags: ['Delivery Receipts'],
        responses: { 201: { description: 'Delivery receipt processed and discrepancies evaluated' } }
      }
    },
    '/api/receipts/sync': {
      post: {
        summary: 'Batch sync queued offline receipts from Drift SQLite mobile outbox',
        tags: ['Delivery Receipts'],
        responses: { 200: { description: 'Batch synchronization result with idempotency receipts' } }
      }
    },
    '/api/discrepancies': {
      get: {
        summary: 'List auto-flagged shortage, excess, and damage discrepancies',
        tags: ['Discrepancies'],
        responses: { 200: { description: 'Array of discrepancies' } }
      }
    },
    '/api/discrepancies/{id}/resolve': {
      patch: {
        summary: 'Document resolution of a discrepancy',
        tags: ['Discrepancies'],
        responses: { 200: { description: 'Discrepancy resolved' } }
      }
    },
    '/api/reports/dashboard': {
      get: {
        summary: 'Executive dashboard with KPIs, material fulfillment, and supplier reliability',
        tags: ['Reports & Analytics'],
        responses: { 200: { description: 'Executive dashboard metrics' } }
      }
    },
    '/api/reports/export-csv': {
      get: {
        summary: 'Export delivery ledger and discrepancies to CSV',
        tags: ['Reports & Analytics'],
        responses: { 200: { description: 'CSV file download' } }
      }
    },
    '/api/ai/explain-discrepancy': {
      post: {
        summary: 'AI commercial impact and contractual recommendation for delivery discrepancy',
        tags: ['Gemini AI Intelligence'],
        responses: { 200: { description: 'Plain-language analysis and recommendation' } }
      }
    },
    '/api/ai/project-summary': {
      post: {
        summary: 'AI executive delivery summary and material availability insights',
        tags: ['Gemini AI Intelligence'],
        responses: { 200: { description: 'Executive summary and key insights' } }
      }
    },
    '/api/ai/query-report': {
      post: {
        summary: 'Natural-language queries against authorized project report ledger',
        tags: ['Gemini AI Intelligence'],
        responses: { 200: { description: 'Answer backed by exact delivery metrics' } }
      }
    }
  }
};
