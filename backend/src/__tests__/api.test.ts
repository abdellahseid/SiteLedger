import { describe, it, expect, beforeAll } from 'vitest';
import request from 'supertest';
import { app } from '../index';

describe('SiteLedger Backend REST API Tests', () => {
  let authToken = '';
  let projectId = '';
  let supplierId = '';
  let materialId = '';
  let createdPoId = '';
  let createdPoLineId = '';
  let createdReceiptId = '';
  let createdDiscrepancyId = '';

  beforeAll(async () => {
    // Authenticate as Project Manager (Aster Bekele)
    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'pm@siteledger.et',
        password: 'Password123!'
      });

    expect(loginRes.status).toBe(200);
    expect(loginRes.body.token).toBeDefined();
    authToken = loginRes.body.token;

    // Fetch projects
    const projRes = await request(app)
      .get('/api/projects')
      .set('Authorization', `Bearer ${authToken}`);
    expect(projRes.status).toBe(200);
    expect(projRes.body.projects.length).toBeGreaterThan(0);
    projectId = projRes.body.projects[0].id;

    // Fetch suppliers
    const supRes = await request(app)
      .get('/api/materials/suppliers')
      .set('Authorization', `Bearer ${authToken}`);
    expect(supRes.status).toBe(200);
    supplierId = supRes.body.suppliers[0].id;

    // Fetch materials
    const matRes = await request(app)
      .get('/api/materials')
      .set('Authorization', `Bearer ${authToken}`);
    expect(matRes.status).toBe(200);
    materialId = matRes.body.materials[0].id;
  });

  it('GET /health returns healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('healthy');
  });

  it('GET /api/auth/demo-accounts lists roles', async () => {
    const res = await request(app).get('/api/auth/demo-accounts');
    expect(res.status).toBe(200);
    expect(res.body.accounts.length).toBeGreaterThanOrEqual(4);
  });

  it('POST /api/orders creates a new Purchase Order', async () => {
    const poNumber = `PO-TEST-${Date.now()}`;
    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        projectId,
        supplierId,
        poNumber,
        notes: 'Test PO for foundation beams',
        lines: [
          {
            materialId,
            orderedQuantity: 500,
            unitPriceEtb: 1350,
            notes: 'Test batch delivery'
          }
        ]
      });

    expect(res.status).toBe(201);
    expect(res.body.order.po_number).toBe(poNumber);
    expect(res.body.lines.length).toBe(1);
    createdPoId = res.body.order.id;
    createdPoLineId = res.body.lines[0].id;
  });

  it('PATCH /api/orders/:id/approve approves the Purchase Order', async () => {
    const res = await request(app)
      .patch(`/api/orders/${createdPoId}/approve`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.order.status).toBe('APPROVED');
  });

  it('GET /api/orders/by-number/:poNumber retrieves PO for site QR lookup', async () => {
    const orderRes = await request(app)
      .get(`/api/orders/${createdPoId}`)
      .set('Authorization', `Bearer ${authToken}`);
    const poNumber = orderRes.body.order.po_number;

    const res = await request(app)
      .get(`/api/orders/by-number/${poNumber}`)
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.order.id).toBe(createdPoId);
    expect(res.body.lines.length).toBe(1);
  });

  it('POST /api/receipts receives materials and flags discrepancies', async () => {
    const idempotencyKey = `idemp-test-${Date.now()}`;
    const res = await request(app)
      .post('/api/receipts')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        projectId,
        purchaseOrderId: createdPoId,
        receiptNumber: `REC-TEST-${Date.now()}`,
        waybillNumber: 'WB-TEST-99881',
        truckLicensePlate: 'ET-3-99112',
        driverName: 'Alula Tesfaye',
        idempotencyKey,
        notes: 'Rain ingress spotted at rear of truck during arrival',
        lines: [
          {
            purchaseOrderLineId: createdPoLineId,
            materialId,
            orderedQuantity: 500,
            deliveredQuantity: 470, // 30 bags short
            acceptedQuantity: 450,  // 20 bags damaged
            damagedQuantity: 20,
            rejectedQuantity: 20,
            rejectionReason: 'Moisture hardened bags',
            unit: 'Bags'
          }
        ]
      });

    expect(res.status).toBe(201);
    expect(res.body.receipt).toBeDefined();
    expect(res.body.receipt.status).toBe('FLAGGED');
    expect(res.body.discrepancies.length).toBe(2); // 1 shortage (30 bags), 1 damage (20 bags)
    createdReceiptId = res.body.receipt.id;
    createdDiscrepancyId = res.body.discrepancies[0].id;
  });

  it('POST /api/receipts handles duplicate submission idempotently', async () => {
    const idempotencyKey = `idemp-duplicate-${Date.now()}`;
    const payload = {
      projectId,
      purchaseOrderId: createdPoId,
      receiptNumber: `REC-DUP-${Date.now()}`,
      waybillNumber: 'WB-DUP-11223',
      truckLicensePlate: 'ET-3-11223',
      driverName: 'Kenenisa Bekele',
      idempotencyKey,
      lines: [
        {
          purchaseOrderLineId: createdPoLineId,
          materialId,
          orderedQuantity: 500,
          deliveredQuantity: 500,
          acceptedQuantity: 500,
          damagedQuantity: 0,
          rejectedQuantity: 0,
          unit: 'Bags'
        }
      ]
    };

    const firstRes = await request(app)
      .post('/api/receipts')
      .set('Authorization', `Bearer ${authToken}`)
      .send(payload);
    expect(firstRes.status).toBe(201);
    expect(firstRes.body.isDuplicate).toBe(false);

    // Re-submit identical payload
    const secondRes = await request(app)
      .post('/api/receipts')
      .set('Authorization', `Bearer ${authToken}`)
      .send(payload);
    expect(secondRes.status).toBe(200);
    expect(secondRes.body.isDuplicate).toBe(true);
    expect(secondRes.body.receipt.id).toBe(firstRes.body.receipt.id);
  });

  it('PATCH /api/discrepancies/:id/resolve documents resolution', async () => {
    const res = await request(app)
      .patch(`/api/discrepancies/${createdDiscrepancyId}/resolve`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        resolutionType: 'SUPPLIER_REPLACEMENT',
        resolutionNotes: 'Supplier agreed to dispatch replacement 30 bags on tomorrow 08:00 AM delivery truck with no additional freight charge.'
      });

    expect(res.status).toBe(200);
    expect(res.body.discrepancy.status).toBe('RESOLVED');
    expect(res.body.discrepancy.resolution_type).toBe('SUPPLIER_REPLACEMENT');
  });

  it('POST /api/ai/explain-discrepancy provides commercial explanation', async () => {
    const res = await request(app)
      .post('/api/ai/explain-discrepancy')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        discrepancyId: createdDiscrepancyId
      });

    expect(res.status).toBe(200);
    expect(res.body.explanation).toBeDefined();
    expect(res.body.recommendedAction).toBeDefined();
  });

  it('GET /api/reports/dashboard returns executive KPIs', async () => {
    const res = await request(app)
      .get('/api/reports/dashboard')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.body.orders).toBeDefined();
    expect(res.body.deliveries).toBeDefined();
    expect(res.body.materials.length).toBeGreaterThan(0);
  });

  it('GET /api/reports/export-csv exports CSV with content-type', async () => {
    const res = await request(app)
      .get('/api/reports/export-csv')
      .set('Authorization', `Bearer ${authToken}`);

    expect(res.status).toBe(200);
    expect(res.headers['content-type']).toContain('text/csv');
    expect(res.text).toContain('Receipt Number,Waybill Number');
  });
});
