import { pool } from './connection';

export async function runMigrations() {
  console.log('Running SiteLedger database migrations...');
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Enable UUID extension
    await client.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`);

    // Organizations (Tenants)
    await client.query(`
      CREATE TABLE IF NOT EXISTS organizations (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        name VARCHAR(255) NOT NULL,
        slug VARCHAR(100) UNIQUE NOT NULL,
        country VARCHAR(100) DEFAULT 'Ethiopia',
        currency VARCHAR(10) DEFAULT 'ETB',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Users
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(255) NOT NULL,
        phone VARCHAR(50),
        job_title VARCHAR(100),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Memberships (Tenant Isolation & Roles)
    await client.query(`
      CREATE TABLE IF NOT EXISTS memberships (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        role VARCHAR(50) NOT NULL CHECK (role IN ('ADMIN', 'PROJECT_MANAGER', 'PROCUREMENT_OFFICER', 'STOREKEEPER', 'SUPPLIER')),
        is_primary BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (organization_id, user_id)
      );
    `);

    // Projects
    await client.query(`
      CREATE TABLE IF NOT EXISTS projects (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        code VARCHAR(50) NOT NULL,
        name VARCHAR(255) NOT NULL,
        location VARCHAR(255) NOT NULL,
        description TEXT,
        status VARCHAR(50) DEFAULT 'ACTIVE' CHECK (status IN ('PLANNING', 'ACTIVE', 'ON_HOLD', 'COMPLETED')),
        budget_etb NUMERIC(15, 2) DEFAULT 0.00,
        start_date DATE,
        target_completion DATE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (organization_id, code)
      );
    `);

    // Project Assignments
    await client.query(`
      CREATE TABLE IF NOT EXISTS project_assignments (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (project_id, user_id)
      );
    `);

    // Suppliers
    await client.query(`
      CREATE TABLE IF NOT EXISTS suppliers (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        contact_person VARCHAR(255),
        phone VARCHAR(50),
        email VARCHAR(255),
        address VARCHAR(255),
        rating NUMERIC(3, 2) DEFAULT 5.00,
        is_verified BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Material Catalog
    await client.query(`
      CREATE TABLE IF NOT EXISTS materials (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        code VARCHAR(50) NOT NULL,
        name VARCHAR(255) NOT NULL,
        category VARCHAR(100) NOT NULL,
        unit VARCHAR(50) NOT NULL, -- Bags, Tonnes, m3, Pcs, Bundles
        standard_specification TEXT,
        default_unit_cost_etb NUMERIC(12, 2) DEFAULT 0.00,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (organization_id, code)
      );
    `);

    // Purchase Orders
    await client.query(`
      CREATE TABLE IF NOT EXISTS purchase_orders (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
        supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
        po_number VARCHAR(50) NOT NULL,
        version INT DEFAULT 1,
        status VARCHAR(50) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'PARTIALLY_RECEIVED', 'COMPLETED', 'CANCELLED')),
        total_amount_etb NUMERIC(15, 2) DEFAULT 0.00,
        notes TEXT,
        created_by UUID REFERENCES users(id),
        approved_by UUID REFERENCES users(id),
        approved_at TIMESTAMP WITH TIME ZONE,
        expected_delivery_date DATE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (organization_id, po_number)
      );
    `);

    // Purchase Order Lines
    await client.query(`
      CREATE TABLE IF NOT EXISTS purchase_order_lines (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
        material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
        ordered_quantity NUMERIC(12, 2) NOT NULL,
        accepted_quantity NUMERIC(12, 2) DEFAULT 0.00,
        unit_price_etb NUMERIC(12, 2) NOT NULL,
        total_price_etb NUMERIC(15, 2) NOT NULL,
        notes TEXT
      );
    `);

    // Purchase Order Version History
    await client.query(`
      CREATE TABLE IF NOT EXISTS purchase_order_history (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
        version INT NOT NULL,
        changed_by UUID REFERENCES users(id),
        action VARCHAR(50) NOT NULL, -- CREATED, UPDATED, SUBMITTED_FOR_APPROVAL, APPROVED, REJECTED
        snapshot_json JSONB NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Receipts (Delivery Records)
    await client.query(`
      CREATE TABLE IF NOT EXISTS receipts (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
        purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE RESTRICT,
        receipt_number VARCHAR(50) NOT NULL,
        waybill_number VARCHAR(100) NOT NULL,
        truck_license_plate VARCHAR(50) NOT NULL,
        driver_name VARCHAR(255) NOT NULL,
        driver_phone VARCHAR(50),
        carrier_name VARCHAR(255),
        storekeeper_id UUID NOT NULL REFERENCES users(id),
        delivery_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(50) DEFAULT 'SUBMITTED' CHECK (status IN ('DRAFT', 'SUBMITTED', 'VERIFIED', 'FLAGGED')),
        idempotency_key VARCHAR(100) UNIQUE NOT NULL,
        latitude NUMERIC(10, 7),
        longitude NUMERIC(10, 7),
        notes TEXT,
        supplier_representative_name VARCHAR(255),
        signature_path VARCHAR(500),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (organization_id, receipt_number)
      );
    `);

    // Receipt Lines
    await client.query(`
      CREATE TABLE IF NOT EXISTS receipt_lines (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        receipt_id UUID NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
        purchase_order_line_id UUID NOT NULL REFERENCES purchase_order_lines(id) ON DELETE RESTRICT,
        material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
        ordered_quantity NUMERIC(12, 2) NOT NULL,
        delivered_quantity NUMERIC(12, 2) NOT NULL, -- Total arrived on truck
        accepted_quantity NUMERIC(12, 2) NOT NULL,
        damaged_quantity NUMERIC(12, 2) DEFAULT 0.00,
        rejected_quantity NUMERIC(12, 2) DEFAULT 0.00,
        rejection_reason TEXT,
        unit VARCHAR(50) NOT NULL
      );
    `);

    // Evidence / Photo Documentation
    await client.query(`
      CREATE TABLE IF NOT EXISTS evidence (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        receipt_id UUID NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
        receipt_line_id UUID REFERENCES receipt_lines(id) ON DELETE SET NULL,
        photo_type VARCHAR(50) NOT NULL CHECK (photo_type IN ('WAYBILL', 'TRUCK_PLATE', 'MATERIAL_OVERVIEW', 'DAMAGE_DETAIL', 'SEAL_SECURITY', 'SIGNATURE')),
        file_path VARCHAR(500) NOT NULL,
        file_url VARCHAR(500) NOT NULL,
        file_size_bytes BIGINT,
        mime_type VARCHAR(100),
        caption TEXT,
        captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Discrepancies
    await client.query(`
      CREATE TABLE IF NOT EXISTS discrepancies (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
        receipt_id UUID NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
        receipt_line_id UUID REFERENCES receipt_lines(id) ON DELETE SET NULL,
        material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
        type VARCHAR(50) NOT NULL CHECK (type IN ('SHORTAGE', 'EXCESS', 'DAMAGE', 'SPECIFICATION_MISMATCH', 'CONTAMINATION')),
        severity VARCHAR(50) NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
        status VARCHAR(50) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'DISMISSED')),
        expected_quantity NUMERIC(12, 2) NOT NULL,
        actual_quantity NUMERIC(12, 2) NOT NULL,
        variance_quantity NUMERIC(12, 2) NOT NULL, -- Negative for shortage, positive for excess
        financial_impact_etb NUMERIC(15, 2) DEFAULT 0.00,
        description TEXT NOT NULL,
        assigned_to UUID REFERENCES users(id),
        resolution_type VARCHAR(50) CHECK (resolution_type IN ('SUPPLIER_REPLACEMENT', 'CREDIT_NOTE', 'ACCEPTED_WITH_CONCESSION', 'REJECTED_RETURNED', 'CLAIM_FILED')),
        resolution_notes TEXT,
        resolved_by UUID REFERENCES users(id),
        resolved_at TIMESTAMP WITH TIME ZONE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Audit Events (Immutable append-only ledger)
    await client.query(`
      CREATE TABLE IF NOT EXISTS audit_events (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
        entity_type VARCHAR(100) NOT NULL,
        entity_id UUID NOT NULL,
        action VARCHAR(100) NOT NULL,
        actor_id UUID REFERENCES users(id),
        actor_name VARCHAR(255),
        actor_role VARCHAR(50),
        ip_address VARCHAR(100),
        previous_state JSONB,
        new_state JSONB,
        changes_diff JSONB,
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Sync Idempotency Store
    await client.query(`
      CREATE TABLE IF NOT EXISTS sync_idempotency (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        idempotency_key VARCHAR(100) UNIQUE NOT NULL,
        resource_type VARCHAR(50) NOT NULL,
        resource_id UUID NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Helpful Indexes
    await client.query(`CREATE INDEX IF NOT EXISTS idx_po_project ON purchase_orders(project_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_receipts_po ON receipts(purchase_order_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_receipts_project ON receipts(project_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_discrepancies_project ON discrepancies(project_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_discrepancies_status ON discrepancies(status);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_events(entity_type, entity_id);`);

    await client.query('COMMIT');
    console.log('✅ Database migrations executed successfully.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', err);
    throw err;
  } finally {
    client.release();
  }
}

if (require.main === module) {
  runMigrations()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}
