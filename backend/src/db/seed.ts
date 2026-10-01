import bcrypt from 'bcryptjs';
import { pool } from './connection';

export async function runSeed() {
  console.log('Seeding SiteLedger construction demo database...');
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // 1. Clean existing seed data
    await client.query(`
      TRUNCATE TABLE 
        audit_events, discrepancies, evidence, receipt_lines, receipts,
        purchase_order_history, purchase_order_lines, purchase_orders,
        materials, suppliers, project_assignments, projects,
        memberships, users, organizations, sync_idempotency
      CASCADE;
    `);

    // 2. Organization
    const orgRes = await client.query(`
      INSERT INTO organizations (name, slug, country, currency)
      VALUES ('Abyssinia Infrastructures PLC', 'abyssinia-infra', 'Ethiopia', 'ETB')
      RETURNING id;
    `);
    const orgId = orgRes.rows[0].id;

    // 3. Password hash (Password123!)
    const passwordHash = await bcrypt.hash('Password123!', 10);

    // 4. Users
    const usersData = [
      { email: 'pm@siteledger.et', name: 'Aster Bekele', role: 'PROJECT_MANAGER', title: 'Senior Project Director', phone: '+251-91-123-4567' },
      { email: 'procurement@siteledger.et', name: 'Dawit Tadesse', role: 'PROCUREMENT_OFFICER', title: 'Chief Procurement Manager', phone: '+251-91-234-5678' },
      { email: 'storekeeper@siteledger.et', name: 'Chala Lemma', role: 'STOREKEEPER', title: 'Lead Site Materials Controller', phone: '+251-91-345-6789' },
      { email: 'supplier@siteledger.et', name: 'Henok Girma', role: 'SUPPLIER', title: 'Key Account Logistics Representative', phone: '+251-91-456-7890' },
      { email: 'admin@siteledger.et', name: 'Kalkidan Alemu', role: 'ADMIN', title: 'Operations VP', phone: '+251-91-567-8901' },
    ];

    const userMap: Record<string, string> = {};
    for (const u of usersData) {
      const uRes = await client.query(`
        INSERT INTO users (email, password_hash, full_name, phone, job_title)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id;
      `, [u.email, passwordHash, u.name, u.phone, u.title]);
      
      const userId = uRes.rows[0].id;
      userMap[u.role] = userId;

      await client.query(`
        INSERT INTO memberships (organization_id, user_id, role, is_primary)
        VALUES ($1, $2, $3, TRUE);
      `, [orgId, userId, u.role]);
    }

    // 5. Projects
    const p1 = await client.query(`
      INSERT INTO projects (organization_id, code, name, location, description, status, budget_etb, start_date, target_completion)
      VALUES ($1, 'BLIP-02', 'Bole Lemi Industrial Park — Phase II Expansion', 'Bole Sub-City, Addis Ababa', 'Manufacturing hangars, heavy vehicle access arterial roads, and water retention systems.', 'ACTIVE', 450000000.00, '2025-11-01', '2027-04-30')
      RETURNING id;
    `, [orgId]);
    const projBoleLemiId = p1.rows[0].id;

    const p2 = await client.query(`
      INSERT INTO projects (organization_id, code, name, location, description, status, budget_etb, start_date, target_completion)
      VALUES ($1, 'MSTI-01', 'Meskel Square Transit Interchange Facility', 'Kirkos, Addis Ababa', 'Multi-modal commuter hub with underground logistics dock and pedestrian flyovers.', 'ACTIVE', 320000000.00, '2026-01-15', '2027-10-15')
      RETURNING id;
    `, [orgId]);
    const projMeskelId = p2.rows[0].id;

    const p3 = await client.query(`
      INSERT INTO projects (organization_id, code, name, location, description, status, budget_etb, start_date, target_completion)
      VALUES ($1, 'AALT-03', 'Addis-Adama Logistics Express Depot', 'Adama Expressway Zone', 'Bulk bonded warehousing and automated intermodal freight container yards.', 'PLANNING', 210000000.00, '2026-06-01', '2028-02-28')
      RETURNING id;
    `, [orgId]);
    const projAdamaId = p3.rows[0].id;

    // Assign users to projects
    for (const pId of [projBoleLemiId, projMeskelId, projAdamaId]) {
      for (const role of ['PROJECT_MANAGER', 'PROCUREMENT_OFFICER', 'STOREKEEPER']) {
        await client.query(`
          INSERT INTO project_assignments (project_id, user_id)
          VALUES ($1, $2) ON CONFLICT DO NOTHING;
        `, [pId, userMap[role]]);
      }
    }

    // 6. Suppliers
    const s1 = await client.query(`
      INSERT INTO suppliers (organization_id, name, contact_person, phone, email, address, rating)
      VALUES ($1, 'Muger Cement Enterprise', 'Abebe Kebede', '+251-11-236-0001', 'sales@mugercement.com.et', 'Ambo Road, Oromia / Addis Office', 4.85)
      RETURNING id;
    `, [orgId]);
    const supMugerId = s1.rows[0].id;

    const s2 = await client.query(`
      INSERT INTO suppliers (organization_id, name, contact_person, phone, email, address, rating)
      VALUES ($1, 'Habesha Steel Mills PLC', 'Birhanu Negash', '+251-11-440-1234', 'orders@habeshasteel.com.et', 'Dukem Industrial Zone, Oromia', 4.70)
      RETURNING id;
    `, [orgId]);
    const supHabeshaId = s2.rows[0].id;

    const s3 = await client.query(`
      INSERT INTO suppliers (organization_id, name, contact_person, phone, email, address, rating)
      VALUES ($1, 'National Cement Share Company', 'Mulugeta Tilahun', '+251-25-111-2233', 'supply@nationalcement.et', 'Dire Dawa Industrial Area', 4.60)
      RETURNING id;
    `, [orgId]);
    const supNationalId = s3.rows[0].id;

    const s4 = await client.query(`
      INSERT INTO suppliers (organization_id, name, contact_person, phone, email, address, rating)
      VALUES ($1, 'Derba MIDROC Cement', 'Sintayehu Wolde', '+251-11-554-9900', 'dispatch@derbacement.com', 'Muger Valley, Oromia', 4.90)
      RETURNING id;
    `, [orgId]);
    const supDerbaId = s4.rows[0].id;

    // 7. Materials Catalog
    const materialsData = [
      { code: 'MAT-CEM-01', name: 'Portland Pozzolana Cement (PPC 42.5R)', category: 'Cementitious', unit: 'Bags', cost: 1350.00, spec: 'ES EN 197-1 Ethiopian Standard, 50kg waterproof multi-wall paper sack' },
      { code: 'MAT-STL-16', name: 'High Yield Deformed Rebar Grade 60 (16mm)', category: 'Reinforcing Steel', unit: 'Tonnes', cost: 118000.00, spec: 'ASTM A615 / ES 327, 12m length bundles with manufacturer heat tags' },
      { code: 'MAT-STL-12', name: 'High Yield Deformed Rebar Grade 60 (12mm)', category: 'Reinforcing Steel', unit: 'Tonnes', cost: 119500.00, spec: 'ASTM A615 / ES 327, 12m length bundles for shear stirrups and deck mesh' },
      { code: 'MAT-AGG-20', name: 'Crushed Basalt Aggregate (20mm Gradation)', category: 'Aggregates', unit: 'm3', cost: 2400.00, spec: 'Clean crushed volcanic basalt, silt content < 1.5%, Los Angeles abrasion < 25%' },
      { code: 'MAT-BEAM-305', name: 'Structural Steel Universal Beam (305x165x40)', category: 'Structural Steel', unit: 'Tonnes', cost: 145000.00, spec: 'EN 10025 S355JR structural steel sections, primer coated' },
      { code: 'MAT-BLK-20', name: 'Hollow Concrete Masonry Blocks (40x20x20cm)', category: 'Masonry', unit: 'Pcs', cost: 72.00, spec: 'Compressive strength > 7.0 MPa, cured min 21 days' }
    ];

    const matMap: Record<string, string> = {};
    for (const m of materialsData) {
      const mRes = await client.query(`
        INSERT INTO materials (organization_id, code, name, category, unit, standard_specification, default_unit_cost_etb)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id;
      `, [orgId, m.code, m.name, m.category, m.unit, m.spec, m.cost]);
      matMap[m.code] = mRes.rows[0].id;
    }

    // 8. Purchase Orders
    // PO 1: Approved & Partially Received
    const po1Res = await client.query(`
      INSERT INTO purchase_orders (
        organization_id, project_id, supplier_id, po_number, version, status,
        total_amount_etb, notes, created_by, approved_by, approved_at, expected_delivery_date
      ) VALUES (
        $1, $2, $3, 'PO-2026-BLIP-001', 1, 'PARTIALLY_RECEIVED',
        2700000.00, 'Batch 1 structural foundation cement for Bole Lemi Hangar 3 foundation slab',
        $4, $5, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_DATE + INTERVAL '2 days'
      ) RETURNING id;
    `, [orgId, projBoleLemiId, supMugerId, userMap['PROCUREMENT_OFFICER'], userMap['PROJECT_MANAGER']]);
    const po1Id = po1Res.rows[0].id;

    // PO 1 Line: 2000 Bags of Cement
    const pol1Res = await client.query(`
      INSERT INTO purchase_order_lines (
        purchase_order_id, material_id, ordered_quantity, accepted_quantity, unit_price_etb, total_price_etb, notes
      ) VALUES (
        $1, $2, 2000.00, 920.00, 1350.00, 2700000.00, 'Deliver in two flatbed trucks of 1000 bags each'
      ) RETURNING id;
    `, [po1Id, matMap['MAT-CEM-01']]);
    const pol1Id = pol1Res.rows[0].id;

    // PO 2: Approved, Pending First Delivery
    const po2Res = await client.query(`
      INSERT INTO purchase_orders (
        organization_id, project_id, supplier_id, po_number, version, status,
        total_amount_etb, notes, created_by, approved_by, approved_at, expected_delivery_date
      ) VALUES (
        $1, $2, $3, 'PO-2026-BLIP-002', 1, 'APPROVED',
        3540000.00, 'Heavy reinforcement steel for shear walls and foundation columns',
        $4, $5, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_DATE + INTERVAL '4 days'
      ) RETURNING id;
    `, [orgId, projBoleLemiId, supHabeshaId, userMap['PROCUREMENT_OFFICER'], userMap['PROJECT_MANAGER']]);
    const po2Id = po2Res.rows[0].id;

    await client.query(`
      INSERT INTO purchase_order_lines (
        purchase_order_id, material_id, ordered_quantity, accepted_quantity, unit_price_etb, total_price_etb
      ) VALUES 
        ($1, $2, 20.00, 0.00, 118000.00, 2360000.00),
        ($1, $3, 10.00, 0.00, 118000.00, 1180000.00);
    `, [po2Id, matMap['MAT-STL-16'], matMap['MAT-STL-12']]);

    // PO 3: Draft awaiting PM sign-off
    const po3Res = await client.query(`
      INSERT INTO purchase_orders (
        organization_id, project_id, supplier_id, po_number, version, status,
        total_amount_etb, notes, created_by, expected_delivery_date
      ) VALUES (
        $1, $2, $3, 'PO-2026-MSTI-003', 1, 'PENDING_APPROVAL',
        1440000.00, 'Aggregates for concrete slab pouring at bus terminal platform A',
        $4, CURRENT_DATE + INTERVAL '10 days'
      ) RETURNING id;
    `, [orgId, projMeskelId, supDerbaId, userMap['PROCUREMENT_OFFICER']]);
    const po3Id = po3Res.rows[0].id;

    await client.query(`
      INSERT INTO purchase_order_lines (
        purchase_order_id, material_id, ordered_quantity, accepted_quantity, unit_price_etb, total_price_etb
      ) VALUES ($1, $2, 600.00, 0.00, 2400.00, 1440000.00);
    `, [po3Id, matMap['MAT-AGG-20']]);

    // PO 4: Completed
    const po4Res = await client.query(`
      INSERT INTO purchase_orders (
        organization_id, project_id, supplier_id, po_number, version, status,
        total_amount_etb, notes, created_by, approved_by, approved_at, expected_delivery_date
      ) VALUES (
        $1, $2, $3, 'PO-2026-AALT-004', 1, 'COMPLETED',
        720000.00, 'Security perimeter boundary wall blocks',
        $4, $5, CURRENT_TIMESTAMP - INTERVAL '14 days', CURRENT_DATE - INTERVAL '3 days'
      ) RETURNING id;
    `, [orgId, projAdamaId, supNationalId, userMap['PROCUREMENT_OFFICER'], userMap['PROJECT_MANAGER']]);
    const po4Id = po4Res.rows[0].id;

    await client.query(`
      INSERT INTO purchase_order_lines (
        purchase_order_id, material_id, ordered_quantity, accepted_quantity, unit_price_etb, total_price_etb
      ) VALUES ($1, $2, 10000.00, 10000.00, 72.00, 720000.00);
    `, [po4Id, matMap['MAT-BLK-20']]);

    // 9. Delivery Receipt with real discrepancy (Shortage + Rain Damage)
    const rec1Res = await client.query(`
      INSERT INTO receipts (
        organization_id, project_id, purchase_order_id, receipt_number, waybill_number,
        truck_license_plate, driver_name, driver_phone, carrier_name, storekeeper_id,
        delivery_timestamp, status, idempotency_key, latitude, longitude, notes,
        supplier_representative_name
      ) VALUES (
        $1, $2, $3, 'REC-2026-00189', 'WB-MUG-89412',
        'ET-3-84920-AA', 'Tewodros Kassahun', '+251-91-998-8776', 'Trans-Ethiopia Freight SC',
        $4, CURRENT_TIMESTAMP - INTERVAL '1 day', 'FLAGGED', 'idemp-seed-rec-001',
        9.0123456, 38.7654321, 'Truck arrived during afternoon heavy rain. Tarpaulin was torn at rear left corner. Offloaded at Gate 4 stockyard.',
        'Mulugeta Haile'
      ) RETURNING id;
    `, [orgId, projBoleLemiId, po1Id, userMap['STOREKEEPER']]);
    const rec1Id = rec1Res.rows[0].id;

    // Receipt Line: 1000 ordered on this truck, 950 delivered (50 shortage), 920 accepted, 30 damaged by rain water
    const recl1Res = await client.query(`
      INSERT INTO receipt_lines (
        receipt_id, purchase_order_line_id, material_id, ordered_quantity,
        delivered_quantity, accepted_quantity, damaged_quantity, rejected_quantity,
        rejection_reason, unit
      ) VALUES (
        $1, $2, $3, 1000.00,
        950.00, 920.00, 30.00, 30.00,
        '30 bags soaked through torn tarpaulin, solid hardening/lumping detected inside paper sacks.', 'Bags'
      ) RETURNING id;
    `, [rec1Id, pol1Id, matMap['MAT-CEM-01']]);
    const recl1Id = recl1Res.rows[0].id;

    // Evidence Photos
    await client.query(`
      INSERT INTO evidence (receipt_id, receipt_line_id, photo_type, file_path, file_url, file_size_bytes, mime_type, caption)
      VALUES 
        ($1, NULL, 'WAYBILL', '/uploads/demo/waybill-wb-89412.jpg', '/uploads/demo/waybill-wb-89412.jpg', 428000, 'image/jpeg', 'Supplier signed delivery note showing 1,000 bags dispatched'),
        ($1, NULL, 'TRUCK_PLATE', '/uploads/demo/truck-plate-84920.jpg', '/uploads/demo/truck-plate-84920.jpg', 312000, 'image/jpeg', 'License plate verification: ET-3-84920 AA at Gate 4 scale'),
        ($1, $2, 'DAMAGE_DETAIL', '/uploads/demo/damage-cement-caked.jpg', '/uploads/demo/damage-cement-caked.jpg', 589000, 'image/jpeg', 'Rain penetration on pallet #4: water caked lumps rejecting 30 bags');
    `, [rec1Id, recl1Id]);

    // 10. Auto-Generated Discrepancies
    // Shortage discrepancy: 50 bags short
    await client.query(`
      INSERT INTO discrepancies (
        organization_id, project_id, receipt_id, receipt_line_id, material_id,
        type, severity, status, expected_quantity, actual_quantity, variance_quantity,
        financial_impact_etb, description, assigned_to
      ) VALUES (
        $1, $2, $3, $4, $5,
        'SHORTAGE', 'HIGH', 'UNDER_REVIEW', 1000.00, 950.00, -50.00,
        67500.00, 'Physical tally count revealed 950 bags offloaded vs 1,000 bags stated on Supplier Waybill WB-MUG-89412. Shortage of 50 bags (ETB 67,500).',
        $6
      );
    `, [orgId, projBoleLemiId, rec1Id, recl1Id, matMap['MAT-CEM-01'], userMap['PROCUREMENT_OFFICER']]);

    // Damage discrepancy: 30 bags damaged
    await client.query(`
      INSERT INTO discrepancies (
        organization_id, project_id, receipt_id, receipt_line_id, material_id,
        type, severity, status, expected_quantity, actual_quantity, variance_quantity,
        financial_impact_etb, description, assigned_to
      ) VALUES (
        $1, $2, $3, $4, $5,
        'DAMAGE', 'MEDIUM', 'OPEN', 950.00, 920.00, -30.00,
        40500.00, '30 bags rejected due to rainwater damage through torn tarpaulin. Hydration lumps prevent structural concrete compliance.',
        $6
      );
    `, [orgId, projBoleLemiId, rec1Id, recl1Id, matMap['MAT-CEM-01'], userMap['PROCUREMENT_OFFICER']]);

    // 11. Audit Events
    await client.query(`
      INSERT INTO audit_events (
        organization_id, entity_type, entity_id, action, actor_id, actor_name, actor_role, changes_diff
      ) VALUES 
        ($1, 'PURCHASE_ORDER', $2, 'APPROVE', $3, 'Aster Bekele', 'PROJECT_MANAGER', '{"status": {"old": "PENDING_APPROVAL", "new": "APPROVED"}}'::jsonb),
        ($1, 'RECEIPT', $4, 'CREATE_AND_VERIFY', $5, 'Chala Lemma', 'STOREKEEPER', '{"accepted_quantity": 920, "shortage": 50, "damaged": 30}'::jsonb);
    `, [orgId, po1Id, userMap['PROJECT_MANAGER'], rec1Id, userMap['STOREKEEPER']]);

    await client.query('COMMIT');
    console.log('✅ SiteLedger database seeded successfully with rich Ethiopian construction demo records.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Database seed failed:', err);
    throw err;
  } finally {
    client.release();
  }
}

if (require.main === module) {
  runSeed()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}
